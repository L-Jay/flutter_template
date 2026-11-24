#!/usr/bin/env python3
"""模板工程配置工具：同时维护 Dart 常量与 iOS/Android 原生配置。

由 tool/app.sh 调用，子命令：
  init   创建工程后回填原生定制
  set    单独修改某个配置项（幂等）
  check  校验 Dart 与原生配置是否一致
"""

import argparse
import plistlib
import re
from pathlib import Path
from xml.sax.saxutils import escape

ANDROID_PERMISSIONS = """
    <!-- 头像拍摄/选择：相机 + 相册/存储（按系统版本区分） -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>
    <uses-permission
        android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="29"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-feature
        android:name="android.hardware.camera"
        android:required="false"/>
"""

GRADLE_PLACEHOLDERS = [
    "// 极光推送占位；在极光后台创建应用后替换 JPUSH_APPKEY",
    'manifestPlaceholders["JPUSH_PKGNAME"] = applicationId',
    'manifestPlaceholders["JPUSH_APPKEY"] = ""',
    'manifestPlaceholders["JPUSH_CHANNEL"] = "developer-default"',
]

IOS_USAGE_DESCRIPTIONS = {
    "NSCameraUsageDescription": "用于拍摄照片作为头像",
    "NSPhotoLibraryUsageDescription": "用于从相册选择照片作为头像",
    "NSPhotoLibraryAddUsageDescription": "用于保存图片到相册",
}

WECHAT_QUERY_SCHEMES = ("weixinULAPI", "weixinURLParamsAPI", "weixin")


def constant_pattern(name: str) -> re.Pattern:
    return re.compile(rf"^const {name} = .*;$", re.M)


def read_constant(root: Path, name: str) -> str | None:
    path = root / "lib/common/constants.dart"
    if not path.exists():
        return None
    match = re.search(rf"^const {name} = (.*);$", path.read_text(), re.M)
    if not match:
        return None
    value = match.group(1).strip()
    if value.startswith("'") and value.endswith("'"):
        value = value[1:-1]
    return value


def write_constant(root: Path, name: str, value: str, quote: bool = True) -> bool:
    path = root / "lib/common/constants.dart"
    if not path.exists():
        return False
    literal = f"'{value}'" if quote else value
    line = f"const {name} = {literal};"
    text = path.read_text()
    if constant_pattern(name).search(text):
        text = constant_pattern(name).sub(line, text, count=1)
    else:
        text = f"{text.rstrip()}\n{line}\n"
    path.write_text(text)
    return True


# ---------- Android ----------


def patch_android_manifest(root: Path, display_name: str | None = None) -> None:
    path = root / "android/app/src/main/AndroidManifest.xml"
    if not path.exists():
        return

    text = path.read_text()
    if "android.permission.CAMERA" not in text:
        match = re.search(r"<manifest[^>]*>", text)
        if match:
            text = text[: match.end()] + ANDROID_PERMISSIONS + text[match.end() :]

    if display_name:
        text = re.sub(
            r'android:label="[^"]*"',
            f'android:label="{escape(display_name)}"',
            text,
            count=1,
        )
    path.write_text(text)


def patch_android_label(root: Path, display_name: str) -> None:
    patch_android_manifest(root, display_name)


def gradle_placeholders_block(root: Path) -> None:
    path = root / "android/app/build.gradle.kts"
    if not path.exists():
        return

    text = path.read_text()
    if "JPUSH_APPKEY" in text:
        return

    match = re.search(r"\n(\s*)versionName = flutter\.versionName\n", text)
    if not match:
        return

    indent = match.group(1)
    block = "".join(f"{indent}{line}\n" for line in GRADLE_PLACEHOLDERS)
    path.write_text(text[: match.end()] + block + text[match.end() :])


def set_jpush_key(root: Path, key: str) -> None:
    write_constant(root, "JPUSH_APP_KEY", key)

    path = root / "android/app/build.gradle.kts"
    if not path.exists():
        return
    gradle_placeholders_block(root)
    text = path.read_text()
    text = re.sub(
        r'(manifestPlaceholders\["JPUSH_APPKEY"\]\s*=\s*")[^"]*(")',
        lambda m: f"{m.group(1)}{key}{m.group(2)}",
        text,
    )
    path.write_text(text)


# ---------- iOS ----------


def load_plist(root: Path) -> tuple[Path, dict] | None:
    path = root / "ios/Runner/Info.plist"
    if not path.exists():
        return None
    with path.open("rb") as file:
        return path, plistlib.load(file)


def patch_info_plist(root: Path, app_name: str, display_name: str) -> None:
    loaded = load_plist(root)
    if not loaded:
        return
    path, info = loaded
    info["CFBundleDisplayName"] = display_name
    info["CFBundleName"] = app_name
    info.update(IOS_USAGE_DESCRIPTIONS)
    with path.open("wb") as file:
        plistlib.dump(info, file, sort_keys=False)


def set_display_name(root: Path, display_name: str) -> None:
    patch_android_label(root, display_name)

    loaded = load_plist(root)
    if not loaded:
        return
    path, info = loaded
    info["CFBundleDisplayName"] = display_name
    with path.open("wb") as file:
        plistlib.dump(info, file, sort_keys=False)


def set_wechat(root: Path, appid: str, universal_link: str | None) -> None:
    write_constant(root, "WECHAT_APP_ID", appid)
    if universal_link is not None:
        write_constant(root, "universal_link", universal_link)

    loaded = load_plist(root)
    if not loaded:
        return
    path, info = loaded

    url_types = info.get("CFBundleURLTypes", [])
    url_types = [item for item in url_types if item.get("CFBundleURLName") != "weixin"]

    if appid:
        queries = info.get("LSApplicationQueriesSchemes", [])
        for scheme in WECHAT_QUERY_SCHEMES:
            if scheme not in queries:
                queries.append(scheme)
        info["LSApplicationQueriesSchemes"] = queries

        wx_scheme = appid if appid.startswith("wx") else f"wx{appid}"
        url_types.append(
            {
                "CFBundleTypeRole": "Editor",
                "CFBundleURLName": "weixin",
                "CFBundleURLSchemes": [wx_scheme],
            }
        )

    if url_types:
        info["CFBundleURLTypes"] = url_types
    else:
        info.pop("CFBundleURLTypes", None)

    with path.open("wb") as file:
        plistlib.dump(info, file, sort_keys=False)


def set_alipay(root: Path, appid: str) -> None:
    write_constant(root, "ALIPAY_APP_ID", appid)


def set_real_third_party(root: Path, enabled: bool) -> None:
    write_constant(
        root,
        "ENABLE_REAL_THIRD_PARTY",
        "true" if enabled else "false",
        quote=False,
    )


# ---------- 工程 ----------


def patch_pubspec(root: Path, app_name: str, display_name: str) -> None:
    path = root / "pubspec.yaml"
    text = path.read_text()

    text = re.sub(r"(?m)^name:\s*.*$", f"name: {app_name}", text, count=1)
    text = re.sub(
        r"(?m)^description:\s*.*$",
        f"description: {display_name} Flutter app.",
        text,
        count=1,
    )

    output = []
    skipping = False
    for line in text.splitlines(keepends=True):
        stripped = line.strip()

        # 删除模板本地联调用的 dependency_overrides 及其注释
        if stripped.startswith("#") and (
            "dependency_overrides" in stripped or "本地联调" in stripped
        ):
            continue

        if re.match(r"^dependency_overrides:\s*$", line):
            skipping = True
            continue

        if skipping:
            if stripped == "" or line[:1] in (" ", "\t"):
                continue
            skipping = False

        output.append(line)

    path.write_text("".join(output))


def reset_template_constants(root: Path) -> None:
    write_constant(root, "WECHAT_APP_ID", "")
    write_constant(root, "universal_link", "")


def patch_package_imports(root: Path, app_name: str, old_name: str) -> None:
    for pattern in ("lib/**/*.dart", "test/**/*.dart"):
        for path in root.glob(pattern):
            text = path.read_text()
            if f"package:{old_name}/" in text:
                path.write_text(text.replace(f"package:{old_name}/", f"package:{app_name}/"))


def apply_settings(
    root: Path,
    push_key: str | None,
    wechat_appid: str | None,
    universal_link: str | None,
    alipay_appid: str | None,
    real_third_party: str | None,
) -> None:
    if push_key:
        set_jpush_key(root, push_key)
    if wechat_appid is not None:
        set_wechat(root, wechat_appid, universal_link)
    if alipay_appid:
        set_alipay(root, alipay_appid)
    if real_third_party:
        set_real_third_party(root, real_third_party == "on")


def command_init(args: argparse.Namespace) -> None:
    root = Path.cwd()
    patch_android_manifest(root, args.display_name)
    gradle_placeholders_block(root)
    patch_info_plist(root, args.app_name, args.display_name)
    patch_pubspec(root, args.app_name, args.display_name)
    reset_template_constants(root)
    patch_package_imports(root, args.app_name, args.old_name)
    apply_settings(
        root,
        args.push_key,
        args.wechat_appid,
        args.universal_link,
        args.alipay_appid,
        args.real_third_party,
    )


def command_set(args: argparse.Namespace) -> None:
    root = Path.cwd()
    option = args.option
    value = args.value or ""

    if option == "display-name":
        set_display_name(root, value)
    elif option == "push":
        set_jpush_key(root, value)
    elif option == "wechat":
        set_wechat(root, value, args.universal_link)
    elif option == "alipay":
        set_alipay(root, value)
    elif option == "real-third-party":
        set_real_third_party(root, value == "on")
    else:
        raise SystemExit(f"未知配置项：{option}")


def command_check() -> None:
    root = Path.cwd()
    results: list[tuple[bool, str]] = []

    def expect(condition: bool, ok_msg: str, fail_msg: str) -> None:
        results.append((condition, ok_msg if condition else fail_msg))

    pubspec = (root / "pubspec.yaml")
    pubspec_text = pubspec.read_text() if pubspec.exists() else ""
    expect(
        "dependency_overrides:" not in pubspec_text,
        "未残留本地 dependency_overrides",
        "pubspec 仍含 dependency_overrides，发布前需删除",
    )

    jpush_key = read_constant(root, "JPUSH_APP_KEY") or ""
    gradle_path = root / "android/app/build.gradle.kts"
    gradle_text = gradle_path.read_text() if gradle_path.exists() else ""
    gradle_key = re.search(r'manifestPlaceholders\["JPUSH_APPKEY"\]\s*=\s*"([^"]*)"', gradle_text)
    if jpush_key:
        expect(
            gradle_key is not None and gradle_key.group(1) == jpush_key,
            "极光 AppKey 已同时写入 Dart 与 Android",
            "极光 AppKey 两端不一致：constants 与 build.gradle.kts",
        )
    else:
        results.append((True, "极光 AppKey 未配置（推送将自动跳过）"))

    wechat_appid = read_constant(root, "WECHAT_APP_ID") or ""
    loaded = load_plist(root)
    info = loaded[1] if loaded else {}
    schemes = [
        scheme
        for item in info.get("CFBundleURLTypes", [])
        for scheme in item.get("CFBundleURLSchemes", [])
    ]
    if wechat_appid:
        wx_scheme = wechat_appid if wechat_appid.startswith("wx") else f"wx{wechat_appid}"
        expect(
            wx_scheme in schemes,
            "微信 AppID 与 iOS URL Scheme 一致",
            f"微信 AppID 已配置，但 Info.plist 缺少 URL Scheme {wx_scheme}",
        )
    else:
        results.append((True, "微信 AppID 未配置"))

    real_mode = read_constant(root, "ENABLE_REAL_THIRD_PARTY") == "true"
    if real_mode:
        expect(
            bool(wechat_appid),
            "真实第三方模式已开启且微信 AppID 已配置",
            "已开启真实第三方模式，但微信 AppID 为空",
        )
        expect(
            bool(read_constant(root, "universal_link")),
            "universal_link 已配置",
            "已开启真实第三方模式，但 universal_link 为空",
        )

    expect(
        all(key in info for key in IOS_USAGE_DESCRIPTIONS),
        "iOS 权限文案齐全",
        "Info.plist 缺少相机/相册权限文案",
    )

    manifest_path = root / "android/app/src/main/AndroidManifest.xml"
    manifest_text = manifest_path.read_text() if manifest_path.exists() else ""
    expect(
        "android.permission.CAMERA" in manifest_text,
        "Android 权限已声明",
        "AndroidManifest 缺少相机/相册权限",
    )

    app_name = re.search(r"(?m)^name:\s*(\S+)", pubspec_text)
    expect(
        app_name is None or app_name.group(1) != "flutter_template",
        "工程名已从模板重命名",
        "pubspec 仍是 flutter_template，请通过 create 创建新工程",
    )

    failed = 0
    for ok, message in results:
        print(f"{'✓' if ok else '✗'} {message}")
        if not ok:
            failed += 1

    print()
    if failed:
        print(f"检查未通过：{failed} 项需要处理")
        raise SystemExit(1)
    print("检查通过")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    init = subparsers.add_parser("init")
    init.add_argument("--app-name", required=True)
    init.add_argument("--display-name", required=True)
    init.add_argument("--old-name", default="flutter_template")
    init.add_argument("--push-key", default="")
    init.add_argument("--wechat-appid", default=None)
    init.add_argument("--universal-link", default=None)
    init.add_argument("--alipay-appid", default="")
    init.add_argument("--real-third-party", default="off")
    init.set_defaults(handler=command_init)

    set_parser = subparsers.add_parser("set")
    set_parser.add_argument(
        "option",
        choices=("display-name", "push", "wechat", "alipay", "real-third-party"),
    )
    set_parser.add_argument("value", nargs="?")
    set_parser.add_argument("--universal-link", default=None)
    set_parser.set_defaults(handler=command_set)

    check = subparsers.add_parser("check")
    check.set_defaults(handler=lambda _: command_check())

    return parser


def main() -> None:
    args = build_parser().parse_args()
    args.handler(args)


if __name__ == "__main__":
    main()

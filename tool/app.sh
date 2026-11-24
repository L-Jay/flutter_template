#!/usr/bin/env bash
#
# 模板工程配置工具：同时维护 Dart 常量与 iOS / Android 原生配置。
#
# 用法：
#   tool/app.sh create <app_name> <org> [display_name] [options]
#   tool/app.sh set <option> <value> [options]
#   tool/app.sh check
#
# create 示例：
#   tool/app.sh create my_app com.company "我的应用" \
#     --push-key <jpush-key> --wechat-appid wx1234567890 --yes
#
# set 示例（可单独执行，幂等）：
#   tool/app.sh set display-name "我的应用"
#   tool/app.sh set push <jpush-key>   # 也可写成 set push jpush <key>
#   tool/app.sh set wechat wx1234567890 https://example.com/app/
#   tool/app.sh set alipay 2021000000000000
#   tool/app.sh set real-third-party on
#
# create 选项：
#   --platforms <list>        生成的平台，默认 android,ios
#   --push-key <key>          同时写入 constants.dart 与 build.gradle.kts
#   --wechat-appid <id>       写入 constants.dart 与 iOS URL Scheme
#   --universal-link <url>    写入 constants.dart
#   --alipay-appid <id>       写入 constants.dart
#   --real-third-party <on|off>
#   --reset-git               删除模板 .git 并重新 git init
#   --keep-dir                保留当前目录名（默认完成后重命名为 app_name）
#   -y, --yes                 跳过确认
#   -h, --help                查看帮助
#
set -euo pipefail

usage() {
  awk 'NR > 1 { if ($0 ~ /^#/) { sub(/^# ?/, ""); print } else exit }' "$0"
}

die() {
  printf '错误：%s\n' "$1" >&2
  exit 1
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TMP_DIR=""
trap 'rm -rf "${TMP_DIR:-}"' EXIT

check_value() {
  local name="$1"
  local value="$2"
  case "$value" in
    *"'"* | *'"'* | *$'\n'*)
      die "$name 不能包含引号或换行"
      ;;
  esac
}

run_create() {
  local APP_NAME=""
  local ORG=""
  local DISPLAY_NAME=""
  local PLATFORMS="android,ios"
  local PUSH_KEY=""
  local WECHAT_APPID=""
  local UNIVERSAL_LINK=""
  local ALIPAY_APPID=""
  local REAL_THIRD_PARTY="off"
  local RESET_GIT=0
  local ASSUME_YES=0
  local KEEP_DIR=0
  local POSITIONAL=()
  local HAS_WECHAT=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platforms)
        [[ $# -ge 2 ]] || die "--platforms 缺少参数"
        PLATFORMS="$2"
        shift 2
        ;;
      --push-key)
        [[ $# -ge 2 ]] || die "--push-key 缺少参数"
        PUSH_KEY="$2"
        shift 2
        ;;
      --wechat-appid)
        [[ $# -ge 2 ]] || die "--wechat-appid 缺少参数"
        WECHAT_APPID="$2"
        HAS_WECHAT=1
        shift 2
        ;;
      --universal-link)
        [[ $# -ge 2 ]] || die "--universal-link 缺少参数"
        UNIVERSAL_LINK="$2"
        shift 2
        ;;
      --alipay-appid)
        [[ $# -ge 2 ]] || die "--alipay-appid 缺少参数"
        ALIPAY_APPID="$2"
        shift 2
        ;;
      --real-third-party)
        [[ $# -ge 2 ]] || die "--real-third-party 缺少参数"
        REAL_THIRD_PARTY="$2"
        shift 2
        ;;
      --reset-git)
        RESET_GIT=1
        shift
        ;;
      --keep-dir)
        KEEP_DIR=1
        shift
        ;;
      -y | --yes)
        ASSUME_YES=1
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      -*)
        die "未知选项：$1"
        ;;
      *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
  done

  APP_NAME="${POSITIONAL[0]:-}"
  ORG="${POSITIONAL[1]:-}"
  DISPLAY_NAME="${POSITIONAL[2]:-$APP_NAME}"

  [[ -n "$APP_NAME" && -n "$ORG" ]] || {
    usage
    exit 1
  }

  [[ "$REAL_THIRD_PARTY" == "on" || "$REAL_THIRD_PARTY" == "off" ]] \
    || die "--real-third-party 只能是 on 或 off"
  [[ "$APP_NAME" =~ ^[a-z][a-z0-9_]*$ ]] \
    || die "app_name 需为小写字母开头的 snake_case，例如 my_app"
  [[ "$ORG" =~ ^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$ ]] \
    || die "org 需为反向域名，例如 com.company"
  [[ "$PLATFORMS" =~ ^(android|ios|web|macos|linux|windows)(,(android|ios|web|macos|linux|windows))*$ ]] \
    || die "platforms 仅支持 android,ios,web,macos,linux,windows"

  check_value "工程名" "$APP_NAME"
  check_value "显示名" "$DISPLAY_NAME"
  check_value "极光 AppKey" "$PUSH_KEY"
  check_value "微信 AppID" "$WECHAT_APPID"
  check_value "universal link" "$UNIVERSAL_LINK"
  check_value "支付宝 AppID" "$ALIPAY_APPID"

  [[ -f pubspec.yaml ]] || die "请在项目根目录执行"
  grep -Eq '^name: flutter_template$' pubspec.yaml \
    || die "当前目录不是 flutter_template 模板（pubspec name 不是 flutter_template）"
  command -v flutter >/dev/null 2>&1 || die "未找到 flutter 命令"
  command -v python3 >/dev/null 2>&1 || die "未找到 python3（用于修改 plist / manifest）"

  local target_dir
  if [[ $KEEP_DIR -eq 1 || "$(basename "$ROOT")" == "$APP_NAME" ]]; then
    target_dir="$ROOT"
  else
    target_dir="$(dirname "$ROOT")/$APP_NAME"
    [[ ! -e "$target_dir" ]] || die "目标目录已存在：$target_dir"
  fi

  printf '\n将执行以下操作：\n'
  printf '  工程名：%s\n' "$APP_NAME"
  printf '  包名：%s.%s\n' "$ORG" "$APP_NAME"
  printf '  显示名：%s\n' "$DISPLAY_NAME"
  printf '  平台：%s\n' "$PLATFORMS"
  printf '  极光 AppKey：%s\n' "${PUSH_KEY:-（留空）}"
  printf '  微信 AppID：%s\n' "${WECHAT_APPID:-（留空）}"
  printf '  支付宝 AppID：%s\n' "${ALIPAY_APPID:-（留空）}"
  printf '  真实第三方：%s\n' "$REAL_THIRD_PARTY"
  printf '  操作目录：%s\n' "$ROOT"
  if [[ "$target_dir" != "$ROOT" ]]; then
    printf '  完成后目录：%s\n' "$target_dir"
  fi
  printf '  会删除并重建 android / ios 等平台目录，请确认已在 git 中提交或备份。\n\n'

  if [[ $ASSUME_YES -eq 0 ]]; then
    read -r -p "继续？[y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || {
      echo "已取消"
      exit 0
    }
  fi

  TMP_DIR="$(mktemp -d)"

  echo "==> 生成原生工程壳"
  flutter create \
    --org "$ORG" \
    --project-name "$APP_NAME" \
    --platforms "$PLATFORMS" \
    "$TMP_DIR/shell" >/dev/null

  echo "==> 替换平台目录"
  for dir in android ios web macos linux windows; do
    [[ -d "$dir" ]] && rm -rf "$dir"
  done

  local platform
  IFS=',' read -r -a PLATFORM_LIST <<<"$PLATFORMS"
  for platform in "${PLATFORM_LIST[@]}"; do
    if [[ -d "$TMP_DIR/shell/$platform" ]]; then
      cp -R "$TMP_DIR/shell/$platform" .
    fi
  done

  if [[ -d ios ]]; then
    echo "==> 回填 Podfile（permission_handler 宏）"
    cp tool/native/Podfile ios/Podfile
  fi

  echo "==> 回填原生配置与包名"
  local init_args=(
    --app-name "$APP_NAME"
    --display-name "$DISPLAY_NAME"
    --real-third-party "$REAL_THIRD_PARTY"
  )
  [[ -n "$PUSH_KEY" ]] && init_args+=(--push-key "$PUSH_KEY")
  [[ $HAS_WECHAT -eq 1 ]] && init_args+=(--wechat-appid "$WECHAT_APPID")
  [[ -n "$UNIVERSAL_LINK" ]] && init_args+=(--universal-link "$UNIVERSAL_LINK")
  [[ -n "$ALIPAY_APPID" ]] && init_args+=(--alipay-appid "$ALIPAY_APPID")

  python3 tool/native/patch.py init "${init_args[@]}"

  echo "==> 安装依赖"
  flutter pub get >/dev/null

  if [[ $RESET_GIT -eq 1 ]]; then
    echo "==> 重置 git"
    rm -rf .git
    git init -q
  fi

  local done_hint=""
  if [[ "$target_dir" != "$ROOT" ]]; then
    echo "==> 重命名工程目录：$(basename "$target_dir")"
    mv "$ROOT" "$target_dir"
    cd "$target_dir"
    done_hint="请先进入新目录：cd \"$target_dir\""
  fi

  cat <<EOF

完成：${DISPLAY_NAME}（${ORG}.${APP_NAME}）
工程目录：${target_dir}
${done_hint}

后续可随时单独调整配置（同时写入 Dart 与原生）：
  tool/app.sh set push <jpush-key>
  tool/app.sh set wechat <appid> [universal-link]
  tool/app.sh set alipay <appid>
  tool/app.sh set display-name "<显示名>"
  tool/app.sh set real-third-party on|off
  tool/app.sh check

仍需手动处理：
  1. iOS：在 Xcode 中开启 Push Notifications 能力并配置 APNs
  2. 微信开放平台登记包名 / universal link，支付宝商户配置
  3. 替换 README、AGENTS 中的模板说明与示例数据
  4. 按需执行：flutter run
EOF
}

run_set() {
  local option="${1:-}"
  [[ -n "$option" ]] || {
    usage
    exit 1
  }
  shift || true

  [[ -f pubspec.yaml ]] || die "请在项目根目录执行"
  [[ -f lib/common/constants.dart ]] || die "未找到 lib/common/constants.dart"

  case "$option" in
    display-name)
      local value="${1:-}"
      [[ -n "$value" ]] || die "缺少显示名"
      check_value "显示名" "$value"
      python3 tool/native/patch.py set display-name "$value"
      echo "已更新显示名：$value"
      ;;
    push)
      local value="${1:-}"
      if [[ "$value" == "jpush" ]]; then
        value="${2:-}"
      fi
      [[ -n "$value" ]] || die "缺少极光 AppKey"
      check_value "极光 AppKey" "$value"
      python3 tool/native/patch.py set push "$value"
      echo "已写入极光 AppKey（Dart + Android）"
      ;;
    wechat)
      local value="${1:-}"
      local universal="${2:-}"
      if [[ "$universal" == "--universal-link" ]]; then
        universal="${3:-}"
      fi
      [[ $# -ge 1 ]] || die "缺少微信 AppID"
      check_value "微信 AppID" "$value"
      check_value "universal link" "$universal"
      if [[ -n "$universal" ]]; then
        python3 tool/native/patch.py set wechat "$value" --universal-link "$universal"
      else
        python3 tool/native/patch.py set wechat "$value"
      fi
      echo "已写入微信 AppID（Dart + iOS URL Scheme）"
      ;;
    alipay)
      local value="${1:-}"
      [[ -n "$value" ]] || die "缺少支付宝 AppID"
      check_value "支付宝 AppID" "$value"
      python3 tool/native/patch.py set alipay "$value"
      echo "已写入支付宝 AppID（Dart）"
      ;;
    real-third-party)
      local value="${1:-}"
      [[ "$value" == "on" || "$value" == "off" ]] || die "只支持 on 或 off"
      python3 tool/native/patch.py set real-third-party "$value"
      echo "已设置真实第三方模式：$value"
      ;;
    *)
      die "未知配置项：$option"
      ;;
  esac
}

COMMAND="${1:-}"
[[ $# -gt 0 ]] && shift

case "$COMMAND" in
  create)
    run_create "$@"
    ;;
  set)
    run_set "$@"
    ;;
  check)
    [[ -f pubspec.yaml ]] || die "请在项目根目录执行"
    python3 tool/native/patch.py check
    ;;
  -h | --help | help | "")
    usage
    ;;
  *)
    die "未知命令：$COMMAND（可用：create / set / check）"
    ;;
esac

import '../common/common.dart';
import 'about_us_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String version = LJUtil.packageInfo.version;
    final bool isLogin = UserService.to.isLogin.value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildRow(
                  context,
                  icon: Icons.shield_outlined,
                  title: context.l10n.accountSecurity,
                  onTap: () =>
                      EasyLoading.showToast(context.l10n.accountSecurityPlaceholder),
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: context.l10n.privacyPolicy,
                  onTap: () => _openWebView(
                    context.l10n.privacyPolicy,
                    ConfigService.to.configDataInfo.value.privacyUrl,
                  ),
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.description_outlined,
                  title: context.l10n.userAgreement,
                  onTap: () => _openWebView(
                    context.l10n.userAgreement,
                    ConfigService.to.configDataInfo.value.protocolUrl,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildRow(
                  context,
                  icon: Icons.cleaning_services_outlined,
                  title: context.l10n.clearCache,
                  onTap: _clearCache,
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.palette_outlined,
                  title: context.l10n.theme,
                  value: _themeLabel(context),
                  onTap: _pickTheme,
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.translate_rounded,
                  title: context.l10n.language,
                  value: _languageLabel(context),
                  onTap: _pickLanguage,
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: context.l10n.aboutUs,
                  onTap: () => RouterManager.pushPage(const AboutUsPage()),
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _buildRow(
                  context,
                  icon: Icons.numbers_rounded,
                  title: context.l10n.currentVersion,
                  value: version,
                ),
              ],
            ),
          ),
          if (isLogin) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              title: context.l10n.logout,
              type: AppButtonType.secondary,
              height: 44,
              onPressed: _logout,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              '${context.l10n.currentVersion} $version',
              style: AppTextStyle.small(colors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    final AppColors colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Icon(icon, size: 20, color: colors.brand),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.body(colors.textPrimary),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: AppTextStyle.caption(colors.textHint),
              ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textHint,
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _pickTheme() {
    final List<ThemeMode> modes = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
    ];

    _showPicker(
      title: context.l10n.theme,
      labels: [context.l10n.themeLight, context.l10n.themeDark, context.l10n.themeSystem],
      selectedIndex: modes.indexOf(ThemeService.to.themeMode.value),
      onSelected: (index) {
        ThemeService.to.setMode(modes[index]);
        setState(() {});
      },
    );
  }

  void _pickLanguage() {
    final List<String?> codes = [null, 'zh', 'en'];

    _showPicker(
      title: context.l10n.language,
      labels: [context.l10n.languageSystem, context.l10n.languageZh, context.l10n.languageEn],
      selectedIndex: codes.indexOf(
        LanguageService.to.locale.value?.languageCode,
      ),
      onSelected: (index) {
        LanguageService.to.setLocale(codes[index]);
        setState(() {});
      },
    );
  }

  void _showPicker({
    required String title,
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    final AppColors colors = context.colors;

    DialogUtil.show(
      title: title,
      cancelTitle: context.l10n.cancel,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (index) {
          final bool selected = index == selectedIndex;

          return InkWell(
            onTap: () {
              onSelected(index);
              SmartDialog.dismiss(tag: 'show');
            },
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      labels[index],
                      style: AppTextStyle.body(colors.textPrimary),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_rounded, size: 18, color: colors.brand),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _themeLabel(BuildContext context) {
    switch (ThemeService.to.themeMode.value) {
      case ThemeMode.light:
        return context.l10n.themeLight;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      case ThemeMode.system:
        return context.l10n.themeSystem;
    }
  }

  String _languageLabel(BuildContext context) {
    final String? code = LanguageService.to.locale.value?.languageCode;
    if (code == 'zh') return context.l10n.languageZh;
    if (code == 'en') return context.l10n.languageEn;
    return context.l10n.languageSystem;
  }

  void _openWebView(String title, String? url) {
    if (url?.isNotEmpty != true) {
      EasyLoading.showToast(context.l10n.protocolMissing);
      return;
    }

    RouterManager.pushNamed(
      Routers.webview,
      arguments: {'url': url, 'title': title},
    );
  }

  void _clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    EasyLoading.showSuccess(context.l10n.cacheCleared);
  }

  void _logout() {
    DialogUtil.normal(
      title: context.l10n.tip,
      text: context.l10n.logoutConfirm,
      cancelTitle: context.l10n.cancel,
      confirmTitle: context.l10n.confirm,
      confirmCallback: () {
        UserService.to.logout();
        setState(() {});
      },
    );
  }
}

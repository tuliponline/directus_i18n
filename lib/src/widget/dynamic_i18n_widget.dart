part of directus_i18n;

/// A widget that automatically refreshes when i18n keys are updated
class DynamicI18nWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final String? refreshTrigger; // Optional key to watch for changes

  const DynamicI18nWidget({
    Key? key,
    required this.builder,
    this.refreshTrigger,
  }) : super(key: key);

  @override
  State<DynamicI18nWidget> createState() => _DynamicI18nWidgetState();
}

class _DynamicI18nWidgetState extends State<DynamicI18nWidget> {
  @override
  void initState() {
    super.initState();
    // Listen for i18n updates if needed
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// A simple text widget that uses dynamic i18n
class DynamicI18nText extends StatelessWidget {
  final String i18nKey;
  final String? fallback;
  final Map<String, String>? params;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const DynamicI18nText(
    this.i18nKey, {
    Key? key,
    this.fallback,
    this.params,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      i18nKey.tr(fallback: fallback, params: params, context: context),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A button widget that uses dynamic i18n
class DynamicI18nButton extends StatelessWidget {
  final String i18nKey;
  final String? fallback;
  final Map<String, String>? params;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? child;

  const DynamicI18nButton(
    this.i18nKey, {
    Key? key,
    this.fallback,
    this.params,
    this.onPressed,
    this.style,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child ?? DynamicI18nText(
        i18nKey,
        fallback: fallback,
        params: params,
      ),
    );
  }
}

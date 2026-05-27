import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── Common Card Widget ────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hasAccentBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.onTap,
    this.hasAccentBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: hasAccentBorder
              ? const BorderSide(color: AppColors.accentLime, width: 3)
              : BorderSide(color: borderColor ?? AppColors.border),
          top: BorderSide(color: borderColor ?? AppColors.border),
          right: BorderSide(color: borderColor ?? AppColors.border),
          bottom: BorderSide(color: borderColor ?? AppColors.border),
        ),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Primary Button ────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool outline;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.outline = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height ?? 52,
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : AppColors.accentLime,
          borderRadius: BorderRadius.circular(12),
          border: outline ? Border.all(color: AppColors.border) : null,
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: outline ? AppColors.textPrimary : AppColors.background,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon,
                          size: 18,
                          color: outline ? AppColors.textPrimary : AppColors.background),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: outline
                          ? AppTextStyles.buttonOutline
                          : AppTextStyles.button,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Pill Chip ─────────────────────────────────────────────────────────────
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLime : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accentLime : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.h3.copyWith(
            fontSize: 13,
            color: selected ? AppColors.background : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 13, letterSpacing: 0.06 * 13, color: AppColors.textSecondary)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTextStyles.caption.copyWith(color: AppColors.accentLime)),
          ),
      ],
    );
  }
}

// ─── Metric Chip ───────────────────────────────────────────────────────────
class MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const MetricChip({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Divider with label ────────────────────────────────────────────────────
class LabelDivider extends StatelessWidget {
  final String label;
  const LabelDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF222222))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: Color(0xFF222222))),
      ],
    );
  }
}

// ─── Currency format helper ────────────────────────────────────────────────
String formatRupees(double amount) {
  if (amount >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  }
  return '₹${amount.toStringAsFixed(0)}';
}

String formatRupeesExact(double amount) {
  final str = amount.toStringAsFixed(0);
  if (str.length <= 3) return '₹$str';
  final lastThree = str.substring(str.length - 3);
  final rest = str.substring(0, str.length - 3);
  final withCommas = rest.replaceAllMapped(
    RegExp(r'(\d{2})(?=\d)'),
    (m) => '${m[1]},',
  );
  return '₹$withCommas,$lastThree';
}

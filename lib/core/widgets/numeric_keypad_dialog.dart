import 'package:flutter/material.dart';
import 'package:rider_os/core/constants/app_spacing.dart';
import 'package:rider_os/core/constants/app_typography.dart';
import 'package:rider_os/core/responsive/responsive_engine.dart';

class NumericKeypadDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final bool allowDecimal;

  const NumericKeypadDialog({
    super.key,
    required this.title,
    this.initialValue = '',
    this.allowDecimal = true,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) =>
          NumericKeypadDialog(title: title, initialValue: initialValue),
    );
  }

  @override
  State<NumericKeypadDialog> createState() => _NumericKeypadDialogState();
}

class _NumericKeypadDialogState extends State<NumericKeypadDialog> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'C') {
        _value = '';
      } else if (key == 'DEL') {
        if (_value.isNotEmpty) {
          _value = _value.substring(0, _value.length - 1);
        }
      } else if (key == '.') {
        if (widget.allowDecimal && !_value.contains('.')) {
          _value += _value.isEmpty ? '0.' : '.';
        }
      } else {
        _value += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screen = ScreenInfo.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screen.scale(16)),
      ),
      child: Container(
        width: screen.scale(400),
        padding: EdgeInsets.all(screen.scale(AppSpacing.lg)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.metricSmall.copyWith(
                    color: colors.primary,
                    fontSize: screen.scaleText(24),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.secondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: screen.scale(AppSpacing.md)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screen.scale(AppSpacing.md),
                vertical: screen.scale(AppSpacing.sm),
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(screen.scale(8)),
              ),
              child: Text(
                _value.isEmpty ? '0' : _value,
                style: AppTypography.metricLarge.copyWith(
                  fontSize: screen.scaleText(48),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(height: screen.scale(AppSpacing.xl)),
            _buildKeypad(screen, colors),
            SizedBox(height: screen.scale(AppSpacing.md)),
            SizedBox(
              width: double.infinity,
              height: screen.scale(64),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.scale(8)),
                  ),
                ),
                onPressed: () => Navigator.pop(context, _value),
                child: Text(
                  'DONE',
                  style: AppTypography.label.copyWith(
                    color: colors.onPrimary,
                    fontSize: screen.scaleText(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(ScreenInfo screen, ColorScheme colors) {
    return Column(
      children: [
        Row(
          children: [
            _buildKey('7', screen, colors),
            _buildKey('8', screen, colors),
            _buildKey('9', screen, colors),
          ],
        ),
        Row(
          children: [
            _buildKey('4', screen, colors),
            _buildKey('5', screen, colors),
            _buildKey('6', screen, colors),
          ],
        ),
        Row(
          children: [
            _buildKey('1', screen, colors),
            _buildKey('2', screen, colors),
            _buildKey('3', screen, colors),
          ],
        ),
        Row(
          children: [
            _buildKey('.', screen, colors, isAction: true),
            _buildKey('0', screen, colors),
            _buildKey(
              'DEL',
              screen,
              colors,
              isAction: true,
              icon: Icons.backspace_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(
    String label,
    ScreenInfo screen,
    ColorScheme colors, {
    bool isAction = false,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(screen.scale(AppSpacing.xs)),
        child: Material(
          color: isAction
              ? colors.surfaceContainer
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(screen.scale(8)),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => _onKeyPress(label),
            child: Container(
              height: screen.scale(72),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(
                      icon,
                      color: colors.onSurface,
                      size: screen.scaleText(24),
                    )
                  : Text(
                      label,
                      style: AppTypography.metricSmall.copyWith(
                        fontSize: screen.scaleText(28),
                        color: isAction ? colors.secondary : colors.onSurface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:okcolor/models/oklab.dart';

class ExpandableDescription extends StatefulWidget {
  final String text;
  final bool isDark;

  const ExpandableDescription({super.key, required this.text, required this.isDark});

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: widget.isDark ? OkLab(0.71, 0, -0.02).toColor() : OkLab(0.45, -0.01, -0.03).toColor(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark
            ? OkLab(0.28, 0.09, -0.13).toColor().withValues(alpha: 0.2)
            : OkLab(0.98, 0.01, -0.01).toColor().withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final span = TextSpan(text: widget.text, style: textStyle);
          final tp = TextPainter(text: span, maxLines: 3, textDirection: TextDirection.ltr);

          tp.layout(maxWidth: constraints.maxWidth);

          final isExceedMaxLines = tp.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),

              if (isExceedMaxLines) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? 'Thu gọn' : 'Xem đầy đủ',
                        style: const TextStyle(color: Color(0xFFFF2E7E), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFFFF2E7E),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

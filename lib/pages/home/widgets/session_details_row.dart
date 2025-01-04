import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/session_reader.dart';

class SessionDetailsRow extends StatefulWidget {
  const SessionDetailsRow({
    super.key,
    required this.session,
  });

  final Session session;

  @override
  State<SessionDetailsRow> createState() => _SessionDetailsRowState();
}

class _SessionDetailsRowState extends State<SessionDetailsRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => _hover = true),
      onExit: (event) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        scale: _hover ? 1.2 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Session ${widget.session.id}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
                Text(
                  widget.session.time.timeShort,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600.themed(brightness),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _hover
                  ? SizedBox(
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 12,
                          ),
                          Text(
                            widget.session.dayRange,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600.themed(brightness),
                            ),
                          ),
                          Text(
                            widget.session.timeRange,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600.themed(brightness),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

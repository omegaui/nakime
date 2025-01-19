import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:nakime/config/app_colors.dart';
import 'package:nakime/core/constants/session_tag_constants.dart';
import 'package:nakime/core/extensions/font_weight_extension.dart';
import 'package:nakime/core/extensions/time_extension.dart';
import 'package:nakime/core/sessions/session_reader.dart';

class SessionTagInfoPage extends StatelessWidget {
  const SessionTagInfoPage({
    super.key,
    required this.session,
  });

  final Session session;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        session.tagDisplayName.capitalizeFirst!,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Session ${session.id}",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    session.dayRange,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600.themed(brightness),
                    ),
                  ),
                  Text(
                    session.timeRange,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600.themed(brightness),
                    ),
                  ),
                  Text(
                    "${session.hasTag ? "~" : ""}${session.time.timeShort} ${SessionTagConstants.getTagTimeSignificance(session.tag)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600.themed(brightness),
                    ),
                  ),
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      SessionTagConstants.getTagDescription(session.tag),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

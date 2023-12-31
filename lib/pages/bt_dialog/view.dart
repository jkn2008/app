import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/bt_dialog/controller.dart';
import 'package:miru_app/utils/bt_server.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress.dart';

class BTDialog extends StatefulWidget {
  const BTDialog({Key? key}) : super(key: key);

  @override
  State<BTDialog> createState() => _BTDialogState();
}

class _BTDialogState extends State<BTDialog> {
  final BTDialogController c = Get.put(BTDialogController());

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (!c.isInstalled.value) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("bt-server.not-installed".i18n),
            const SizedBox(height: 16),
            if (c.isDownloading.value)
              SizedBox(
                width: double.infinity,
                child: ProgressBar(value: c.progress.value),
              )
            else
              PlatformFilledButton(
                child: Text("common.install".i18n),
                onPressed: () {
                  c.downloadOrUpgradeServer(context);
                },
              ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.isRuning.value)
            Text("bt-server.running".i18n)
          else
            Text("bt-server.stopped".i18n),
          const SizedBox(height: 16),
          if (c.isRuning.value)
            Text(
              FlutterI18n.translate(
                context,
                'bt-server.version',
                translationParams: {
                  "version": c.version.value,
                },
              ),
            )
          else
            PlatformFilledButton(
              child: Text("bt-server.start".i18n),
              onPressed: () {
                BTServerUtils.startServer();
              },
            ),
        ],
      );
    });
  }

  Widget _buildAndroid(BuildContext context) {
    return AlertDialog(
      title: const Text("BT-Server"),
      content: _buildContent(context),
      actions: [
        PlatformTextButton(
          child: Text("common.close".i18n),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return fluent.ContentDialog(
      title: const Text("BT-Server"),
      content: _buildContent(context),
      actions: [
        fluent.Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("common.close".i18n),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}

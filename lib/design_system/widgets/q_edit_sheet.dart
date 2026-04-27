import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';
import '../typography.dart';
import 'q_button.dart';
import 'q_field.dart';

/// Modal bottom sheet with a single editable field used to update one
/// FormationState row at a time (DOB, nationality, etc.).
///
/// Returns the new trimmed value on Save, or null on cancel.
Future<String?> showQEditSheet(
  BuildContext context, {
  required String title,
  required String initial,
  String? placeholder,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool multiline = false,
}) {
  final ctrl = TextEditingController(text: initial);
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: QPayTokens.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottomInset),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: QPayTokens.n300,
                    borderRadius: BorderRadius.circular(QPayTokens.rPill),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(title, style: QPayType.heroTitle.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 14),
              QField(
                controller: ctrl,
                placeholder: placeholder,
                keyboardType: keyboardType ??
                    (multiline ? TextInputType.multiline : null),
                inputFormatters: inputFormatters,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              QButton(
                label: 'Save',
                onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              ),
            ],
          ),
        ),
      );
    },
  );
}

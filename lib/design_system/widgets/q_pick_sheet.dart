import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';
import 'q_field.dart';

/// Modal bottom sheet that lets the user pick one option out of a long
/// list. Includes a search field and a scrollable list. Returns the
/// chosen option (the [T] returned by [labelFor] for matching) or null
/// if dismissed.
Future<T?> showQPickSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelFor,
  required String Function(T) searchKeyFor,
  T? selected,
  String? searchPlaceholder,
}) {
  return showModalBottomSheet<T?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: QPayTokens.canvas,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => _PickSheet<T>(
      title: title,
      options: options,
      labelFor: labelFor,
      searchKeyFor: searchKeyFor,
      selected: selected,
      searchPlaceholder: searchPlaceholder,
    ),
  );
}

class _PickSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final String Function(T) labelFor;
  final String Function(T) searchKeyFor;
  final T? selected;
  final String? searchPlaceholder;

  const _PickSheet({
    required this.title,
    required this.options,
    required this.labelFor,
    required this.searchKeyFor,
    required this.selected,
    required this.searchPlaceholder,
  });

  @override
  State<_PickSheet<T>> createState() => _PickSheetState<T>();
}

class _PickSheetState<T> extends State<_PickSheet<T>> {
  final _query = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.options;
    _query.addListener(_onQuery);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _onQuery() {
    final q = _query.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.options;
      } else {
        _filtered = widget.options
            .where((o) => widget.searchKeyFor(o).toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.78;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: QPayTokens.n300,
                borderRadius: BorderRadius.circular(QPayTokens.rPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: QPayType.heroTitle.copyWith(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QField(
                controller: _query,
                placeholder: widget.searchPlaceholder ?? 'Search',
                autofocus: true,
                prefix: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: QPayTokens.ink3,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final opt = _filtered[i];
                  final isSelected = widget.selected != null &&
                      widget.labelFor(widget.selected as T) ==
                          widget.labelFor(opt);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(QPayTokens.rMd),
                      onTap: () => Navigator.of(context).pop(opt),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.labelFor(opt),
                                style: QPayType.optionTitle.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                size: 20,
                                color: QPayTokens.ink,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

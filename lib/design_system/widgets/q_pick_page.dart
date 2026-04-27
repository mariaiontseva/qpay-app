import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';
import 'q_field.dart';

/// Push a full-screen searchable picker and await the user's choice.
/// Returns the selected option, or null if dismissed.
Future<T?> pushQPickPage<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelFor,
  required String Function(T) searchKeyFor,
  T? selected,
  String? searchPlaceholder,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute<T>(
      fullscreenDialog: false,
      builder: (_) => _PickPage<T>(
        title: title,
        options: options,
        labelFor: labelFor,
        searchKeyFor: searchKeyFor,
        selected: selected,
        searchPlaceholder: searchPlaceholder,
      ),
    ),
  );
}

class _PickPage<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final String Function(T) labelFor;
  final String Function(T) searchKeyFor;
  final T? selected;
  final String? searchPlaceholder;

  const _PickPage({
    required this.title,
    required this.options,
    required this.labelFor,
    required this.searchKeyFor,
    required this.selected,
    required this.searchPlaceholder,
  });

  @override
  State<_PickPage<T>> createState() => _PickPageState<T>();
}

class _PickPageState<T> extends State<_PickPage<T>> {
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
    return Scaffold(
      backgroundColor: QPayTokens.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ───── Top bar (back + title) ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: QPayTokens.ink,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
              child: Text(
                widget.title,
                style: QPayType.heroTitle,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matches.',
                        style: QPayType.statusLine,
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 0),
                      itemBuilder: (ctx, i) {
                        final opt = _filtered[i];
                        final isSelected = widget.selected != null &&
                            widget.labelFor(widget.selected as T) ==
                                widget.labelFor(opt);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(QPayTokens.rMd),
                            onTap: () =>
                                Navigator.of(context).pop(opt),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.labelFor(opt),
                                      style:
                                          QPayType.optionTitle.copyWith(
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
          ],
        ),
      ),
    );
  }
}

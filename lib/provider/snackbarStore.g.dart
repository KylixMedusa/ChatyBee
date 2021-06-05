// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snackbarStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SnackbarStore on _SnackbarStore, Store {
  final _$snackbarAtom = Atom(name: '_SnackbarStore.snackbar');

  @override
  SnackbarType get snackbar {
    _$snackbarAtom.reportRead();
    return super.snackbar;
  }

  @override
  set snackbar(SnackbarType value) {
    _$snackbarAtom.reportWrite(value, super.snackbar, () {
      super.snackbar = value;
    });
  }

  final _$_SnackbarStoreActionController =
      ActionController(name: '_SnackbarStore');

  @override
  void add(SnackbarType newSnackbar) {
    final _$actionInfo = _$_SnackbarStoreActionController.startAction(
        name: '_SnackbarStore.add');
    try {
      return super.add(newSnackbar);
    } finally {
      _$_SnackbarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void remove() {
    final _$actionInfo = _$_SnackbarStoreActionController.startAction(
        name: '_SnackbarStore.remove');
    try {
      return super.remove();
    } finally {
      _$_SnackbarStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
snackbar: ${snackbar}
    ''';
  }
}

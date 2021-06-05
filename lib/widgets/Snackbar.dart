import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../provider/snackbarStore.dart';

class Snackbar extends StatefulWidget {
  final Widget child;

  Snackbar({Key key, this.child}) : super(key: key);

  @override
  _SnackbarState createState() => _SnackbarState();
}

class _SnackbarState extends State<Snackbar> with TickerProviderStateMixin {
  CurvedAnimation _progressAnimation;

  @override
  void initState() {
    super.initState();
  }

  void _configureProgressIndicatorAnimation(SnackbarType snackbar) {
    if (snackbar != null &&
        snackbar.showProgressIndicator &&
        snackbar.progressIndicatorController != null) {
      _progressAnimation = CurvedAnimation(
          curve: Curves.linear, parent: snackbar.progressIndicatorController);
    }
  }

  Widget _generateSnackbar(SnackbarType snackbar) {
    this._configureProgressIndicatorAnimation(snackbar);
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: snackbar.backgroundColor,
        gradient: snackbar.backgroundGradient,
        boxShadow: snackbar.boxShadows,
        borderRadius: BorderRadius.circular(snackbar.borderRadius),
        border: snackbar.borderColor != null
            ? Border.all(
                color: snackbar.borderColor, width: snackbar.borderWidth)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressIndicator(snackbar),
          ..._getAppropriateRowLayout(snackbar),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(SnackbarType snackbar) {
    if (snackbar.showProgressIndicator && _progressAnimation != null) {
      return AnimatedBuilder(
          animation: _progressAnimation,
          builder: (_, __) {
            return CircularProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: snackbar.progressIndicatorBackgroundColor,
              valueColor: snackbar.progressIndicatorValueColor,
            );
          });
    }

    if (snackbar.showProgressIndicator) {
      return CircularProgressIndicator(
        backgroundColor: snackbar.progressIndicatorBackgroundColor,
        valueColor: snackbar.progressIndicatorValueColor,
      );
    }

    return Container();
  }

  List<Widget> _getAppropriateRowLayout(SnackbarType snackbar) {
    double buttonRightPadding;
    double iconPadding = 0;
    if (snackbar.padding.right - 12 < 0) {
      buttonRightPadding = 4;
    } else {
      buttonRightPadding = snackbar.padding.right - 12;
    }

    if (snackbar.padding.left > 16.0) {
      iconPadding = snackbar.padding.left;
    }

    if (snackbar.icon == null && snackbar.mainButton == null) {
      return [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (snackbar.title != null || snackbar.titleText != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: snackbar.padding.top,
                        left: snackbar.padding.left,
                        right: snackbar.padding.right,
                      ),
                      child: _getTitleText(snackbar),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(
                  top: (snackbar.title != null || snackbar.titleText != null)
                      ? 6.0
                      : snackbar.padding.top,
                  left: snackbar.padding.left,
                  right: snackbar.padding.right,
                  bottom: snackbar.padding.bottom,
                ),
                child: snackbar.messageText ??
                    _getDefaultNotificationText(snackbar),
              ),
            ],
          ),
        ),
      ];
    } else if (snackbar.icon != null && snackbar.mainButton == null) {
      return <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 42.0 + iconPadding),
          child: _getIcon(snackbar),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (snackbar.title != null || snackbar.titleText != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: snackbar.padding.top,
                        left: 4.0,
                        right: snackbar.padding.left,
                      ),
                      child: _getTitleText(snackbar),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(
                  top: (snackbar.title != null || snackbar.titleText != null)
                      ? 6.0
                      : snackbar.padding.top,
                  left: 4.0,
                  right: snackbar.padding.right,
                  bottom: snackbar.padding.bottom,
                ),
                child: snackbar.messageText ??
                    _getDefaultNotificationText(snackbar),
              ),
            ],
          ),
        ),
      ];
    } else if (snackbar.icon == null && snackbar.mainButton != null) {
      return <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (snackbar.title != null || snackbar.titleText != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: snackbar.padding.top,
                        left: snackbar.padding.left,
                        right: snackbar.padding.right,
                      ),
                      child: _getTitleText(snackbar),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(
                  top: (snackbar.title != null || snackbar.titleText != null)
                      ? 6.0
                      : snackbar.padding.top,
                  left: snackbar.padding.left,
                  right: 8.0,
                  bottom: snackbar.padding.bottom,
                ),
                child: snackbar.messageText ??
                    _getDefaultNotificationText(snackbar),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: buttonRightPadding),
          child: _getMainActionButton(snackbar),
        ),
      ];
    } else {
      return <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 42.0 + iconPadding),
          child: _getIcon(snackbar),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (snackbar.title != null || snackbar.titleText != null)
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: snackbar.padding.top,
                        left: 4.0,
                        right: 8.0,
                      ),
                      child: _getTitleText(snackbar),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(
                  top: (snackbar.title != null || snackbar.titleText != null)
                      ? 6.0
                      : snackbar.padding.top,
                  left: 4.0,
                  right: 8.0,
                  bottom: snackbar.padding.bottom,
                ),
                child: snackbar.messageText ??
                    _getDefaultNotificationText(snackbar),
              ),
            ],
          ),
        ),
        Padding(
              padding: EdgeInsets.only(right: buttonRightPadding),
              child: _getMainActionButton(snackbar),
            ) ??
            Container(),
      ];
    }
  }

  Widget _getIcon(SnackbarType snackbar) {
    if (snackbar.icon != null) {
      return snackbar.icon;
    } else {
      return Container();
    }
  }

  Widget _getTitleText(SnackbarType snackbar) {
    return snackbar.titleText != null
        ? snackbar.titleText
        : Text(
            snackbar.title ?? "",
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          );
  }

  Text _getDefaultNotificationText(SnackbarType snackbar) {
    return Text(
      snackbar.message ?? "",
      style: TextStyle(fontSize: 14.0, color: Colors.white),
    );
  }

  Widget _getMainActionButton(SnackbarType snackbar) {
    if (snackbar.mainButton != null) {
      return snackbar.mainButton;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final snackbarStore = Provider.of<SnackbarStore>(context);
    return Observer(
      builder: (_) {
        return Stack(
          children: [
            widget.child,
            snackbarStore.snackbar != null &&
                    !snackbarStore.snackbar.isDismissible
                ? Positioned.fill(child: GestureDetector(onTap: () {}))
                : Container(
                    width: 0,
                    height: 0,
                  ),
            snackbarStore.snackbar != null &&
                    !snackbarStore.snackbar.isDismissible
                ? Positioned(
                    bottom: 40,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            snackbarStore.snackbar.borderRadius),
                        child: _generateSnackbar(snackbarStore.snackbar),
                      ),
                    ))
                : snackbarStore.snackbar != null &&
                        snackbarStore.snackbar.isDismissible
                    ? Positioned(
                        bottom: 40,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Dismissible(
                            direction: DismissDirection.down,
                            onDismissed: (DismissDirection val) {
                              snackbarStore.remove();
                            },
                            key: new ValueKey(0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  snackbarStore.snackbar.borderRadius),
                              child: _generateSnackbar(snackbarStore.snackbar),
                            ),
                          ),
                        ))
                    : Container(
                        width: 0,
                        height: 0,
                      )
          ],
        );
      },
    );
  }
}

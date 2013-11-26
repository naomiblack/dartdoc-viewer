// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.main;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart';
import 'dart:html';
import 'package:dartdoc_viewer/read_yaml.dart';

// TODO(alanknight): Clean up the dart-style CSS file's formatting once
// it's stable.
@CustomTag("dartdoc-main")
class MainElement extends DartdocElement {
  @observable String pageContentClass;
  @observable bool shouldShowLibraryPanel;
  @observable bool shouldShowLibraryMinimap;
  @observable bool shouldShowClassMinimap;

  // TODO(jmesserly): somewhat unfortunate, but for now we don't have
  // polymer_expressions so we need a workaround.
  @observable String showOrHideLibraries;
  @observable String showOrHideMinimap;
  @observable String showOrHideInherited;
  @observable String showOrHidePackages;

  /// Records the timestamp of the event that opened the options menu.
  var _openedAt;

  MainElement.created() : super.created();

  enteredView() {
    super.enteredView();

    registerObserver('viewer', viewer.changes.listen(_onViewerChange));
    registerObserver('onclick',
        onClick.listen(hideOptionsMenuWhenClickedOutside));
  }

  void _onViewerChange(changes) {
    if (!viewer.isDesktop) {
      pageContentClass = '';
    } else {
      var left = viewer.isPanel ? 'margin-left ' : '';
      var right = viewer.isMinimap ? 'margin-right' : '';
      pageContentClass = '$left$right';
    }

    shouldShowLibraryPanel =
        viewer.currentPage != null && viewer.isPanel;

    shouldShowClassMinimap =
        viewer.currentPage is Class && viewer.isMinimap;

    shouldShowLibraryMinimap =
        viewer.currentPage is Library && viewer.isMinimap;

    showOrHideLibraries = viewer.isPanel ? 'Hide' : 'Show';
    showOrHideMinimap = viewer.isMinimap ? 'Hide' : 'Show';
    showOrHideInherited = viewer.isInherited ? 'Hide' : 'Show';
    showOrHidePackages = viewer.showPkgLibraries ? 'Hide' : 'Show';
  }

  query(String selectors) => shadowRoot.querySelector(selectors);

  searchSubmitted() {
    query('#nav-collapse-button').classes.add('collapsed');
    query('#nav-collapse-content').classes.remove('in');
    query('#nav-collapse-content').classes.add('collapse');
  }

  togglePanel() => viewer.togglePanel();
  toggleInherited() => viewer.toggleInherited();
  toggleMinimap() => viewer.toggleMinimap();
  togglePkg() => viewer.togglePkg();

  void toggleOptionsMenu(MouseEvent event, detail, target) {
    var list = shadowRoot.querySelector(".dropdown-menu").parent;
    if (list.classes.contains("open")) {
      list.classes.remove("open");
    } else {
      _openedAt = event.timeStamp;
      list.classes.add("open");
    }
  }

  void hideOptionsMenuWhenClickedOutside(MouseEvent e) {
    if (_openedAt != null && _openedAt == e.timeStamp) {
      _openedAt == null;
      return;
    }
    hideOptionsMenu();
  }

  void hideOptionsMenu() {
    var list = shadowRoot.querySelector(".dropdown-menu").parent;
    list.classes.remove("open");
  }

  var _buildIdentifier;
  @observable get buildIdentifier {
    if (_buildIdentifier != null) return _buildIdentifier;

    _buildIdentifier = ''; // Don't try twice.
    retrieveFileContents('docs/VERSION').then((version) {
      _buildIdentifier = notifyPropertyChange(#buildIdentifier,
          _buildIdentifier, "r $version");
    }).catchError((_) => null);
    return '';
  }

  void navHideShow() {
    var nav = shadowRoot.querySelector("#nav-collapse-content");
    if (nav.classes.contains("in")) {
      nav.classes.remove("in");
    } else {
      nav.classes.add("in");
    }
  }
}

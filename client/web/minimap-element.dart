// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.minimap_element;

import 'dart:html';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' show viewer, defaultSyntax;

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap")
class MinimapElement extends PolymerElement {
  @published Category category;

  @observable String lowerCaseName;
  @observable String currentLocation;

  get syntax => defaultSyntax;
  get applyAuthorStyles => true;

  MinimapElement.created() : super.created() {
    registerObserver('isInherited', viewer.changes.listen((changes) {
      for (var change in changes) {
        if (change.name == #isInherited) {
          categoryChanged();
          return;
        }
      }
    }));

    updateLocation(x) { currentLocation = '${window.location}'; }
    updateLocation(null);
    registerObserver('currentLocation',
        windowLocation.changes.listen(updateLocation));
  }

  @observable Iterable<Item> itemsToShow;

  categoryChanged() {
    if (category == null) return;

    lowerCaseName = category.name.toLowerCase();
    itemsToShow = category.content.where(
        (x) => !x.isInherited || viewer.isInherited);
  }

  hideShow(event, detail, target) {
    var loc = new DocsLocation(target.hash);
    var list = shadowRoot.querySelector('ul');
    if (list.classes.contains('in')) {
      list.classes.remove('in');
    } else {
      list.classes.add('in');
    }
  }
}

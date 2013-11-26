// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.category;

import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Category.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-category")
class CategoryElement extends DartdocElement {
  @published Category category;

  @observable String title;
  @observable String stylizedName;
  @observable var categoryContent;
  @observable List<Method> categoryMethods;
  @observable List<Variable> categoryVariables;
  @observable List categoryEverythingElse;

  @observable String accordionStyle;
  @observable String accordionParent;
  @observable String divClass;

  CategoryElement.created() : super.created() {
    registerObserver('viewer', viewer.changes.listen((changes) {
      if (changes.any((c) => c.name == #isInherited)) {
        categoryChanged();
      }
      if (changes.any((c) => c.name == #isDesktop)) {
        _updateStyles();
      }
    }));
    _updateStyles();
  }

  void _updateStyles() {
    accordionStyle = viewer.isDesktop ? '' : 'collapsed';
    accordionParent = viewer.isDesktop ? '' : '#accordion-grouping';
    divClass = viewer.isDesktop ? 'collapse in' : 'collapse';
  }

  void categoryChanged() {
    title = category == null ? '' : category.name;
    stylizedName = category == null ? '' : category.name.replaceAll(' ', '-');
    categoryContent = category == null ? [] : category.content;

    categoryMethods = [];
    categoryVariables = [];
    categoryEverythingElse = [];
    for (var c in categoryContent) {
      if (c.isInherited && !viewer.isInherited) continue;

      List list;
      if (c is Method) {
        list = categoryMethods;
      } else if (c is Variable) {
        list = categoryVariables;
      } else {
        list = categoryEverythingElse;
      }
      list.add(c);
    }
  }

  hideShow(event, detail, AnchorElement target) {
    var list = shadowRoot.querySelector(target.attributes["data-target"]);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
      list.style.height = '0px';
    } else {
      list.classes.add("in");
      list.style.height = 'auto';
    }
  }
}

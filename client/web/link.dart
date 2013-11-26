// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.link;

import 'dart:html';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:polymer/polymer.dart';

// TODO(jmesserly): just extend HtmlElement?
@CustomTag("dartdoc-link")
class LinkElement extends PolymerElement {
  @published LinkableType type;

  LinkElement.created() : super.created();

  enteredView() {
    super.enteredView();
    index.onLoad(_updateComment);
  }

  void typeChanged() {
    this.children.clear();
    if (type == null) return;

    Element child;
    final location = type.loc.withAnchor;
    if (index.map.containsKey(location)) {
      child = new AnchorElement()..href = '#$location';
    } else {
      child = new Element.tag('i');
    }
    this.append(child..text = type.simpleType);
  }
}

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.comment;

import 'dart:html';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';

@CustomTag('dartdoc-comment')
class CommentElement extends PolymerElement {
  @published Container item;
  @published bool preview = false;
  Element _commentElement;

  factory CommentElement() => new Element.tag('section', 'dartdoc-comment');

  CommentElement.created() : super.created() {
    classes.add('description');
  }

  itemChanged() => _updateComment();
  previewChanged() => _updateComment();

  enteredView() {
    super.enteredView();
    index.onLoad(_updateComment);
  }

  /// Adds [item]'s comment to the the element with markdown links converted to
  /// working links.
  void _updateComment() {
    if (_commentElement != null) {
      _commentElement.remove();
      _commentElement = null;
    }

    if (item == null) return;

    var comment = item.comment;
    if (preview && (item is Class || item is Library)) {
      comment = (item as LazyItem).previewComment;
    }
    if (comment != '' && comment != null) {
      // TODO(jmesserly): for now, trusting doc comment HTML.
      _commentElement = new Element.html(comment, treeSanitizer: sanitizer);
      var firstParagraph = (_commentElement is ParagraphElement) ?
          _commentElement : _commentElement.querySelector("p");
      if (firstParagraph != null) {
        firstParagraph.classes.add("firstParagraph");
      }
      var links = _commentElement.querySelectorAll('a');
      for (AnchorElement link in links) {
        _resolveLink(link);
      }
      append(_commentElement);
    }
  }

  bool _isParameterReference(AnchorElement link, DocsLocation loc) {
    return link.text.length > loc.withAnchor.length;
  }

  void _replaceWithParameterReference(AnchorElement link, DocsLocation loc) {
    // If the link is to a parameter of this method, it shouldn't be
    // made into a working link. It instead is replaced with an <i>
    // tag to make it stand out within the comment.
    // TODO(tmandel): Handle parameters differently?
    var parameterName =
        link.text.substring(loc.withAnchor.length + 1, link.text.length);
    loc.anchor = loc.toHash("${loc.subMemberName}_$parameterName");
    loc.subMemberName = null;
    link.replaceWith(new AnchorElement()
        ..href = '#${loc.withAnchor}'
        ..text = parameterName);
  }

  void _resolveLink(AnchorElement link) {
    if (link.href != '') return;
    var loc = new DocsLocation(link.text);
    if (_isParameterReference(link, loc)) {
      _replaceWithParameterReference(link, loc);
      return;
    }
    if (index.map.containsKey(link.text)) {
      _setLinkReference(link, loc);
      return;
    }
    loc.packageName = null;
    if (index.map.containsKey(loc.withAnchor)) {
      _setLinkReference(link, loc);
      return;
    }
    // If markdown links to private or otherwise unknown members are
    // found, make them <i> tags instead of <a> tags for CSS.
    link.replaceWith(new Element.tag('i')..text = link.text);
  }

  void _setLinkReference(AnchorElement link, DocsLocation loc) {
    var linkable = new LinkableType(loc.withAnchor);
    link
      ..href = '#${linkable.location}'
      ..text = linkable.simpleType;
  }
}

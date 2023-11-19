import 'dart:io';

import 'package:jm_dict_en/entry.dart';
import 'package:xml/xml.dart';

class Dictionary {
  List<Entry> wordEntries;

  Dictionary(this.wordEntries);

  static Dictionary fromXmlPath(String filepath) {
    final file = File(filepath);
    final contents = file.readAsStringSync();
    return fromXmlString(contents);
  }

  static Dictionary fromXmlString(String xmlString) {
    final XmlDocument dictionaryDocument = XmlDocument.parse(xmlString);
    final childrenOfRoot =
        dictionaryDocument.rootElement.findElements('*').toList();

    final List<Entry> entries = [];

    for (var entryElement in childrenOfRoot) {
      final keb =
          _parseStringFromElement(entryElement.getElement('k_ele'), 'keb');
      final reb =
          _parseStringFromElement(entryElement.getElement('r_ele'), 'reb');
      final gloss = _parseMultipleStringFromElements(
          entryElement.findAllElements('sense'), 'gloss');
      final seq = _parseSeq(entryElement.getElement('ent_seq'));
      final example = _parseExample(entryElement.getElement('example'));

      entries.add(
        Entry(keb, reb, gloss, seq, example),
      );
    }

    final dict = Dictionary(entries);
    return dict;
  }

  static int _parseSeq(XmlElement? seqElement) {
    if (seqElement == null) {
      return -1;
    }
    return int.parse(seqElement.innerText);
  }

  static List<String?> _parseMultipleStringFromElements(
    Iterable<XmlElement?> elements,
    String targetName,
  ) {
    return elements
        .map((element) => _parseStringFromElement(element, targetName))
        .toList();
  }

  static String? _parseStringFromElement(
      XmlElement? parentOfTarget, String targetName) {
    if (parentOfTarget == null) {
      return null;
    } else if (parentOfTarget.name.local == targetName) {
      return parentOfTarget.innerText;
    }

    XmlElement? targetElement = parentOfTarget.getElement(targetName);

    return _parseStringFromElement(targetElement, targetName);
  }

  static List<String?> _parseExample(XmlElement? exampleElement) {
    if (exampleElement == null) {
      return [];
    }

    List<String> example = [];
    for (XmlElement child in exampleElement.childElements) {
      example.add(child.innerText);
    }
    return example;
  }

  Entry search(String word) {
    return wordEntries.firstWhere(
        (element) =>
            element.reb == word ||
            element.keb == word ||
            element.gloss.contains(word),
        orElse: () => Entry("Not found", "Not found", [], -1, []));
    // try {
    //   return wordEntries
    //       .findAllElements('entry')
    //       .map((entryElement) => Entry.fromXmlElement(entryElement))
    //       .firstWhere(
    //         (entry) =>
    //             entry.reb == word ||
    //             entry.keb == word ||
    //             entry.gloss.contains(word),
    //         orElse: () => Entry("Not found", "Not found", [], -1),
    //       );
    // } catch (e) {
    //   print('Error reading/parsing the XML file: $e');
    //   return Entry("Error", "Error", [], -1);
    // }
  }
}

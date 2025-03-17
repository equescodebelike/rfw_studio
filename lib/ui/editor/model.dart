import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';
import 'package:signals/signals_flutter.dart';

import '../../src/libraries/base.dart';
import '../widgets/actions.dart';
import '../widgets/controllers/code.dart';
import '../widgets/controllers/rfw.dart';

class EditorViewModel {
  EditorViewModel({
    required this.code,
    required this.json,
    required this.libraries,
  });
  final List<BaseLibrary> libraries;
  final cleanup = <EffectCleanup>[];
  final RfwController code;
  final CodeController json;
  final runtime = Runtime();
  final data = DynamicContent();
  final formKey = GlobalKey<FormState>();
  late final rfw$ = valueNotifierToSignal(code);
  late final data$ = valueNotifierToSignal(json);
  final codeError$ = signal<ParserException?>(null);
  final jsonError$ = signal<FormatException?>(null);
  final library = const LibraryName(<String>['main']);
  final widget$ = signal('root');
  final selected$ = signal<RfwNode?>(null);

  final treeController = TreeController<RfwNode>(
    roots: [],
    childrenProvider: (val) => val.children.toList(),
    defaultExpansionState: true,
  );

  late final library$ = computed(() {
    final str = rfw$.value.text.trim();
    if (str.isEmpty) return null;
    try {
      codeError$.value = null;
      final lib = parseLibraryFile(str);
      runtime.update(library, lib);
      return lib;
    } catch (error) {
      if (error is ParserException) {
        codeError$.value = error;
      }
    }
  });

  void init() {
    for (final library in libraries) {
      final lib = LocalWidgetLibrary({
        for (final entry in library.build().entries) ...{
          entry.key: (context, source) {
            return entry.value.builder(
              context,
              () => library.createKey(entry.key),
              source,
            );
          },
        },
      });
      runtime.update(LibraryName(library.import), lib);
      for (final alias in library.alias) {
        runtime.update(LibraryName(alias), lib);
      }
    }
    cleanup.add(effect(() {
      final lib = library$.value;
      if (lib == null) return;
      final widgets = lib.widgets;
      final w = widget$.value;
      final widget = widgets.firstWhereOrNull((e) => e.name == w);
      if (widget == null) return;
      // print((w, widget.initialState, widget.root, lib.toString()));
      final items = lib.widgets.map(RfwNode.parse).toList();
      treeController.roots = items;
    }));
    cleanup.add(effect(() {
      final txt = data$().text.trim();
      if (txt.isEmpty) return;
      try {
        jsonError$.value = null;
        data.updateAll(jsonDecode(txt));
      } catch (err) {
        if (err is FormatException) {
          jsonError$.value = err;
        }
      }
    }));
  }

  void dispose() {
    for (final cb in cleanup) {
      cb();
    }
    json.dispose();
    code.dispose();
  }

  void clearKeys() {
    for (final library in libraries) {
      library.keys.clear();
    }
  }

  void onEvent(BuildContext context, String name, DynamicMap arguments) {
    debugPrint('user triggered event "$name" with data: $arguments');
    toast(context, '$name ${jsonEncode(arguments)}');
  }

  static const encoder = JsonEncoder.withIndent(' ');

  void loadDefault() {
    batch(() {
      json.text = encoder.convert(jsonDecode(_defaultJson));
      code.text = _defaultRfw;
    });
  }
}

const _defaultJson = '''
{
  "greet": {"name": "World"}
}
''';

const _defaultRfw = '''
import widgets;
import local;

widget root = CustomScaffold(
  body: SingleChildScrollView(
    child: ContentBlock(
      child: Column(
        children: [
          H2(text: "15 марта"),
          CustomSpacer(),
          Paragraph(text: "— память преподобного Агафона Египетского. Его удивительное житие из книги «Малый патерик. Истории о древних подвижниках» и предлагаем для совместного чтения."),
          CustomSpacer(),
          Paragraph(text: "Под «предлагаем для совместного чтения»:"),
          CustomSpacer(),
          Paragraph(text: "Во времена святого Антония Великого жил в Египте один монах по имени Агафон. Говорят, что Агафон, когда был молод, посещал святого Антония. А у святого был от Бога дар видеть души людей, как мы видим лица. Итак, когда они поговорили, святой Антоний сказал юному Агафону, что он тоже станет святым и будет таким кротким и беззлобным, что не сможет замечать в людях плохого, но одно только хорошее."),
          CustomSpacer(),
          Paragraph(text: "Так оно и стало, ибо со временем отец Агафон стал таким кротким, что никогда ни на кого не сердился, сколько бы ему зла ни причиняли."),
          CustomSpacer(),
          Paragraph(text: "Итак, случилось со святым Агафоном следующее происшествие, из которого видно, каким терпеливым и кротким он стал. Пошел однажды святой в город продавать глиняные сосуды, которые делал своими руками в пустыне (мы забыли сказать, что отец Агафон был пустынником). Идя, он увидел на дороге прокаженного[1]. Прокаженный спросил его:"),
          CustomSpacer(),
          Paragraph(text: "— Куда ты идешь?"),
          CustomSpacer(),
          Paragraph(text: "— В город, чтобы продать эти сосуды, — ответил ему святой."),
          CustomSpacer(),
          Paragraph(text: "— Будь добр, — снова сказал прокаженный, — возьми и меня с собой."),
          CustomSpacer(),
          Paragraph(text: "— Давай! — согласился святой Агафон и, взвалив прокаженного себе на спину, с трудом дотащил его до города."),
          CustomSpacer(),
          Paragraph(text: "Когда они добрались до рынка, прокаженный снова говорит ему:"),
          CustomSpacer(),
          Paragraph(text: "— Положи меня туда, где будешь продавать сосуды."),
          CustomSpacer(),
          Paragraph(text: "Святой сделал, как просил больной, и не успел продать первый сосуд, как прокаженный опять накинулся на него:"),
          CustomSpacer(),
          Paragraph(text: "— Ты продал сосуд?"),
          CustomSpacer(),
          Paragraph(text: "— Да! — ответил отец Агафон."),
          CustomSpacer(),
          Paragraph(text: "— Если ты продал его, значит, у тебя есть деньги! Теперь купи мне хлеб на эти деньги!"),
          CustomSpacer(),
          Paragraph(text: "Святой ни мало не стал размышлять, пошел и купил прокаженному хлеба. Однако прокаженный не унимался. Как только отец Агафон продал следующий сосуд, прокаженный опять набросился:"),
          CustomSpacer(),
          Paragraph(text: "— Ты продал еще один сосуд? Купи мне винограду!"),
          CustomSpacer(),
          Paragraph(text: "И так продолжалось до самого вечера: как только святой продавал что-нибудь, прокаженный просил его купить ему то одно, то другое, пока не закончились и все сосуды, и деньги."),
          CustomSpacer(),
          Paragraph(text: "Когда стало вечереть, отец Агафон хотел было пойти домой. Прокаженный, однако, не давал ему спуску:"),
          CustomSpacer(),
          Paragraph(text: "— Ты хочешь уйти? Возьми и меня тоже и оставь там, где взял!"),
          CustomSpacer(),
          Paragraph(text: "Оставшись и без сосудов, и без денег, святой взвалил на спину прокаженного и медленно поплелся. Дойдя до места, где утром взял прокаженного, он бережно опустил его и хотел уже уйти. Но не успел сделать и шагу, как слышит за спиной такой приятный голос, что по всей земле не сыскать слаще и прекраснее его:"),
          CustomSpacer(),
          Paragraph(text: "— Благословен ты, Агафон, Господом неба и земли!"),
          CustomSpacer(),
          Paragraph(text: "Он повернулся посмотреть, кто это говорит, но не увидел никого."),
          CustomSpacer(),
          Paragraph(text: "Тогда святой Агафон понял, что прокаженный, которого он нес на спине, не был настоящим прокаженным, но Ангелом небесным, посланным от Бога испытать его кротость и терпение. От такой радости у отца Агафона как рукой сняло усталость. Он тихонько пошел к своей келье и много дней после этого все не мог оторвать помысла своего от произошедшего."),
          CustomSpacer(),
          Footnote(text: "[1] Прокаженный — человек, который страдал проказой. Это заболевание в основном выражается в поражении кожи. Такие люди в древности часто жили отдельно, изолированно от других. С ними почти никто не общался."),
        ],
      ),
    ),
  ),
);
''';

class RfwNode {
  final String title;
  final String? prefix;
  final RfwNode? parent;
  final Color? color;
  final List<RfwNode> children = [];
  Object source;

  RfwNode(
    this.source,
    this.title, {
    this.prefix,
    this.parent,
    this.color,
  });

  static RfwNode parse(
    Object? target, {
    RfwNode? parent,
    String? prefix,
  }) {
    return switch (target) {
      WidgetDeclaration val => () {
          final node = RfwNode(
            target,
            val.name,
            parent: parent,
            prefix: prefix,
            color: Colors.blueGrey,
          );
          node.children.add(RfwNode.parse(val.root, parent: node));
          return node;
        }(),
      ConstructorCall val => () {
          final node = RfwNode(
            target,
            val.name,
            parent: parent,
            prefix: prefix,
            color: Colors.blue,
          );
          for (final item in val.arguments.entries) {
            node.children.add(RfwNode.parse(
              item.value,
              parent: node,
              prefix: item.key,
            ));
          }
          return node;
        }(),
      Switch val => () {
          final node = RfwNode(
            target,
            'Switch',
            parent: parent,
            prefix: prefix,
            color: Colors.orange,
          );
          for (final item in val.outputs.entries) {
            node.children.add(RfwNode.parse(
              item.value,
              parent: node,
              prefix: item.key?.toString(),
            ));
          }
          return node;
        }(),
      ArgsReference _ => RfwNode(
          target,
          'Args',
          parent: parent,
          prefix: prefix,
          color: Colors.brown,
        ),
      DataReference _ => RfwNode(
          target,
          'Data',
          parent: parent,
          prefix: prefix,
          color: Colors.purple,
        ),
      AnyEventHandler _ => RfwNode(
          target,
          'Event',
          parent: parent,
          prefix: prefix,
          color: Colors.teal,
        ),
      // ArgsReference val => ArgsNode(val, parent),
      // AnyEventHandler val => EventNode(val, parent),
      // DataReference val => DataNode(val, parent),
      // Object? val => ValueNode(val, parent),

      final List<Object?> children => () {
          final node = RfwNode(
            target,
            '',
            parent: parent,
            prefix: prefix,
            color: Colors.green,
          );
          for (final child in children) {
            node.children.add(
              RfwNode.parse(
                child,
                parent: node,
                prefix: child?.toString(),
              ),
            );
          }
          return node;
        }(),
      (Object? _) => RfwNode(
          target ?? Object(),
          'Value',
          parent: parent,
          prefix: prefix,
        )
    };
  }
}

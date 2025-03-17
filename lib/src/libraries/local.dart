import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfw/rfw.dart';

import '../schema/core.dart';
import '../schema/decoders.dart';
import 'base.dart';

class LocalLibrary extends BaseLibrary {
  LocalLibrary()
      : super(
          name: 'Local',
          import: ['local'],
          alias: [
            ['core', 'local']
          ],
        );

  @override
  Map<String, LibraryComponent> build() {
    return {
      'GreenBox': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'color': ColorSchema(nullable: true),
            'child': WidgetSchema(nullable: true),
          },
        ),
        builder: (context, createKey, source) {
          return ColoredBox(
            key: createKey(),
            color: ArgumentDecoders.color(source, ['color']) ?? const Color(0xFF002211),
            child: source.optionalChild(['child']),
          );
        },
      ),
      'ImageBlock': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'image': StringSchema(),
            'margin': EdgeInsetsGeometrySchema(nullable: true),
            'child': WidgetSchema(nullable: true),
          },
        ),
        builder: (context, createKey, source) {
          return Container(
            key: createKey(),
            margin: ArgumentDecoders.edgeInsets(source, ['margin']),
            child: _buildImage(source),
          );
        },
      ),
      'Hello': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'name': StringSchema(nullable: true),
          },
        ),
        builder: (context, createKey, source) {
          return Center(
            key: createKey(),
            child: Text(
              'Hello, ${source.v<String>(['name']) ?? ''}!',
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
      'H1': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'text': StringSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Text(
            key: createKey(),
            source.v<String>(['text']) ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          );
        },
      ),
      'H2': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'text': StringSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Padding(
            key: createKey(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              source.v<String>(['text']) ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        },
      ),
      'Paragraph': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'text': StringSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Padding(
            key: createKey(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              source.v<String>(['text']) ?? '',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          );
        },
      ),
      'ItalicText': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'text': StringSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Text(
            key: createKey(),
            source.v<String>(['text']) ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          );
        },
      ),
      'Footnote': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'text': StringSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Padding(
            key: createKey(),
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              source.v<String>(['text']) ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
      'ContentBlock': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'child': WidgetSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Container(
            key: createKey(),
            margin: const EdgeInsets.all(16),
            child: source.child(['child']),
          );
        },
      ),
      'CustomSpacer': (
        schema: Schema(
          type: DataType.object,
        ),
        builder: (context, createKey, source) {
          return const SizedBox(height: 16);
        }
      ),
      'CustomScaffold': (
        schema: Schema(
          type: DataType.object,
          properties: {
            'body': WidgetSchema(),
          },
        ),
        builder: (context, createKey, source) {
          return Scaffold(
            key: createKey(),
            backgroundColor: const Color(0xFFfdeda4),
            appBar: AppBar(
              backgroundColor: const Color(0xFFfdeda4),
              title: const Text('Подробнее'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: source.child(['body']),
          );
        },
      ),
    };
  }

  Widget _buildImage(DataSource source) {
    final imageBase64 = source.v<String>(['image']) ?? '';
    return imageBase64.isNotEmpty
        ? Image.network(imageBase64, height: 400)
        : const Image(image: AssetImage('assets/default.png'));
  }
}

// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_trustpilot/otel_trustpilot.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_trustpilot-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('reviews.list records stars + source + verified', () async {
    await tracedTrustpilot<String>(
      operation: 'business_units.reviews',
      invoke: () async => const TrustpilotCallResult(
        value: 'ok',
        result: TrustpilotResult(
          businessUnitId: 'bu_1',
          reviewId: 'rev_1',
          reviewStars: 5,
          reviewLanguage: 'en',
          reviewSource: 'invitation',
          reviewVerified: true,
          reviewFlagged: false,
          replyStatus: 'replied',
          trustScore: 4.6,
          statusCode: 200,
        ),
      ),
    );
    final a =
        attrsOf(spans.findSpanByName('trustpilot business_units.reviews')!);
    expect(a['trustpilot.review.stars'], 5);
    expect(a['trustpilot.review.source'], 'invitation');
    expect(a['trustpilot.review.verified'], true);
    expect(a['trustpilot.trust_score'], 4.6);
  });

  test('1-star review captures without span error (business outcome)',
      () async {
    await tracedTrustpilot<String>(
      operation: 'business_units.reviews',
      invoke: () async => const TrustpilotCallResult(
        value: 'ok',
        result: TrustpilotResult(
          reviewId: 'rev_2',
          reviewStars: 1,
          replyStatus: 'not_replied',
        ),
      ),
    );
    expect(
      spans.findSpanByName('trustpilot business_units.reviews')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('bounced invitation sets span error', () async {
    await tracedTrustpilot<String>(
      operation: 'private.invitations.list_history',
      invoke: () async => const TrustpilotCallResult(
        value: 'ok',
        result: TrustpilotResult(
          invitationId: 'inv_1',
          invitationStatus: 'bounced',
        ),
      ),
    );
    expect(
      spans
          .findSpanByName('trustpilot private.invitations.list_history')!
          .status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutTrustpilotInstrumentationAsync(() async {
      await tracedTrustpilot<String>(
        operation: 'categories.list',
        invoke: () async => const TrustpilotCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('trustpilot '), isEmpty);
  });
}

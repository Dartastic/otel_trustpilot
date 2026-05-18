// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_trustpilot_suppression.dart';

const _tracerName = 'dartastic_otel_libs_trustpilot';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class TrustpilotResult {
  const TrustpilotResult({
    this.businessUnitId,
    this.locationId,
    this.entityKind,
    this.entityId,
    this.reviewId,
    this.reviewStars,
    this.reviewLanguage,
    this.reviewSource,
    this.reviewVerified,
    this.reviewFlagged,
    this.reviewReported,
    this.replyStatus,
    this.invitationId,
    this.invitationStatus,
    this.invitationsSent,
    this.trustScore,
    this.statusCode,
  });

  /// Business unit (the company being reviewed).
  final String? businessUnitId;

  /// Specific location for multi-location businesses.
  final String? locationId;

  /// `business_unit` / `consumer` / `review` / `private_review` /
  /// `service_review` / `location_review` / `invitation` /
  /// `category` / `tag` / `webhook`.
  final String? entityKind;

  final String? entityId;

  final String? reviewId;

  /// 1 through 5.
  final int? reviewStars;

  /// Two-letter ISO language code.
  final String? reviewLanguage;

  /// `organic` (consumer wrote unprompted on the site) / `invitation`
  /// (response to a Trustpilot invitation email) / `invitation-aft`
  /// (automatic follow-up).
  final String? reviewSource;

  /// `true` when Trustpilot's basic verification (purchase confirmed)
  /// has been done.
  final bool? reviewVerified;

  /// `true` when the business flagged the review.
  final bool? reviewFlagged;

  /// `true` when a consumer reported the review.
  final bool? reviewReported;

  /// `not_replied` / `replied` / `deleted`.
  final String? replyStatus;

  final String? invitationId;

  /// `pending` / `sent` / `delivered` / `opened` / `clicked` /
  /// `reviewed` / `bounced` / `rejected` / `unsubscribed`.
  final String? invitationStatus;

  /// Counts for bulk invitation send.
  final int? invitationsSent;

  /// Business unit's current TrustScore (0.0-5.0).
  final double? trustScore;

  final int? statusCode;
}

class TrustpilotCallResult<T> {
  const TrustpilotCallResult({required this.value, this.result});
  final T value;
  final TrustpilotResult? result;
}

/// Wraps a Trustpilot API call in a CLIENT span. [operation] is one
/// of `business_units.get`, `business_units.reviews`,
/// `business_units.location_reviews`, `private.reviews`,
/// `private.review.respond`, `private.invitations.create`,
/// `private.invitations.batch_create`,
/// `private.invitations.list_history`, `categories.list`,
/// `consumer.profile`, `webhooks.create`.
Future<T> tracedTrustpilot<T>({
  required String operation,
  required Future<TrustpilotCallResult<T>> Function() invoke,
}) async {
  if (trustpilotInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'trustpilot',
    'rpc.method': operation,
    'trustpilot.operation': operation,
  };

  final span = _tracer().startSpan(
    'trustpilot $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.businessUnitId != null) {
        extras.add(OTel.attributeString(
          'trustpilot.business_unit.id',
          r.result!.businessUnitId!,
        ));
      }
      if (r.result!.locationId != null) {
        extras.add(OTel.attributeString(
          'trustpilot.location.id',
          r.result!.locationId!,
        ));
      }
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'trustpilot.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'trustpilot.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.reviewId != null) {
        extras.add(OTel.attributeString(
          'trustpilot.review.id',
          r.result!.reviewId!,
        ));
      }
      if (r.result!.reviewStars != null) {
        extras.add(OTel.attributeInt(
          'trustpilot.review.stars',
          r.result!.reviewStars!,
        ));
      }
      if (r.result!.reviewLanguage != null) {
        extras.add(OTel.attributeString(
          'trustpilot.review.language',
          r.result!.reviewLanguage!,
        ));
      }
      if (r.result!.reviewSource != null) {
        extras.add(OTel.attributeString(
          'trustpilot.review.source',
          r.result!.reviewSource!,
        ));
      }
      if (r.result!.reviewVerified != null) {
        extras.add(OTel.attributeBool(
          'trustpilot.review.verified',
          r.result!.reviewVerified!,
        ));
      }
      if (r.result!.reviewFlagged != null) {
        extras.add(OTel.attributeBool(
          'trustpilot.review.flagged',
          r.result!.reviewFlagged!,
        ));
      }
      if (r.result!.reviewReported != null) {
        extras.add(OTel.attributeBool(
          'trustpilot.review.reported',
          r.result!.reviewReported!,
        ));
      }
      if (r.result!.replyStatus != null) {
        extras.add(OTel.attributeString(
          'trustpilot.reply.status',
          r.result!.replyStatus!,
        ));
      }
      if (r.result!.invitationId != null) {
        extras.add(OTel.attributeString(
          'trustpilot.invitation.id',
          r.result!.invitationId!,
        ));
      }
      if (r.result!.invitationStatus != null) {
        extras.add(OTel.attributeString(
          'trustpilot.invitation.status',
          r.result!.invitationStatus!,
        ));
        if (r.result!.invitationStatus == 'bounced' ||
            r.result!.invitationStatus == 'rejected') {
          span.setStatus(
            SpanStatusCode.Error,
            'Trustpilot invitation ${r.result!.invitationStatus}',
          );
        }
      }
      if (r.result!.invitationsSent != null) {
        extras.add(OTel.attributeInt(
          'trustpilot.invitations.sent',
          r.result!.invitationsSent!,
        ));
      }
      if (r.result!.trustScore != null) {
        extras.add(OTel.attributeDouble(
          'trustpilot.trust_score',
          r.result!.trustScore!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Trustpilot HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

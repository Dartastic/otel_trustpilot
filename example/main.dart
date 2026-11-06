// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_trustpilot/otel_trustpilot.dart';

/// Traces Trustpilot calls with OpenTelemetry.
///
/// `otel_trustpilot` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Trustpilot call in
/// [tracedTrustpilot]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'trustpilot-example');

  // Wraps a Trustpilot API call in a CLIENT span.
  final trustpilotId = await tracedTrustpilot<String>(
    operation: 'private.invitations.create',
    invoke: () async {
      // Make the Trustpilot call here, then report what it returned.
      const id = 'trustpilot_8f3a2c';
      return const TrustpilotCallResult(
          value: id,
          result: TrustpilotResult(
              businessUnitId: 'businessunit_8f3a2c',
              locationId: 'location_8f3a2c',
              entityKind: 'business_unit',
              entityId: 'entity_8f3a2c',
              reviewId: 'review_8f3a2c',
              reviewStars: 1,
              reviewLanguage: 'en',
              reviewSource: 'organic',
              reviewVerified: true,
              reviewFlagged: true,
              reviewReported: true,
              replyStatus: 'not_replied',
              invitationId: 'invitation_8f3a2c',
              invitationStatus: 'pending',
              invitationsSent: 1,
              trustScore: 0.5,
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedTrustpilot private.invitations.create returned $trustpilotId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutTrustpilotInstrumentationAsync.
  await runWithoutTrustpilotInstrumentationAsync(
    () => tracedTrustpilot<String>(
      operation: 'private.invitations.create',
      invoke: () async {
        const id = 'trustpilot_8f3a2c';
        return const TrustpilotCallResult(
            value: id,
            result: TrustpilotResult(
                businessUnitId: 'businessunit_8f3a2c',
                locationId: 'location_8f3a2c',
                entityKind: 'business_unit',
                entityId: 'entity_8f3a2c',
                reviewId: 'review_8f3a2c',
                reviewStars: 1,
                reviewLanguage: 'en',
                reviewSource: 'organic',
                reviewVerified: true,
                reviewFlagged: true,
                reviewReported: true,
                replyStatus: 'not_replied',
                invitationId: 'invitation_8f3a2c',
                invitationStatus: 'pending',
                invitationsSent: 1,
                trustScore: 0.5,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}

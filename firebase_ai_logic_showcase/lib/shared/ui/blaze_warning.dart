import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import '../../firebase_options.dart';

class BlazeWarning extends StatelessWidget {
  const BlazeWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            text:
                'This demo includes some features that require an upgrade to the pay-as-you-go Blaze pricing plan, which you can ',
            children: [
              WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.top,
                child: Link(
                  uri: Uri.parse(
                    'https://console.firebase.google.com/project/${DefaultFirebaseOptions.currentPlatform.projectId}/overview?purchaseBillingPlan=metered',
                  ),
                  target: LinkTarget.blank,
                  builder: (context, followLink) => GestureDetector(
                    onTap: followLink,
                    child: Text(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        height: 1.15,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      'set up in the Firebase console',
                    ),
                  ),
                ),
              ),
              TextSpan(text: '.'),
              TextSpan(text: '\n\n'),
              TextSpan(
                text:
                    'Eligible developers can claim ',
              ),
              WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.top,
                child: Link(
                  uri: Uri.parse(
                    'https://firebase.blog/posts/2024/11/claim-300-to-get-started',
                  ),
                  target: LinkTarget.blank,
                  builder: (context, followLink) => GestureDetector(
                    onTap: followLink,
                    child: Text(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        height: 1.15,
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      '\$300 of credits',
                    ),
                  ),
                ),
              ),
              TextSpan(text: ' to get started.'),
            ],
          ),
        ),
      ),
    );
  }
}

class BlazeFooter extends StatelessWidget {
  const BlazeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text:
                  '* This demo includes some features that require an upgrade to the ',
            ),
            WidgetSpan(
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.top,
              child: Link(
                uri: Uri.parse('https://firebase.google.com/pricing'),
                target: LinkTarget.blank,
                builder: (context, followLink) => GestureDetector(
                  onTap: followLink,
                  child: Text(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      height: 1.15,
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    'pay-as-you-go Blaze pricing plan',
                  ),
                ),
              ),
            ),
            TextSpan(text: ', which you can '),
            WidgetSpan(
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.top,
              child: Link(
                uri: Uri.parse(
                  'https://console.firebase.google.com/project/${DefaultFirebaseOptions.currentPlatform.projectId}/overview?purchaseBillingPlan=metered',
                ),
                target: LinkTarget.blank,
                builder: (context, followLink) => GestureDetector(
                  onTap: followLink,
                  child: Text(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      height: 1.15,
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    'set up in the Firebase console',
                  ),
                ),
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

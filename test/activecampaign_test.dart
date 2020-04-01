import 'package:flutter_test/flutter_test.dart';

import 'package:activecampaign/activecampaign.dart';

void main() {
  test('add tag to contag', () async {
    final configs = {
      "activeCampaignAccount": "YOUR_ACTIVE_CAMPAIGN_ACCOUNT",
      "activeCampaignKey": "YOUR_ACTIVE_CAMPAIGN_KEY",
      "activeCampaignEventKey": "YOUR_ACTIVE_CAMPAIGN_EVENT_KEY",
      "activeCampaignEventActid": "YOUR_ACTIVE_CAMPAIGN_EVENT_ACT_ID",
      "proxyUrl": "YOUR_PROXY_SERVER" // optional, to bypass CORs in Flutter web
    };

    ActiveCampaign.config(configs);
    // add tag
    var result = await ActiveCampaign.shared.addTagToContact(
        "your_email@domain.com", "first name", "last name", "your tag");
    expect(true, result != null);

    // tracking
    var trackingResult = await ActiveCampaign.shared.trackEvent(
        'event_name', 'your_email@domain.com', {'your_property': 'your_data'});
    expect(true, trackingResult != null);
  });
}

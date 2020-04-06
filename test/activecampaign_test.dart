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
        "youremail@gmail.com", "tag1",
        firstName: "firstname", lastName: "lastname", forceUpdated: true);
    expect(true, result != null);

    // update properties
    var updateResult = await ActiveCampaign.shared.updateProperties(
        "youremail@gmail.com",
        firstName: "firstname",
        lastName: "lastname",
        properties: {"property1": "value1", "property2": "value2"});
    expect(true, updateResult == null);

    // tracking
    var trackingResult = await ActiveCampaign.shared
        .trackEvent('event_name', 'youremail@gmail.com', 'event data');
    expect(true, trackingResult != null);
  });
}

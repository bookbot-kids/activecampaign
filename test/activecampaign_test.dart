import 'package:flutter_test/flutter_test.dart';

import 'package:activecampaign/activecampaign.dart';

void main() {
  test('add tag to contag', () async {
    final configs = {
      "activeCampaignAccount": "YOUR_ACTIVE_CAMPAIGN_ACCOUNT",
      "activeCampaignKey": "YOUR_ACTIVE_CAMPAIGN_KEY",
      "proxyUrl": "YOUR_PROXY_SERVER" // optional, to bypass CORs in Flutter web
    };

    ActiveCampaign.config(configs);
    var result = await ActiveCampaign.shared.addTagToContact(
        "your_email@domain.com", "first name", "last name", "your tag");
    expect(true, result != null);
  });
}

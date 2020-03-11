library activecampaign;

import 'package:sync_db/sync_db.dart';

class ActiveCampaign {
  //singleton
  ActiveCampaign._privateConstructor();
  static final ActiveCampaign shared = ActiveCampaign._privateConstructor();
  factory ActiveCampaign() {
    return shared;
  }

  HTTP _http;
  String _apiKey;

  /// Init with configurations
  /// Requires to have `activeCampaignAccount` & `activeCampaignKey`
  static void config(Map config) {
    shared._http = HTTP(
        'https://${config["activeCampaignAccount"]}.api-us1.com/api/3/',
        config);
    shared._apiKey = config['activeCampaignKey'];
    shared._http.headers = {"Api-Token": config['activeCampaignKey']};
  }

  /// Add a tag into contact. Create if not exist
  Future<dynamic> addTagToContact(
      String email, String firstName, String lastName, String tag) async {
    if (_apiKey == null) {
      throw new Exception("you must call ActiveCampaign.config() first");
    }

    // get all tags
    var response = await _http.get("tags");
    var tagIds = Map<String, String>();
    if (response['tags'] != null) {
      List tags = response['tags'];
      tags.forEach((item) {
        tagIds[item['id']] = item['tag'];
      });
    }

    var tagId =
        tagIds.keys.firstWhere((k) => tagIds[k] == tag, orElse: () => null);
    // create tag if not exist
    if (tagId == null) {
      var body = """
      {
        "tag": {
          "tag": "$tag",
          "tagType": "contact",
          "description": "$tag"
        }
      }
      """;
      var response = await _http.post('tags', data: body);
      if (response['tag'] != null) {
        tagId = response['tag']['id'];
      }
    }

    // create contact if not exist
    var contact = await createContact(email, firstName, lastName);
    if (contact != null && tagId != null) {
      return await addTagIdToContactId(tagId, contact['id']);
    }

    return null;
  }

  /// Add tag id to a contact
  Future<dynamic> addTagIdToContactId(String tagId, String contactId) async {
    var body = """
      {
        "contactTag": {
          "contact": "$contactId",
          "tag": "$tagId"
        }
      }
      """;
    // add tag to contact
    try {
      var response = await _http.post('contactTags', data: body);
      if (response['contactTag'] != null) {
        return response;
      }
    } catch (e) {}

    return null;
  }

  /// Create contact if not exist
  /// Return a contact object
  Future<dynamic> createContact(
      String email, String firstName, String lastName) async {
    // get all contacts
    var response = await _http.get("contacts");
    var contact;
    if (response['contacts'] != null) {
      List contacts = response['contacts'];
      contact = contacts.firstWhere((item) => item['email'] == email,
          orElse: () => null);
    }

    if (contact == null) {
      // create new contact
      var body = """
        {
          "contact": {
            "email": "$email",
            "firstName": "$firstName",
            "lastName": "$lastName"
          }
        }
        """;
      var response = await _http.post('contacts', data: body);
      if (response['contact'] != null) {
        return response['contact'];
      }
    }

    return contact;
  }
}

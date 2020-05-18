library activecampaign;

import 'package:activecampaign/robust_http.dart';

class ActiveCampaign {
  //singleton
  ActiveCampaign._privateConstructor();
  static final ActiveCampaign shared = ActiveCampaign._privateConstructor();
  factory ActiveCampaign() {
    return shared;
  }

  HTTP _http;
  String _apiKey;
  String _baseUrl;
  String _proxyUrl;
  bool _enableHttp;
  String _eventKey;
  String _eventActid;
  Map _config;

  /// Init with configurations
  /// Requires to have `activeCampaignAccount` & `activeCampaignKey`
  /// It also supports a `proxyUrl` to bypass CORs
  static void config(Map config) {
    shared._config = config;
    shared._proxyUrl = config["proxyUrl"];
    shared._enableHttp = config["enableHttp"] ?? true;
    if (shared._enableHttp == true) {
      shared._baseUrl =
          'https://${config["activeCampaignAccount"]}.api-us1.com/api/3/';
    } else {
      shared._baseUrl = '${config["activeCampaignAccount"]}.api-us1.com/api/3/';
    }

    if (shared._proxyUrl != null) {
      shared._http = HTTP(null, config);
    } else {
      shared._http = HTTP(shared._baseUrl, config);
    }
    shared._apiKey = config['activeCampaignKey'];
    shared._http.headers = {"Api-Token": config['activeCampaignKey']};

    shared._eventKey = config["activeCampaignEventKey"];
    shared._eventActid = config["activeCampaignEventActid"];
  }

  /// Get the url if using proxy
  get url {
    if (_proxyUrl != null) {
      return _proxyUrl + _baseUrl;
    }

    return '';
  }

  /// Add a tag into contact. Create if not exist
  Future<dynamic> addTagToContact(String email, String tag,
      {String firstName, String lastName, bool forceUpdated = false}) async {
    if (_apiKey == null) {
      throw new Exception("you must call ActiveCampaign.config() first");
    }

    // get all tags
    var response = await _http.get("${url}tags");
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
      var response = await _http.post('${url}tags', data: body);
      if (response['tag'] != null) {
        tagId = response['tag']['id'];
      }
    }

    // create contact if not exist
    var contact = await createContact(email,
        firstName: firstName, lastName: lastName, forceUpdated: forceUpdated);
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
      var response = await _http.post('${url}contactTags', data: body);
      if (response['contactTag'] != null) {
        return response;
      }
    } catch (e) {}

    return null;
  }

  Future<dynamic> updateProperties(String email,
      {String firstName,
      String lastName,
      Map<String, String> properties,
      bool forceUpdated = false}) async {
    if (properties == null) {
      return null;
    }
    var contact = await createContact(email,
        firstName: firstName, lastName: lastName, forceUpdated: forceUpdated);
    if (contact == null || contact['id'] == null) {
      return null;
    }

    var contactId = contact['id'];
    var response = await _http.get("${url}fields");
    if (response['fields'] != null) {
      for (var property in properties.entries) {
        String fieldId;
        for (var field in response['fields']) {
          if (property.key == field['title']) {
            fieldId = field['id'];
            break;
          }
        }

        if (fieldId == null) {
          // create custom field
          var body = """
          {
          "field": {
            "type": "text",
            "title": "${property.key}",
            "descript": "${property.key}",
            "visible": 1,
            }
          }
          """;
          var res = await _http.post("${url}fields", data: body);
          fieldId = res['field']['id'];
        }

        // Update field value
        var body = """
          {
            "fieldValue": {
                "contact": $contactId,
                "field": $fieldId,
                "value": "${property.value}"
            }
          }
          """;

        await _http.post("${url}fieldValues", data: body);
      }
    }

    return null;
  }

  /// Create contact if not exist
  /// Return a contact object
  Future<dynamic> createContact(String email,
      {String firstName, String lastName, bool forceUpdated = false}) async {
    var contact;
    // get contact by email
    var params = {'email': email};
    var response = await _http.get("${url}contacts", parameters: params);
    if (response['contacts'] != null) {
      List contacts = response['contacts'];
      contact = contacts.firstWhere((item) => item['email'] == email,
          orElse: () => null);
    }

    if (contact == null || forceUpdated == true) {
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
      var response = await _http.post('${url}contact/sync', data: body);
      if (response['contact'] != null) {
        return response['contact'];
      }
    }

    return contact;
  }

  Future<dynamic> trackEvent(
      String eventName, String email, String eventData) async {
    if (_eventKey == null || _eventActid == null) {
      throw new Exception("you must call ActiveCampaign.config() first");
    }

    HTTP http;
    String subUrl;
    if (_proxyUrl != null) {
      if (_enableHttp) {
        subUrl = _proxyUrl + 'https://trackcmp.net/';
      } else {
        subUrl = _proxyUrl + 'trackcmp.net/';
      }

      http = HTTP(null, _config);
    } else {
      subUrl = '';
      http = HTTP('https://trackcmp.net/', _config);
    }

    http.dio.options.contentType = 'application/x-www-form-urlencoded';
    var visit = '{"email" : "$email"}';

    var params = {
      'key': _eventKey,
      'event': eventName,
      'eventdata': eventData,
      'actid': _eventActid,
      'visit': visit
    };

    var rep = await http.post('${subUrl}event', data: params);
    return rep;
  }
}

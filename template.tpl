___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Permate SuperTag",
  "categories": ["AFFILIATE_MARKETING", "ADVERTISING", "ATTRIBUTION"],
  "brand": {
    "id": "brand_dummy",
    "displayName": "Mẫu tùy chỉnh"
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "tracking_domain",
    "simpleValueType": true,
    "defaultValue": "https://qa.pmdevtk.com",
    "displayName": "Tracking domain"
  },
  {
    "type": "TEXT",
    "name": "session_click",
    "simpleValueType": true,
    "defaultValue": 684000,
    "displayName": "Session click"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Permission
const log = require('logToConsole');
const getCookieValues = require('getCookieValues');
const setCookie = require('setCookie');
const getUrl = require('getUrl');
const JSON = require('JSON');
const parseUrl = require('parseUrl');
const getTimestampMillis = require('getTimestampMillis');
const getReferrerUrl = require('getReferrerUrl');
const encodeUriComponent = require('encodeUriComponent');
const callInWindow = require('callInWindow');

const SESSION_CLICK = data.session_click || 684000;
const TRACKING_DOMAIN = data.tracking_domain;
const SCRIPT_URL = TRACKING_DOMAIN + '/get_url';
const COOKIES_EXPIRES = 604800; // 7 days
const COOKIES_0_EXPIRES = 7776000; // 90 days

function setPmOCookie(host, isSecure, data) {
  setCookie('pm_cep_o', data.cep, {
    'domain': host,
    'path': '/',
    'max-age': COOKIES_0_EXPIRES,
    'secure': isSecure
  });
  setCookie('pm_click', JSON.stringify({campaign: data.campaign, click: data.click_id}), {
    'domain': host,
    'path': '/',
    'max-age': COOKIES_0_EXPIRES,
    'secure': isSecure
  });
}

function setFillParamsCookie(host, isSecure, fillParams) {
  setCookie('pm_q', fillParams, {
    'domain': host,
    'path': '/',
    'max-age': COOKIES_EXPIRES,
    'secure': isSecure
  });
}

function processData() {
  if (!TRACKING_DOMAIN) {
    log('TRACKING_DOMAIN is undefined');
    return;
  }
  let pId = '';
  let cookieClickId = '';
  let currentUrl = getUrl();
  let currentUrlObj = parseUrl(currentUrl) || {};
  let searchParamObj = {};
  let isSecure = 'https:' === currentUrlObj.protocol;

  if (currentUrlObj && currentUrlObj.searchParams) {
    searchParamObj = currentUrlObj.searchParams;
  }
  let cpId = searchParamObj.pm_cid;
  let clId = searchParamObj.pm_click_id;

  // Get cookieClickId & pId
  if (cpId) {
    if (clId) {
      pId = getCookieValues('p-' + cpId + clId)[0];
    } else {
      pId = getCookieValues('p-' + cpId)[0];
      let pmClick = getCookieValues('pm_click')[0];
      if (pmClick) {
        let jsonPMClick = JSON.parse(pmClick);
        let campaign = jsonPMClick.campaign;
        let click = jsonPMClick.click;
        if (campaign === cpId) {
          cookieClickId = click;
        }
      }
    }
  }

  // Get cep
  let cep = getCookieValues('pm_cep_o')[0];
  if (cep && !cpId) {
    let delimiter = currentUrl.indexOf('?') > -1 ? '&' : '?';
    currentUrl += delimiter + 'pm_cep=' + cep;
    pId = cep;
  } else if (cookieClickId) {
    var delimiter = currentUrl.indexOf('?') > -1 ? '&' : '?';
    currentUrl += delimiter + 'pm_click_id=' + cookieClickId;
  }

  if (!cpId && !cep) {
    return;
  }

  var sscMatch = getCookieValues('pm_ss_o')[0];
  if (pId && sscMatch) {
    var fillParams = getCookieValues('pm_q')[0];
    callInWindow('pmReplaceUrl', cep, fillParams, (data) => {
      if (data) {
        setFillParamsCookie(currentUrlObj.host, isSecure, data);
      }
    });
    return;
  } else {
    setCookie('pm_ss_o', '1', {
      'domain': currentUrlObj.host,
      'path': '/',
      'max-age': SESSION_CLICK,
      'secure': isSecure
    });
  }

  let referrer = getReferrerUrl('queryParams');
  let cdnScript = SCRIPT_URL + '?ref=' + encodeUriComponent(referrer) + '&location=o&url=' + encodeUriComponent(currentUrl) + '&time=' + getTimestampMillis();
  if (pId) {
    cdnScript += '&cid=no';
  }

  var fillParamData = getCookieValues('pm_q')[0];
  callInWindow('pmSendPixel', cdnScript, fillParamData, (data) => {
    if (data) {
      setPmOCookie(currentUrlObj.host, isSecure, data);
    }
  }, (data) => {
    if (data) {
      setFillParamsCookie(currentUrlObj.host, isSecure, data);
    }
  });

  if (cpId) {
    if (clId) {
      setCookie('p-' + cpId + clId, '1', {
        'domain': currentUrlObj.host,
        'path': '/',
        'max-age': COOKIES_EXPIRES,
        'secure': isSecure
      });
    } else {
      setCookie('p-' + cpId, '1', {
        'domain': currentUrlObj.host,
        'path': '/',
        'max-age': COOKIES_EXPIRES,
        'secure': isSecure
      });
    }
  }
}

processData();

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_referrer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "pmSendPixel"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "pmReplaceUrl"
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Quick Test
  code: runCode();
setup: ''


___NOTES___

Created on 12/6/2024, 10:45:23 AM



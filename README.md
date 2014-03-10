
__Documentation Status__: Incomplete; look at code and/or unit tests for the moment.

[![Build Status](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL.png?branch=master)](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL)

An Objective-C implementation of the [JSON Hypertext Application Language](http://tools.ietf.org/html/draft-kelly-json-hal-05) Internet-Draft.

# Installation

[CocoaPods](http://cocoapods.org/) is the easiest way to use ObjectiveHAL.

    platform :ios, '6.1'
    pod 'ObjectiveHAL'

# Examples

ObjectiveHAL depends on the AFNetworking library for network operations. 
Specifically, the user of ObjectiveHAL is expected to construct an 
AFHTTPClient and pass a pointer to it when creating any link traversal 
operation.

The examples are all based on the following HAL document:

```
{
  "_links": {
    "curies": [
      {
        "href": "http://tempuri.org/rels/{rel}",
        "name": "r",
        "templated": "true"
      },
      {
        "href": "http://tempuri.org/rels/app/{rel}",
        "name": "app",
        "templated": "true"
      },
      {
        "href": "http://tempuri.org/rels/asset/{rel}",
        "name": "asset",
        "templated": "true"
      }
    ],
    "self": {
      "href": "/app/2"
    },
    "app:icon": {
      "href": "/icon/2"
    }
  },
  "_embedded": {
    "app:icon": {
      "_links": {
        "self": {
          "href": "/icon/2"
        },
        "asset:small_image": {
          "href": "/images/i310.png"
        },
        "asset:large_image": {
          "href": "/images/i223.png"
        }
      }
    }
  },
  "name": "High Altitude Survival (resource)",
  "synopsis": "A series of short films that illustrate some of the dangers inherent in high altitude mountainering and discuss life-saving survival techniques."
}
```

## Creating a HAL resource from some JSON

    // Fetch JSON somehow.
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

	// Construct HAL resource.
    OHResource *resource = [OHResource resourceWithJSONData:json];
    
## Accessing Resource Properties

more to come....
    


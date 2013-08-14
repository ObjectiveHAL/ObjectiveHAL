ObjectiveHAL
============

[![Build Status](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL.png?branch=master)](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL)

An Objective-C implementation of the [JSON Hypertext Application Language](http://tools.ietf.org/html/draft-kelly-json-hal-05) Internet-Draft.

Example usage:

    CSURITemplate *template = [[CSURITemplate alloc] initWithURITemplate:@"{?list*}"];
    NSDictionary *variables = @{@"list": @[@"red", @"green", @"blue"]};
    NSString *uri = [template URIWithVariables:variables];
    assert([uri isEqualToString:@"?list=red&list=green&list=blue"]);

Installation
------------

[CocoaPods](http://cocoapods.org/) is the easiest way to use ObjectiveHAL.

    platform :ios, '6.1'
    pod 'ObjectiveHAL'

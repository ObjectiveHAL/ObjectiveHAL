ObjectiveHAL
============

[![Build Status](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL.png?branch=master)](https://travis-ci.org/ObjectiveHAL/ObjectiveHAL)

An Objective-C implementation of the [JSON Hypertext Application Language](http://tools.ietf.org/html/draft-kelly-json-hal-05) Internet-Draft.

Installation
------------

[CocoaPods](http://cocoapods.org/) is the easiest way to use ObjectiveHAL.

    platform :ios, '6.1'
    pod 'ObjectiveHAL'

Examples
--------

The workhorse of ObjectiveHAL is the OHClient class. This class derives from the
AFClient class (part of AFNetworking). To get started with ObjectiveHAL you need
to instantiate the OHClient like this:

    baseURL = [NSURL URLWithString:@"http://localhost:7100"];
    client = [OHClient clientWithBaseURL:baseURL];
    
Once you have a client you can query for the top-level (root) resource on the server.
This will return an instance of OHResource.

    [client fetchRootObjectFromPath:@"/api/v1"];
    
    
---
layout: index
---

[![Build Status](https://travis-ci.org/Shopify/splunk-auth-proxy.png?branch=master)](https://travis-ci.org/Shopify/splunk-auth-proxy)

Splunk single sign-on proxy for Google Apps OpenID authentication

## Usage

	git clone https://github.com/Shopify/splunk-auth-proxy.git
	cd splunk-auth-proxy
	npm install

	coffee server.coffee <config.json>

### Pre-requisites

* [nodejs](http://nodejs.org/)
* [npm](http://npmjs.org/)

### Splunk SSO configuration

server.conf

	[general]
	trustedIP = 127.0.0.1

web.conf

	[settings]
	enableSplunkWebSSL = 0
	trustedIP = 127.0.0.1
	SSOMode = strict
	remoteUser = Remote-User

## Contributing

Fork, branch & pull request.

## License

Copyright (c) 2011 Shopify. Released under the [MIT-LICENSE](http://opensource.org/licenses/MIT).
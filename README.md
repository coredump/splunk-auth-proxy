# splunk-auth-proxy

Splunk single sign-on proxy for Google Apps OpenID authentication

## Usage

###pre-requisites
nodejs (http://nodejs.org/)

npm (http://npmjs.org/)

````
git clone git@github.com:Shopify/splunk-auth-proxy.git
cd splunk-auth-proxy
npm install

coffee server.coffee <config.json>
````

###splunk SSO configuration

server.conf

````
[general]
trustedIP = 127.0.0.1
````

web.conf

````
[settings]
enableSplunkWebSSL = 0
trustedIP = 127.0.0.1
SSOMode = strict
remoteUser = Remote-User
````
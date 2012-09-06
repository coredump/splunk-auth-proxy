# splunk-auth-proxy

Splunk single sign-on proxy for Google Apps OpenID authentication

## Usage

###pre-requisites
nodejs (http://nodejs.org/)

npm (http://npmjs.org/)

````
git clone https://github.com/Shopify/splunk-auth-proxy.git
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
##Contributing
1.Fork  
2.Branch  
3.Pull Request  

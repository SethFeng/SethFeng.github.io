# HTTPS证书配置

## 客户端(https://www.jianshu.com/p/64172ccfb73b)
生成客户端证书
```
keytool -genkeypair -alias client -keyalg RSA -validity 3650 -keypass 123456 -storepass 123456 -keystore client.jks
```
```

What is your first and last name?
  [Unknown]:  A Tom
What is the name of your organizational unit?
  [Unknown]:  Tomu
What is the name of your organization?
  [Unknown]:  Tomo
What is the name of your City or Locality?
  [Unknown]:  Shanghai
What is the name of your State or Province?
  [Unknown]:  SH
What is the two-letter country code for this unit?
  [Unknown]:  CN
Is CN=A Tom, OU=Tomu, O=Tomo, L=Shanghai, ST=SH, C=CN correct?
  [no]:  yes

```
查看证书内容
```
keytool -list -keystore client.jks -storepass 123456
```
```

Keystore type: JKS
Keystore provider: SUN

Your keystore contains 1 entry

client, Jan 15, 2019, PrivateKeyEntry,
Certificate fingerprint (SHA1): 17:B8:22:9F:E3:A7:F3:F7:BA:1C:93:2B:DA:31:EE:A7:4C:32:A7:19
```


```
keytool -genkeypair -alias server -keyalg RSA -validity 3650 -keypass 123456 -storepass 123456 -keystore server.keystore
```

```
What is your first and last name?
  [Unknown]:  A Tom
What is the name of your organizational unit?
  [Unknown]:  Tomu
What is the name of your organization?
  [Unknown]:  Tomo
What is the name of your City or Locality?
  [Unknown]:  Beijing
What is the name of your State or Province?
  [Unknown]:  BJ
What is the two-letter country code for this unit?
  [Unknown]:  CN
Is CN=A Tom, OU=Tomu, O=Tomo, L=Beijing, ST=BJ, C=CN correct?
  [no]:  yes
```

查看内容
```
keytool -list -keystore server.keystore -storepass 123456
```

```
Keystore type: JKS
Keystore provider: SUN

Your keystore contains 1 entry

server, Jan 15, 2019, PrivateKeyEntry,
Certificate fingerprint (SHA1): 2B:CA:05:05:6A:05:68:37:71:FF:82:AD:86:66:91:48:94:B5:10:B9
```

keytool -export -alias client -file client.cer -keystore client.jks -storepass 123456

keytool -export -alias server -file server.cer -keystore server.keystore -storepass 123456

将客户端证书导入服务端keystore中，再将服务端证书导入客户端keystore中， 一个keystore可以导入多个证书，生成证书列表。
生成客户端信任证书库(由服务端证书生成的证书库)：
    keytool -import -v -alias server -file server.cer -keystore truststore.jks -storepass 123456 
将客户端证书导入到服务器证书库(使得服务器信任客户端证书)：
    keytool -import -v -alias client -file client.cer -keystore server.keystore -storepass 123456

运行protecle.jar将client.jks和truststore.jks分别转换成client.bks和truststore.bks

客户端：client.bks、truststore.bks
服务端：server.keystore

tomcat server.xml:
keystoreFile="${catalina.base}/key/server.keystore" keystorePass="123456"
           truststoreFile="${catalina.base}/key/server.keystore" truststorePass="123456"









# 手动转base 64编码的pem到jks
base 64: OpenSSL: PEM


pem -> p12
cat android_cert.pem android_key.pem > android.pem
openssl pkcs12 -export -in android.pem -out android.p12
openssl pkcs12 -in android.p12 -nocerts -nodes

p12 -> jks
keytool -importkeystore -srckeystore android.p12 -srcstoretype pkcs12 -destkeystore android.jks



pem -> jks
keytool -importcert -file root2.pem -keystore root2.jks -alias "server"


p12 -> pem
openssl pkcs12 -in path.p12 -out newfile.crt.pem -clcerts -nokeys
openssl pkcs12 -in path.p12 -out newfile.key.pem -nocerts -nodes
openssl pkcs12 -in path.p12 -out newfile.pem

查看pem中加密私钥(BEGIN PRIVATE KEY -> BEGIN RSA PRIVATE KEY)：
openssl rsa -in protected.key -out unprotected.key


Base64编码的证书：
```
-----BEGIN CERTIFICATE-----
IjCCBMowggQzoAMCAQICEAlLTA9Y1WjWPxvngISRWxQwDQYJKoZIhvcNAQEEBQAw
gcwxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBU
cnVzdCBOZXR3b3JrMUYwRAYDVQQLEz13d3cudmVyaXNpZ24uY29tL3JlcG9zaXRv
cnkvUlBBIEluY29ycC4gQnkgUmVmLixMSUFCLkxURChjKTk4MUgwRgYDVQQDEz9W
C2CGSAGG+EUBBwEBMIAwKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LnZlcmlzaWdu
LmNvbS9DUFMwYgYIKwYBBQUHAgIwVjAVFg5WZXJpU2lnbiwgSW5jLjADAgEBGj1W
ZXJpU2lnbidzIENQUyBpbmNvcnAuIGJ5IHJlZmVyZW5jZSBsaWFiLiBsdGQuIChj
KTk3IFZlcmlTaWduAAAAAAAAMBEGCWCGSAGG+EIBAQQEAwIHgDCBhgYKYIZIAYb4
RQEGAwR4FnZkNDY1MmJkNjNmMjA0NzAyOTI5ODc2M2M5ZDJmMjc1MDY5YzczNTli
ZWQxYjA1OWRhNzViYzRiYzk3MDE3NDdkYTVkM2YyMTQxYmVhZGIyYmQyZTg5MjFm
YTU2YmY0ZDQxMTQ5OTdhM2I4NDNmNGU1OTI2NTQxMA0GCSqGSIb3DQEBBAUAA4GB
AInZL/R7kMLBcunvA2KRxe+BE2i58wQBrlhtBk5kQ3oYSUsyjfEV3JiH/aBjC8QL
NYx0vBUt2bcYTZtmPLlhepbBiNi8X/Ke+Pf8c4RVYDs43a7SDw3fmo1BAkPD1BeG
ES9KTr3VCeTcoLZTfB5ZCERqVMoriTB7jzCUMItNvoe3Ig0K
-----END CERTIFICATE-----
```
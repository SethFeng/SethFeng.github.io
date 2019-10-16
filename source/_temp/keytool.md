keytool

生成keystore
keytool -genkey -alias feng.keystore -keyalg RSA -validity 20000 -keystore feng.keystore
输入密码：fengshenzhu

The JKS keystore uses a proprietary format. It is recommended to migrate to PKCS12 which is an industry standard format using "keytool -importkeystore -srckeystore feng.keystore -destkeystore feng.keystore -deststoretype pkcs12".
keytool -importkeystore -srckeystore feng.keystore -destkeystore feng.keystore -deststoretype pkcs12

keytool -list -v -keystore feng.keystore -storepass fengshenzhu






redex --sign -s feng.keystore -a feng.keystore -p fengshenzhu -c /Users/admin/Projects/AndroidAdvanceWithGeektime/Chapter22/redex-test/stripdebuginfo.config -P app/proguard-rules.pro  -o app/build/outputs/apk/dev/release/strip_app-dev-release.apk app/build/outputs/apk/dev/release/app-dev-release.apk

redex --sign -s feng.keystore -a feng.keystore -p fengshenzhu -c /Users/admin/Projects/AndroidAdvanceWithGeektime/Chapter22/redex-test/interdex.config -P app/proguard-rules.pro  -o app/build/outputs/apk/dev/release/interdex_app-dev-release.apk app/build/outputs/apk/dev/release/app-dev-release.apk
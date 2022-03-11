# Android xml Inflate

Activity#setContentView
PhoneWindow#setContentView
LayoutInflater#inflate
XmlResourceParser 
	Resources.getLayout(resource)
	ResourceImpl#getValue
	AssetManager.getResourceValue
	AssetManager.openXmlBlockAsset
	AssetManager.openXmlAssetNative
	new XmlBlock$Parser
	AttributeSet attrs = Xml.asAttributeSet(parser)
	LayoutInflater#createViewFromTag



# PMS
PackeageManagerService$PackageHandler(ServiceThread)

PackageHandler$mPendingInstalls ArrayList<HandlerParams> 

InstallParams{8cbd456 file=/data/app/vmdl168996074.tmp cid=null}

/data/app/vmdl168996074.tmp/base.apk



adb install msg
INIT_COPY
MCS_BOUND
START_INTENT_FILTER_VERIFICATIONS
WRITE_PACKAGE_RESTRICTIONS
POST_INSTALL
MCS_UNBIND


adb uninstall msg
START_CLEANING_PACKAGE


AMS



提现
登录获取access_token https://oauth2-api.1sapp.com/qapptoken

获取bind info https://openapi.1sapp.com/withdraw/getBindInfo
获取商品列表 https://kanduoduo.redianduanzi.com/coin/pay/index
获取中台商品sku列表 https://openapi.1sapp.com/withdraw/sku/list



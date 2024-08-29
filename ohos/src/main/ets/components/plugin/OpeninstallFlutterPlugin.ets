import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import { OpData, OpenInstall } from '@openinstall/sdk'
import { HashMap } from '@kit.ArkTS';

/** OpeninstallFlutterPlugin **/
export default class OpeninstallFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context = getContext(this) as common.UIAbilityContext

  constructor() {
  }

  getUniqueClassName(): string {
    return "OpeninstallFlutterPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "openinstall_flutter_plugin");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("OpenHarmony ^ ^ ")
    } else if (call.method == "init") {
      console.log('openInstall.init')
      OpenInstall.init(this.context)
      result.success("success")
    } else if (call.method == "getInstall") {
      console.log('openInstall.getInstall')
      OpenInstall.getInstall({
        onResult: result => {
          let data = JSON.stringify(result)
          console.log("OpenInstall", "getInstall data: " + data + " result:" + result)
          this.callbackFlutter("onInstallNotification", result)
        },
        onError: err => {
          console.log("OpenInstall", "getInstall onError : " + JSON.stringify(err));
        }
      })
      result.success("success")
    } else {
      result.notImplemented()
    }
  }

  /**
   * 回调flutter
   */
  callbackFlutter(method: string, data: OpData): void {
    console.log("OpenInstall", "callbackFlutter method: " + method + " OpData:" + OpData)
    this.channel?.invokeMethod(method, this.data2Map(data));
  }

  /**
   * 跳转参数转为map
   */
  data2Map(data: OpData): HashMap<String, String> {
    let result = new HashMap<String, String>()
    result.set("channelCode", data.channelCode)
    result.set("bindData", data.bindData)
    console.log("OpenInstall", "data2Map channelCode: " + data.channelCode + " bindData:" + data.bindData)
    return result;
  }
}
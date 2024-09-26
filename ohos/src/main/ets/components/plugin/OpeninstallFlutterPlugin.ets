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
  private tag: string = 'fb-ohos-openInstall'

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
      console.log(this.tag, 'openInstall.init')
      let c = getContext(this) as common.UIAbilityContext
      OpenInstall.init(c)
      console.log(this.tag, 'openInstall.init - end')
      result.success("success")
    } else if (call.method == "getInstall") {
      console.log(this.tag, 'openInstall.getInstall')
      OpenInstall.getInstall({
        onResult: result => {
          let data = JSON.stringify(result)
          console.log(this.tag, "getInstall data: " + data + " result:" + result)
          this.callbackFlutter("onInstallNotification", result)
        },
        onError: err => {
          console.log(this.tag, "getInstall onError : " + JSON.stringify(err));
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
    console.log(this.tag, "callbackFlutter --> method: " + method)
    this.channel?.invokeMethod(method, this.data2Map(data))
  }

  /**
   * 跳转参数转为map
   */
  data2Map(data: OpData): HashMap<String, String> {
    let result = new HashMap<String, String>()
    result.set("channelCode", data.channelCode ?? '')
    result.set("bindData", JSON.stringify(data.bindData))
    console.log(this.tag, "data2Map bindData:" + JSON.stringify(data.bindData))
    return result;
  }
}
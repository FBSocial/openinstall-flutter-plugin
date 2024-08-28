import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import common from '@ohos.app.ability.common';
import { OpenInstall } from '@openinstall/sdk'

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
      console.log('openInstall.init -- start')
      OpenInstall.init(this.context)
      console.log('openInstall.init -- end')
      result.success("success")
    } else {
      result.notImplemented()
    }
  }
}
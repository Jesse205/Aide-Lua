# Aide Lua
[![QQ](https://img.shields.io/badge/Join-QQ_Group-ff69b4)](https://jq.qq.com/?_wv=1027&k=41q8mp8y)
![icon](https://gitee.com/Jesse205/AideLua/raw/master/ic_cover-aidelua.png)

## 简介
Aide Lua 是一款依赖 Aide 的 Lua 编辑器

## 下载
[〖Aide 高级设置版〗](https://www.lanzouy.com/b00zdhbeb)

1. [Gitee下载(推荐，快速下载)](https://gitee.com/Jesse205/AideLua/releases)

2. [天翼云盘(可能更新不及时)](https://cloud.189.cn/t/ZZ7RzijyqiUv)

3. [腾讯微云(可能更新不及时)](https://share.weiyun.com/oLiNtxMR)

4. [百度网盘(可能今天下不完)](https://pan.baidu.com/s/1j1RwisPR8iq1fPS3O_fl7Q)，密码jxnb

5. [123云盘(可能更新不及时)](https://www.123pan.com/s/G7a9-Yzck)

## 使用须知
1. 本软件默认开启自动保存代码且无法关闭（自动保存触发条件：切换到其他应用、点击二次打包以及打包运行、打开其他文件、关闭文件、打开侧滑（大屏除外）、点击标签栏等）

2. 此软件不能用来开发大型项目

3. 此软件必须搭配编译器，不管你用的是真正的Gradle还是仿Gradle（AIDE属于仿Gradle）

## 使用教程
[视频教程](https://b23.tv/nvVHoa)

### 一、配置AIDE
  1. 进入“设置-高级设置-工程相关”

  2. 关闭“启用alert调试文件”，打开“重定义Apk构建路径”

  3. 重启AIDE

### 二、初次打包
  1. 在AideLua点击新建项目，在填写与选择完成后点击“新建”

  2. 用AIDE打开项目，点击“构建刷新”

  3. 点击AideLua的“打包运行”按钮（或“二次打包”，手动签名）并安装，测试是否可以正常打包

  4. 点击AideLua的“运行”按钮，测试是否正常通过已安装的应用调试

## 注意事项
1. AIDE必须使用AIDE高级设置版本，否则无法打开重定义Apk路径

2. AIDE必须打开重定义Apk路径，否则会导致APK混乱

3. AIDE最好关闭adrt调试文件

4. 不是必须用AIDE编译，只不过用AIDE编译会更好一些

## [引用的开源](https://gitee.com/Jesse205/AideLua/blob/master/app/src/main/luaLibs/openSourceLicenses.aly)

## 高级玩法
.aidelua/config.lua用法
| 键(key) | 类型 | 推荐值（[...]为已省略或自定义的内容） | 默认值 | 说明 |
| ---- | ---- | ---- | ---- | ---- |
| tool | table | {[...]} | {} | 二次打包工具信息 |
| tool.version | string | "1.1" | "1.0" | 二次打包工具的版本号 |
| appName | string | / | / | 应用名（仅供AideLua显示） |
| packageName | string | / | / | 应用包名（仅供AideLua显示和更好的调试） |
| debugActivity | string | / | "com.androlua.LuaActivity" | 调试的Activity名(不是标签)（仅供AideLua更好的调试） |
| include | table | {"project:app",[...]"project:androlua"} | / | 要编译lua的库，第一个为主程序 |
| main (已废除) | string | "app" | "app" | 主程序（仅1.0版本） |
| compileLua | boolean | true | true | 编译Lua |
| icon | table/string | {[...]} | / (智能判断) | 项目图标配置（仅供AideLua显示，相对路径为项目路径） |
| icon.day | string | "ic_launcher-aidelua.png" | / (智能判断) | 亮色模式图标 |
| icon.night | string | "ic_launcher_night-aidelua.png" | / (智能判断) | 深色模式图标 |


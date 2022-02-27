appInfo={
  {
    name=R.string.app_name,
    message="依赖Aide的一款Lua编辑器",
    icon=R.mipmap.ic_launcher,
    click=function()
      openUrl("https://gitee.com/Jesse205/AideLua")
    end,
  },
  {
    name=R.string.windmill,
    message="为极客和程序员等打造，重认手机上的工具",
    icon=R.drawable.ic_windmill,
    click=function()
      openUrl("https://www.coolapk.com/apk/com.agyer.windmill")
    end,
  },
}

--开发者们
developers={
  {
    name="Eddie",
    qq=2140125724,
    message="AideLua 开发者",
  },
  {
    name="xiaoyi",
    qq=2821981550,
    message="快乐程序 运营者",
  },
}

--启用开源许可
openSourceLicenses=true

--单个QQ群
--qqGroup=708199076

--多个QQ群
qqGroups={
  {
    name="Aide Lua Bug测试群",
    id=680850455,
  },
  {
    name="Aide Lua 尝鲜群",
    id=628045718,
  },
  {
    name="Edde 综合群",
    id=708199076,
  },
}
--[[格式：
{
  {
    name="群名称",--群名称
    id=708199076,--群号
  },
  {
    name="群名称",--群名称
    id=708199076,--群号
  },
  --以此类推
}
]]

--支持项目
--supportUrl="https://afdian.net/@Jesse205"--支持项目链接
supportNewPage=false--支持项目页面跳转标识
supportList={--如果有多种方式支持项目，可以使用列表
  {
    name="问题反馈",
    url="https://gitee.com/Jesse205/AideLua/issues",
  },
  {
    name="参与开发",
    url="https://gitee.com/Jesse205/AideLua",
  },
  {
    name="资金支持",
    func=function(view)
      print("暂不支持")
    end,
  },
}
--[[格式：
{
  {
    name="百度",--显示的名称
    url="http://www.baidu.com"--跳转链接
    func=function(view)--函数（不可和url共存）
    end,
  },
  {
    name="百度",--显示的名称
    url="http://www.baidu.com"--跳转链接
    func=function(view)--函数（不可和url共存）
    end,
  },
  --以此类推
}
]]

--版权信息
--copyright="No Copyright"

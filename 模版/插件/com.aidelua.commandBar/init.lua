appname="命令栏示例"--插件名
packagename="com.aidelua.commandBar"--插件包名
appver="1.0"
appcode=1
mineditorcode=41499--最低编辑器版本号
targeteditorcode=41499--目标编辑器版本号
mode="plugin"--模式：插件
events={--事件
  --activityName：页面名称
  onCreate=function(activityName,savedInstanceState)
    if activityName=="main" then--主页
      appBarLinearLayout.addView(loadlayout2({
        LinearLayoutCompat;
        layout_width="fill";
        {
          Button;
          text="二次打包";
          onClick=function()
            if binMenu then--存在这个菜单
              if binMenu.isEnabled() then--菜单已启用
                onOptionsItemSelected(binMenu)--点击菜单
              end
            end
          end;
        }
      }),0)
    end
  end,
}
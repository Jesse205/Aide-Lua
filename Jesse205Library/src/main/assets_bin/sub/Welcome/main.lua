require "import"
useCustomAppToolbar=true
import "Jesse205"
import "android.content.pm.PackageManager"
import "android.text.Html"

import "com.Jesse205.layout.util.SettingsLayUtil"
import "com.Jesse205.widget.AutoToolbarLayout"

import "welcome"
import "agreements"

function buildTitlebar(icon,text)
  return {--设置项(图片,标题)
    CardView;
    layout_width="fill";
    radius=0;
    id="topCard";
    backgroundColor=theme.color.windowBackground;
    {
      LinearLayout;
      layout_width="fill";
      layout_height="fill";
      gravity="center";
      {
        ImageView,
        layout_margin="16dp",
        layout_width="24dp",
        layout_height="24dp",
        imageResource=icon;
        colorFilter=theme.color.colorAccent,
      },
      {
        TextView;
        textSize="16sp";
        textColor=theme.color.textColorPrimary;
        layout_weight=1;
        layout_margin="16dp";
        text=text;
        typeface=Typeface.defaultFromStyle(Typeface.BOLD);
      };
    };
  }
end

function MyPageView()
  local lastX=0
  return luajava.override(PageView,{
    onInterceptTouchEvent=function(super,event)
      if event.getAction()==MotionEvent.ACTION_DOWN then
        lastX=event.getRawX()
      end
      return super(event)
    end,
    onTouchEvent=function(super,event)
      if lastX-event.getRawX()>0 then
        if NowPage and NowPage.allowNext==false then
          --return false
          --return lastEvent
          event.setAction(MotionEvent.ACTION_CANCEL)
        end
      end

      return super(event)
    end
  })
end

--import "pages.welcomePage"
import "pages.agreementPage"
import "pages.permissionPage"

activity.setTitle(R.string.Jesse205_welcome)
activity.setContentView(loadlayout2("layout"))

toolbar=activity.findViewById(R.id.toolbar)
activity.setSupportActionBar(toolbar)
actionBar=activity.getSupportActionBar()
--actionBar.setDisplayHomeAsUpEnabled(true)

ScreenFixContent={
  layoutManagers={},
  orientation={
    identical={mainLay2},
    --different={buttonBar},
  },
  fillParentViews={buttonBar},
}

--NowPage=welcomePage
pages={}

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    --activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
  if config.orientation==Configuration.ORIENTATION_LANDSCAPE then--横屏时
    local linearParams=previousButton.getLayoutParams()
    linearParams.width=math.dp2int(64)
    linearParams.gravity=Gravity.TOP|Gravity.CENTER
    previousButton.setLayoutParams(linearParams)
    local linearParams=nextButton.getLayoutParams()
    linearParams.width=math.dp2int(64)
    linearParams.gravity=Gravity.BOTTOM|Gravity.CENTER
    nextButton.setLayoutParams(linearParams)
   else
    local linearParams=previousButton.getLayoutParams()
    linearParams.width=math.dp2int(64)
    linearParams.gravity=Gravity.LEFT|Gravity.CENTER
    previousButton.setLayoutParams(linearParams)
    local linearParams=nextButton.getLayoutParams()
    linearParams.width=math.dp2int(64)
    linearParams.gravity=Gravity.RIGHT|Gravity.CENTER
    nextButton.setLayoutParams(linearParams)
  end
  for index,content in ipairs(pages) do
    if content.onConfigurationChanged then
      content:onConfigurationChanged(config)
    end
  end
end

function onKeyUp(KeyCode,event)
  if KeyCode==KeyEvent.KEYCODE_BACK then
    local nowPage=pageView.getCurrentItem()
    if nowPage>0 then
      pageView.showPage(nowPage-1)
      return true
    end
  end
end

function refreshBottomBarState()
  local config=activity.getResources().getConfiguration()
  local isLandscape=config.orientation==Configuration.ORIENTATION_LANDSCAPE
  if previousButton.getVisibility()==View.GONE and nextButton.getVisibility()==View.GONE then
    local linearParams=buttonBar.getLayoutParams()
    if isLandscape then
      linearParams.width=0
     else
      linearParams.height=0
    end
    buttonBar.setLayoutParams(linearParams)
   else
    local linearParams=buttonBar.getLayoutParams()
    if isLandscape then
      linearParams.width=-2
     else
      linearParams.height=-2
    end
    buttonBar.setLayoutParams(linearParams)
  end
end

for index,content in ipairs(agreements) do
  table.insert(pages,agreementPage(content.title,content.icon,content.name,content.date))
end

table.insert(pages,permissionPage)
NowPage=pages[1]

maxPage=table.size(pages)
progressBar.setMax((maxPage)*1000)

adp=ArrayPageAdapter()

for index,content in ipairs(pages) do
  adp.add(loadlayout2(content.layout,content))
  if content.onInitLayout then
    content:onInitLayout()
  end
end

pageView.setAdapter(adp)

pageView.setOnPageChangeListener(PageView.OnPageChangeListener{
  onPageScrolled=function(arg0,arg1,arg2)
    progressBar.setProgress((arg0+arg1+1)*1000)
  end,
  onPageChange=function(view,page)
    local nowPage=pages[page+1]
    NowPage=nowPage
    if page+1==maxPage then
      nextButton.setText(R.string.Jesse205_step_finish)
     else
      nextButton.setText(R.string.Jesse205_step_next)
    end
    if page==0 then
      previousButton.setClickable(false)
      previousButton.setVisibility(View.GONE)
     else
      previousButton.setClickable(true)
      previousButton.setVisibility(View.VISIBLE)
    end
    if nowPage.allowNext==false then
      nextButton.setClickable(false)
      nextButton.setVisibility(View.GONE)
     else
      nextButton.setClickable(true)
      nextButton.setVisibility(View.VISIBLE)
    end
    refreshBottomBarState()
    actionBar.setTitle(nowPage.title)
  end
})

previousButton.onClick=function()
  local nowPage=pageView.getCurrentItem()
  if nowPage>0 then
    pageView.showPage(nowPage-1)
  end
end
nextButton.onClick=function()
  local nowPage=pageView.getCurrentItem()+1
  if nowPage<maxPage then
    pageView.showPage(nowPage)
   elseif nowPage==maxPage then
    setSharedData("welcome",true)
    newActivity("../../main")
    activity.finish()
  end
end

screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder(ScreenFixContent)

onConfigurationChanged(activity.getResources().getConfiguration())


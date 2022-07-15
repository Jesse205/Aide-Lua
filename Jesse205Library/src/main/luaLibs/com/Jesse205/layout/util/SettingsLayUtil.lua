local SettingsLayUtil={}
import "com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions"

SettingsLayUtil.TITLE=1
SettingsLayUtil.ITEM=2
SettingsLayUtil.ITEM_NOSUMMARY=3
SettingsLayUtil.ITEM_SWITCH=4
SettingsLayUtil.ITEM_SWITCH_NOSUMMARY=5
SettingsLayUtil.ITEM_AVATAR=6
SettingsLayUtil.ITEM_AVATAR_NOSUMMARY=7
SettingsLayUtil.ITEM_ONLYSUMMARY=8

local colorAccent=theme.color.colorAccent
local textColorPrimary=theme.color.textColorPrimary
local textColorSecondary=theme.color.textColorSecondary

local newPageIconLay={
  AppCompatImageView;
  id="rightIcon";
  layout_margin="16dp";
  layout_marginLeft=0;
  layout_width="24dp";
  layout_height="24dp";
  colorFilter=textColorSecondary;
};

local itemsLay={
  {--标题
    LinearLayoutCompat;
    layout_width="fill";
    orientation="vertical";
    layout_height="40dp";
    gravity="bottom";
    focusable=false;
    {
      AppCompatTextView;
      id="title";
      textSize="14sp";
      typeface=Typeface.defaultFromStyle(Typeface.BOLD);
      textColor=colorAccent;
      layout_marginLeft="16dp";
      layout_marginRight="16dp";
      layout_marginBottom="8dp";
    };
  };

  {--设置项(图片,标题,简介)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    {
      AppCompatImageView,
      id="icon",
      layout_margin="16dp",
      layout_width="24dp",
      layout_height="24dp",
      colorFilter=colorAccent,
    },
    {
      LinearLayoutCompat;
      orientation="vertical";
      gravity="center";
      layout_weight=1;
      layout_margin="16dp";
      {
        AppCompatTextView;
        id="title";
        textSize="16sp";
        layout_width="fill";
        textColor=textColorPrimary;
      };
      {
        AppCompatTextView;
        textSize="14sp";
        id="summary";
        layout_width="fill";
      };
    };
    newPageIconLay;
  };

  {--设置项(图片,标题)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    {
      AppCompatImageView;
      id="icon";
      layout_margin="16dp";
      layout_width="24dp";
      layout_height="24dp";
      colorFilter=colorAccent;
    };
    {
      AppCompatTextView;
      id="title";
      textSize="16sp";
      textColor=textColorPrimary;
      layout_weight=1;
      layout_margin="16dp";
    };
    newPageIconLay;
  };


  {--设置项(图片,标题,简介,开关)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=true;
    --layout_height="72dp";
    {
      AppCompatImageView,
      id="icon",
      layout_margin="16dp",
      layout_marginLeft="16dp",
      layout_width="24dp",
      layout_height="24dp",
      colorFilter=colorAccent,
    },
    {
      LinearLayoutCompat;
      orientation="vertical";
      gravity="center";
      layout_weight=1;
      layout_margin="16dp";
      {
        AppCompatTextView;
        textSize="16sp";
        textColor=textColorPrimary;
        id="title";
        layout_width="fill";
      };
      {
        AppCompatTextView;
        layout_width="fill";
        textSize="14sp";
        id="summary";
      };
    };
    {
      SwitchCompat;
      focusable=false;
      clickable=false;
      layout_marginRight="16dp";
      id="status";
    };
  };


  {--设置项(图片,标题,开关)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=true;
    {
      AppCompatImageView,
      id="icon",
      layout_margin="16dp",
      layout_width="24dp",
      layout_height="24dp",
      colorFilter=colorAccent,
    },
    {
      AppCompatTextView;
      id="title";
      textSize="16sp";
      layout_weight=1;
      layout_margin="16dp";
      textColor=textColorPrimary;
    };
    {
      SwitchCompat;
      id="status";
      focusable=false;
      clickable=false;
      layout_marginRight="16dp";
    };
  };

  {--设置项(头像,标题,简介)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    {
      MaterialCardView;
      layout_height="40dp";
      layout_width="40dp";
      layout_margin="16dp";
      radius="20dp";
      {
        CardView;
        layout_height="fill";
        layout_width="fill";
        radius="18dp";
        {
          AppCompatImageView;
          layout_height="fill";
          layout_width="fill";
          id="icon";
        };
      };
    };
    {
      LinearLayoutCompat;
      orientation="vertical";
      gravity="center";
      layout_margin="16dp";
      layout_weight=1;
      layout_marginLeft=0;
      {
        AppCompatTextView;
        id="title";
        textSize="16sp";
        layout_width="fill";
        textColor=textColorPrimary;
      };
      {
        AppCompatTextView;
        id="summary";
        textSize="14sp";
        layout_width="fill";
      };
    };
    newPageIconLay;
  };

  {--设置项(头像,标题)
    LinearLayoutCompat;
    layout_width="fill";
    gravity="center";
    focusable=true;
    {
      MaterialCardView;
      layout_height="40dp";
      layout_width="40dp";
      layout_margin="16dp";
      radius="20dp";
      {
        CardView;
        layout_height="fill";
        layout_width="fill";
        radius="18dp";
        {
          AppCompatImageView;
          layout_height="fill";
          layout_width="fill";
          id="icon";
        };
      };
    };
    {
      AppCompatTextView;
      id="title";
      textSize="16sp";
      layout_weight=1;
      textColor=textColorPrimary;
      layout_margin="16dp";
      layout_marginLeft=0;
    };
    newPageIconLay;
  };

  {--设置项(简介)
    LinearLayoutCompat;
    gravity="center";
    layout_width="fill";
    focusable=false;
    {
      AppCompatTextView;
      layout_weight=1;
      layout_marginLeft="72dp",
      layout_margin="16dp";
      layout_width="fill";
      textSize="14sp";
      id="summary";
    };
  };
}
SettingsLayUtil.itemsLay=itemsLay

local function setAlpha(views,alpha)
  for index,content in pairs(views) do
    if content then
      content.setAlpha(alpha)
    end
  end
end
SettingsLayUtil.setAlpha=setAlpha

function SettingsLayUtil.newAdapter(data,onItemClick,onItemLongClick)
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      return #data
    end,
    getItemViewType=function(position)
      return data[position+1][1]
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(itemsLay[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      if viewType~=1 then
        view.setFocusable(true)
        view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
        view.onClick=function(view)
          local data=ids._data
          local key=data.key
          if not(onItemClick and onItemClick(view,ids,key,data)) then
            local statusView=ids.status
            if statusView then
              local checked=not(statusView.checked)
              statusView.setChecked(checked)
              if data.checked~=nil then
                data.checked=checked
               elseif data.key then
                setSharedData(data.key,checked)
              end
            end
          end
        end
        if onItemLongClick then
          view.onLongClick=function(view)
            local data=ids._data
            local key=data.key
            onItemLongClick(view,ids,key,data)
          end
        end
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data=data[position+1]
      local layoutView=holder.view
      local tag=layoutView.getTag()
      tag._data=data
      --datum
      --tag.key=data.key
      local title=data.title
      local icon=data.icon
      local summary=data.summary
      local enabled=data.enabled
      --View
      local titleView=tag.title
      local summaryView=tag.summary
      local statusView=tag.status
      local rightIconView=tag.rightIcon
      local iconView=tag.icon

      if title and titleView then
        titleView.text=title
      end
      if summary and summaryView then
        summaryView.text=summary
      end
      if icon and iconView then
        if type(icon)=="number" then
          iconView.setImageResource(icon)
         else
          Glide.with(activity)
          .load(icon)
          .transition(DrawableTransitionOptions.withCrossFade())
          .into(iconView)
        end
      end
      if enabled==false then
        setAlpha({titleView,summaryView,iconView,rightIconView},0.5)
        layoutView.setEnabled(false)
        if statusView then
          statusView.setEnabled(false)
        end
       else
        setAlpha({titleView,summaryView,iconView,rightIconView},1)
        layoutView.setEnabled(true)
        if statusView then
          statusView.setEnabled(true)
        end
      end
      if statusView then
        if data.checked~=nil then
          statusView.setChecked(data.checked)
         elseif data.key then
          statusView.setChecked(getSharedData(data.key) or false)
         else
          statusView.setChecked(false)
        end
      end
      if rightIconView then
        local newPage=data.newPage
        local visibility=rightIconView.getVisibility()
        if newPage then
          if newPage=="newApp" then
            rightIconView.setImageResource(R.drawable.ic_launch)
           else
            rightIconView.setImageResource(R.drawable.ic_chevron_right)
          end
          if visibility~=View.VISIBLE then
            rightIconView.setVisibility(View.VISIBLE)
          end
         else
          if visibility~=View.GONE then
            rightIconView.setVisibility(View.GONE)
          end
        end
      end
    end,
  }))
end

function SettingsLayUtil.newAdapter2(config)
  --[[config={
  data,
  onItemClick,
  onItemLongClick,
  creatorConfig={
    onCreateViewHolder=function(ids,view,parent,viewType)
      end
    }
  }]]
  local data=config.data
  local onItemClick=config.onItemClick
  local onItemLongClick=config.onItemLongClick
  local creatorConfig=config.creatorConfig
  local onCreateViewHolder
  if creatorConfig then
    onCreateViewHolder=creatorConfig.onCreateViewHolder
  end
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount=function()
      return #data
    end,
    getItemViewType=function(position)
      return data[position+1][1]
    end,
    onCreateViewHolder=function(parent,viewType)
      local ids={}
      local view=loadlayout2(itemsLay[viewType],ids)
      local holder=LuaCustRecyclerHolder(view)
      view.setTag(ids)
      if not(onCreateViewHolder and onCreateViewHolder(ids,view,parent,viewType)==true) then
      if viewType~=1 then
        view.setFocusable(true)
        view.setBackground(ThemeUtil.getRippleDrawable(theme.color.rippleColorPrimary,true))
        view.onClick=function(view)
          local data=ids._data
          local key=data.key
          if not(onItemClick and onItemClick(view,ids,key,data)) then
            local statusView=ids.status
            if statusView then
              local checked=not(statusView.checked)
              statusView.setChecked(checked)
              if data.checked~=nil then
                data.checked=checked
               elseif data.key then
                setSharedData(data.key,checked)
              end
            end
          end
        end
        if onItemLongClick then
          view.onLongClick=function(view)
            local data=ids._data
            local key=data.key
            onItemLongClick(view,ids,key,data)
          end
        end
      end
      end
      return holder
    end,

    onBindViewHolder=function(holder,position)
      local data=data[position+1]
      local layoutView=holder.view
      local tag=layoutView.getTag()
      tag._data=data
      --datum
      --tag.key=data.key
      local title=data.title
      local icon=data.icon
      local summary=data.summary
      local enabled=data.enabled
      --View
      local titleView=tag.title
      local summaryView=tag.summary
      local statusView=tag.status
      local rightIconView=tag.rightIcon
      local iconView=tag.icon

      if title and titleView then
        titleView.text=title
      end
      if summary and summaryView then
        summaryView.text=summary
      end
      if icon and iconView then
        if type(icon)=="number" then
          iconView.setImageResource(icon)
         else
          Glide.with(activity)
          .load(icon)
          .transition(DrawableTransitionOptions.withCrossFade())
          .into(iconView)
        end
      end
      if enabled==false then
        setAlpha({titleView,summaryView,iconView,rightIconView},0.5)
        layoutView.setEnabled(false)
        if statusView then
          statusView.setEnabled(false)
        end
       else
        setAlpha({titleView,summaryView,iconView,rightIconView},1)
        layoutView.setEnabled(true)
        if statusView then
          statusView.setEnabled(true)
        end
      end
      if statusView then
        if data.checked~=nil then
          statusView.setChecked(data.checked)
         elseif data.key then
          statusView.setChecked(getSharedData(data.key) or false)
         else
          statusView.setChecked(false)
        end
      end
      if rightIconView then
        local newPage=data.newPage
        local visibility=rightIconView.getVisibility()
        if newPage then
          if newPage=="newApp" then
            rightIconView.setImageResource(R.drawable.ic_launch)
           else
            rightIconView.setImageResource(R.drawable.ic_chevron_right)
          end
          if visibility~=View.VISIBLE then
            rightIconView.setVisibility(View.VISIBLE)
          end
         else
          if visibility~=View.GONE then
            rightIconView.setVisibility(View.GONE)
          end
        end
      end
    end,
  }))
end
return SettingsLayUtil
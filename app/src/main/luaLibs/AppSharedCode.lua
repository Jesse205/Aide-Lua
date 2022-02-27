function getConfigFromFile(path)
  local env={}
  assert(loadfile(tostring(path),"bt",env))()
  return env
end

function LuaLexerIteratorBuilder(code)
  local lexer=LuaLexer(code)
  return function()
    local advance=lexer.advance()
    local text=lexer.yytext()
    local column=lexer.yycolumn()
    return advance,text,column
  end
end


local richAnim=getSharedData("richAnim")
function newLayoutTransition()
  if richAnim and notSafeModeEnable then
    return LayoutTransition().enableTransitionType(LayoutTransition.CHANGING)
  end
end



import "PluginsUtil"

--PluginsUtil.loadPlugins()
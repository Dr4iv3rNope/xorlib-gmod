xorlib.Dependency("xorlib/language", "cl_language.lua")
xorlib.Dependency("xorlib/language", "sh_context.lua")
xorlib.Dependency("xorlib/language", "cl_context.lua")

x.XorlibLanguageContext = x.XorlibLanguageContext or x.LanguageContext("xorlib")
x.XorlibLanguageContext:FallbackTo("en")

x.RecursiveInclude(x.ClientIncluder, "xorlib_languages")

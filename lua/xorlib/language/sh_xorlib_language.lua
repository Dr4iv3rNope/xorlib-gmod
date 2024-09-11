xorlib.Dependency("xorlib/language", "sh_language.lua")
xorlib.Dependency("xorlib/language", "sh_context.lua")

x.XorlibLanguageContext = x.XorlibLanguageContext or x.LanguageContext("xorlib")
x.XorlibLanguageContext:FallbackTo("en")

x.RecursiveInclude(x.SharedIncluder, "xorlib_languages")

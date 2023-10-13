xorlib.Dependency("xorlib/language", "sh_base.lua")

x.XorlibLanguageContext = x.LanguageContext("xorlib")
x.RecursiveInclude(x.AutoIncluder, "xorlib_languages")

x.XorlibLanguageContext:ChangeLanguage("en")

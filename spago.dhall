{ name = "halogen-echarts-simple"
, dependencies =
  [ "aff"
  , "console"
  , "echarts-simple"
  , "effect"
  , "foldable-traversable"
  , "halogen"
  , "halogen-subscriptions"
  , "maybe"
  , "prelude"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, license = "Apache-2.0"
, repository = "https://github.com/lucasdicioccio/purescript-halogen-echarts-simple"
}

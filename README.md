# Halogen-ECharts Simple

A thin wrapper to help showing [ECharts](https://echarts.apache.org/)
visualizations into your Halogen apps.

## Installation

Assuming you use `npm` and `spago`.

```
npm i echarts
spago install halogen-echarts-simple
```

## Usage

The `simple` in the title means that we provide a very simple layer. That is,
you have to fill in the blanks.

What this library offers is a function to return Halogen components provided that you teach it:
- (a) what is the type of the `options` object passed to EChart
- (b) what sort of click-callback objects you care to capture

The `type Options o = {|o}` definition embodies the `(a)` above.
The `type Output i = {|i}` definition embodies the `(b)` above.

You thus need some boilerplate work to type and translate the various ECharts
datatypes (with its flurry of possible branches). That is, rather than trying
to build a all-you-can-eat-buffet type that would match every 'options', we
prefer to restrict ourselves to _simple_ situations where a given graph has
exactly one type. Besides the boilerplate, there probably are limitations (I
have not tried the most advanced charts options involving JavaScript functions
yet). For situations where the ECharts options merely are uniform data, the
boilerplate work should be pretty straightforward.

## Example

Translating [the line-simple example](https://echarts.apache.org/examples/en/editor.html?c=line-simple), you'll see the result of this demo [on my personal blog](https://lucasdicioccio.github.io/halogen-echarts-example.html).

```javascript
option = {
  xAxis: {
    type: 'category',
    data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      data: [150, 230, 224, 218, 135, 147, 260],
      type: 'line'
    }
  ]
};
```

would become

```purescript
type Options =
  { xAxis :: { type :: String, data :: Array String }
  , yAxis :: { type :: String }
  , series :: Array { data :: Array Int, type :: String }
  }

type Output = {}
```

then you can use the component as follows

```purescript
import Halogen.ECharts as ECharts

let
  obj :: Options
  obj =
    { xAxis: {type: "category", data: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]}
    , yAxis: {type: "value"}
    , series: [{type: "line", data: [150, 230, 224, 218, 135, 147, 260]}]
    }
in
H.slot_ _myChart unit ECharts.component {options:obj, modified:false}
```

## the `modified :: Bool` Input parameter

From the above example you may have noticed that the Input object requires
extra information.  The `modified` boolean allows you to tune whether you want
to re-render the graph each time the component is re-rendered or only using the
explicit Query-ing mechanism that Halogen offers.  Typically you will hardcode
the `modified` value depending on how often component re-renders are in your
application.

## TODO list

- [ ] allows to pick the container size
- [ ] consider catching window resizes
- [ ] consider supporting foreign json rather than a Record (in purescript-echarts-simple first)


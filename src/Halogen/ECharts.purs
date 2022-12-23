
module Halogen.ECharts where

import Prelude (bind, discard, pure, unit, ($), (>>=))
import Data.Traversable (traverse_)
import Data.Maybe (Maybe(..))

import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.Subscription (create, notify)
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP

import ECharts as ECharts

type Options o = {|o}

type Output i = {|i}

data Action o i
  = Initialize
  | Render
  | Update (Options o)
  | OnEvent (Output i)

type State o =
  { options :: (Options o)
  , chart   :: Maybe ECharts.ChartRef
  }

type Input o =
  { options  :: Options o
  , modified :: Boolean -- allows to pick whether to auto-update on any refresh or use Query-based
  }

data Query o a =
    SetOptions (Options o) a
  | ReRender a

type StyleString = String

style480x400 :: StyleString
style480x400 = "width:480px;height:400px;"

style640x480 :: StyleString
style640x480 = "width:640px;height:480px;"

component
  :: forall option item m. MonadAff m
  => StyleString
  -> H.Component (Query option) (Input option) (Output item) m
component style =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval $ H.defaultEval
      { handleAction = handleAction
      , initialize = Just Initialize
      , receive = \input -> if input.modified then Just (Update input.options) else Nothing
      , handleQuery = handleQuery
      }
    }
  where
    initialState i = { options: i.options, chart: Nothing }

    render _ =
      HH.div
      [ HP.class_ $ HH.ClassName "echarts-container"
      ]
      [ HH.div
        [ HP.class_ $ HH.ClassName "echarts-ref"
        , HP.style style
        , HP.ref (H.RefLabel "chart-ref")
        ]
        [
        ]
      ]

    handleQuery :: forall a. Query option a -> H.HalogenM (State option) (Action option item) () (Output item) m (Maybe a)
    handleQuery  = case _ of
      SetOptions options a -> do
        handleAction $ Update options
        pure (Just a)
      ReRender a -> do
        handleAction $ Render
        pure (Just a)
 
    handleAction = case _ of
      Initialize -> do
        H.getRef (H.RefLabel "chart-ref") >>= traverse_ \element -> do
          obj <- H.liftEffect $ do
            { emitter, listener } <- create
            chart <- ECharts.init element
            ECharts.showLoading chart
            ECharts.on chart "click" (\cbdata -> notify listener (OnEvent cbdata))
            pure {chart, emitter}
          _ <- H.subscribe obj.emitter
          H.modify_ _ { chart = Just obj.chart }
          handleAction $ Render
      Update options -> do
        H.modify_ _ { options = options }
        handleAction $ Render
      Render -> do
        st0 <- H.get
        case st0.chart of
          Nothing -> pure unit
          Just chart -> do
            H.liftEffect $ do
              ECharts.hideLoading chart
              ECharts.setOptions chart st0.options
      OnEvent item -> do
        H.raise item

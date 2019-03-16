module Main exposing (main)

import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url


type Msg
 = Tick Float GetKeyState
  |  MakeRequest Browser.UrlRequest
  |  UrlChange Url.Url
-- Need AT LEAST these messages (can add more as needed)

type alias Model = { size : Float, angle : Float }
-- Model can be anything (but probably should be a record)

init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =  ( { size = 10.0 , angle = 0.0} , Cmd.none ) --ignore arguments for most part; same init from browser,element


main : AppWithTick () Model Msg --will always be this type signature 
main =
    appWithTick Tick
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = MakeRequest
        , onUrlChange = UrlChange
        }

--<<VIEW>>
view : Model -> { title : String, body : Collage Msg }
view model = 
  let 
    title = "Stupid Circle"
    body  = collage 700 700 [ ngon 5 model.size 
                                |> filled blue
                                |> rotate model.angle 
                            ] -- |> is Haskell $ equivalent; works like piping; redirects input
    {- 
                            [ circle model.size 
                            |> filled red ] 
    -}
  in { title = title, body = body }

--<<UPDATE>>
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = --always take msg and model, and always pattern mathch on msg (on every possible msg)
   case msg of
       Tick time getKeyState -> --get called everytime browser refresh frame; return a model and msg (a tuple of it) 
           ( { model | size = model.size + 1, angle = model.angle + 1 }, Cmd.none )
       MakeRequest req ->
           ( model, Cmd.none ) -- do nothing
       UrlChange url -> 
           ( model, Cmd.none ) -- do nothing


--<<SUBSCRIPTIONS>>     
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

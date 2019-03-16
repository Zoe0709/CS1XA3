import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model =
    { var0 : String
    , var1 : String
    }
    
init : Model
init = 
    { var0 = ""
    , var1 = ""
    }
    
type Msg = Change0 String | Change1 String

update : Msg -> Model -> Model
update msg model = case msg of
                    Change0 newvar0 -> { model | var0 = newvar0 }
                    Change1 newvar1 -> { model | var1 = newvar1 }

view : Model -> Html Msg
view model = div []
                [ input [ placeholder "String1", value model.var0, onInput Change0 ] []
                , input [ placeholder "String2", value model.var1, onInput Change1 ] []
                , div [] [ text (model.var0), text ":", text (model.var1) ]
                ]

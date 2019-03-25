module Main exposing (..)
import Http exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import String



-- MAIN


main =
 Browser.element
     { init = init
     , update = update
     , subscriptions = subscriptions
     , view = view
     }



-- MODEL


type alias Model =
  { username : String, password : String, confirm_password : String, error_response : String
  }


init : () -> (Model, Cmd Msg)
init _ = ({username="",password="",confirm_password="",error_response =""},Cmd.none)



-- UPDATE


type Msg
  = Username String
  | Password String
  | Confirm_password String
  | Button String String String
  | GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Username username ->
            ({ model | username = username }, Cmd.none)

        Password password ->
            ({ model | password = password }, Cmd.none)

        Confirm_password confirm_password ->
            ({ model | confirm_password = confirm_password }, Cmd.none)

        Button username password confirm_password -> 
            ({ model | username = username, password = password, confirm_password = confirm_password }, performPost model)

        GotText result ->
            case result of
                Ok val ->
                    ( { model | error_response = val }, Cmd.none )

                Err error ->
                    ( handleError model error, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.username Username
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter Password" model.confirm_password Confirm_password
    , viewValidation model
    , button [ onClick (Button model.username model.password model.confirm_password) ][text "log in"]
    , text model.error_response
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.confirm_password then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]


performPost : Model -> Cmd Msg
performPost model =
    Http.post
        { url = "https://mac1xa3.ca/e/ningh4/lab7/"
        , body = Http.stringBody "application/x-www-form-urlencoded" ("name="++model.username++"&password="++model.password++"&confirm_password="++model.confirm_password)
        , expect = Http.expectString GotText
        }




handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error_response = "bad url: " ++ url }
        Http.Timeout ->
            { model | error_response = "timeout" }
        Http.NetworkError ->
            { model | error_response = "network error" }
        Http.BadStatus i ->
            { model | error_response = "bad status " ++ String.fromInt i }
        Http.BadBody body ->
            { model | error_response = "bad body " ++ body }



subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

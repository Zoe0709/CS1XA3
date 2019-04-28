module Zoe exposing (..)
import List exposing(..)
import Basics exposing(..)
import Browser
import Browser.Navigation exposing (Key(..))
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)
import Url
import List exposing(..)
import String exposing (fromInt)
import Json.Encode as E
import Json.Decode as D
import Html exposing (..)
import Html.Attributes
import Html.Events as Events
import Http
import Random

{-
elm install elm/http
elm install elm/Url
elm install elm/json
elm install elm/random
elm install the graphics svg thingy
-}

type Msg = Tick Float GetKeyState
         | MakeRequest Browser.UrlRequest
         | UrlChange Url.Url
         | BlockClicked Blocks
         | Restart
         | StartButton
         | GenerateRandomInt Int
         | SendLoginPost
         | SendSignupPost 
         | RequestLogout
         | LoginResponse (Result Http.Error String) 
         | LogoutResponse (Result Http.Error String) 
         | SignupResponse (Result Http.Error String) 
         | UserscorePostResponse (Result Http.Error String) 
         | GetUserscore (Result Http.Error Highscore) 
         | InputUsername String
         | InputPassword String

type Blocks = Block1 | Block2 | Block3 | Block4 | Block5 | Block6 | Block7 | Block8 | Block9 | None

type alias Table = ( (String, String, String), (String, String, String), (String, String, String) )

type alias Highscore = {username : String, highscore : Int}


type Screen = Login | Game

type alias Model = { board : Table
                    , blockClicked : Bool
                    , initialBlockNum : Blocks 
                    , clickedBlockValue : String
                    , blockPositions : List (Int,Int)
                    , username : String 
                    , password : String 
                    , moves : Int
                    , win : Bool
                    , firstMoveMade : Bool
                    , screen : Screen
                    , error : String
                    , userscore : Highscore
                    }


init : () -> Url.Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model = { board = ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") )
                , blockClicked = False
                , initialBlockNum = None 
                , clickedBlockValue = ""
                , blockPositions = [(1,2),(2,2),(3,2),(1,1),(2,1),(3,1),(1,0),(2,0),(3,0)] 
                , username = ""
                , password = ""
                , moves = 0      
                , win = False 
                , firstMoveMade = False 
                , screen = Login   
                , error = ""    
                , userscore = {username = "", highscore = 999}
                }
    in (model, Cmd.none)
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = case msg of
    Tick time keystate -> (model,Cmd.none)
    MakeRequest req    -> (model,Cmd.none)
    UrlChange url      -> (model,Cmd.none)
    BlockClicked n ->   if model.win == True then 
                        let
                            newhighscore = if model.moves < model.userscore.highscore then model.moves else model.userscore.highscore
                            olduserhighscore = model.userscore
                            newuserhighscore = { olduserhighscore | highscore = newhighscore}
                        in ({model | userscore = newuserhighscore }, userscorePost model)
    
                        else
                            let
                                firstBlock = case (findListItem model.blockPositions ((blockNumToInt (n))-1)) of 
                                    Nothing -> (384,235)
                                    Just val -> val
                                secondBlock = case (findListItem model.blockPositions (blockNumToInt (model.initialBlockNum)-1)) of 
                                    Nothing -> (99,23)
                                    Just val -> val
                                blockDistance = distance firstBlock secondBlock
                            in  
                                if (model.blockClicked == False && isBlank model.board n == False) then ({model | blockClicked = True, initialBlockNum = n, clickedBlockValue = (blockNum model.board n)}, Cmd.none) 
                                        else
                                            if (model.blockClicked == True && isBlank model.board n == True && (blockDistance == 1.0)) then 
                                                let 
                                                    newBoard = insertString (insertString model.board n model.clickedBlockValue) model.initialBlockNum ""
                                                    newhighscore = if newBoard == ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") ) then if model.moves < model.userscore.highscore then model.moves + 1 else model.userscore.highscore else model.userscore.highscore
                                                    olduserhighscore = model.userscore
                                                    newuserhighscore = { olduserhighscore | highscore = newhighscore}  
                                                    postmodel = {model | userscore = newuserhighscore}
                                                    message = if newBoard == ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") ) then userscorePost postmodel else Cmd.none
                                                in
                                                    ({model | board = newBoard
                                                            , blockClicked = False
                                                            , initialBlockNum = None
                                                            , clickedBlockValue = ""
                                                            , moves = model.moves + 1
                                                            , firstMoveMade = if model.firstMoveMade == False then True else True
                                                            , win = if playerWon newBoard == True then True else False
                                                            , userscore = newuserhighscore
                                                    }
                                                    , message)
                                            else ({model | initialBlockNum = None, clickedBlockValue = "", blockClicked = False}, Cmd.none)
    Restart -> ({model | board = ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") )
                        , blockClicked = False
                        , initialBlockNum = None 
                        , clickedBlockValue = ""
                        , moves = 0
                        , firstMoveMade = False
                        , win = False } 
                , Cmd.none)

    StartButton -> (model, randomIntGenerator)
    GenerateRandomInt int -> let newBoard = shuffle model.board model int
                             in ({model | board = newBoard
                                        , blockClicked = False
                                        , initialBlockNum = None 
                                        , clickedBlockValue = ""
                                        , moves = 0
                                        , firstMoveMade = False
                                        , win = False 
                                }, Cmd.none)                
 
    InputUsername inputUsername-> let
                                    old = model.userscore
                                    new = {old | username = inputUsername}
                                in
                                    ({model | username = inputUsername, userscore = new}, Cmd.none)

    
    InputPassword inputPassword -> ({model | password = inputPassword}, Cmd.none)

    SendLoginPost -> (model, loginPost model)

    SendSignupPost -> (model, signupPost model)

    RequestLogout -> (model, logoutPost)

    LoginResponse response -> 
        case response of 
            Ok "Success" -> ({model | screen = Game}, userscoreGet)
            Ok "Fail" ->(model, Cmd.none)
            Ok _ -> (model, Cmd.none)
            Err error ->    
                ( handleError model error, Cmd.none)

    SignupResponse response -> 
            case response of 
            Ok "Success" -> ({model | screen = Game}, userscoreGet)
            Ok "Fail" ->(model, Cmd.none)
            Ok _ -> (model, Cmd.none)
            Err error ->  
                ( handleError model error, Cmd.none)

    LogoutResponse response -> 
        case response of
            Ok "Success" -> let 
                                m = { board = ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") )
                                        , blockClicked = False
                                        , initialBlockNum = None 
                                        , clickedBlockValue = ""
                                        , blockPositions = [(1,2),(2,2),(3,2),(1,1),(2,1),(3,1),(1,0),(2,0),(3,0)] 
                                        , username = ""
                                        , password = ""
                                        , moves = 0      
                                        , win = False 
                                        , firstMoveMade = False 
                                        , screen = Login   
                                        , error = ""    
                                        , userscore = {username = "", highscore = 999}
                                        }
                            in (m, Cmd.none)
            Ok "Fail" -> (model, Cmd.none) 
            Ok _ -> (model, Cmd.none)                                       
            Err error -> 
                ( handleError model error, Cmd.none)

    UserscorePostResponse response ->
        case response of    
            Ok _ -> (model, Cmd.none)   
            Err error ->
                ( handleError model error, userscoreGet)   

    GetUserscore response ->
        case response of    
            Ok val -> ({model | userscore = val}, Cmd.none)
            Err error ->
                ( handleError model error, Cmd.none)   




handleError : Model -> Http.Error -> Model
handleError model error =
    case error of
        Http.BadUrl url ->
            { model | error = "bad url: " ++ url }
        Http.Timeout ->
            { model | error = "timeout" }
        Http.NetworkError ->
            { model | error = "network error" }
        Http.BadStatus i ->
            { model | error = "bad status " ++ String.fromInt i }
        Http.BadBody body ->
            { model | error = "bad body " ++ body }



view : Model -> { title : String, body : Collage Msg }
view model = 
    let 
        title = "Mygame"
        body = collage 100 100 shapes
        shapes = case model.screen of 
            Login -> [background, topic, loginB, signupB
                    , html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Username", Events.onInput InputUsername][]) |> move (-30,15)
                    , html 50 20 (Html.input [Html.Attributes.style "width" "25px", Html.Attributes.style "height" "5px", Html.Attributes.style "font-size" "3pt", Html.Attributes.placeholder "Password", Html.Attributes.type_ "password", Events.onInput InputPassword] []) |> move (2,15)
                    ]
            Game -> [block1, text1, block2, text2, block3, text3, block4, text4, block5, text5, block6, text6, block7, text7, block8, text8, block9, text9, selectedBlock, moves, restart, win, logout, startButton, highscore]

        --Login 
        background = square 90
            |> filled (rgb 0 224 224) 
            |> addOutline (solid 0.7) black 
            |> move(0,0)
        topic = GraphicSVG.text "Please log in"
            |> size 8
            |> filled black
            |> move (-24,20)
        loginB = group [ loginshape, logintext ]
            |> notifyTap SendLoginPost
            |> move (-12,-15)
        loginshape = roundedRect 17 10 2
            |> filled orange
            |> addOutline (solid 0.5) black
        logintext = GraphicSVG.text "log in" 
            |> size 3.5
            |> filled black
            |> move (-5,-1)
        signupB = group [ signupshape, signuptext ]
            |> notifyTap SendSignupPost
            |> move (12,-15)
        signupshape = roundedRect 17 10 2
            |> filled yellow
            |> addOutline (solid 0.5) black
        signuptext = GraphicSVG.text "sign up" 
            |> size 3.5
            |> filled black
            |> move (-6,-1)

        --Game
        highscore = GraphicSVG.text ("Highscore: " ++ String.fromInt model.userscore.highscore)
            |> size 5
            |> filled black
            |> move (-22,45)

        startButton = GraphicSVG.text "start"
            |> size 5
            |> filled black
            |> move (-20,-45)
            |> notifyTap StartButton

        logout = GraphicSVG.text "Logout"
            |> size 5
            |> filled black
            |> move (20,-45)
            |> notifyTap RequestLogout

        win = GraphicSVG.text "Player Wins!"
            |> size 5
            |> (if model.firstMoveMade == True && model.win == True then filled black else filled blank)
            |> move (-50,-45)

        restart = GraphicSVG.text ("Restart")
            |> size 5
            |> filled black 
            |> move (0,-45)
            |> notifyTap Restart

        selectedBlock = GraphicSVG.text("Selected Block: " ++ model.clickedBlockValue)
            |> size 5
            |> filled black 
            |> move (0,40)

        moves = GraphicSVG.text ("# of Moves: " ++ String.fromInt model.moves)
            |> size 5
            |> filled black 
            |> move (-40,40)

        block1 = square 25
            |> filled lightBlue 
            |> addOutline (solid 1) black 
            |> move(-25,25)
            |> notifyTap (BlockClicked Block1)

        text1 = GraphicSVG.text (blockNum model.board Block1)
            |> filled black
            |> move(-28,22)
            |> notifyTap (BlockClicked Block1)


        block2 = square 25
            |> filled lightRed 
            |> addOutline (solid 1) black 
            |> move(0,25)
            |> notifyTap (BlockClicked Block2)

        text2 = GraphicSVG.text (blockNum model.board Block2)
            |> filled black
            |> move(0,25)
            |> notifyTap (BlockClicked Block2)


        block3 = square 25
            |> filled lightBlue 
            |> addOutline (solid 1) black 
            |> move(25,25)
            |> notifyTap (BlockClicked Block3)
            
        text3 = GraphicSVG.text (blockNum model.board Block3)
            |> filled black
            |> move(25,25)
            |> notifyTap (BlockClicked Block3)

        block4 = square 25
            |> filled lightRed 
            |> addOutline (solid 1) black 
            |> move(-25,0)
            |> notifyTap  (BlockClicked Block4)
            
        text4 = GraphicSVG.text (blockNum model.board Block4)
            |> filled black
            |> move(-25,0)
            |> notifyTap  (BlockClicked Block4)            

        block5 = square 25
            |> filled lightBlue 
            |> addOutline (solid 1) black 
            |> move(0,0)
            |> notifyTap  (BlockClicked Block5)     

        text5 = GraphicSVG.text (blockNum model.board Block5)
            |> filled black
            |> move(0,0)
            |> notifyTap  (BlockClicked Block5)            

        block6 = square 25
            |> filled lightRed 
            |> addOutline (solid 1) black 
            |> move(25,0)   
            |> notifyTap  (BlockClicked Block6)        

        text6 = GraphicSVG.text (blockNum model.board Block6)
            |> filled black
            |> move(25,0)   
            |> notifyTap  (BlockClicked Block6)            

        block7 = square 25
            |> filled lightBlue 
            |> addOutline (solid 1) black 
            |> move(-25,-25)
            |> notifyTap  (BlockClicked Block7)     

        text7 = GraphicSVG.text (blockNum model.board Block7)
            |> filled black
            |> move(-25,-25)
            |> notifyTap  (BlockClicked Block7)     


        block8 = square 25
            |> filled lightRed 
            |> addOutline (solid 1) black 
            |> move(0,-25)
            |> notifyTap  (BlockClicked Block8)        

        text8 = GraphicSVG.text (blockNum model.board Block8)
            |> filled black
            |> move(0,-25)        
            |> notifyTap  (BlockClicked Block8)              

        block9 = square 25
            |> filled white 
            |> addOutline (solid 1) black 
            |> move(25,-25)
            |> notifyTap  (BlockClicked Block9)     

        text9 = GraphicSVG.text (blockNum model.board Block9)
            |> filled black
            |> move(25,-25)             
            |> notifyTap  (BlockClicked Block9)                 

     in { title = title , body = body }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : AppWithTick () Model Msg
main = appWithTick Tick
       { init = init
       , update = update
       , view = view
       , subscriptions = subscriptions
       , onUrlRequest = MakeRequest
       , onUrlChange = UrlChange
       }  



--at position Blocks what is the string?
blockNum : Table -> Blocks -> String --Works
blockNum ( (a, b, c), (d, e, f), (g, h, i) ) n = 
    case n of 
        Block1 -> a
        Block2 -> b
        Block3 -> c
        Block4 -> d
        Block5 -> e
        Block6 -> f
        Block7 -> g
        Block8 -> h
        Block9 -> i
        None -> ""


--is the board at Blocks have an empty string?      --works
isBlank : Table -> Blocks -> Bool   
isBlank table blockNumber = blockNum table blockNumber == ""

--insert blocknumber to the table at position n, if that block is blank         --Works 
insertString : Table -> Blocks -> String -> Table
insertString ( (a, b, c), (d, e, f), (g, h, i) ) blockNumber s = 
    case blockNumber of 
        Block1 -> ( (s, b, c), (d, e, f), (g, h, i) )
        Block2 -> ( (a, s, c), (d, e, f), (g, h, i) )
        Block3 -> ( (a, b, s), (d, e, f), (g, h, i) )
        Block4 -> ( (a, b, c), (s, e, f), (g, h, i) )
        Block5 -> ( (a, b, c), (d, s, f), (g, h, i) )
        Block6 -> ( (a, b, c), (d, e, s), (g, h, i) )
        Block7 -> ( (a, b, c), (d, e, f), (s, h, i) )
        Block8 -> ( (a, b, c), (d, e, f), (g, s, i) )
        Block9 -> ( (a, b, c), (d, e, f), (g, h, s) )
        None -> ( (a, b, c), (d, e, f), (g, h, i) )


distance : (Int,Int) -> (Int,Int) -> Float 
distance (a,b) (c,d) = toFloat ((a-c)^2 +(b-d)^2)^(1/2)


findListItem : List a -> Int ->  Maybe a
findListItem xs n = head (drop n xs)
 
blockNumToInt : Blocks -> Int
blockNumToInt n =    
    case n of 
        Block1 -> 1
        Block2 -> 2
        Block3 -> 3
        Block4 -> 4
        Block5 -> 5
        Block6 -> 6
        Block7 -> 7
        Block8 -> 8
        Block9 -> 9
        _ -> 1 --come back

playerWon : Table -> Bool 
playerWon table = if table ==  ( ("1", "2", "3"), ("4", "5", "6"), ("7", "8", "") ) then True else False



positionToBlock : (Int,Int) -> Blocks 
positionToBlock n =     
    case n of 
        (1,2) -> Block1 
        (2,2) -> Block2 
        (3,2) -> Block3
        (1,1) -> Block4 
        (2,1) -> Block5 
        (3,1) -> Block6 
        (1,0) -> Block7 
        (2,0) -> Block8 
        (3,0) -> Block9
        (_,_) -> None 

--Shuffle
randomPosition : (Int,Int) -> Int -> (Int,Int)
randomPosition (a,b) i = let
                            x = (mod (a+i) 3)
                            y = (mod (b+i) 3)
                         in
                            (x+1,y)

mod : Int -> Int -> Int 
mod a b = a-((a // b) * b)

randomIntGenerator : Cmd Msg 
randomIntGenerator = Random.generate GenerateRandomInt (Random.int 1 500)



shuffle : Table -> Model -> Int -> Table 
shuffle ( (a,b,c), (d,e,f), (g,h,i) ) model n =
    let
        -- gives original position of the blocks
        posBlock1 = case (findListItem model.blockPositions 0) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock2 = case (findListItem model.blockPositions 1) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock3 = case (findListItem model.blockPositions 2) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock4 = case (findListItem model.blockPositions 3) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock5 = case (findListItem model.blockPositions 4) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock6 = case (findListItem model.blockPositions 5) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock7 = case (findListItem model.blockPositions 6) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock8 = case (findListItem model.blockPositions 7) of   
                        Nothing -> (999,999)
                        Just val -> val
        posBlock9 = case (findListItem model.blockPositions 8) of   
                        Nothing -> (999,999)
                        Just val -> val   

        -- gives the original value in the blocks
        stringAtBlock1 = blockNum model.board Block1
        stringAtBlock2 = blockNum model.board Block2
        stringAtBlock3 = blockNum model.board Block3
        stringAtBlock4 = blockNum model.board Block4
        stringAtBlock5 = blockNum model.board Block5
        stringAtBlock6 = blockNum model.board Block6
        stringAtBlock7 = blockNum model.board Block7
        stringAtBlock8 = blockNum model.board Block8
        stringAtBlock9 = blockNum model.board Block9         

        --gives new position of the blocks 
        newBlock1Pos = randomPosition posBlock1 n  
        newBlock2Pos = randomPosition posBlock2 n   
        newBlock3Pos = randomPosition posBlock3 n   
        newBlock4Pos = randomPosition posBlock4 n   
        newBlock5Pos = randomPosition posBlock5 n   
        newBlock6Pos = randomPosition posBlock6 n   
        newBlock7Pos = randomPosition posBlock7 n   
        newBlock8Pos = randomPosition posBlock8 n   
        newBlock9Pos = randomPosition posBlock9 n   


        -- gives block number of that position 
        block1Destination = positionToBlock newBlock1Pos
        block2Destination = positionToBlock newBlock2Pos
        block3Destination = positionToBlock newBlock3Pos
        block4Destination = positionToBlock newBlock4Pos
        block5Destination = positionToBlock newBlock5Pos
        block6Destination = positionToBlock newBlock6Pos
        block7Destination = positionToBlock newBlock7Pos
        block8Destination = positionToBlock newBlock8Pos
        block9Destination = positionToBlock newBlock9Pos  

        a_table = insertString model.board block1Destination stringAtBlock1
        b_table = insertString a_table  block2Destination stringAtBlock2
        c_table = insertString b_table block3Destination stringAtBlock3
        d_table = insertString c_table block4Destination stringAtBlock4
        e_table = insertString d_table block5Destination stringAtBlock5
        f_table = insertString e_table block6Destination stringAtBlock6
        g_table = insertString f_table block7Destination stringAtBlock7
        h_table = insertString g_table block8Destination stringAtBlock8
        finalTable = insertString h_table block9Destination stringAtBlock9
    in 
        finalTable






rootUrl = "https://mac1xa3.ca/e/ningh4/"

usernamePasswordEncode : Model -> E.Value
usernamePasswordEncode model =
    E.object
        [ ( "username", E.string model.username)
        , ( "password", E.string model.password)
        ]        

loginPost : Model -> Cmd Msg
loginPost model =
    Http.post
        { url = rootUrl ++ "login/"
        , body = Http.jsonBody <| usernamePasswordEncode model 
        , expect = Http.expectString LoginResponse
        }

signupPost : Model -> Cmd Msg
signupPost model =
    Http.post
        { url = rootUrl ++ "signup/"
        , body = Http.jsonBody <| usernamePasswordEncode model 
        , expect = Http.expectString SignupResponse
        }        

logoutPost : Cmd Msg 
logoutPost =
    Http.get 
        { url = rootUrl ++ "logout/"
        , expect = Http.expectString LogoutResponse
        }        

userscoreEncode : Model -> E.Value
userscoreEncode model = 
    E.object
        [ ("username", E.string model.userscore.username)
        , ("highscore", E.int model.userscore.highscore)
        ]

userscorePost : Model -> Cmd Msg 
userscorePost model = 
    Http.post 
        { url = rootUrl ++ "highscore/"
        , body = Http.jsonBody <| userscoreEncode model 
        , expect = Http.expectString UserscorePostResponse
        }
userscoreDecode : D.Decoder Highscore 
userscoreDecode = 
    D.map2 Highscore 
        (D.field "username" D.string)
        (D.field "highscore" D.int)

userscoreGet : Cmd Msg
userscoreGet =
    Http.get
        { url = rootUrl ++ "userscoreget/"
        , expect = Http.expectJson GetUserscore userscoreDecode
        }


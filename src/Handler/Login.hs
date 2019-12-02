{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Login where

import Import
import Text.Lucius
import Text.Julius
import Database.Persist.Postgresql

formLogin :: Form (Text, Text)
formLogin = renderBootstrap $ (,)
    <$> areq emailField "E-mail: " Nothing
    <*> areq passwordField "Senha: " Nothing

getSairR :: Handler Html
getSairR = do 
    deleteSession "_NOME"
    redirect HomeR

getEntrarR :: Handler Html
getEntrarR = do 
    (widget,_) <- generateFormPost formLogin
    msg <- getMessage
    defaultLayout $ do
        setTitle "Eletrônica Universal - Entrar"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
            <meta name=keywords content="eletronica, hobby eletrônica, arduino">
            <meta name=description content="Cadastre e fique ligado nos lançamentos">
            <meta name=author content="Miguel Arcanjo - Luiz Sorbello - Gustavo">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">            
            <meta name="viewport" content="width=device-width, initial-scale=1">
            |]
        toWidgetHead [lucius|
            h1 {
                color : red;
            }
            form button {
                margin: 10px;
            }
        |]
        toWidget $(juliusFile "templates/mobile.julius")
        $(whamletFile "templates/usuario_menu.hamlet") 

        [whamlet|
            <div class="w3-container w3-center w3-margin-top">
                $maybe mensa <- msg 
                    <div class="w3-panel w3-yellow w3-padding-16 w3-display-container">
                        <span onclick="this.parentElement.style.display='none'"
    class="w3-button w3-large w3-display-topright">&times;</span>
                            ^{mensa}
                
                <h1>
                    SOU ASSINANTE
                
                <form method=post action=@{EntrarR}>
                    ^{widget}
                    <button class="w3-button w3-xlarge w3-green">
                        Entrar
        |]
        $(whamletFile "templates/rodape.hamlet")

postEntrarR :: Handler Html
postEntrarR = do 
    ((result,_),_) <- runFormPost formLogin
    case result of 
        FormSuccess ("root@root.com","root125") -> do 
            setSession "_NOME" "admin"
            redirect AdminR
        FormSuccess (email,senha) -> do 
           -- select * from usuario where email=digitado.email
           usuario <- runDB $ getBy (UniqueEmailIy email)
           case usuario of 
                Nothing -> do 
                    setMessage [shamlet|
                        <div>
                            E-mail N ENCONTRADO!
                    |]
                    redirect EntrarR
                Just (Entity _ usu) -> do 
                    if (usuarioSenha usu == senha) then do
                        setSession "_NOME" (usuarioNome usu)
                        redirect AssinanteR
                    else do 
                        setMessage [shamlet|
                            <div>
                                Senha INCORRETA!
                        |]
                        redirect HomeR 
        _ -> redirect HomeR
    
getAdminR :: Handler Html
getAdminR = do 
    defaultLayout $ do
        addScript (StaticR js_gtag_js)
        setTitle "Eletrônica Universal"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
        -- addScriptRemote "url" -> CHAMA JS EXTERNO
        -- addScript (StaticR script_js), ONDE script 
        -- eh o nome do seu script.
        -- pasta css, arquivo: bootstrap.css
        -- addStylesheet (StaticR css_bootstrap_css)     
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
            <meta name=author content="Miguel Arcanjo - Luiz Sorbello - Gustavo">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">            
            <meta name="viewport" content="width=device-width, initial-scale=1">
            |]        

        -- toWidgetHead [lucius|
        --     h1 {
        --         color : red;
        --     }
        -- |]
        toWidget $(juliusFile "templates/mobile.julius")
        $(whamletFile "templates/admin_menu.hamlet")
        $(whamletFile "templates/admin.hamlet")
        $(whamletFile "templates/rodape.hamlet")



    
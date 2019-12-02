{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Usuario where

import Import
import Text.Lucius
import Text.Julius
import Database.Persist.Postgresql

formUsu :: Form (Usuario, Text)
formUsu = renderBootstrap $ (,)
    <$> (Usuario 
        <$> areq textField "Nome: " Nothing
        <*> areq emailField "E-mail: " Nothing
        <*> areq passwordField "Senha: " Nothing)
    <*> areq passwordField "Digite Novamente: " Nothing

getUsuarioR :: Handler Html
getUsuarioR = do 
    (widget,_) <- generateFormPost formUsu
    msg <- getMessage
    defaultLayout $ do
        setTitle "Eletrônica Universal - Cadastro"
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
                    ASSINATURA DA REVISTA
                
                <form method=post action=@{UsuarioR}>
                    ^{widget}
                    <button class="w3-button w3-xlarge w3-green">
                        Assinar
        |]
        $(whamletFile "templates/rodape.hamlet")

postUsuarioR :: Handler Html
postUsuarioR = do 
    ((result,_),_) <- runFormPost formUsu
    case result of 
        FormSuccess (usuario,veri) -> do 
            if (usuarioSenha usuario == veri) then do 
                runDB $ insert usuario 
                setMessage [shamlet|
                    <div>
                        USUARIO INCLUIDO
                |]
                redirect UsuarioR
            else do 
                setMessage [shamlet|
                    <div>
                        SENHA E VERIFICACAO N CONFEREM
                |]
                redirect UsuarioR
        _ -> redirect HomeR
        
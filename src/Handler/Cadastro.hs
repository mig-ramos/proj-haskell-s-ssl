{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Cadastro where

import Import
import Text.Lucius
import Text.Julius
import Database.Persist.Postgresql

-- renderDivs
formCadastro :: Form Cadastro 
formCadastro = renderBootstrap $ Cadastro 
    <$> areq textField "Nome: " Nothing 
    <*> areq emailField "Email: "   Nothing 
    <*> areq textField  "Interesse: " Nothing 

getCadastroR :: Handler Html 
getCadastroR = do 
    (widget, enctype) <- generateFormPost formCadastro 
    msg <- getMessage
    defaultLayout $ do 
        -- addStylesheet (StaticR css_bootstrap_css)
        setTitle "Eletrônica Universal - Cadastro"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
            <meta name="google-site-verification" content="a7H32sTci5dQttMhgXtyAkX4yi75NJhvnaBCiXMwpHo" />
            <meta name=keywords content="eletronica, hobby eletrônica, arduino">
            <meta name=description content="Cadastre qual sua área de interesse e fique ligado no lançamento">
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
        $(whamletFile "templates/cadastro_menu.hamlet")


        [whamlet|
            <div class="w3-container w3-center w3-margin-top">
                $maybe mensa <- msg
                    <div class="w3-panel w3-yellow w3-padding-16 w3-display-container">
                        <span onclick="this.parentElement.style.display='none'"
    class="w3-button w3-large w3-display-topright">&times;</span>
                            ^{mensa}
                
                <h1>
                    CADASTRE <em>de sua sugestão!
                <p>
                    Sua sugestão é de grande valia para o aprimoramento do Site. Deixe seu melhor e-mail para avisarmos de todos os lançamentos.
                
                <form method=post action=@{CadastroR}>
                    ^{widget}
                    <button class="w3-button w3-xlarge w3-green">
                        Cadastrar
        |]
        $(whamletFile "templates/rodape.hamlet")

postCadastroR :: Handler Html 
postCadastroR = do 
    ((result,_),_) <- runFormPost formCadastro 
    case result of 
        FormSuccess cadastro -> do 
            runDB $ insert cadastro 
            setMessage [shamlet|
                <h2>
                    REGISTRO INCLUIDO
            |]
            redirect CadastroR
        _ -> redirect HomeR

getListCadastroR :: Handler Html 
getListCadastroR = do 
    -- select * from cadastro order by cadastro.nome
    cadastros <- runDB $ selectList [] [Asc CadastroNome]
    defaultLayout $ do
        setTitle "Eletrônica Universal - Interesses"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
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
        $(whamletFile "templates/listagem_menu.hamlet")
        $(whamletFile "templates/listagem_cadastros.hamlet")
        $(whamletFile "templates/rodape.hamlet")

postApagarCadastroR :: CadastroId -> Handler Html 
postApagarCadastroR aid = do 
    _ <- runDB $ get404 aid
    runDB $ delete aid 
    redirect ListCadastroR
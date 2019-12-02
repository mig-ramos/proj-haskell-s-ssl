{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Home where

import Import
import Data.FileEmbed (embedFile)
import Text.Lucius
import Text.Julius
--import Network.HTTP.Types.Status
import Database.Persist.Postgresql

getAssinanteR :: Handler Html
getAssinanteR = do 
    defaultLayout $ do 
        addScript (StaticR js_gtag_js)
        setTitle "Eletrônica Universal"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
  
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
            <meta name=keywords content="eletronica, hobby eletrônica, arduino, projetos eletrônicos">
            <meta name=description content="Fundamentos da Eletrônica Universal, suas ramificações, IOT e projetos.">
            <meta name=author content="Miguel Arcanjo - Luiz Sorbello - Gustavo">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">            
            <meta name="viewport" content="width=device-width, initial-scale=1">
            |] 

        toWidget $(juliusFile "templates/mobile.julius")
        $(whamletFile "templates/assinante_menu.hamlet")
        $(whamletFile "templates/assinante.hamlet")

        $(whamletFile "templates/rodape.hamlet")

getAdsR :: Handler TypedContent
getAdsR = return $ TypedContent "text/plain"
    $ toContent $(embedFile "static/ads.txt")

getHomeR :: Handler Html
getHomeR = do 
    defaultLayout $ do 
        addScript (StaticR js_gtag_js)
        setTitle "Eletrônica Universal"
        addStylesheetRemote "https://fonts.googleapis.com/css?family=Sail|Roboto+Condensed:300,400,400i,700"
        addStylesheetRemote "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
        addStylesheet (StaticR css_w3_css)
        addStylesheet (StaticR css_mystyle_css)
   
        toWidgetHead
            [hamlet|
            <meta charset="UTF-8">
            <script data-ad-client="ca-pub-4957039376509185" async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js">
            <meta name="google-site-verification" content="a7H32sTci5dQttMhgXtyAkX4yi75NJhvnaBCiXMwpHo" />
            <meta name=keywords content="eletronica, hobby eletrônica, arduino">
            <meta name=description content="Fundamentos da Eletrônica Universal, suas ramificações, IOT e projetos.">
            <meta name=author content="Miguel Arcanjo - Luiz Sorbello - Gustavo">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">            
            <meta name="viewport" content="width=device-width, initial-scale=1">
            |]        

        toWidget $(juliusFile "templates/index.julius")
        $(whamletFile "templates/index_menu.hamlet")
        $(whamletFile "templates/index.hamlet")
        $(whamletFile "templates/rodape.hamlet")


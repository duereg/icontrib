{-# LANGUAGE OverloadedStrings #-}

module LoginTest where

import qualified DB.Login                    as L
import qualified Data.Login                  as L
import qualified DB.DB                       as DB

import TestUtil

main :: IO ()
main = do
    db <- DB.emptyMemoryDB
    addIdentityTests db
    cookieTests db

uid :: L.Identity
uid = L.Identity "hello"

addIdentityTests :: DB.Database -> IO ()
addIdentityTests db = do
    assertEqM   "listIdentities"    (L.listIdentities db)                     []              -- No users
    assertL     "login empty"       (L.loginToToken db uid "world")           ("DoesntExist")   -- User doesn't exist
    assertL     "add bad user"      (L.addIdentity db (L.Identity "") "")     ("BadUsername")   -- Bad user name
    assertR   "added user"        (L.addIdentity db uid "world")              ()                -- Add user named 'hello'
    assertEqM   "listIdentities2"   (L.listIdentities db)                     [uid]             -- User in DB 
    assertL     "added user"        (L.addIdentity db uid "again")            ("AlreadyExists") -- User 'hello' already exists

cookieTests :: DB.Database -> IO ()
cookieTests db = do
    -- Bad password for existing user
    assertL "login bad password" (L.loginToToken db uid "badpassword") ("BadPassword")

    -- Good password for existing user
    goodcookie <- assertRightErrorT "login existing" $ L.loginToToken db uid "world"

    -- User lookup with bad cookie
    assertL "tokenToIdentity bad cookie"  (L.tokenToIdentity db (L.Token "randomnonsense")) ("BadToken")  
    -- User lookup with good cookie
    assertR "tokenToIdentity good cookie" (L.tokenToIdentity db goodcookie) (uid)

    -- Remove cookie
    L.clearIdentityTokens db uid

    -- User lookup after cookie removed
    assertL "tokenToIdentity good cookie" (L.tokenToIdentity db goodcookie)       ("BadToken")      


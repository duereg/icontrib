{-# LANGUAGE DeriveDataTypeable, TemplateHaskell, TypeFamilies, FlexibleContexts #-}
module Query.UserInfo where

import Control.Monad.State                   ( get, put, MonadState )
import Control.Monad.Reader                  ( ask, MonadReader )
import Data.Function                         ( on )
import Data.List                             ( sortBy )
import Data.Generics                         ( listify )

import Data.CharityInfo                      ( CharityID(..) )
import Data.Login                            ( Identity )

import Data.IxSet                            ( (@*) )
import qualified Data.IxSet                  as IxSet

import Data.Acid
import SiteError
import Data.UserInfo
import Data.DB

replace :: MonadState DB m => (UserInfoDB -> m UserInfoDB) -> m ()
replace ff = do
    db <- get
    ll <- ff (userInfos db)
    put $ db { userInfos = ll }

use :: MonadReader DB m => (UserInfoDB -> m b) -> m b
use ff = do
    db <- ask
    ff (userInfos db)

userInfoU :: UserInfo -> Update DB ()
userInfoU ui =  replace $ \ db -> return (IxSet.updateIx (owner ui) ui db)

userInfoByOwnerQ :: Identity -> Query DB (Either String UserInfo)
userInfoByOwnerQ key = runErrorT $ use $ \ db -> ((IxSet.getOne $ db @* [key]) `justOr` doesntExist)

usersQ :: Query DB ([Identity])
usersQ = use $ \ db -> return $ map owner $ IxSet.toList db

mostInfluentialUserQ:: Query DB (Either String Identity)
mostInfluentialUserQ= runErrorT $ use $ \ db -> do 
   let 
        head' [] = doesntExist
        head' ls = return $ owner $ head ls
        influence aa = negate $ (centsDonated aa) + (alignedDonated aa)
   head' $ sortBy (compare `on` influence) $ IxSet.toList db

userCharitiesQ :: Query DB ([CharityID])
userCharitiesQ = use $ \ db -> do 
    let isCharityID (CharityID _) = True
    return $ (listify isCharityID (IxSet.toList db))



{-# LANGUAGE FlexibleContexts, MultiParamTypeClasses, FlexibleInstances, TypeSynonymInstances, TypeFamilies, DeriveDataTypeable, TemplateHaskell #-}
{-# OPTIONS_GHC -fspec-constr-count=2 -fno-warn-orphans #-}
module Data.UserInfo where

import Data.Data                             ( Typeable, Data )
import Data.Login

import Data.IxSet
import Data.SafeCopy
import Data.Distribution
import Data.Fund


data UserInfo = UserInfo { owner            :: Identity
                         , firstName        :: String
                         , lastName         :: String
                         , phone            :: String
                         , email            :: String
                         , imageUrl         :: String
                         , centsDonated     :: Int
                         , alignedDonated   :: Int
                         , alignedUsers     :: [Identity]
                         , distribution     :: [Distribution]
                         , funds            :: [Fund]
                         }
              deriving (Eq, Ord, Show, Data, Typeable)


instance Indexable UserInfo where
    empty = ixSet [ ixFun $ \ci -> [ owner ci ]
                  ]
$(deriveSafeCopy 0 'base ''UserInfo)

type UserInfoDB = IxSet UserInfo
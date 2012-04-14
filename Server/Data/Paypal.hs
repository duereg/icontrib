{-# LANGUAGE OverloadedStrings, GeneralizedNewtypeDeriving, DeriveDataTypeable, TemplateHaskell #-}
module Data.Paypal where
import Data.Time.Format                      ( parseTime )
import Data.Time.Clock                       ( UTCTime )
import Text.Email.Validate                   ( EmailAddress, validate )
import System.Locale                         ( defaultTimeLocale )

newtype Cents = Cents Int
              deriving Num
newtype Email = Email EmailAddress

data Payment = Payment { reciever_email :: Email
                       , txn_id         :: String
                       , payer_email    :: Email
                       , payment_fee    :: Cents
                       , payment_gross  :: Cents
                       , payment_date   :: UTCTime
                       }
              deriving (Eq, Ord, Show, Data, Typeable)
instance Indexable Payment where
    empty = ixSet [ ixFun $ \ix -> (txn_id ix)
                  ]

$(deriveSafeCopy 0 'base ''Payment)
type PaymentDB = IxSet Payment

data IPNMessage = IPNMessage { urlParams :: [(String,String)] }
                  deriving (Eq, Ord, Show, Data, Typeable)

instance Indexable IPNMessage where
    empty = ixSet [ ixFun $ \ci -> unzip (urlParams ci)
                  ]
$(deriveSafeCopy 0 'base ''IPNMessage)
type IPNMessageDB = IxSet IPNMessage


newtype CharityPaypalAddress = CharityPaypalAddress Email
                             deriving (Eq, Ord, Show, Data, Typeable)
newtype UserPaypalAddress = UserPaypalAddress Email
                          deriving (Eq, Ord, Show, Data, Typeable)

data Deposit = Deposit { userAddr :: UserPaypalAddress,
                       , charityAddr :: CharityPaypalAddress,
                       , cents :: Cents,
                       , time :: UTCTime
                       }
             deriving (Eq, Ord, Show, Data, Typeable)

instance Indexable Deposit where
    empty = ixSet [ ixFun $ \ix -> (userAddr ix)
                  ]

$(deriveSafeCopy 0 'base ''Deposit)
type DepositDB = IxSet Desposit

data Withdraw = Withdraw { reciever :: Email, 
                         , deposits :: [Deposit]
                         }
             deriving (Eq, Ord, Show, Data, Typeable)

instance Indexable Withdraw where
    empty = ixSet [ ixFun $ \ix -> (reciever ix)
                  , ixFun $\ ix -> (sum (map cents (deposits ix))) 
                  ]

$(deriveSafeCopy 0 'base ''Withdraw)
type WithdrawDB = IxSet Withdraw


class Parse a where
    parse :: MonadError String m => String -> m a

instance Parse PaymentStatus where
    parse 
        | (downcase str) == "completed" = Completed
    parse  = throwError $ "unexpected payment status: " ++ str

instance Parse UTCTime where
    parse str = parseTime defaultTimeLocale "%H:%M:%S %b %d, %Y %Z" str `justOr` (throwError $ "couldn't parse time string" ++ str)

instance Parse Email where
    parse str = Email `ap` (validate $ str)

instance Parse Cents where
    parse str = do
        let fl :: Float 
            fl = (read str) * 100
        when ((floor fl) /= fl) $ throwError $ "float parsing error to cents" ++ str
        return $ Cents (fromRational str) 


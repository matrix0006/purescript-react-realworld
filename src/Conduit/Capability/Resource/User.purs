module Conduit.Capability.Resource.User where

import Prelude
import Conduit.Data.Error (Error)
import Conduit.Data.User (CurrentUser, User)
import Conduit.Data.Username (Username)
import Data.Either (Either)
import React.Halo (HaloM, lift)

type UserInstance m
  = { loginUser :: { email :: String, password :: String } -> m (Either Error CurrentUser)
    , registerUser :: { username :: Username, email :: String, password :: String } -> m (Either Error CurrentUser)
    , updateUser :: { | User ( password :: String ) } -> m (Either Error CurrentUser)
    , logoutUser :: m Unit
    }

class
  Monad m <= UserRepository m where
  loginUser :: { email :: String, password :: String } -> m (Either Error CurrentUser)
  registerUser :: { username :: Username, email :: String, password :: String } -> m (Either Error CurrentUser)
  updateUser :: { | User ( password :: String ) } -> m (Either Error CurrentUser)
  logoutUser :: m Unit

instance userRepositoryHaloM :: UserRepository m => UserRepository (HaloM props state action m) where
  loginUser = lift <<< loginUser
  registerUser = lift <<< registerUser
  updateUser = lift <<< updateUser
  logoutUser = lift logoutUser

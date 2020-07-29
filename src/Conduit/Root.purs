module Conduit.Root where

import Prelude
import Conduit.Component.App as App
import Conduit.Component.Header (header)
import Conduit.Control.Routing (Completed, Pending, Routing, continue, redirect)
import Conduit.Data.Route (Route(..))
import Conduit.Env (Env)
import Conduit.Hook.Routing (useRoute)
import Conduit.Hook.User (useUser)
import Conduit.Page.Home (mkHomePage)
import Conduit.Page.Login (mkLoginPage)
import Conduit.Page.Settings (mkSettingsPage)
import Conduit.State.User (UserState)
import Control.Monad.Indexed.Qualified as Ix
import Data.Maybe (Maybe(..))
import Data.Tuple (fst)
import Effect.Class (liftEffect)
import React.Basic.DOM as R
import React.Basic.Hooks as React
import Wire.React.Class (read) as Wire

mkRoot :: App.Component Env Unit
mkRoot = do
  homePage <- mkHomePage
  loginPage <- mkLoginPage
  settingsPage <- mkSettingsPage
  App.component' "Root" \env props -> React.do
    user <- useUser env
    route <- useRoute env
    pure
      $ React.fragment
          [ header user route
          , case route of
              Home -> do
                homePage unit
              Login -> do
                loginPage unit
              Settings -> do
                settingsPage unit
              Error -> do
                R.text "Error"
              _ -> do
                React.empty
          ]

onNavigate :: UserState -> Route -> Routing Pending Completed Unit
onNavigate userState route = Ix.do
  auth <- (liftEffect :: _ -> _ Pending Pending _) $ fst <$> Wire.read userState
  case route, auth of
    Login, Just _ -> do
      redirect Home
    Settings, Nothing -> do
      redirect Home
    _, _ -> do
      continue
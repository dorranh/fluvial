{-# LANGUAGE TemplateHaskell #-}

module Main where

import Hedgehog
import Hedgehog.Main
import Fluvial

prop_test :: Property
prop_test = property $ do
  doFluvial === "Fluvial"

main :: IO ()
main = defaultMain [checkParallel $$(discover)]

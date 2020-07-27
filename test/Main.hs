{-# LANGUAGE TemplateHaskell #-}

module Main where

import Hedgehog
import Hedgehog.Main
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

import Fluvial
import Fluvial.Grid
import Data.Matrix

prop_test :: Property
prop_test = property $ do
  doFluvial === "Fluvial"


-- Generate grids
-- Get i,j coords
-- Get values for coords
-- Assert equal
genIntList :: Gen Matrix Int
genIntList = 
  let listLength = Range.linear 2 5
  in Gen listLength (\x -> fromList $ replicate (length x) x)

prop_ix_to_ij :: Property
prop_ix_to_ij = 
  property $ do 
    grid <- forAll genIntList
    map ((\x -> grid ! x) . (\x -> ixToIJ x grid)) [1..(nelem grid)] === toList grid

main :: IO ()
main = defaultMain [checkParallel $$(discover)]

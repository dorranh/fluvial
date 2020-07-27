module Main where

import Fluvial.Grid
import Data.Matrix
import System.Process
import System.IO
import Codec.Picture
import Codec.Picture.Types
-- main =
-- --   print test
-- main = do 
--   (_, Just hout, _, _) <- createProcess (proc "gdalinfo" ["/home/dorran/scratch/haskell/fluvial/ASTGTMV003_N46E007/ASTGTMV003_N46E007_dem.tif", "-json"]){ std_out = CreatePipe }
--   text <- hGetContents hout
--   putStr text

main = do 
  img <- readTiff "/home/dorran/scratch/haskell/fluvial/ASTGTMV003_N46E007/plain_ASTGTMV003_N46E007_dem.tif"
  case img of
    Left err -> print $ "Couldnt read the image :( " ++ err
    Right img -> print (dynamicMap imageWidth img )

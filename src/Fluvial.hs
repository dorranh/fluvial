module Fluvial where

import Data.Matrix
import Codec.Picture.Tiff
import Codec.Picture

doFluvial :: String
doFluvial = "Fluvial"

-- loadDEM :: String -> Ve
-- loadDEM path = do 
--     img <- readImage path
--     case img of 
--         Left _ -> return ()
--         Right img -> imageData img

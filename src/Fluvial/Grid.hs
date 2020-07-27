module Fluvial.Grid where

import Data.Matrix
import Data.Fixed 
import Data.List
import Data.Ord (comparing)


type Grid = Matrix
type CellXY = Matrix (Double, Double)
type DEM = Matrix Double
type Flow = Matrix Int 

-- TODO: These simple examples can go into the tests
exampleXY :: CellXY
exampleXY = fromLists [ [(0.0, 3.0), (1.0, 3.0), (2.0, 3.0), (3.0, 3.0)],
                        [(0.0, 2.0), (1.0, 2.0), (2.0, 2.0), (3.0, 2.0)],
                        [(0.0, 1.0), (1.0, 1.0), (2.0, 1.0), (3.0, 1.0)],
                        [(0.0, 0.0), (1.0, 0.0), (2.0, 0.0), (3.0, 0.0)] ]

exampleDEM :: DEM
exampleDEM = fromLists [ [10.0, 10.0, 10.0, 10.0] ,
                         [10.0, 8.0, 8.0, 6.0],
                         [10.0, 8.0, 5.0, 6.0],
                         [10.0, 6.0, 6.0, 3.0] ]



-- TODO: This returns values even if the indices are out of range
ixToIJ :: Int -> Grid a -> (Int, Int)
ixToIJ ix grid = let
    nr = fromInteger $ fromIntegral $ nrows grid :: Double 
    nc = fromInteger $ fromIntegral $ ncols grid :: Double
    c =  mod' (fromIntegral ix - 1.0) nc + 1.0 in
        (round $ mod' ((fromIntegral ix - c) / nc) nr + 1, round c)

nelem :: Grid a -> Int
nelem grid = fromIntegral $ nrows grid * ncols grid

-- D8 Algorithm:
-- 1  2  3 
-- 8  X  4
-- 7  6  5
--
-- id, di, dj, distance
type Neighbor = (Int, Int, Int, Double)
neighborsD8 :: [Neighbor]
neighborsD8 = [
    (1, -1, -1, sqrt 2),
    (2, -1, 0, 1),
    (3, -1, 1, sqrt 2),
    (4, 0, 1, 1),
    (5, 1, 1, sqrt 2),
    (6, 1, 0, 1),
    (7, 1, -1, sqrt 2),
    (8, 0, -1, 1)]

neighborGradient :: Int -> DEM -> Neighbor -> Double
neighborGradient ix grid neighbor = 
    let 
        (_, di, dj, dist) = neighbor 
        (i, j) = ixToIJ ix grid
        ni = i + di
        nj = j + dj
        val = getElem i j grid
        nval = safeGet ni nj grid
    in case nval of 
        Just v -> (v - val) / dist
        -- Cells outside of domain are considered to have the same elevation as the
        -- cell of interest.
        Nothing -> 0.0

neighborGradients :: Int -> DEM -> [Neighbor] -> [Double]
neighborGradients ix grid = map (neighborGradient ix grid)

flowValue :: Int -> DEM -> [Neighbor] -> Int
flowValue ix dem ns = let 
        (steepestNeighbor, _, _, _) = ns !! fst (minimumBy (comparing snd) $ zip [0..] $ neighborGradients ix dem ns )
    in steepestNeighbor

addTuple :: (Num a, Num b) => (a, b) -> (a, b) -> (a, b)
addTuple (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

demToFlow :: DEM -> [Neighbor] -> Flow
demToFlow dem ns = fromList (nrows dem) (ncols dem) (map (\ix -> flowValue ix dem ns :: Int) [1..(nelem dem)])

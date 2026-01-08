module Lec_1_8_26 where

bob :: (Integer, Bool)
bob = (10 + 12, True)

bob3 :: (Integer, Bool, Char)
bob3 = (10 + 12, True, 'd')


nextThree :: Int -> [Int]
nextThree n = [n, n + 1, n + 2, n + 3]

nextK n 0 =                      [n]
nextK n 1 =               [n, n + 1]
nextK n 2 =        [n, n + 1, n + 2]
nextK n 3 = [n, n + 1, n + 2, n + 3]
nextK n _ = error "OH NO!!!!"

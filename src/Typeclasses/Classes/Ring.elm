module Typeclasses.Classes.Ring exposing
    ( Ring
    , numberRing, trivialRing, exclusiveOrRing
    , CommutativeRing(..)
    )

{-| Ring typeclass definition and its instances for basic types.


# Definition

@docs Ring

#Instances

@docs numberRing, trivialRing, exclusiveOrRing

-}

import Typeclasses.Classes.AbelianGroup
import Typeclasses.Classes.CommutativeMonoid
import Typeclasses.Classes.Group
import Typeclasses.Classes.Monoid


{-| Explicit typeclass which implements group operations for type `a`.
-}
type alias Ring a =
    { addition : Typeclasses.Classes.AbelianGroup.AbelianGroup a
    , multiplication : Typeclasses.Classes.Monoid.Monoid a
    }


type CommutativeRing a
    = CommutativeRing
        { addition : Typeclasses.Classes.AbelianGroup.AbelianGroup a
        , multiplication : Typeclasses.Classes.CommutativeMonoid.CommutativeMonoid a
        }


{-| Construct real number ring
-}
numberRing : CommutativeRing number
numberRing =
    { addition = Typeclasses.Classes.AbelianGroup.numberSum
    , multiplication = Typeclasses.Classes.CommutativeMonoid.numberProduct
    }
        |> CommutativeRing


{-| Construct trivial ring
-}
trivialRing : CommutativeRing ()
trivialRing =
    { addition = Typeclasses.Classes.AbelianGroup.trivialGroup
    , multiplication = Typeclasses.Classes.CommutativeMonoid.unit
    }
        |> CommutativeRing


{-| Construct exclusive all ring
-}
exclusiveOrRing : CommutativeRing Bool
exclusiveOrRing =
    { addition = Typeclasses.Classes.AbelianGroup.exclusiveOr
    , multiplication = Typeclasses.Classes.CommutativeMonoid.all
    }
        |> CommutativeRing

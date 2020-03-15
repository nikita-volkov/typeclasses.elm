module Typeclasses.Classes.Monoid exposing
    ( Monoid
    , identityAndConcat, semigroupAndIdentity, appendable, numberProduct, numberSum
    , map
    , intProduct, intSum, string, maybeFirst, list, setUnion, setDifference, cmd, sub, task, all, any, composition, unit, exclusiveOr, modularArithmetic
    , CommutativeMonoid(..)
    )

{-| Monoid typeclass definition and its instances for basic types.


# Definition

@docs Monoid


# Construction utilities

@docs identityAndConcat, semigroupAndIdentity, appendable, numberProduct, numberSum


# Instance transformation utilities

@docs map


# Instances

@docs intProduct, intSum, string, maybeFirst, list, setUnion, setDifference, cmd, sub, task, all, any, composition, unit, exclusiveOr, modularArithmetic

-}

import Either exposing (Either(..))
import Set exposing (Set)
import Task exposing (Task)
import Typeclasses.Classes.Semigroup as Semigroup exposing (Semigroup)


{-| Explicit typeclass which implements monoid operations for type `a`.
-}
type alias Monoid a =
    { semigroup : Semigroup a
    , identity : a
    , concat : List a -> a
    }


type CommutativeMonoid a
    = CommutativeMonoid
        { semigroup : Semigroup.CommutativeSemigroup a
        , identity : a
        , concat : List a -> a
        }



-- * Construction utilities
-------------------------


{-| Construct an instance by specifying identity value and a concatenation operation.
-}
identityAndConcat : a -> (List a -> a) -> Monoid a
identityAndConcat identity concat =
    { semigroup = Semigroup.concat concat
    , identity = identity
    , concat = concat
    }


{-| Construct an instance by specifying a semigroup instance and an identity value.
-}
semigroupAndIdentity : Semigroup a -> a -> Monoid a
semigroupAndIdentity semigroup identity =
    { semigroup = semigroup
    , identity = identity
    , concat = List.foldl semigroup.prepend identity
    }


{-| Construct an instance by specifying a commutative semigroup instance and an identity value.
-}
commutativeSemigroupAndIdentity : Semigroup.CommutativeSemigroup a -> a -> CommutativeMonoid a
commutativeSemigroupAndIdentity commutativeSemigroup identity =
    let
        (Semigroup.CommutativeSemigroup semigroup) =
            commutativeSemigroup
    in
    { semigroup = commutativeSemigroup
    , identity = identity
    , concat = List.foldl semigroup.prepend identity
    }
        |> CommutativeMonoid


{-| Construct an instance for any type which satisfies Elm's `appendable` magic constraint,
by providing an identity value.
-}
appendable : appendable -> Monoid appendable
appendable =
    semigroupAndIdentity Semigroup.appendable


{-| Construct an instance for any type which satisfies Elm's `number` magic constraint.
Implements multiplication.
-}
numberProduct : CommutativeMonoid number
numberProduct =
    { semigroup = Semigroup.numberProduct, identity = 1, concat = List.product }
        |> CommutativeMonoid


{-| Construct an instance for any type which satisfies Elm's `number` magic constraint.
Implements sum.
-}
numberSum : CommutativeMonoid number
numberSum =
    { semigroup = Semigroup.numberSum, identity = 0, concat = List.sum }
        |> CommutativeMonoid



-- * Transformation utilities
-------------------------


{-| Map over the owner type of an instance to produce a new instance.

You need to provide both a covariant and a contravariant mapping
(i.e., `(a -> b)` and `(b -> a)`).

-}
map : (a -> b) -> (b -> a) -> Monoid a -> Monoid b
map aToB bToA monoidOfA =
    semigroupAndIdentity
        (Semigroup.map aToB bToA monoidOfA.semigroup)
        (aToB monoidOfA.identity)



-- * Instances
-------------------------


{-| Instance for integers under the multiplication operation.
-}
intProduct : CommutativeMonoid Int
intProduct =
    numberProduct


{-| Instance for integers under the sum operation.
-}
intSum : CommutativeMonoid Int
intSum =
    numberSum


{-| Instance for strings under the appending operation.
-}
string : Monoid String
string =
    appendable ""


{-| Instance for maybe, which chooses the first `Just` value.
-}
maybeFirst : Monoid (Maybe a)
maybeFirst =
    semigroupAndIdentity Semigroup.maybeFirst Nothing


{-| Instance for list under concatenation.
-}
list : Monoid (List a)
list =
    appendable []


{-| Instance for set under the union operation.
-}
setUnion : Monoid (Set comparable)
setUnion =
    let
        (Semigroup.CommutativeSemigroup setUnionSemigroup) =
            Semigroup.setUnion
    in
    semigroupAndIdentity setUnionSemigroup Set.empty


{-| Instance for set under the difference operation.
-}
setDifference : Monoid (Set comparable)
setDifference =
    semigroupAndIdentity Semigroup.setDifference Set.empty


{-| Instance for commands under the batch operation.
-}
cmd : Monoid (Cmd msg)
cmd =
    identityAndConcat Cmd.none Cmd.batch


{-| Instance for subscriptions under the batch operation.
-}
sub : Monoid (Sub msg)
sub =
    identityAndConcat Sub.none Sub.batch


{-| Instance for tasks, which sequentially executes them and groups the results.
-}
task : Monoid a -> Monoid (Task x a)
task monoidOfA =
    { semigroup = Semigroup.task monoidOfA.semigroup
    , identity = Task.succeed monoidOfA.identity
    , concat = Task.sequence >> Task.map monoidOfA.concat
    }


{-| Instance for all
-}
all : CommutativeMonoid Bool
all =
    commutativeSemigroupAndIdentity Semigroup.and True


{-| Instance for any
-}
any : CommutativeMonoid Bool
any =
    commutativeSemigroupAndIdentity Semigroup.or False


{-| Instance for a -> a function
-}
composition : Monoid (a -> a)
composition =
    semigroupAndIdentity Semigroup.composition Basics.identity


{-| Instance for trivial monoid
-}
unit : CommutativeMonoid ()
unit =
    commutativeSemigroupAndIdentity Semigroup.unit ()


{-| Instance for exclusiveOr
-}
exclusiveOr : CommutativeMonoid Bool
exclusiveOr =
    commutativeSemigroupAndIdentity Semigroup.xor False


{-| Instance for modularArithmetic
-}
modularArithmetic : Int -> CommutativeMonoid Int
modularArithmetic divisor =
    commutativeSemigroupAndIdentity (Semigroup.modularArithmetic divisor) 0

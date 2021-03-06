-- Haskell data types for the abstract syntax.
-- Generated by the BNF converter.

{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE PatternSynonyms #-}

-- | The abstract syntax of language grammar.

module Grammar.Abs where

import Prelude (Integer, String)
import qualified Prelude as C
  ( Eq, Ord, Show, Read
  , Functor, Foldable, Traversable
  , Int, Maybe(..)
  )
import qualified Data.String

type Program = Program' BNFC'Position
data Program' a = Prog a [TopDef' a]
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type TopDef = TopDef' BNFC'Position
data TopDef' a
    = FuncDefT a Ident [Arg' a] (Type' a) (Block' a)
    | FuncDef a Ident [Arg' a] (Block' a)
    | GlobalDcl a (Decl' a)
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Arg = Arg' BNFC'Position
data Arg' a = Ar a [Ident] (Type' a)
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Block = Block' BNFC'Position
data Block' a = Blk a [Stmt' a]
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Stmt = Stmt' BNFC'Position
data Stmt' a
    = Empty a
    | BStmt a (Block' a)
    | DStmt a (Decl' a)
    | Ass a [Expr' a] [Expr' a]
    | For a (Stmt' a) (Expr' a) (Stmt' a) (Block' a)
    | ForExpr a (Expr' a) (Block' a)
    | Incr a Ident
    | Decr a Ident
    | Ret a (Expr' a)
    | VoidRet a
    | Cond a (Expr' a) (Block' a)
    | CondElse a (Expr' a) (Block' a) (Block' a)
    | Print a [Expr' a]
    | SExp a (Expr' a)
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Decl = Decl' BNFC'Position
data Decl' a
    = Dcl a [Ident] (Type' a)
    | DclInit a [Ident] [Expr' a]
    | DclInitT a [Ident] (Type' a) [Expr' a]
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Type = Type' BNFC'Position
data Type' a
    = Int a
    | Str a
    | Bool a
    | FuncLitT a [Type' a] (Type' a)
    | FuncLit a [Type' a]
    | Ptr a (Type' a)
    | Void a
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type Expr = Expr' BNFC'Position
data Expr' a
    = EApp a Ident [Expr' a]
    | ELitFunT a [Arg' a] (Type' a) (Block' a)
    | ELitFun a [Arg' a] (Block' a)
    | ELitFunApp a (Expr' a) [Expr' a]
    | EVar a Ident
    | ELitInt a Integer
    | ELitTrue a
    | ELitFalse a
    | EString a String
    | ELitNil a
    | Ref a (Expr' a)
    | Deref a (Expr' a)
    | Neg a (Expr' a)
    | Not a (Expr' a)
    | EMul a (Expr' a) (MulOp' a) (Expr' a)
    | EAdd a (Expr' a) (AddOp' a) (Expr' a)
    | ERel a (Expr' a) (RelOp' a) (Expr' a)
    | EAnd a (Expr' a) (Expr' a)
    | EOr a (Expr' a) (Expr' a)
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type AddOp = AddOp' BNFC'Position
data AddOp' a = Plus a | Minus a
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type MulOp = MulOp' BNFC'Position
data MulOp' a = Times a | Div a | Mod a
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

type RelOp = RelOp' BNFC'Position
data RelOp' a = LTH a | LE a | GTH a | GE a | EQU a | NE a
  deriving (C.Eq, C.Ord, C.Show, C.Read, C.Functor, C.Foldable, C.Traversable)

newtype Ident = Ident String
  deriving (C.Eq, C.Ord, C.Show, C.Read, Data.String.IsString)

-- | Start position (line, column) of something.

type BNFC'Position = C.Maybe (C.Int, C.Int)

pattern BNFC'NoPosition :: BNFC'Position
pattern BNFC'NoPosition = C.Nothing

pattern BNFC'Position :: C.Int -> C.Int -> BNFC'Position
pattern BNFC'Position line col = C.Just (line, col)

-- | Get the start position of something.

class HasPosition a where
  hasPosition :: a -> BNFC'Position

instance HasPosition Program where
  hasPosition = \case
    Prog p _ -> p

instance HasPosition TopDef where
  hasPosition = \case
    FuncDefT p _ _ _ _ -> p
    FuncDef p _ _ _ -> p
    GlobalDcl p _ -> p

instance HasPosition Arg where
  hasPosition = \case
    Ar p _ _ -> p

instance HasPosition Block where
  hasPosition = \case
    Blk p _ -> p

instance HasPosition Stmt where
  hasPosition = \case
    Empty p -> p
    BStmt p _ -> p
    DStmt p _ -> p
    Ass p _ _ -> p
    For p _ _ _ _ -> p
    ForExpr p _ _ -> p
    Incr p _ -> p
    Decr p _ -> p
    Ret p _ -> p
    VoidRet p -> p
    Cond p _ _ -> p
    CondElse p _ _ _ -> p
    Print p _ -> p
    SExp p _ -> p

instance HasPosition Decl where
  hasPosition = \case
    Dcl p _ _ -> p
    DclInit p _ _ -> p
    DclInitT p _ _ _ -> p

instance HasPosition Type where
  hasPosition = \case
    Int p -> p
    Str p -> p
    Bool p -> p
    FuncLitT p _ _ -> p
    FuncLit p _ -> p
    Ptr p _ -> p
    Void p -> p

instance HasPosition Expr where
  hasPosition = \case
    EApp p _ _ -> p
    ELitFunT p _ _ _ -> p
    ELitFun p _ _ -> p
    ELitFunApp p _ _ -> p
    EVar p _ -> p
    ELitInt p _ -> p
    ELitTrue p -> p
    ELitFalse p -> p
    EString p _ -> p
    ELitNil p -> p
    Ref p _ -> p
    Deref p _ -> p
    Neg p _ -> p
    Not p _ -> p
    EMul p _ _ _ -> p
    EAdd p _ _ _ -> p
    ERel p _ _ _ -> p
    EAnd p _ _ -> p
    EOr p _ _ -> p

instance HasPosition AddOp where
  hasPosition = \case
    Plus p -> p
    Minus p -> p

instance HasPosition MulOp where
  hasPosition = \case
    Times p -> p
    Div p -> p
    Mod p -> p

instance HasPosition RelOp where
  hasPosition = \case
    LTH p -> p
    LE p -> p
    GTH p -> p
    GE p -> p
    EQU p -> p
    NE p -> p


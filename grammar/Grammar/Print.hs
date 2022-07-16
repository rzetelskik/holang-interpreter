{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif

{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for Grammar.
--   Generated by the BNF converter.

module Grammar.Print where

import Prelude
  ( ($), (.)
  , Bool(..), (==), (<)
  , Int, Integer, Double, (+), (-), (*)
  , String, (++)
  , ShowS, showChar, showString
  , all, dropWhile, elem, foldr, id, map, null, replicate, shows, span
  )
import Data.Char ( Char, isSpace )
import qualified Grammar.Abs

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i = \case
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    [";"]        -> showChar ';'
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i     = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t s =
    case (all isSpace t', null spc, null rest) of
      (True , _   , True ) -> []              -- remove trailing space
      (False, _   , True ) -> t'              -- remove trailing space
      (False, True, False) -> t' ++ ' ' : s   -- add space if none
      _                    -> t' ++ s
    where
      t'          = showString t []
      (spc, rest) = span isSpace s

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt     _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q = \case
  s | s == q -> showChar '\\' . showChar s
  '\\' -> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  s -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print Grammar.Abs.Ident where
  prt _ (Grammar.Abs.Ident i) = doc $ showString i
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print (Grammar.Abs.Program' a) where
  prt i = \case
    Grammar.Abs.Prog _ topdefs -> prPrec i 0 (concatD [prt 0 topdefs])

instance Print (Grammar.Abs.TopDef' a) where
  prt i = \case
    Grammar.Abs.FuncDefT _ id_ args type_ block -> prPrec i 0 (concatD [doc (showString "func"), prt 0 id_, doc (showString "("), prt 0 args, doc (showString ")"), prt 0 type_, prt 0 block])
    Grammar.Abs.FuncDef _ id_ args block -> prPrec i 0 (concatD [doc (showString "func"), prt 0 id_, doc (showString "("), prt 0 args, doc (showString ")"), prt 0 block])
    Grammar.Abs.GlobalDcl _ decl -> prPrec i 0 (concatD [prt 0 decl])
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [Grammar.Abs.TopDef' a] where
  prt = prtList

instance Print (Grammar.Abs.Arg' a) where
  prt i = \case
    Grammar.Abs.Ar _ ids type_ -> prPrec i 0 (concatD [prt 0 ids, prt 0 type_])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [Grammar.Abs.Ident] where
  prt = prtList

instance Print [Grammar.Abs.Arg' a] where
  prt = prtList

instance Print (Grammar.Abs.Block' a) where
  prt i = \case
    Grammar.Abs.Blk _ stmts -> prPrec i 0 (concatD [doc (showString "{"), prt 0 stmts, doc (showString "}")])

instance Print [Grammar.Abs.Stmt' a] where
  prt = prtList

instance Print (Grammar.Abs.Stmt' a) where
  prt i = \case
    Grammar.Abs.Empty _ -> prPrec i 0 (concatD [doc (showString ";")])
    Grammar.Abs.BStmt _ block -> prPrec i 0 (concatD [prt 0 block])
    Grammar.Abs.DStmt _ decl -> prPrec i 0 (concatD [prt 0 decl])
    Grammar.Abs.Ass _ exprs1 exprs2 -> prPrec i 0 (concatD [prt 0 exprs1, doc (showString "="), prt 0 exprs2, doc (showString ";")])
    Grammar.Abs.For _ stmt1 expr stmt2 block -> prPrec i 0 (concatD [doc (showString "for"), prt 0 stmt1, prt 0 expr, doc (showString ";"), prt 0 stmt2, prt 0 block])
    Grammar.Abs.ForExpr _ expr block -> prPrec i 0 (concatD [doc (showString "for"), prt 0 expr, prt 0 block])
    Grammar.Abs.Incr _ id_ -> prPrec i 0 (concatD [prt 0 id_, doc (showString "++"), doc (showString ";")])
    Grammar.Abs.Decr _ id_ -> prPrec i 0 (concatD [prt 0 id_, doc (showString "--"), doc (showString ";")])
    Grammar.Abs.Ret _ expr -> prPrec i 0 (concatD [doc (showString "return"), prt 0 expr, doc (showString ";")])
    Grammar.Abs.VoidRet _ -> prPrec i 0 (concatD [doc (showString "return"), doc (showString ";")])
    Grammar.Abs.Cond _ expr block -> prPrec i 0 (concatD [doc (showString "if"), prt 0 expr, prt 0 block])
    Grammar.Abs.CondElse _ expr block1 block2 -> prPrec i 0 (concatD [doc (showString "if"), prt 0 expr, prt 0 block1, doc (showString "else"), prt 0 block2])
    Grammar.Abs.Print _ exprs -> prPrec i 0 (concatD [doc (showString "print"), doc (showString "("), prt 0 exprs, doc (showString ")"), doc (showString ";")])
    Grammar.Abs.SExp _ expr -> prPrec i 0 (concatD [prt 0 expr, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print (Grammar.Abs.Decl' a) where
  prt i = \case
    Grammar.Abs.Dcl _ ids type_ -> prPrec i 0 (concatD [doc (showString "var"), prt 0 ids, prt 0 type_, doc (showString ";")])
    Grammar.Abs.DclInit _ ids exprs -> prPrec i 0 (concatD [doc (showString "var"), prt 0 ids, doc (showString "="), prt 0 exprs, doc (showString ";")])
    Grammar.Abs.DclInitT _ ids type_ exprs -> prPrec i 0 (concatD [doc (showString "var"), prt 0 ids, prt 0 type_, doc (showString "="), prt 0 exprs, doc (showString ";")])

instance Print (Grammar.Abs.Type' a) where
  prt i = \case
    Grammar.Abs.Int _ -> prPrec i 0 (concatD [doc (showString "int")])
    Grammar.Abs.Str _ -> prPrec i 0 (concatD [doc (showString "string")])
    Grammar.Abs.Bool _ -> prPrec i 0 (concatD [doc (showString "bool")])
    Grammar.Abs.FuncLitT _ types type_ -> prPrec i 0 (concatD [doc (showString "func"), doc (showString "("), prt 0 types, doc (showString ")"), prt 0 type_])
    Grammar.Abs.FuncLit _ types -> prPrec i 0 (concatD [doc (showString "func"), doc (showString "("), prt 0 types, doc (showString ")")])
    Grammar.Abs.Ptr _ type_ -> prPrec i 0 (concatD [doc (showString "*"), prt 0 type_])
    Grammar.Abs.Void _ -> prPrec i 0 (concatD [doc (showString "void")])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [Grammar.Abs.Type' a] where
  prt = prtList

instance Print (Grammar.Abs.Expr' a) where
  prt i = \case
    Grammar.Abs.EApp _ id_ exprs -> prPrec i 8 (concatD [prt 0 id_, doc (showString "("), prt 0 exprs, doc (showString ")")])
    Grammar.Abs.ELitFunT _ args type_ block -> prPrec i 7 (concatD [doc (showString "func"), doc (showString "("), prt 0 args, doc (showString ")"), prt 0 type_, prt 0 block])
    Grammar.Abs.ELitFun _ args block -> prPrec i 7 (concatD [doc (showString "func"), doc (showString "("), prt 0 args, doc (showString ")"), prt 0 block])
    Grammar.Abs.ELitFunApp _ expr exprs -> prPrec i 6 (concatD [prt 7 expr, doc (showString "("), prt 0 exprs, doc (showString ")")])
    Grammar.Abs.EVar _ id_ -> prPrec i 6 (concatD [prt 0 id_])
    Grammar.Abs.ELitInt _ n -> prPrec i 6 (concatD [prt 0 n])
    Grammar.Abs.ELitTrue _ -> prPrec i 6 (concatD [doc (showString "true")])
    Grammar.Abs.ELitFalse _ -> prPrec i 6 (concatD [doc (showString "false")])
    Grammar.Abs.EString _ str -> prPrec i 6 (concatD [prt 0 str])
    Grammar.Abs.ELitNil _ -> prPrec i 6 (concatD [doc (showString "nil")])
    Grammar.Abs.Ref _ expr -> prPrec i 5 (concatD [doc (showString "&"), prt 6 expr])
    Grammar.Abs.Deref _ expr -> prPrec i 5 (concatD [doc (showString "*"), prt 6 expr])
    Grammar.Abs.Neg _ expr -> prPrec i 5 (concatD [doc (showString "-"), prt 6 expr])
    Grammar.Abs.Not _ expr -> prPrec i 5 (concatD [doc (showString "!"), prt 6 expr])
    Grammar.Abs.EMul _ expr1 mulop expr2 -> prPrec i 4 (concatD [prt 4 expr1, prt 0 mulop, prt 5 expr2])
    Grammar.Abs.EAdd _ expr1 addop expr2 -> prPrec i 3 (concatD [prt 3 expr1, prt 0 addop, prt 4 expr2])
    Grammar.Abs.ERel _ expr1 relop expr2 -> prPrec i 2 (concatD [prt 2 expr1, prt 0 relop, prt 3 expr2])
    Grammar.Abs.EAnd _ expr1 expr2 -> prPrec i 1 (concatD [prt 2 expr1, doc (showString "&&"), prt 1 expr2])
    Grammar.Abs.EOr _ expr1 expr2 -> prPrec i 0 (concatD [prt 1 expr1, doc (showString "||"), prt 0 expr2])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [Grammar.Abs.Expr' a] where
  prt = prtList

instance Print (Grammar.Abs.AddOp' a) where
  prt i = \case
    Grammar.Abs.Plus _ -> prPrec i 0 (concatD [doc (showString "+")])
    Grammar.Abs.Minus _ -> prPrec i 0 (concatD [doc (showString "-")])

instance Print (Grammar.Abs.MulOp' a) where
  prt i = \case
    Grammar.Abs.Times _ -> prPrec i 0 (concatD [doc (showString "*")])
    Grammar.Abs.Div _ -> prPrec i 0 (concatD [doc (showString "/")])
    Grammar.Abs.Mod _ -> prPrec i 0 (concatD [doc (showString "%")])

instance Print (Grammar.Abs.RelOp' a) where
  prt i = \case
    Grammar.Abs.LTH _ -> prPrec i 0 (concatD [doc (showString "<")])
    Grammar.Abs.LE _ -> prPrec i 0 (concatD [doc (showString "<=")])
    Grammar.Abs.GTH _ -> prPrec i 0 (concatD [doc (showString ">")])
    Grammar.Abs.GE _ -> prPrec i 0 (concatD [doc (showString ">=")])
    Grammar.Abs.EQU _ -> prPrec i 0 (concatD [doc (showString "==")])
    Grammar.Abs.NE _ -> prPrec i 0 (concatD [doc (showString "!=")])

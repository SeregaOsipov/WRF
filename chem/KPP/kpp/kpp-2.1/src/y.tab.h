/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    JACOBIAN = 258,
    DOUBLE = 259,
    FUNCTION = 260,
    DEFVAR = 261,
    DEFRAD = 262,
    DEFFIX = 263,
    SETVAR = 264,
    SETRAD = 265,
    SETFIX = 266,
    HESSIAN = 267,
    STOICMAT = 268,
    STOCHASTIC = 269,
    INITVALUES = 270,
    EQUATIONS = 271,
    LUMP = 272,
    INIEQUAL = 273,
    EQNEQUAL = 274,
    EQNCOLON = 275,
    LMPCOLON = 276,
    LMPPLUS = 277,
    SPCPLUS = 278,
    SPCEQUAL = 279,
    ATOMDECL = 280,
    CHECK = 281,
    CHECKALL = 282,
    REORDER = 283,
    MEX = 284,
    DUMMYINDEX = 285,
    EQNTAGS = 286,
    LOOKAT = 287,
    LOOKATALL = 288,
    TRANSPORT = 289,
    TRANSPORTALL = 290,
    MONITOR = 291,
    USES = 292,
    SPARSEDATA = 293,
    WRFCONFORM = 294,
    WRITE_ATM = 295,
    WRITE_SPC = 296,
    WRITE_MAT = 297,
    WRITE_OPT = 298,
    INITIALIZE = 299,
    XGRID = 300,
    YGRID = 301,
    ZGRID = 302,
    USE = 303,
    LANGUAGE = 304,
    INTFILE = 305,
    DRIVER = 306,
    RUN = 307,
    INLINE = 308,
    ENDINLINE = 309,
    PARAMETER = 310,
    SPCSPC = 311,
    INISPC = 312,
    INIVALUE = 313,
    EQNSPC = 314,
    EQNSIGN = 315,
    EQNCOEF = 316,
    RATE = 317,
    LMPSPC = 318,
    SPCNR = 319,
    ATOMID = 320,
    LKTID = 321,
    MNIID = 322,
    INLCTX = 323,
    INCODE = 324,
    SSPID = 325,
    EQNLESS = 326,
    EQNTAG = 327,
    EQNGREATER = 328,
    TPTID = 329,
    USEID = 330
  };
#endif
/* Tokens.  */
#define JACOBIAN 258
#define DOUBLE 259
#define FUNCTION 260
#define DEFVAR 261
#define DEFRAD 262
#define DEFFIX 263
#define SETVAR 264
#define SETRAD 265
#define SETFIX 266
#define HESSIAN 267
#define STOICMAT 268
#define STOCHASTIC 269
#define INITVALUES 270
#define EQUATIONS 271
#define LUMP 272
#define INIEQUAL 273
#define EQNEQUAL 274
#define EQNCOLON 275
#define LMPCOLON 276
#define LMPPLUS 277
#define SPCPLUS 278
#define SPCEQUAL 279
#define ATOMDECL 280
#define CHECK 281
#define CHECKALL 282
#define REORDER 283
#define MEX 284
#define DUMMYINDEX 285
#define EQNTAGS 286
#define LOOKAT 287
#define LOOKATALL 288
#define TRANSPORT 289
#define TRANSPORTALL 290
#define MONITOR 291
#define USES 292
#define SPARSEDATA 293
#define WRFCONFORM 294
#define WRITE_ATM 295
#define WRITE_SPC 296
#define WRITE_MAT 297
#define WRITE_OPT 298
#define INITIALIZE 299
#define XGRID 300
#define YGRID 301
#define ZGRID 302
#define USE 303
#define LANGUAGE 304
#define INTFILE 305
#define DRIVER 306
#define RUN 307
#define INLINE 308
#define ENDINLINE 309
#define PARAMETER 310
#define SPCSPC 311
#define INISPC 312
#define INIVALUE 313
#define EQNSPC 314
#define EQNSIGN 315
#define EQNCOEF 316
#define RATE 317
#define LMPSPC 318
#define SPCNR 319
#define ATOMID 320
#define LKTID 321
#define MNIID 322
#define INLCTX 323
#define INCODE 324
#define SSPID 325
#define EQNLESS 326
#define EQNTAG 327
#define EQNGREATER 328
#define TPTID 329
#define USEID 330

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 68 "scan.y" /* yacc.c:1909  */

  char str[500];

#line 208 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */

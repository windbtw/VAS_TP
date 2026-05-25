(* Domaine des constantes de Kildall. *)

(* Treillis :
 *         T
 *    / / |  \ \
 *   .. -1 0 1 ..
 *    \ \ |  / /
 *         _|_
 *
 * gamma(T)     = Z
 * gamma(Cst n) = { n }
 * gamma(Bot)   = vide
 *)
type t =
  | Bot
  | Cst of int
  | Top

let fprint ff = function
  | Bot   -> Format.fprintf ff "_|_"
  | Cst n -> Format.fprintf ff "%d" n
  | Top   -> Format.fprintf ff "T"

(* x ⊑♯ y *)
let order x y = match x, y with
  | Bot, _              -> true
  | _, Top              -> true
  | Cst n, Cst m        -> n = m
  | _, _                -> false

let top = Top
let bottom = Bot

let join x y = match x, y with
  | Bot, z | z, Bot     -> z
  | Top, _ | _, Top     -> Top
  | Cst n, Cst m        -> if n = m then Cst n else Top

let meet x y = match x, y with
  | Top, z | z, Top     -> z
  | Bot, _ | _, Bot     -> Bot
  | Cst n, Cst m        -> if n = m then Cst n else Bot

(* Pas de chaine croissante infinie ; join suffit. *)
let widening = join

(* Abstraction d'un intervalle concret [n1, n2]. *)
let sem_itv n1 n2 =
  if n1 > n2 then Bot
  else if n1 = n2 then Cst n1
  else Top

let sem_plus x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | Cst a, Cst b        -> Cst (a + b)
  | _, _                -> Top

let sem_minus x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | Cst a, Cst b        -> Cst (a - b)
  | _, _                -> Top

let sem_times x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | Cst 0, _ | _, Cst 0 -> Cst 0
  | Cst a, Cst b        -> Cst (a * b)
  | _, _                -> Top

let sem_div x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | _, Cst 0            -> Bot
  | Cst a, Cst b        -> Cst (a / b)
  | _, _                -> Top

let sem_guard = function
  | Bot                 -> Bot
  | Cst n when n > 0    -> Cst n
  | Cst _               -> Bot
  | Top                 -> Top

(* Semantiques arriere : valeurs par defaut (imprécises mais correctes). *)
let backsem_plus x y _r = x, y
let backsem_minus x y _r = x, y
let backsem_times x y _r = x, y
let backsem_div x y _r = x, y

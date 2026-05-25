(* Domaine de la parite (entiers modulo 2). *)

(* Treillis :
 *           T
 *         /   \
 *      Even   Odd
 *         \   /
 *          _|_
 *
 * gamma(T)    = Z
 * gamma(Even) = { 2n  | n in Z }
 * gamma(Odd)  = { 2n+1 | n in Z }
 * gamma(Bot)  = vide
 *)
type t =
  | Bot
  | Even
  | Odd
  | Top

let fprint ff = function
  | Bot   -> Format.fprintf ff "_|_"
  | Even  -> Format.fprintf ff "pair"
  | Odd   -> Format.fprintf ff "impair"
  | Top   -> Format.fprintf ff "T"

let order x y = match x, y with
  | Bot, _              -> true
  | _, Top              -> true
  | Even, Even          -> true
  | Odd, Odd            -> true
  | _, _                -> false

let top = Top
let bottom = Bot

let join x y = match x, y with
  | Bot, z | z, Bot     -> z
  | Top, _ | _, Top     -> Top
  | Even, Even          -> Even
  | Odd, Odd            -> Odd
  | Even, Odd | Odd, Even -> Top

let meet x y = match x, y with
  | Top, z | z, Top     -> z
  | Bot, _ | _, Bot     -> Bot
  | Even, Even          -> Even
  | Odd, Odd            -> Odd
  | Even, Odd | Odd, Even -> Bot

(* Treillis fini, pas de chaine infinie. *)
let widening = join

(* Parite d'un entier. *)
let parity_of n = if n mod 2 = 0 then Even else Odd

(* Abstraction de [n1, n2]. *)
let sem_itv n1 n2 =
  if n1 > n2 then Bot
  else if n1 = n2 then parity_of n1
  else Top

(* pair + pair = pair, pair + impair = impair, impair + impair = pair. *)
let sem_plus x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | Top, _ | _, Top     -> Top
  | Even, Even | Odd, Odd -> Even
  | Even, Odd  | Odd, Even -> Odd

(* La parite se comporte comme l'addition pour la soustraction. *)
let sem_minus = sem_plus

(* pair * n = pair, impair * impair = impair. *)
let sem_times x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | Even, _ | _, Even   -> Even
  | Odd, Odd            -> Odd
  | _, _                -> Top

(* La division entiere ne preserve pas la parite en general
 * (ex. 4 / 2 = 2 pair, 6 / 4 = 1 impair). *)
let sem_div x y = match x, y with
  | Bot, _ | _, Bot     -> Bot
  | _, _                -> Top

(* La garde > 0 ne raffine pas la parite (pair et impair peuvent etre > 0). *)
let sem_guard = function
  | Bot                 -> Bot
  | t                   -> t

let backsem_plus x y _r = x, y
let backsem_minus x y _r = x, y
let backsem_times x y _r = x, y
let backsem_div x y _r = x, y

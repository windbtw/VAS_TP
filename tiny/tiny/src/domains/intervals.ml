(* Domaine des intervalles. *)

(* type t :
 *   Bot                 : intervalle vide
 *   Itv (None,   b)     : ]-oo, b]
 *   Itv (a,   None)     : [a, +oo[
 *   Itv (None,None)     : ]-oo, +oo[ = Top
 *   Itv (Some a,Some b) : [a, b]    (avec a <= b)
 *)
type t =
  | Bot
  | Itv of int option * int option

(* --- Extensions de <= aux entiers etendus a +/- l'infini --- *)

(* leq_minf x y : x <= y avec None interprete comme -oo *)
let leq_minf x y = match x, y with
  | None, _ -> true                    (* -oo <= y *)
  | _, None -> false                   (* x > -oo (x != -oo) *)
  | Some x, Some y -> x <= y

(* leq_pinf x y : x <= y avec None interprete comme +oo *)
let leq_pinf x y = match x, y with
  | _, None -> true                    (* x <= +oo *)
  | None, _ -> false                   (* +oo > y (y != +oo) *)
  | Some x, Some y -> x <= y

(* min/max sur bornes inferieures (None = -oo) *)
let min_minf x y = if leq_minf x y then x else y
let max_minf x y = if leq_minf x y then y else x

(* min/max sur bornes superieures (None = +oo) *)
let min_pinf x y = if leq_pinf x y then x else y
let max_pinf x y = if leq_pinf x y then y else x

(* Constructeur sur : maintient l'invariant n1 <= n2. *)
let mk_itv o1 o2 = match o1, o2 with
  | None, _ | _, None -> Itv (o1, o2)
  | Some n1, Some n2  -> if n1 > n2 then Bot else Itv (o1, o2)

(* --- Affichage --- *)

let fprint_bound_low ff = function
  | None   -> Format.fprintf ff "]-oo"
  | Some n -> Format.fprintf ff "[%d" n

let fprint_bound_up ff = function
  | None   -> Format.fprintf ff "+oo["
  | Some n -> Format.fprintf ff "%d]" n

let fprint ff = function
  | Bot -> Format.fprintf ff "_|_"
  | Itv (a, b) ->
      Format.fprintf ff "%a, %a" fprint_bound_low a fprint_bound_up b

(* --- Treillis --- *)

let top = Itv (None, None)
let bottom = Bot

(* [a,b] ⊑♯ [c,d]  ssi  c <= a et b <= d *)
let order x y = match x, y with
  | Bot, _ -> true
  | _, Bot -> false
  | Itv (a, b), Itv (c, d) ->
      leq_minf c a && leq_pinf b d

(* [a,b] ⊔ [c,d] = [min(a,c), max(b,d)] *)
let join x y = match x, y with
  | Bot, z | z, Bot -> z
  | Itv (a, b), Itv (c, d) ->
      Itv (min_minf a c, max_pinf b d)

(* [a,b] ⊓ [c,d] = [max(a,c), min(b,d)] (Bot si vide) *)
let meet x y = match x, y with
  | Bot, _ | _, Bot -> Bot
  | Itv (a, b), Itv (c, d) ->
      mk_itv (max_minf a c) (min_pinf b d)

(* --- Elargissement standard (TP2 Q3) ---
 *   [a,b] ▽ [c,d] =
 *      [a, b]     si c >= a et d <= b
 *      [a, +oo[   si c >= a et d >  b
 *      ]-oo, b]   si c <  a et d <= b
 *      ]-oo, +oo[ si c <  a et d >  b
 *   ⊥ ▽ y = y    x ▽ ⊥ = x
 *)
let widening x y = match x, y with
  | Bot, z | z, Bot -> z
  | Itv (a, b), Itv (c, d) ->
      let low  = if leq_minf a c then a else None in    (* a <= c : stable, sinon -oo *)
      let high = if leq_pinf d b then b else None in    (* d <= b : stable, sinon +oo *)
      Itv (low, high)

(* --- Operateurs abstraits --- *)

(* Abstraction de l'intervalle concret [n1, n2]. *)
let sem_itv n1 n2 =
  if n1 > n2 then Bot
  else Itv (Some n1, Some n2)

(* Addition de bornes inferieures (None = -oo). *)
let add_low a c = match a, c with
  | None, _ | _, None -> None
  | Some x, Some y    -> Some (x + y)

(* Addition de bornes superieures (None = +oo). Meme code, mais semantique differente. *)
let add_high b d = match b, d with
  | None, _ | _, None -> None
  | Some x, Some y    -> Some (x + y)

(* [a,b] + [c,d] = [a+c, b+d] *)
let sem_plus x y = match x, y with
  | Bot, _ | _, Bot -> Bot
  | Itv (a, b), Itv (c, d) ->
      Itv (add_low a c, add_high b d)

(* [a,b] - [c,d] = [a-d, b-c]
 * Pour les bornes : a - d, avec a borne inf et d borne sup.
 *   si a = -oo OU d = +oo, alors a - d = -oo
 *   sinon a - d entier
 * Idem pour b - c.
 *)
let sub_low a d = match a, d with
  | None, _ | _, None -> None
  | Some x, Some y    -> Some (x - y)

let sub_high b c = match b, c with
  | None, _ | _, None -> None
  | Some x, Some y    -> Some (x - y)

let sem_minus x y = match x, y with
  | Bot, _ | _, Bot -> Bot
  | Itv (a, b), Itv (c, d) ->
      Itv (sub_low a d, sub_high b c)

(* TP2 Q1 : on garde les valeurs par defaut pour times et div. *)
let sem_times _ _ = top
let sem_div _ _ = top

(* Garde > 0 : on intersecte avec [1, +oo[. *)
let sem_guard = function
  | Bot -> Bot
  | t   -> meet t (Itv (Some 1, None))

(* Semantiques arriere : valeurs par defaut (TP2 Q1). *)
let backsem_plus x y _r = x, y
let backsem_minus x y _r = x, y
let backsem_times x y _r = x, y
let backsem_div x y _r = x, y

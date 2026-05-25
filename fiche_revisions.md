# Fiche de révision — TP1 & TP2 (Validation par Analyse Statique)

Synthèse des connaissances nécessaires pour réaliser les TPs *Domaines abstraits numériques non relationnels* (TP1) et *Domaine des intervalles & élargissement* (TP2).

---

## 1. Théorie : domaines abstraits

### Objectif
Calculer une **surapproximation** des invariants d'un programme : pour chaque point de programme, on veut un sur-ensemble des valeurs possibles des variables.

### Structure d'un domaine abstrait
Un domaine abstrait est un **treillis** `(D♯, ⊑♯)` muni de :
- un **ordre partiel** `⊑♯` ;
- une **borne sup** binaire `⊔♯` (join) ;
- une **borne inf** binaire `⊓♯` (meet) ;
- deux extremums `⊤` (toutes les valeurs possibles) et `⊥` (aucune valeur — code mort) ;
- une **fonction de concrétisation** `γ : D♯ → D` (mathématique, pas à implémenter), monotone :
  `x♯ ⊑♯ y♯ ⇒ γ(x♯) ⊑ γ(y♯)` ;
- éventuellement une fonction d'**abstraction** `α : D → D♯` (correspondance de Galois) ;
- des **opérations abstraites** sur D♯ (équivalent abstrait de `+`, `-`, `*`, `/`, tests de comparaison), **correctes** :
  `γ(x♯) + γ(y♯) ⊑ γ(x♯ +♯ y♯)` (surapproximation) ;
- un **élargissement** `▽` (widening) si le treillis a des chaînes strictement croissantes infinies :
  - `x♯ ⊔♯ y♯ ⊑♯ x♯ ▽ y♯`
  - pour toute suite `(x♯ₙ)`, la suite `y♯₀ = x♯₀`, `y♯ᵢ₊₁ = y♯ᵢ ▽ x♯ᵢ₊₁` est **stationnaire**.

### Domaines non relationnels
Dans nos TPs : `(D, ⊑) = (P(Z), ⊆)`. On abstrait **chaque variable séparément** (pas de relations entre variables).

---

## 2. Les trois domaines à implémenter

### Constantes de Kildall (TP1)
- Treillis : `⊥ < n (∀ n ∈ Z) < ⊤` (treillis plat).
- `γ(⊤) = Z`, `γ(n) = {n}`, `γ(⊥) = ∅`.
- Usage : identifier les variables constantes (compilation).
- `n ⊔ m = ⊤` si `n ≠ m`, `= n` sinon.

### Parité / entiers modulo 2 (TP1)
- Treillis à 4 éléments : `⊥ < pair, impair < ⊤`.
- `γ(pair) = {2n | n ∈ Z}`, `γ(impair) = {2n+1 | n ∈ Z}`.

### Intervalles (TP2)
- `D♯ = ⊥ ∪ { (n₁,n₂) ∈ (Z∪{-∞}) × (Z∪{+∞}) | n₁ ≤ n₂ }`.
- `γ(n₁, n₂) = ⟦n₁, n₂⟧`, `γ(⊥) = ∅`.
- Chaînes infinies → **widening obligatoire**.

#### Widening standard sur les intervalles
```
[a,b] ▽ [c,d] = [ a si c ≥ a sinon -∞ , b si d ≤ b sinon +∞ ]
⊥ ▽ y = y     x ▽ ⊥ = x
```
Idée : on **fige** les bornes stables ; les bornes qui croissent strictement sont propulsées à l'infini.

#### Widening avec retard (TP2 q.4)
On n'applique le widening qu'après **k itérations** (ou après une stabilisation partielle). Permet d'obtenir `j ∈ ⟦0,1⟧` sur `ex10.tiny` au lieu de `⟦0,+∞⟧`.

---

## 3. Le code fourni — architecture

### Fichiers clés
- [src/nonRelational.mli](tiny/tiny/src/nonRelational.mli) — **signature du module Domain** à implémenter (à lire en premier).
- [src/domains/dummy.ml](tiny/tiny/src/domains/dummy.ml) — squelette à copier ; valeurs par défaut correctes mais imprécises.
- [src/domains/dummy.mli](tiny/tiny/src/domains/dummy.mli) — signature.
- [src/analyze.ml](tiny/tiny/src/analyze.ml) — première ligne à modifier pour brancher son domaine.
- `src/doc/NonRelational.Domain.html` — doc lisible de la signature.
- `src/doc/InfInt.html` — module entiers étendus à `±∞` (pour `ex08.tiny` & extensions).

### Workflow
```bash
cp src/domains/dummy.mli src/domains/monDomaine.mli
cp src/domains/dummy.ml  src/domains/monDomaine.ml
# éditer src/analyze.ml (1ère ligne) pour pointer vers MonDomaine
cd src && make
./tiny ../examples/ex01.tiny
```

### Fonctions à implémenter (signature `Domain`)
- `top`, `bottom`, `is_bottom`
- `const n` (abstrait un entier), `rand a b` (intervalle concret)
- `join` (⊔), `meet` (⊓), `subset` (⊑)
- **sémantiques avant** : `sem_plus`, `sem_minus`, `sem_times`, `sem_div`, `sem_unary_minus`
- **tests** : `sem_geq`, `sem_gt`, `sem_eq`, `sem_neq` (raffinent les opérandes)
- `widening` — garder `= join` au début, n'implémenter qu'au TP2
- `backsem_*` — sémantiques arrière, à laisser par défaut tant que pas justifié
- `print`

### Conseils
- Garder les valeurs par défaut de `dummy.ml` au début (correctes mais grossières).
- N'implémenter `widening`, `sem_div`, `sem_times`, `backsem_*` qu'après avoir validé le reste.

---

## 4. Options de l'analyseur
| Option | Effet |
|---|---|
| `-v N` | verbosité N (montre les itérations) |
| `-d 1` | itérations descendantes après le point fixe (raffinement) |
| `--verbose` / `--descending` | équivalents longs |

Exemple : `bin/tiny-intervals -v 4 -d 1 examples/ex01.tiny`.

Binaires de référence : `bin/tiny-intervals`, `bin/tiny-kildall`, `bin/tiny-parity` (pour comparer ses résultats).

---

## 5. OCaml — rappels utiles

### Syntaxe de base
```ocaml
(* commentaire *)
let x = 10 in let y = 2 in x + y       (* variable locale *)
let somme x y = x + y                  (* fonction curryfiée *)
if x >= 0 then x else -x               (* conditionnelle *)
Format.fprintf Format.std_formatter "i = %d\n" 42
```

### Types somme + pattern matching
```ocaml
type t = A | B of int * int | C of string | D

match x with
| A          -> 0
| B (12, _)  -> 1   (* premier champ = 12, second quelconque *)
| B _        -> 2
| _          -> 3   (* défaut *)
```
Les cas sont testés **de haut en bas**, premier match gagne. `_` = joker.

### Type `option` (utilisé pour ±∞ dans les intervalles)
```ocaml
type 'a option = None | Some of 'a
(* None encode ±∞, Some n encode la borne finie n *)
```

### Patron pour étendre `≤` à `Z ∪ {±∞}`
```ocaml
let leq_minf x y = match x, y with     (* None = -∞ *)
  | None, _ -> true
  | _, None -> false
  | Some x, Some y -> x <= y

let leq_pinf x y = match x, y with     (* None = +∞ *)
  | _, None -> true
  | None, _ -> false
  | Some x, Some y -> x <= y
```

### Constructeur sûr d'intervalle (maintient `n₁ ≤ n₂`)
```ocaml
let mk_itv o1 o2 = match o1, o2 with
  | None, _ | _, None -> Itv (o1, o2)
  | Some n1, Some n2  -> if n1 > n2 then Bot else Itv (o1, o2)
```

---

## 6. Pièges fréquents
- **`widening = join`** ne fait converger que sur treillis sans chaîne infinie — explose en temps sur `while (i < 1_000_000)` en intervalles.
- Le **widening n'est pas commutatif** ni monotone — c'est normal.
- Bien gérer `⊥` partout (absorbant pour `⊓`, neutre pour `⊔`).
- `sem_eq`, `sem_geq` etc. servent à **raffiner** les opérandes selon le test (utilisé dans les branches `if`/`while`).
- Pour `ex08.tiny` (constantes hors `int` natif) : utiliser le module `InfInt` plutôt que `int`.
- Les fichiers `._*` dans `tiny/` sont des artéfacts macOS — ignorer.

---

## 7. Exemples à connaître
- `ex01.tiny` — sanity check.
- `ex08.tiny` — débordements / grandes constantes ; motivation du module `InfInt`.
- `ex09.tiny` — `while (i < N)` ; motive le widening (TP2 q.2-3).
- `ex10.tiny` — boucle avec `if` interne ; motive le widening **avec retard** (TP2 q.4).

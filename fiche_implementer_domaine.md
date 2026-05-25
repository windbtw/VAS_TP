# Fiche — Comment implémenter un domaine abstrait non-relationnel

Guide pour remplir un fichier `monDomaine.ml` dans l'analyseur `tiny`. La signature à respecter est dans [src/nonRelational.mli](tiny/tiny/src/nonRelational.mli) (module `Domain`).

---

## Workflow général

```bash
# 1. Copier le template
cp src/domains/dummy.mli src/domains/monDomaine.mli
cp src/domains/dummy.ml  src/domains/monDomaine.ml

# 2. Brancher le domaine — modifier src/analyze.ml ligne 22
#    module Dom : Relational.Domain = NonRelational.MakeRelational (MonDomaine)

# 3. Éditer src/domains/monDomaine.ml (voir les 12 sections ci-dessous)

# 4. Compiler & tester
cd src && make && cd ..
src/tiny examples/ex01.tiny
```

Conseil : **garder les valeurs par défaut de `dummy.ml`** quand on ne sait pas — elles sont correctes mais imprécises. On raffine au fur et à mesure.

---

## Sections à remplir, dans l'ordre

### 1. Définir le type `t`
Encoder les éléments du treillis : `⊥`, les éléments « intéressants », `⊤`.

```ocaml
type t =
  | Bot                  (* ⊥ : ensemble vide *)
  | ...                  (* éléments du treillis *)
  | Top                  (* ⊤ : aucune information *)
```

**Question à se poser** : combien d'éléments dans le treillis, finis ou paramétrés ?
- Treillis fini (signes, parité) → constructeurs sans argument.
- Famille infinie (constantes, intervalles) → constructeur paramétré (`Cst of int`, `Itv of int option * int option`).

---

### 2. `fprint` — affichage
Sert au debug et à l'affichage final des invariants.
```ocaml
let fprint ff = function
  | Bot   -> Format.fprintf ff "_|_"
  | Top   -> Format.fprintf ff "T"
  | ...
```

---

### 3. `top` et `bottom`
```ocaml
let top = Top
let bottom = Bot
```
Trivial, mais ne pas oublier de les mettre à jour si le type change.

---

### 4. `order` — l'ordre partiel `⊑♯`
`order x y` doit retourner `true` ssi `x ⊑♯ y`.

**Règles universelles** :
- `Bot ⊑ tout` (⊥ est minimum).
- `tout ⊑ Top` (⊤ est maximum).
- Sinon, dépend du treillis.

```ocaml
let order x y = match x, y with
  | Bot, _ -> true
  | _, Top -> true
  | ... cas spécifiques ...
  | _, _   -> false
```

**Vérifier** : `order x x = true` (réflexivité), `order x y && order y x ⇒ x = y` (antisymétrie).

---

### 5. `join` (⊔) — borne supérieure
"Le plus petit élément qui contient les deux."

**Règles universelles** :
- `Bot ⊔ z = z` (⊥ neutre pour ⊔).
- `Top ⊔ _ = Top` (⊤ absorbant pour ⊔).
- Sinon : si les deux éléments ne sont pas comparables, remonter vers `Top`.

```ocaml
let join x y = match x, y with
  | Bot, z | z, Bot -> z
  | Top, _ | _, Top -> Top
  | ... cas spécifiques ...
```

---

### 6. `meet` (⊓) — borne inférieure
"Le plus grand élément contenu dans les deux."

**Règles universelles** (duales de `join`) :
- `Top ⊓ z = z` (⊤ neutre pour ⊓).
- `Bot ⊓ _ = Bot` (⊥ absorbant pour ⊓).
- Si incompatibles, descendre vers `Bot`.

```ocaml
let meet x y = match x, y with
  | Top, z | z, Top -> z
  | Bot, _ | _, Bot -> Bot
  | ... cas spécifiques ...
```

---

### 7. `widening` (▽)
- **Treillis sans chaîne croissante infinie** (signes, parité, constantes) → `let widening = join` suffit.
- **Treillis avec chaînes infinies** (intervalles) → définir un vrai ▽ qui force la stationnarité (voir TP2).

Critère mathématique : `x ⊔♯ y ⊑♯ x ▽ y` ET toute suite définie par `y_{i+1} = y_i ▽ x_{i+1}` est stationnaire.

---

### 8. `sem_itv n1 n2` — abstraction d'un intervalle concret
Doit sur-approximer `⟦n1, n2⟧`. Cas à traiter dans l'ordre :
```ocaml
let sem_itv n1 n2 =
  if n1 > n2 then Bot              (* intervalle vide *)
  else if n1 = n2 then ...          (* singleton {n1} : meilleure abstraction possible *)
  else ...                          (* plage : Top si on ne peut pas faire mieux *)
```

---

### 9. Opérations arithmétiques `sem_plus`, `sem_minus`, `sem_times`, `sem_div`

**Squelette commun** :
```ocaml
let sem_op x y = match x, y with
  | Bot, _ | _, Bot -> Bot              (* propagation de ⊥ *)
  | ... cas précis ...                  (* quand on peut calculer *)
  | _, _            -> Top              (* sinon, abandon *)
```

**Astuces fréquentes** :
- `sem_times` : `0 × _ = 0` même si l'autre est `Top` (multiplication par 0 absorbante).
- `sem_div` : `_ / 0 = Bot` (division par zéro = exception ⇒ ∅).
- `sem_minus` n'est pas symétrique de `sem_plus` — `0 − T = T`, pas `0`.

**Vérification de correction** : `γ(x) op γ(y) ⊑ γ(x op♯ y)` (toujours sur-approximer).

---

### 10. `sem_guard` — la garde `> 0`
Filtre les valeurs strictement positives.
```ocaml
let sem_guard = function
  | Bot -> Bot
  | t   -> ...    (* raffine ou laisse passer *)
```

**Cas typiques** :
- Si le domaine ne peut pas raffiner (parité : pair et impair peuvent être > 0) → renvoyer `t` tel quel.
- Si on peut affiner (constantes : `Cst 5` reste `Cst 5`, `Cst (-3)` devient `Bot`, intervalles : on intersecte avec `⟦1, +∞⟦`).

---

### 11. `backsem_*` — sémantiques arrière
Servent à raffiner les opérandes connaissant le résultat (utile pour les gardes complexes type `x − 4 > 0`).

**À laisser par défaut au début** : `let backsem_op x y _r = x, y` (correct mais imprécis). Ne raffiner qu'en présence d'un exemple qui le justifie.

---

### 12. Compiler et tester
```bash
cd src && make && cd ..
src/tiny examples/ex01.tiny
```

Comparer avec le binaire de référence : `bin/tiny-kildall`, `bin/tiny-parity`, `bin/tiny-intervals`.

---

## Tableau récapitulatif des trois domaines du TP1/TP2

| Aspect | Constantes (Kildall) | Parité | Intervalles |
|---|---|---|---|
| Type | `Bot \| Cst of int \| Top` | `Bot \| Even \| Odd \| Top` | `Bot \| Itv of int option * int option` |
| Chaîne infinie ? | non | non | **oui** |
| `widening` | `= join` | `= join` | **à définir** |
| `sem_itv n n` | `Cst n` | `Even`/`Odd` selon `n mod 2` | `Itv(Some n, Some n)` |
| `sem_plus` exact ? | si deux singletons | toujours (table 4×4) | toujours (`[a+c, b+d]`) |
| `sem_guard >0` | filtre les `Cst n≤0` | inutile | intersecte avec `⟦1, +∞⟦` |

---

## Pièges courants

1. **Oublier de propager `Bot`** dans les opérations arithmétiques → l'analyse devient incorrecte.
2. **Mettre `top = bottom`** (cas du dummy) → tout devient « dead code ».
3. **`widening = join` avec chaîne infinie** → l'analyse ne termine pas (boucle infinie sur `while (x<1000000)`).
4. **Débordement `int`** dans `sem_plus`/`sem_times` (cas `ex08.tiny`) → résultats faux. Solution : module `InfInt` ([src/doc/InfInt.html](tiny/tiny/src/doc/InfInt.html)).
5. **Pattern matching non exhaustif** → warning du compilateur, parfois bug silencieux. Toujours mettre un `| _, _ -> ...` ou couvrir tous les cas.
6. **Modifier le `.ml` sans recompiler** → tester l'ancien binaire ⇒ résultats incohérents. Toujours `make` après une modif.
7. **Tester sans avoir branché le domaine** dans [analyze.ml:22](tiny/tiny/src/analyze.ml#L22).

---

## Checklist avant de dire "c'est fini"

- [ ] Type `t` défini avec `Bot` et `Top` (sauf raison contraire).
- [ ] `order`, `join`, `meet` cohérents (test mental : `order x (join x y) = true`).
- [ ] `widening` adapté à la (non-)présence de chaînes infinies.
- [ ] Toutes les opérations propagent `Bot`.
- [ ] `sem_guard` filtre correctement (ou renvoie l'argument si impossible).
- [ ] `analyze.ml` pointe sur **mon** domaine.
- [ ] `make` passe sans erreur (les warnings `use_apron` sont normaux).
- [ ] Test sur `ex01.tiny` cohérent avec `bin/tiny-<ref> examples/ex01.tiny`.

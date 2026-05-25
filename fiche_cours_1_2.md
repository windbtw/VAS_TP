# Fiche de synthèse — Cours 1 & 2 (Validation par Analyse Statique)

Interprétation abstraite : cadre théorique (cours 1) + abstractions numériques non relationnelles (cours 2). Plan global du cours : intro → abstractions numériques simples → abstractions relationnelles + outils.

---

## Partie I — Le cadre (cours 1)

### 1.1 Intuition (exemple de la fleur)
Construire un objet complexe (corolle, bouquet) à partir de primitives (`pétale`) et d'opérations (rotation `r[a]`, union `⊔`, tige). La **corolle** s'obtient itérativement → c'est un **point fixe** : `corolle = lfp(X ↦ pétale ⊔ r[45](X))`.

### 1.2 Sur-approximation
- Ordre concret `⊑` : `o ⊑ o'` ⇔ même origine et tout point de `o` ∈ `o'`.
- Une abstraction = une **représentation simplifiée** (contours, cercles centrés, polygones convexes, rectangles parallèles aux axes…).
- L'abstraction **n'est pas injective** (plusieurs concrets → 1 abstrait), sinon ce n'est pas une vraie abstraction.

### 1.3 Concret ↔ Abstrait
- **Domaine abstrait** `D♯` : ensemble d'éléments abstraits + opérations abstraites.
- **Concrétisation** `γ : D♯ → D` : remonte vers le concret (le plus grand objet concret approché).
- **Abstraction** `α : D → D♯` : associe à chaque concret sa représentation simplifiée.
- **Ordre abstrait** `⊑♯` doit être **correct** vis-à-vis de `⊑` :
  `o ⊑♯ o' ⇒ γ(o) ⊑ γ(o')` (γ monotone).

### 1.4 Meilleure abstraction & correspondance de Galois
- `o` a une **meilleure abstraction** si `{ o♯ | o ⊑ γ(o♯) }` admet un minimum.
- **Correspondance de Galois** :
  `α(x) ⊑♯ y ⇔ x ⊑ γ(y)`
- **Théorème** : il existe une correspondance de Galois ssi tout concret admet une meilleure abstraction (donnée par α).
- Ex : (contour, remplissage) = Galois ; (rectangle parallèle, ⊆) = Galois ; mais pas pour les polygones convexes en général.

### 1.5 Opérations abstraites & correction
Pour chaque opération concrète (constante, unaire, binaire) on a une opération abstraite **correcte** :
- `const ⊑ γ(const♯)`
- `unaire(γ(x)) ⊑ γ(unaire♯(x))`
- `binaire(γ(x), γ(y)) ⊑ γ(binaire♯(x, y))`

Avec une correspondance de Galois, la **meilleure** opération abstraite est `op♯ = α ∘ op ∘ γ`.

Le point fixe abstrait `lfp F♯` (avec `F♯ : X ↦ pétale♯ ⊔♯ r♯[45](X)`) sur-approxime correctement le point fixe concret.

### 1.6 Le langage jouet
```
stm  ::= v = expr ; | stm stm | if (expr > 0) { stm } else { stm } | while (expr > 0) { stm }
expr ::= v | n | rand(n₁, n₂) | expr + expr | expr − expr | expr × expr | expr / expr
```
- `v ∈ V` (variables), `n ∈ Z` (entiers).
- `rand(n₁, n₂)` : entier aléatoire dans `⟦n₁, n₂⟧`.
- `e ≤ 0` ≡ sucre pour `1 − e > 0`.
- Sous-ensemble représentatif d'un C-like, **Turing-complet**.

### 1.7 Graphe de flot de contrôle (CFG)
`(L, A)` : points de programme `L`, point d'entrée `0`, arêtes `A ⊆ L × com × L` avec `com ::= v = expr | expr > 0`.

### 1.8 Sémantique concrète

**Expressions** `[[e]]_E : (V → Z) → P(Z)` (un environnement ρ → ensemble de valeurs) :
```
[[v]]_E(ρ)          = { ρ(v) }
[[n]]_E(ρ)          = { n }
[[rand(n₁,n₂)]]_E(ρ) = { n ∈ Z | n₁ ≤ n ≤ n₂ }
[[e₁ + e₂]]_E(ρ)    = { n₁+n₂ | n₁ ∈ [[e₁]]_E(ρ) ∧ n₂ ∈ [[e₂]]_E(ρ) }
```
Cas d'erreur : `rand(n₁,n₂)` avec `n₁ > n₂` → `∅` ; division par 0 → `∅` (exception, abandon).

**Commandes** `[[c]]_C : P(V → Z) → P(V → Z)` :
```
[[v = e]]_C(R) = { ρ[v ↦ n] | ρ ∈ R, n ∈ [[e]]_E(ρ) }
[[e > 0]]_C(R) = { ρ ∈ R | ∃n ∈ [[e]]_E(ρ), n > 0 }
```

**Programme** `[[(L,A)]] : L → P(V → Z)` — plus petite solution du système :
```
R₀  = V → Z
R_l' = ⋃_{(l, c, l') ∈ A} [[c]]_C(R_l)        pour l' ≠ 0
```
À chaque point de programme on associe le **meilleur invariant**.

### 1.9 Outillage mathématique
- **Ordre** : réflexif, transitif, antisymétrique.
- **Borne sup** `⊔` : plus petit majorant.
- **Treillis complet** : tout sous-ensemble admet une borne sup (donc aussi `⊓`, `⊥`, `⊤`).
- `Z` n'est PAS un treillis complet ; `Z̄ = Z ∪ {±∞}` l'est ; `P(S)` muni de `⊆` l'est toujours.
- **Théorème de Knaster-Tarski** : `S` treillis complet + `f : S → S` monotone ⟹ `f` admet un plus petit point fixe :
  `lfp f = ⊓ { x ∈ S | f(x) ⊑ x }`
- Conséquence : la sémantique concrète est **bien définie** mais **pas calculable** → on calcule une sur-approximation.

---

## Partie II — Abstractions non relationnelles (cours 2)

### 2.1 Que veut-on abstraire ?
Type concret : `L → P(V → Z)`.
- `L` (points de programme) fini → on le garde.
- `V` (variables) fini → on le garde.
- `Z` (et donc `V → Z`) est infini → **c'est ici qu'on abstrait**.

Deux grandes approches :
| Approche | Idée | Précision | Coût |
|---|---|---|---|
| **Non relationnel** | abstraire `P(V→Z)` en `V → P(Z)` puis `P(Z)` en `D♯` | ignore les relations entre variables | – | + simple |
| **Relationnel** | abstraire directement `P(V→Z)` en `D♯` | capture les relations | + précis | + coûteux |

Petit dessin : un invariant `{x ∈ ⟦−1,12⟧, y ∈ ⟦42,66⟧ ∩ 4Z + 2}` devient un rectangle en non-relationnel, un trapèze en relationnel.

### 2.2 Abstraction non relationnelle (générique)
À partir d'une abstraction `D♯` de `P(Z)` on déduit `D♯_nr = V → D♯` point à point :
```
x♯ ⊑♯_nr y♯  ⇔  ∀v ∈ V, x♯(v) ⊑♯ y♯(v)
γ_nr(x♯) = { ρ | ∀v, ρ(v) ∈ γ(x♯(v)) }
α_nr(x)  = v ↦ α({ ρ(v) | ρ ∈ x })
⊤_nr, ⊥_nr, ⊔♯_nr, ⊓♯_nr   définis point à point
```

### 2.3 Domaine des signes
```
       ⊤
      / \
    ≤0   ≥0
      \ /
       0      γ(⊤)=Z, γ(≤0)=]−∞,0], γ(≥0)=[0,+∞[, γ(0)={0}, γ(⊥)=∅
       |
       ⊥
```
- L'élément `0` est ajouté pour assurer la **meilleure abstraction** du singleton `{0}` (sinon `≤0` et `≥0` incomparables).
- Galois : `α(S) = ⊤ si ∃s,s'∈S avec s<0<s' ; ≤0 si ∀s≤0 et ∃s<0 ; ≥0 sym. ; 0 si S={0} ; ⊥ si S=∅`.
- Opérations : `n♯ = ≤0/≥0/0` selon signe ; `rand♯(n₁,n₂) = ⊥/0/≤0/≥0/⊤` ; table d'addition (`+♯`).

### 2.4 Sémantique abstraite
**Expressions** `[[e]]♯_E : (V → D♯) → D♯` :
```
[[v]]♯(ρ)       = ρ(v)
[[n]]♯(ρ)       = n♯
[[rand(n₁,n₂)]]♯(ρ) = rand♯(n₁, n₂)
[[e₁ + e₂]]♯(ρ) = [[e₁]]♯ +♯ [[e₂]]♯
```

**Commandes** `[[c]]♯_C : (V → D♯) → (V → D♯)` :
```
[[v = e]]♯(ρ) = ρ[v ↦ [[e]]♯_E(ρ)]
[[e > 0]]♯(ρ) = ρ[v ↦ ρ(v) ⊓♯ α(⟦1,+∞⟧)]   si e = v
              = ρ                              sinon
```
(la garde `e > 0` ne raffine que la variable `v` quand `e ≡ v` — c'est imprécis, on améliorera avec l'**analyse arrière** §2.8).

**Programme** : plus petite solution (au sens de `⊑♯_nr`) de
```
R♯₀  = V → ⊤
R♯_l' = ⊔♯_nr { [[c]]♯_C(R♯_l) | (l, c, l') ∈ A }
```

### 2.5 Calcul effectif du point fixe
**Théorème** : si `(f^n(⊥))_n` est stationnaire, alors `lfp f = f^N(⊥)` pour `N` tel que `f^(N+1)(⊥) = f^N(⊥)`.

Méthode itérative : `R♯⁰ = ⊥` ; `R♯^(k+1) = F♯(R♯^k)` ; on s'arrête quand point fixe atteint.

**Correction** : `R_l ⊆ γ_nr(R♯_l)` pour tout `l`.

**Terminaison** :
- ✅ Si `D♯` n'a pas de chaîne strictement croissante infinie (signes, constantes) → ça termine.
- ❌ Si `D♯` a des chaînes infinies (intervalles : `⟦0,0⟧ ⊏ ⟦0,1⟧ ⊏ ⟦0,2⟧ ⊏ …`) → ça **ne termine pas**.

### 2.6 Domaine des constantes (Kildall)
```
          ⊤
   /  /   |   \  \
  … −2 −1 0 1 2 …
   \  \   |   /  /
          ⊥
γ(⊤)=Z, γ(n)={n}, γ(⊥)=∅
```
- Galois : `α(S) = ⊤ si |S|≥2 ; n si S={n} ; ⊥ si S=∅`.
- Opérations exactes sur les singletons : `n♯ = n`, `x♯ +♯ y♯ = n₁+n₂ si singletons, ⊤ sinon`.
- **Pas de chaîne croissante infinie** (toute chaîne ⊥ < n < ⊤ a longueur ≤ 2) → termine.
- Usage : **constant folding** dans les compilateurs (démo GCC).

### 2.7 Domaine des intervalles
```
                ]−∞, +∞[
                   ⋮
           …   ⟦−1, 1⟧   …
         …   ⟦−1, 0⟧   ⟦0, 1⟧   …
       … ⟦−1,−1⟧  ⟦0, 0⟧  ⟦1, 1⟧ …
                   ⊥
γ(⟦n₁,n₂⟧) = ⟦n₁,n₂⟧, γ(⊥)=∅
α(S) = ⟦min S, max S⟧ si S ≠ ∅
```
Opérations : `n♯ = ⟦n,n⟧` ; `⟦a,b⟧ +♯ ⟦c,d⟧ = ⟦a+c, b+d⟧` (étendu à `±∞`).

**Problème** : chaînes infinies → on n'atteint jamais le point fixe (sur `while (x>0) { x = x−1 }` partant de `x=12`, on grossit `⟦−1, 12⟧, ⟦−2, 12⟧, …`).

### 2.8 Élargissement (widening) `▽`
Opération binaire `▽ : D♯ × D♯ → D♯` vérifiant :
1. **Sur-approximation** : `x♯ ⊔♯ y♯ ⊑♯ x♯ ▽ y♯` (au moins l'union).
2. **Convergence** : pour toute suite `(x♯_n)`, la suite `y♯_0 = x♯_0`, `y♯_(i+1) = y♯_i ▽ x♯_(i+1)` est **stationnaire**.

On intercale `▽` entre itérations : `R♯^(i+1) = R♯^i ▽ F♯(R♯^i)`. La limite sur-approxime `lfp F♯`.

**Élargissement standard sur les intervalles** :
```
⟦a, b⟧ ▽ ⟦c, d⟧ =
  ⟦a, b⟧        si c ≥ a et d ≤ b      (rien ne bouge)
  ⟦a, +∞⟦       si c ≥ a et d > b      (la borne sup s'envole)
  ⟧−∞, b⟧       si c < a et d ≤ b      (la borne inf s'envole)
  ⟧−∞, +∞⟦      si c < a et d > b
  y♯            si x♯ = ⊥
  x♯            si y♯ = ⊥
```
**Pas symétrique** : `⟦0,2⟧ ▽ ⟦0,1⟧ = ⟦0,2⟧` mais `⟦0,1⟧ ▽ ⟦0,2⟧ = ⟦0, +∞⟦`.

### 2.9 Rétrécissement (narrowing) `△`
L'élargissement assure la terminaison mais **perd en précision** (ex. `x=12, while x>0: x--` donne `x ∈ ⟧−∞, 0⟧` au lieu de `x = 0`). On raffine **a posteriori** par itérations descendantes.

Opération `△ : D♯ × D♯ → D♯` vérifiant :
1. `x♯ ⊓♯ y♯ ⊑♯ x♯ △ y♯ ⊑♯ x♯` (entre l'inf et la première opérande).
2. Pour toute suite, `y♯_0 = x♯_0`, `y♯_(i+1) = y♯_i △ x♯_(i+1)` est stationnaire.

Garantit `lfp F♯ ⊑♯ R♯'` à chaque itération.

**Narrowing standard sur les intervalles** — ne raffine que les bornes infinies :
```
⟦a,+∞⟦  △  ⟦c, d⟧ = ⟦a, d⟧
⟧−∞,b⟧  △  ⟦c, d⟧ = ⟦c, b⟧
⟧−∞,+∞⟦ △  ⟦c, d⟧ = ⟦c, d⟧
x♯ sinon
```

### 2.10 Élargissement à seuil
Le narrowing ne récupère pas tout (ex. boucle avec `x ≠ 0` : on ne retrouve pas `x ≥ 0`). Idée : au lieu de propulser directement à `±∞`, **passer d'abord par des constantes seuils** (`0`, ou un ensemble fini fixé). Demande de bien choisir les seuils.

### 2.11 Analyse arrière (backward)
La sémantique abstraite directe des gardes est très imprécise pour `x − 4 > 0` (qui devrait donner `x ≥ 5`).

**Sémantique arrière des expressions** `[[e]]↓♯ : (V → D♯) × D♯ → (V → D♯)` :
> *« sachant que `e` vaut `r`, que peut-on déduire sur les variables ? »*

```
[[v]]↓♯(ρ, r)        = ρ[v ↦ ρ(v) ⊓♯ r]
[[n]]↓♯(ρ, r)        = ⊥ si n♯ ⊓♯ r = ⊥, ρ sinon
[[rand(n₁,n₂)]]↓♯(ρ,r)= ⊥ si rand♯(n₁,n₂) ⊓♯ r = ⊥, ρ sinon
[[e₁ + e₂]]↓♯(ρ, r)  = [[e₁]]↓♯(ρ, r₁) ⊓♯_nr [[e₂]]↓♯(ρ, r₂)
                       avec (r₁, r₂) = +↓♯([[e₁]]♯_E(ρ), [[e₂]]♯_E(ρ), r)
```
Le `+↓♯` raffine les arguments connaissant le résultat. Ex :
- Signes : `+↓♯(≥0, ≥0, ≤0) = (0, 0)` (si `x ≥ 0`, `y ≥ 0` et `x+y ≤ 0` alors `x=y=0`).
- Intervalles : `+↓♯(⟦0,2⟧, ⟦3,8⟧, ⟦4,7⟧) = (⟦0,2⟧, ⟦3,7⟧)`.

Pour traiter une garde `e > 0` : appliquer `[[e]]↓♯(ρ, ⟦1, +∞⟦)`.

---

## 3. Vue d'ensemble — la « pipeline »

```
Programme
   │  CFG + sémantique concrète (incalculable, mais bien définie par Knaster-Tarski)
   ▼
Système d'équations sur P(V → Z)
   │  Choix d'un domaine abstrait D♯ + α/γ (correspondance de Galois si possible)
   ▼
Système abstrait sur D♯_nr
   │  Itération de Kleene F♯^n(⊥)
   ▼
Si chaînes infinies ⇒ widening ▽   ── puis narrowing △  ── puis backward ↓♯
   │
   ▼
Invariant abstrait correct : R_l ⊆ γ_nr(R♯_l) pour tout point l
```

---

## 4. Notations et faits clés à retenir

| Symbole | Signification |
|---|---|
| `D, ⊑` | domaine concret et ordre concret (ici `P(Z)`, `⊆`) |
| `D♯, ⊑♯` | domaine abstrait, ordre abstrait |
| `γ` | concrétisation (monotone) |
| `α` | abstraction (n'existe pas toujours) |
| `⊔♯, ⊓♯` | sup et inf abstraits |
| `⊤, ⊥` | tout / rien |
| `lfp f` | plus petit point fixe |
| `▽` | élargissement (sur-approxime, force stationnarité) |
| `△` | rétrécissement (raffine sous le point fixe, force stationnarité) |
| `[[e]]↓♯` | sémantique arrière (raffinement par les gardes) |

**Trois propriétés clés** d'un domaine abstrait :
1. **γ monotone** (`⊑♯` correct vis-à-vis de `⊑`).
2. **Opérations correctes** (`op♯` sur-approxime `op`).
3. **Termine** : soit pas de chaîne croissante infinie, soit fournir un `▽`.

**Quand utiliser quoi** :
- *Constant folding* → constantes (Kildall).
- *Bornes de variables, débordement* → intervalles + widening + narrowing.
- *Parité, alignement* → modulo (`pair`/`impair`).
- *Précision sur les gardes complexes* → analyse arrière.
- *Relations entre variables* → polyèdres, octogones (cours 3).
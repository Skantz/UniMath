(*****************************************************************

 Structures on sets

 In this file, we look at a particular class of structures on the
 category of set that is closed under products and the terminal
 object. Key in this development are displayed categories and the
 structure identity principle.

 The notion of structure that we consider, consists of:
 - For every hSet, a set of structures on that set
 - For every function, a proposition that represents wheter this
   function preserves the structure.
 The notion of structure must be closed under product and there
 must be a structure for the unit set. We also require that
 structure-preserving maps are closed under identity, composition,
 constant functions, and pairing. We also require that projections
 and the map to the unit set are structure preserving. The final
 requirement is the notion of 'standardness' (see the HoTT book),
 from which we conclude the univalence of the category of
 structured sets.

 Contents
 1. Definition of the structures
 2. The corresponding displayed category
 3. The total category
 4. Transporting structures

 *****************************************************************)
Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Univalence.
Require Import UniMath.CategoryTheory.categories.HSET.All.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Total.
Require Import UniMath.CategoryTheory.DisplayedCats.Isos.
Require Import UniMath.CategoryTheory.DisplayedCats.Univalence.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Require Import UniMath.CategoryTheory.DisplayedCats.SIP.
Require Import UniMath.CategoryTheory.DisplayedCats.Binproducts.

Local Open Scope cat.

Definition univalence_hSet
           {X Y : hSet}
           (w : X ≃ Y)
  : X = Y
  := invmap (hSet_univalence _ _) w.

Definition hSet_univalence_map_univalence_hSet
           {X Y : hSet}
           (w : X ≃ Y)
  : hSet_univalence_map X Y (univalence_hSet w) = w.
Proof.
  exact (homotweqinvweq (hSet_univalence _ _) w).
Defined.

Definition hSet_univalence_univalence_hSet_map
           {X Y : hSet}
           (p : X = Y)
  : univalence_hSet (hSet_univalence_map X Y p) = p.
Proof.
  exact (homotinvweqweq (hSet_univalence _ _) p).
Qed.

Definition univalence_hSet_idweq
           (X : hSet)
  : univalence_hSet (idweq X) = idpath X.
Proof.
  refine (_ @ hSet_univalence_univalence_hSet_map (idpath _)).
  apply maponpaths.
  apply idpath.
Defined.

Definition hSet_univalence_map_inv
           {X Y : hSet}
           (p : X = Y)
  : hSet_univalence_map _ _ (!p) = invweq (hSet_univalence_map _ _ p).
Proof.
  induction p.
  cbn.
  use subtypePath.
  {
    intro.
    apply isapropisweq.
  }
  apply idpath.
Qed.

Definition univalence_hSet_inv
           {X Y : hSet}
           (w : X ≃ Y)
  : !(univalence_hSet w) = univalence_hSet (invweq w).
Proof.
  refine (!(hSet_univalence_univalence_hSet_map _) @ _).
  apply maponpaths.
  rewrite hSet_univalence_map_inv.
  rewrite hSet_univalence_map_univalence_hSet.
  apply idpath.
Qed.

(**
 1. Definition of the structures
 *)
Definition hset_struct_data
  : UU
  := ∑ (P : hSet → UU),
     (∏ (X Y : hSet), P X → P Y → (X → Y) → UU)
     ×
     P unitHSET
     ×
     (∏ (X Y : hSet)
        (PX : P X)
        (PY : P Y),
     P (X × Y)%set).

Definition hset_struct_data_to_fam (P : hset_struct_data) : hSet → UU
  := pr1 P.

Coercion hset_struct_data_to_fam : hset_struct_data >-> Funclass.

Definition mor_hset_struct
           (P : hset_struct_data)
           {X Y : hSet}
           (PX : P X)
           (PY : P Y)
           (f : X → Y)
  : UU
  := pr12 P X Y PX PY f.

Definition hset_struct_unit
           (P : hset_struct_data)
  : P unitHSET
  := pr122 P.

Definition hset_struct_prod
           (P : hset_struct_data)
           {X Y : hSet}
           (PX : P X)
           (PY : P Y)
  : P (X × Y)%set
  := pr222 P X Y PX PY.

Definition hset_struct_laws
           (P : hset_struct_data)
  : UU
  := (∏ (X : hSet),
      isaset (P X))
     ×
     (∏ (X Y : hSet)
        (PX : P X) (PY : P Y)
        (f : X → Y),
      isaprop (mor_hset_struct P PX PY f))
     ×
     (∏ (X : hSet)
        (PX : P X),
      mor_hset_struct P PX PX (λ x, x))
     ×
     (∏ (X Y Z : hSet)
        (PX : P X)
        (PY : P Y)
        (PZ : P Z)
        (f : X → Y)
        (g : Y → Z)
        (Mf : mor_hset_struct P PX PY f)
        (Mg : mor_hset_struct P PY PZ g),
      mor_hset_struct P PX PZ (λ x, g(f x)))
     ×
     (∏ (X : hSet)
        (PX PX' : P X),
      mor_hset_struct P PX PX' (λ x, x)
      → mor_hset_struct P PX' PX (λ x, x)
      → PX = PX')
     ×
     (∏ (X : hSet)
        (PX : P X),
      mor_hset_struct P PX (hset_struct_unit P) (λ _ : X, tt))
     ×
     (∏ (X Y : hSet)
        (PX : P X)
        (PY : P Y),
      mor_hset_struct P (hset_struct_prod P PX PY) PX dirprod_pr1)
     ×
     (∏ (X Y : hSet)
        (PX : P X)
        (PY : P Y),
      mor_hset_struct P (hset_struct_prod P PX PY) PY dirprod_pr2)
     ×
     (∏ (W X Y : hSet)
        (PW : P W)
        (PX : P X)
        (PY : P Y)
        (f : W → X)
        (g : W → Y)
        (Mf : mor_hset_struct P PW PX f)
        (Mg : mor_hset_struct P PW PY g),
       mor_hset_struct P PW (hset_struct_prod P PX PY) (prodtofuntoprod (f ,, g)))
     ×
     (∏ (X Y : hSet)
        (PX : P X)
        (PY : P Y)
        (y : Y),
      mor_hset_struct P PX PY (λ x, y)).

Definition hset_struct
  : UU
  := ∑ (P : hset_struct_data), hset_struct_laws P.

Coercion hset_struct_to_data
         (P : hset_struct)
  : hset_struct_data
  := pr1 P.

Section Projections.
  Context (P : hset_struct).

  Proposition isaset_hset_struct_on_set
              (X : hSet)
    : isaset (P X).
  Proof.
    exact (pr12 P X).
  Qed.

  Proposition isaprop_hset_struct_on_mor
              {X Y : hSet}
              (PX : P X) (PY : P Y)
              (f : X → Y)
    : isaprop (mor_hset_struct P PX PY f).
  Proof.
    exact (pr122 P X Y PX PY f).
  Qed.

  Proposition hset_struct_id
              {X : hSet}
              (PX : P X)
    : mor_hset_struct P PX PX (λ x, x).
  Proof.
    exact (pr1 (pr222 P) X PX).
  Qed.

  Proposition hset_struct_comp
              {X Y Z : hSet}
              {PX : P X}
              {PY : P Y}
              {PZ : P Z}
              {f : X → Y}
              {g : Y → Z}
              (Mf : mor_hset_struct P PX PY f)
              (Mg : mor_hset_struct P PY PZ g)
    : mor_hset_struct P PX PZ (λ x, g(f x)).
  Proof.
    exact (pr12 (pr222 P) X Y Z PX PY PZ f g Mf Mg).
  Qed.

  Proposition hset_struct_standard
              {X : hSet}
              {PX PX' : P X}
              (Mf : mor_hset_struct P PX PX' (λ x, x))
              (Mf' : mor_hset_struct P PX' PX (λ x, x))
    : PX = PX'.
  Proof.
    exact (pr122 (pr222 P) X PX PX' Mf Mf').
  Qed.

  Proposition hset_struct_to_unit
              {X : hSet}
              (PX : P X)
    : mor_hset_struct P PX (hset_struct_unit P) (λ _ : X, tt).
  Proof.
    exact (pr1 (pr222 (pr222 P)) X PX).
  Qed.

  Proposition hset_struct_pr1
              {X Y : hSet}
              (PX : P X)
              (PY : P Y)
    : mor_hset_struct P (hset_struct_prod P PX PY) PX dirprod_pr1.
  Proof.
    exact (pr12 (pr222 (pr222 P)) X Y PX PY).
  Qed.

  Proposition hset_struct_pr2
              {X Y : hSet}
              (PX : P X)
              (PY : P Y)
    : mor_hset_struct P (hset_struct_prod P PX PY) PY dirprod_pr2.
  Proof.
    exact (pr122 (pr222 (pr222 P)) X Y PX PY).
  Qed.

  Proposition hset_struct_pair
              {W X Y : hSet}
              {PW : P W}
              {PX : P X}
              {PY : P Y}
              {f : W → X}
              {g : W → Y}
              (Mf : mor_hset_struct P PW PX f)
              (Mg : mor_hset_struct P PW PY g)
    : mor_hset_struct P PW (hset_struct_prod P PX PY) (prodtofuntoprod (f ,, g)).
  Proof.
    exact (pr1 (pr222 (pr222 (pr222 P))) W X Y PW PX PY f g Mf Mg).
  Qed.

  Proposition hset_struct_const
              {X Y : hSet}
              (PX : P X)
              (PY : P Y)
              (y : Y)
    : mor_hset_struct P PX PY (λ x, y).
  Proof.
    exact (pr2 (pr222 (pr222 (pr222 P))) X Y PX PY y).
  Qed.
End Projections.

Section SetStructure.
  Context (P : hset_struct).

  (**
   2. The corresponding displayed category
   *)
  Definition hset_struct_disp_cat
    : disp_cat SET
    := disp_struct
         SET
         P
         (λ X Y PX PY f, mor_hset_struct P PX PY f)
         (λ X Y PX PY f, isaprop_hset_struct_on_mor P PX PY f)
         (λ X PX, hset_struct_id P PX)
         (λ X Y Z PX PY PZ f g Mf Mg, hset_struct_comp P Mf Mg).

  Proposition is_univalent_disp_hset_struct_disp_cat
    : is_univalent_disp hset_struct_disp_cat.
  Proof.
    use is_univalent_disp_from_SIP_data.
    - exact (isaset_hset_struct_on_set P).
    - exact (λ X PX PX' Mf Mf', hset_struct_standard P Mf Mf').
  Qed.

  Definition dispTerminal_hset_disp_struct
    : dispTerminal hset_struct_disp_cat TerminalHSET.
  Proof.
    refine (hset_struct_unit P ,, _).
    intros X PX.
    use iscontraprop1.
    - apply isaprop_hset_struct_on_mor.
    - exact (hset_struct_to_unit P PX).
  Defined.

  Definition dispBinProducts_hset_disp_struct
    : dispBinProducts hset_struct_disp_cat BinProductsHSET.
  Proof.
    intros X Y PX PY.
    simple refine ((_ ,, (_ ,, _)) ,, _).
    - exact (hset_struct_prod P PX PY).
    - exact (hset_struct_pr1 P PX PY).
    - exact (hset_struct_pr2 P PX PY).
    - intros W f g PW Mf Mg ; cbn.
      use iscontraprop1.
      + abstract
          (use isaproptotal2 ;
           [ intro ;
            apply isapropdirprod ; apply hset_struct_disp_cat
           | ] ;
           intros ;
           apply isaprop_hset_struct_on_mor).
      + simple refine (_ ,, _ ,, _).
        * exact (hset_struct_pair P Mf Mg).
        * apply isaprop_hset_struct_on_mor.
        * apply isaprop_hset_struct_on_mor.
  Defined.

  (**
   3. The total category
   *)
  Definition category_of_hset_struct
    : category
    := total_category hset_struct_disp_cat.

  Proposition eq_mor_hset_struct
              {X Y : category_of_hset_struct}
              {f g : X --> Y}
              (p : ∏ (x : pr11 X), pr1 f x = pr1 g x)
    : f = g.
  Proof.
    use subtypePath.
    {
      intro.
      apply isaprop_hset_struct_on_mor.
    }
    use funextsec.
    exact p.
  Qed.

  Definition is_univalent_category_of_hset_struct
    : is_univalent category_of_hset_struct.
  Proof.
    use is_univalent_total_category.
    - exact is_univalent_HSET.
    - exact is_univalent_disp_hset_struct_disp_cat.
  Defined.

  Definition Terminal_category_of_hset_struct
    : Terminal category_of_hset_struct.
  Proof.
    use total_category_Terminal.
    - exact TerminalHSET.
    - exact dispTerminal_hset_disp_struct.
  Defined.

  Definition BinProducts_category_of_hset_struct
    : BinProducts category_of_hset_struct.
  Proof.
    use total_category_Binproducts.
    - exact BinProductsHSET.
    - exact dispBinProducts_hset_disp_struct.
  Defined.

  (**
   4. Transporting structures
   *)
  Definition transportf_struct_weq
             {X Y : hSet}
             (w : X ≃ Y)
             (PX : P X)
    : P Y
    := transportf P (univalence_hSet w) PX.

  Proposition transportf_struct_idweq
              (X : hSet)
              (PX : P X)
    : transportf_struct_weq (idweq X) PX = PX.
  Proof.
    refine (_ @ idpath_transportf _ _).
    unfold transportf_struct_weq.
    apply maponpaths_2.
    apply univalence_hSet_idweq.
  Qed.

  Definition transportf_mor_weq
             {X₁ X₂ Y₁ Y₂ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (w₂ : X₂ ≃ Y₂)
             (f : X₁ → X₂)
    : Y₁ → Y₂
    := λ y, w₂ (f (invmap w₁ y)).

  Definition transportf_struct_mor_via_transportf
             {X₁ X₂ Y₁ Y₂ : hSet}
             (p₁ : X₁ = Y₁)
             (PX₁ : P X₁)
             (p₂ : X₂ = Y₂)
             (PX₂ : P X₂)
             (f : X₁ → X₂)
             (Hf : mor_hset_struct P PX₁ PX₂ f)
    : mor_hset_struct
        P
        (transportf P p₁ PX₁)
        (transportf P p₂ PX₂)
        (transportf_mor_weq
           (hSet_univalence_map _ _ p₁)
           (hSet_univalence_map _ _ p₂)
           f).
  Proof.
    induction p₁, p₂ ; cbn.
    exact Hf.
  Qed.

  Definition transportf_struct_mor
             {X₁ X₂ Y₁ Y₂ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (PX₁ : P X₁)
             (w₂ : X₂ ≃ Y₂)
             (PX₂ : P X₂)
             (f : X₁ → X₂)
             (Hf : mor_hset_struct P PX₁ PX₂ f)
    : mor_hset_struct
        P
        (transportf_struct_weq w₁ PX₁)
        (transportf_struct_weq w₂ PX₂)
        (transportf_mor_weq w₁ w₂ f).
  Proof.
    pose (transportf_struct_mor_via_transportf
            (univalence_hSet w₁)
            PX₁
            (univalence_hSet w₂)
            PX₂
            f
            Hf)
      as H.
    rewrite !hSet_univalence_map_univalence_hSet in H.
    exact H.
  Qed.

  Definition transportf_struct_mor_via_eq
             {X₁ X₂ Y₁ Y₂ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (PX₁ : P X₁)
             (w₂ : X₂ ≃ Y₂)
             (PX₂ : P X₂)
             (f : X₁ → X₂)
             (Hf : mor_hset_struct P PX₁ PX₂ f)
             (g : Y₁ → Y₂)
             (p : ∏ (y : Y₁), g y = transportf_mor_weq w₁ w₂ f y)
    : mor_hset_struct
        P
        (transportf_struct_weq w₁ PX₁)
        (transportf_struct_weq w₂ PX₂)
        g.
  Proof.
    refine (transportf
              _
              _
              (transportf_struct_mor w₁ PX₁ w₂ PX₂ f Hf)).
    use funextsec.
    intro y.
    exact (!(p y)).
  Qed.

  Definition transportf_mor_weq_prod
             {X₁ X₂ X₃ Y₁ Y₂ Y₃ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (w₂ : X₂ ≃ Y₂)
             (w₃ : X₃ ≃ Y₃)
             (f : X₁ × X₂ → X₃)
    : Y₁ × Y₂ → Y₃
    := λ y, w₃ (f (invmap w₁ (pr1 y) ,, invmap w₂ (pr2 y))).

  Definition transportf_struct_mor_prod_via_transportf
             {X₁ X₂ X₃ Y₁ Y₂ Y₃ : hSet}
             (p₁ : X₁ = Y₁)
             (PX₁ : P X₁)
             (p₂ : X₂ = Y₂)
             (PX₂ : P X₂)
             (p₃ : X₃ = Y₃)
             (PX₃ : P X₃)
             (f : X₁ × X₂ → X₃)
             (Hf : mor_hset_struct P (hset_struct_prod P PX₁ PX₂) PX₃ f)
    : mor_hset_struct
        P
        (hset_struct_prod
           P
           (transportf P p₁ PX₁)
           (transportf P p₂ PX₂))
        (transportf P p₃ PX₃)
        (transportf_mor_weq_prod
           (hSet_univalence_map _ _ p₁)
           (hSet_univalence_map _ _ p₂)
           (hSet_univalence_map _ _ p₃)
           f).
  Proof.
    induction p₁, p₂, p₃.
    exact Hf.
  Qed.

  Definition transportf_struct_mor_prod
             {X₁ X₂ X₃ Y₁ Y₂ Y₃ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (PX₁ : P X₁)
             (w₂ : X₂ ≃ Y₂)
             (PX₂ : P X₂)
             (w₃ : X₃ ≃ Y₃)
             (PX₃ : P X₃)
             (f : X₁ × X₂ → X₃)
             (Hf : mor_hset_struct P (hset_struct_prod P PX₁ PX₂) PX₃ f)
    : mor_hset_struct
        P
        (hset_struct_prod
           P
           (transportf_struct_weq w₁ PX₁)
           (transportf_struct_weq w₂ PX₂))
        (transportf_struct_weq w₃ PX₃)
        (transportf_mor_weq_prod w₁ w₂ w₃ f).
  Proof.
    pose (transportf_struct_mor_prod_via_transportf
            (univalence_hSet w₁)
            PX₁
            (univalence_hSet w₂)
            PX₂
            (univalence_hSet w₃)
            PX₃
            f
            Hf)
      as H.
    rewrite !hSet_univalence_map_univalence_hSet in H.
    exact H.
  Qed.

  Definition transportf_struct_mor_prod_via_eq
             {X₁ X₂ X₃ Y₁ Y₂ Y₃ : hSet}
             (w₁ : X₁ ≃ Y₁)
             (PX₁ : P X₁)
             (w₂ : X₂ ≃ Y₂)
             (PX₂ : P X₂)
             (w₃ : X₃ ≃ Y₃)
             (PX₃ : P X₃)
             (f : X₁ × X₂ → X₃)
             (Hf : mor_hset_struct P (hset_struct_prod P PX₁ PX₂) PX₃ f)
             (g : Y₁ × Y₂ → Y₃)
             (p : ∏ (y : Y₁ × Y₂), g y = transportf_mor_weq_prod w₁ w₂ w₃ f y)
    : mor_hset_struct
        P
        (hset_struct_prod
           P
           (transportf_struct_weq w₁ PX₁)
           (transportf_struct_weq w₂ PX₂))
        (transportf_struct_weq w₃ PX₃)
        g.
  Proof.
    refine (transportf
              _
              _
              (transportf_struct_mor_prod w₁ PX₁ w₂ PX₂ w₃ PX₃ f Hf)).
    use funextsec.
    intro y.
    exact (!(p y)).
  Qed.

  Definition transportf_struct_weq_on_weq_transportf
             {X Y : hSet}
             (p : X = Y)
             (PX : P X)
    : mor_hset_struct
        P
        PX
        (transportf P p PX)
        (hSet_univalence_map _ _ p).
  Proof.
    induction p ; cbn.
    apply hset_struct_id.
  Qed.

  Definition transportf_struct_weq_on_weq
             {X Y : hSet}
             (w : X ≃ Y)
             (PX : P X)
    : mor_hset_struct
        P
        PX
        (transportf_struct_weq w PX)
        w.
  Proof.
    pose (transportf_struct_weq_on_weq_transportf
            (univalence_hSet w)
            PX)
      as H.
    rewrite hSet_univalence_map_univalence_hSet in H.
    exact H.
  Qed.

  Definition transportf_struct_weq_on_invweq_transportf
             {X Y : hSet}
             (p : X = Y)
             (PX : P X)
    : mor_hset_struct
        P
        (transportf P p PX)
        PX
        (hSet_univalence_map _ _ (!p)).
  Proof.
    induction p ; cbn.
    apply hset_struct_id.
  Qed.

  Definition transportf_struct_weq_on_invweq
             {X Y : hSet}
             (w : X ≃ Y)
             (PX : P X)
    : mor_hset_struct
        P
        (transportf_struct_weq w PX)
        PX
        (invmap w).
  Proof.
    pose (transportf_struct_weq_on_invweq_transportf
            (univalence_hSet w)
            PX)
      as H.
    rewrite univalence_hSet_inv in H.
    rewrite hSet_univalence_map_univalence_hSet in H.
    exact H.
  Qed.
End SetStructure.

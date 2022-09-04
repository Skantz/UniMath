(** * Matrices

Elementary row operations on matrices, for elimination procedures

Author: @Skantz (April 2021)
*)

Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.

Require Import UniMath.Combinatorics.StandardFiniteSets.
Require Import UniMath.Combinatorics.Vectors.

Require Import UniMath.NumberSystems.RationalNumbers.
Require Import UniMath.Algebra.Matrix.

Require Import UniMath.Algebra.Elimination.Auxiliary.
Require Import UniMath.Algebra.Elimination.Vectors.

Require Import UniMath.Algebra.Elimination.Matrices.

Section GaussOps.
  (* TODO better (or any) comments for all these functions including assumptions*)

  Context { F : fld }.
  Local Notation Σ := (iterop_fun 0%ring op1).
  Local Notation "R1 ^ R2" := ((pointwise _ op2) R1 R2).
  Local Notation "A ** B" := (@matrix_mult F _ _ A _ B) (at level 80).

Section Auxiliary.

  (* TODO: generalize to rigs, upstream to Vectors *)
  Lemma pointwise_rdistr_vector { n : nat } (v1 v2 v3 : Vector F n)
    : (pointwise n op1 v1 v2) ^ v3 = pointwise n op1 (v1 ^ v3) (v2 ^ v3).
  Proof.
    use (pointwise_rdistr (rigrdistr F)).
  Defined.

  (* TODO: generalize to rigs, upstream to Vectors *)
  Lemma pointwise_assoc2_vector { n : nat } (v1 v2 v3 : Vector F n)
    : (v1 ^ v2) ^ v3 = v1 ^ (v2 ^ v3).
  Proof.
    use (pointwise_assoc (rigassoc2 F)).
  Defined.

  (* TODO: generalize to commrigs, upstream to Vectors *)
  Lemma pointwise_comm2_vector { n : nat } (v1 v2 : Vector F n)
    : v1 ^ v2 = v2 ^ v1.
  Proof.
    use (pointwise_comm (rigcomm2 F)).
  Defined.

End Auxiliary.

Section RowOps.

  Definition gauss_add_row
    { m n : nat } ( mat : Matrix F m n )
    ( r1 r2 : ⟦ m ⟧%stn ) ( s : F )
    : ( Matrix F m n ).
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r2).
    - exact ((mat r2 j) + (s * (mat r1 j)))%rig.
    - exact (mat i j).
  Defined.

  Definition add_row_matrix
    { n : nat } (r1 r2 : ⟦ n ⟧%stn) (s : F)
    : Matrix F n n.
  Proof.
    intros i.
    induction (stn_eq_or_neq i r2).
    - exact (pointwise n op1 (@stdb_vector F n i)
        (@scalar_lmult_vec F s _ ((@stdb_vector F) n r1))).
    - exact (@stdb_vector F n i).
  Defined.

  Definition gauss_scalar_mult_row
    {X : ring} { m n : nat} (mat : Matrix X m n)
    (s : X) (r : ⟦ m ⟧%stn)
    : Matrix X m n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r).
    - exact (s * (mat i j))%ring.
    - exact (mat i j).
  Defined.

  Definition mult_row_matrix {n : nat}
    (s : F) (r : ⟦ n ⟧%stn)
    : Matrix F n n.
  Proof.
    intros i.
    induction (stn_eq_or_neq i r).
    - exact (const_vec s ^ @stdb_vector F _ i).
    - exact (@stdb_vector F _ i).
  Defined.

  Definition gauss_switch_row
    {m n : nat} (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn)
    : Matrix F m n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r1).
    - exact (mat r2 j).
    - induction (stn_eq_or_neq i r2).
      + exact (mat r1 j).
      + exact (mat i j).
  Defined.

  Lemma gauss_switch_row_inv0
    {m n : nat} (mat : Matrix F m n)
    (r1 : ⟦ m ⟧%stn) (r2 : ⟦ m ⟧%stn)
    : ∏ (i : ⟦ m ⟧%stn), i ≠ r1 -> i ≠ r2
    -> (gauss_switch_row mat r1 r2 ) i = mat i.
  Proof.
    intros i i_ne_r1 i_ne_r2.
    unfold gauss_switch_row.
    apply funextfun. intros i'.
    destruct (stn_eq_or_neq i r1) as [i_eq_r1 | i_neq_r1]
    ; destruct (stn_eq_or_neq i r2) as [i_eq_r2 | i_neq_r2].
    - simpl. rewrite i_eq_r2; apply idpath.
    - simpl. rewrite i_eq_r1 in i_ne_r1.
        apply isirrefl_natneq in i_ne_r1. contradiction.
    - simpl. rewrite i_eq_r2 in i_ne_r2.
        apply isirrefl_natneq in i_ne_r2. contradiction.
    - simpl. apply idpath.
  Defined.

  Lemma gauss_switch_row_inv1
    {m n : nat} (mat : Matrix F m n)
    (r1 : ⟦ m ⟧%stn) (r2 : ⟦ m ⟧%stn)
    : (mat r1) = (mat r2) -> (gauss_switch_row mat r1 r2 ) = mat.
  Proof.
    intros m_eq.
    unfold gauss_switch_row.
    apply funextfun. intros i'.
    destruct (stn_eq_or_neq _ _) as [eq | neq];
      destruct (stn_eq_or_neq _ _) as [eq' | neq'];
      try rewrite eq; try rewrite eq';
      try rewrite m_eq; try reflexivity.
  Defined.

  Lemma gauss_switch_row_inv2
    {m n : nat} (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn) (j : (stn n))
    : (mat r1 j) = (mat r2 j) ->
      ∏ (r3 : ⟦ m ⟧%stn), (gauss_switch_row mat r1 r2 ) r3 j = mat r3 j.
  Proof.
    intros m_eq r3.
    unfold gauss_switch_row.
    destruct (stn_eq_or_neq _ _) as [eq | neq];
      destruct (stn_eq_or_neq _ _) as [eq' | neq'];
      try rewrite eq; try rewrite eq';
      try rewrite m_eq; try reflexivity.
  Defined.

  Definition switch_row_matrix
    {R : rig} {n : nat} (r1 r2 : ⟦ n ⟧ %stn)
    : Matrix R n n.
  Proof.
    intros i.
    induction (stn_eq_or_neq i r1).
    - exact (@identity_matrix R n r2).
    - induction (stn_eq_or_neq i r2).
      + exact (@identity_matrix R n r1).
      + exact (@identity_matrix R n i).
  Defined.

  Local Definition test_row_switch
    {m n : nat} (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn)
    : (gauss_switch_row (gauss_switch_row mat r1 r2) r1 r2) = mat.
  Proof.
    use funextfun; intros i.
    use funextfun; intros j.
    unfold gauss_switch_row.
    destruct (stn_eq_or_neq i r1) as [ e_ir1 | ne_ir1 ].
    - destruct (stn_eq_or_neq r2 r1) as [ e_r1r2 | ne_r1r2 ].
      + destruct e_ir1, e_r1r2. apply idpath.
      + destruct (stn_eq_or_neq r2 r2) as [ ? | absurd ].
        * destruct e_ir1. apply idpath.
        * set (H := isirrefl_natneq _ absurd). destruct H.
    - destruct (stn_eq_or_neq i r2) as [ e_ir2 | ne_ir2 ].
      + destruct e_ir2.
        destruct (stn_eq_or_neq r1 r1) as [ ? | absurd ].
        * reflexivity.
        * destruct (stn_eq_or_neq r1 i) as [ e_ir1 | ne_ir1' ].
        -- rewrite e_ir1. apply idpath.
        -- set (H := isirrefl_natneq _ absurd). destruct H.
      + reflexivity.
  Defined.

End RowOps.

Section Elementary.

  (* The following three lemmata test the equivalence
     of multiplication by elementary matrices to swaps of indices. *)
  Lemma scalar_mult_mat_elementary
    {m n : nat} (mat : Matrix F m n) (s : F) (r : ⟦ m ⟧%stn)
    : ((mult_row_matrix s r) ** mat) = gauss_scalar_mult_row mat s r.
  Proof.
    use funextfun. intros i.
    use funextfun. intros ?.
    unfold matrix_mult, mult_row_matrix, gauss_scalar_mult_row, row.
    destruct (stn_eq_or_neq i r) as [? | ?].
    - simpl coprod_rect.
      etrans.
      { apply maponpaths.
        etrans. { apply maponpaths_2, pointwise_comm2_vector. }
        apply pointwise_assoc2_vector. }
      use sum_stdb_vector_pointwise_prod.
    - simpl coprod_rect.
      use sum_stdb_vector_pointwise_prod.
  Defined.

  (* TODO should certainly be over R *)
  Lemma switch_row_mat_elementary
    { m n : nat } (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn)
    : ((switch_row_matrix r1 r2) ** mat) = gauss_switch_row mat r1 r2.
  Proof.
    rewrite matrix_mult_eq; unfold matrix_mult_unf.
    unfold switch_row_matrix, gauss_switch_row.
    apply funextfun. intros i.
    apply funextfun. intros ?.
    destruct (stn_eq_or_neq i r1) as [i_eq_r1 | i_neq_r1].
    - simpl.
      rewrite (@pulse_function_sums_to_point F m
        (λ i : (⟦ m ⟧%stn), @identity_matrix F m r2 i * _)%ring r2).
      + unfold identity_matrix.
        rewrite stn_eq_or_neq_refl.
        simpl.
        apply (@riglunax2 F).
      + intros k r2_neq_k.
        rewrite (@id_mat_ij F m r2 k r2_neq_k).
        apply (@rigmult0x F).
    - simpl.
      pose (H := @sum_id_pointwise_prod_unf F).
      destruct (stn_eq_or_neq i r2) as [i_eq_r2 | i_neq_r2].
      + simpl.
        destruct (stn_eq_or_neq i r1) as [? | ?].
        * rewrite H; apply idpath.
        * rewrite H; apply idpath.
      + simpl; rewrite H.
        apply idpath.
  Defined.

  (* TODO fix mixed up signatures on add_row  / add_row_matrix *)
  Lemma add_row_mat_elementary
    { m n : nat } (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn) (p : r1 ≠ r2) (s : F)
    : ((add_row_matrix  r1 r2 s) ** mat) = (gauss_add_row mat r1 r2 s).
  Proof.
    intros.
    apply funextfun. intros k.
    apply funextfun. intros l.
    unfold matrix_mult, add_row_matrix, gauss_add_row, row.
    destruct (stn_eq_or_neq k r2) as [k_eq_r2 | k_neq_r2].
    - simpl coprod_rect.
      etrans. { apply maponpaths, pointwise_rdistr_vector. }
      etrans. { apply (@sum_pointwise_op1 F). }
      apply map_on_two_paths.
      + etrans. 2: { apply maponpaths_2, k_eq_r2. }
        use sum_stdb_vector_pointwise_prod.
      + etrans.
        { apply maponpaths.
          etrans. { apply maponpaths_2, pointwise_comm2_vector. }
          apply pointwise_assoc2_vector. }
        use sum_stdb_vector_pointwise_prod.
    - use sum_stdb_vector_pointwise_prod.
  Defined.

  Lemma scalar_mult_matrix_product
    { n : nat }
    ( r : ⟦ n ⟧%stn ) ( s1 s2 : F )
    : ((mult_row_matrix s1 r ) ** (mult_row_matrix s2 r ))
      = (mult_row_matrix (s1 * s2)%ring r ).
  Proof.
    rewrite scalar_mult_mat_elementary.
    unfold gauss_scalar_mult_row.
    unfold mult_row_matrix.
    apply funextfun; intros i.
    apply funextfun; intros j.
    destruct (stn_eq_or_neq i r);
      simpl coprod_rect.
    2: { reflexivity. }
    unfold pointwise.
    apply pathsinv0, rigassoc2.
  Defined.

  Lemma scalar_mult_matrix_one
    {n : nat} (r : ⟦ n ⟧%stn)
    : mult_row_matrix 1%ring r = @identity_matrix F _.
  Proof.
    unfold mult_row_matrix.
    apply funextfun; intros i.
    destruct (stn_eq_or_neq i r); simpl coprod_rect.
    2: { reflexivity. }
    apply funextfun; intros j. apply (@riglunax2 F).
  Defined.

  Lemma scalar_mult_matrix_comm
    { n : nat } ( r : ⟦ n ⟧%stn ) ( s1 s2 : F )
    : ((mult_row_matrix s1 r) ** (mult_row_matrix s2 r))
    = ((mult_row_matrix s2 r) ** (mult_row_matrix s1 r)).
  Proof.
    do 2 rewrite scalar_mult_matrix_product.
    apply maponpaths_2, (rigcomm2 F).
  Defined.

  Lemma scalar_mult_matrix_is_inv
    { n : nat }
    ( i : ⟦ n ⟧%stn ) ( s : F ) ( ne : s != 0%ring )
  : @matrix_inverse F _ (mult_row_matrix s i).
  Proof.
    exists (mult_row_matrix (fldmultinv s ne) i).
    split;
      refine (scalar_mult_matrix_product _ _ _ @ _);
      refine (_ @ scalar_mult_matrix_one i);
      apply maponpaths_2.
    - apply fldmultinvrax; assumption.
    - apply fldmultinvlax; assumption.
  Defined.

  Lemma add_row_matrix_plus_eq
    { n : nat } ( r1 r2 : ⟦ n ⟧%stn ) ( s1 s2 : F ) (ne : r1 ≠ r2) :
    ((add_row_matrix r1 r2 s1 ) ** (add_row_matrix r1 r2 s2))
   = (add_row_matrix r1 r2 (s1 + s2)%ring).
  Proof.
    rewrite add_row_mat_elementary; try assumption.
    apply funextfun; intros i; apply funextfun; intros j.
    unfold gauss_add_row, add_row_matrix.
    destruct (stn_eq_or_neq i r2) as [i_eq_r2 | i_neq_r2].
    2: {apply idpath. }
    destruct i_eq_r2.
    rewrite stn_eq_or_neq_refl, (stn_eq_or_neq_right ne); simpl.
    unfold scalar_lmult_vec, pointwise, const_vec.
    rewrite (@rigrdistr F), rigcomm1, (@rigassoc1 F).
    reflexivity.
  Defined.

  Lemma add_row_matrix_zero
      { n : nat } ( r1 r2 : ⟦ n ⟧%stn ) (ne : r1 ≠ r2)
    : add_row_matrix r1 r2 0%ring = @identity_matrix F _.
  Proof.
    apply funextfun; intros i.
    unfold add_row_matrix.
    destruct (stn_eq_or_neq i r2) as [i_eq_r2 | i_neq_r2].
    2: { apply idpath. }
    destruct i_eq_r2. simpl.
    apply funextfun; intros j.
    unfold scalar_lmult_vec, pointwise.
    rewrite (@rigmult0x F).
    apply (@rigrunax1 F).
  Defined.

  Lemma add_row_matrix_commutes { n : nat }
        ( r1 r2 : ⟦ n ⟧%stn ) ( s1 s2 : F ) (ne : r1 ≠ r2) :
       ((add_row_matrix r1 r2 s1 ) ** (add_row_matrix r1 r2 s2 ))
     = ((add_row_matrix r1 r2 s2 ) ** (add_row_matrix r1 r2 s1 )).
  Proof.
    do 2 (rewrite add_row_matrix_plus_eq; try assumption).
    apply maponpaths, (@rigcomm1 F).
  Defined.

  Lemma add_row_matrix_is_inv { n : nat } ( r1 r2 : ⟦ n ⟧%stn )
  (r1_neq_r2 : r1 ≠ r2) ( s : F )
   : @matrix_inverse F n (add_row_matrix r1 r2 s).
  Proof.
    exists (add_row_matrix r1 r2 (- s)%ring).
    split;
      refine (add_row_matrix_plus_eq _ _ _ _ r1_neq_r2 @ _);
      refine (_ @ add_row_matrix_zero _ _ r1_neq_r2);
      apply maponpaths.
    - apply (@ringrinvax1 F).
    - apply (@ringlinvax1 F).
  Defined.

  Lemma switch_row_matrix_involution
    { n : nat } ( r1 r2 : ⟦ n ⟧%stn )
    : ((switch_row_matrix r1 r2)
      ** (switch_row_matrix r1 r2))
      = @identity_matrix _ _.
  Proof.
    intros.
    rewrite switch_row_mat_elementary.
    unfold gauss_switch_row, switch_row_matrix.
    apply funextfun; intros i.
    destruct (stn_eq_or_neq i r1) as [eq | neq];
      destruct (stn_eq_or_neq r1 r2) as [eq' | neq'];
      rewrite stn_eq_or_neq_refl; simpl.
    - rewrite eq'; rewrite stn_eq_or_neq_refl; simpl.
      apply funextfun; intros j.
      rewrite <- eq', eq; apply idpath.
    - rewrite eq; simpl.
      rewrite (stn_eq_or_neq_right (stn_neq_symm neq')); simpl.
      reflexivity.
    - rewrite <- eq'; rewrite stn_eq_or_neq_refl; simpl.
      rewrite (stn_eq_or_neq_right neq); simpl.
      reflexivity.
    - rewrite stn_eq_or_neq_refl; simpl.
      destruct (stn_eq_or_neq _ _) as [eq | ?]; simpl.
      + rewrite eq; reflexivity.
      + reflexivity.
  Defined.

  Lemma switch_row_matrix_is_inv
    { n : nat } ( r1 r2 : ⟦ n ⟧%stn )
    : @matrix_inverse F n (switch_row_matrix r1 r2).
  Proof.
    exists (switch_row_matrix r1 r2).
    split; apply switch_row_matrix_involution.
  Defined.

End Elementary.

End GaussOps.

(* Section ColOps. 
   ... *)

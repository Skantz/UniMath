(** * Matrices

Gaussian Elimination over integers.

Author: @Skantz (April 2021)
*)

Require Import UniMath.Foundations.PartA.
Require Import UniMath.MoreFoundations.PartA.

Require Import UniMath.Combinatorics.StandardFiniteSets.
Require Import UniMath.Combinatorics.FiniteSequences.
Require Import UniMath.Algebra.BinaryOperations.
Require Import UniMath.Algebra.IteratedBinaryOperations.

Require Import UniMath.Algebra.RigsAndRings.
Require Import UniMath.Algebra.Matrix.

Require Import UniMath.NumberSystems.Integers.
Require Import UniMath.NumberSystems.RationalNumbers.

Require Import UniMath.Combinatorics.WellOrderedSets.

Require Import UniMath.Combinatorics.Vectors.

Require Import UniMath.Foundations.NaturalNumbers.
Require Import UniMath.Tactics.Nat_Tactics.
Require Import UniMath.Foundations.PartA.
Require Import UniMath.MoreFoundations.Nat.


(*Local Definition R := pr1hSet natcommrig.*)
Context { R : rig }.
Local Definition F := hq.

(* The first few sections contain Definitions and Lemmas that
   should be moved further up the project tree *)



Local Notation "A ** B" := (matrix_mult A B) (at level 80).
Local Notation  Σ := (iterop_fun 0%hq op1).
Local Notation "R1 ^ R2" := ((pointwise _ op2) R1 R2).


Section Misc.

  Definition min' (n m : nat) : nat.
  Proof.
    induction (natgtb n m).
    - exact m.
    - exact n.
  Defined.

End Misc.


Section PrelStn.

  Local Definition truncate_pr1 { n : nat } ( f : ⟦ n ⟧%stn → hq) ( k : ⟦ n ⟧%stn ) : ( ⟦ n ⟧%stn → hq).
  Proof.
    intros.
    induction (natgtb X k).
    - exact (f X).
    - exact (f k).
  Defined.

  Lemma stn_implies_nneq0 { n : nat } (i : ⟦ n ⟧%stn) : n ≠ 0.
  Proof.
    induction (natchoice0 n) as [T | F].
    - rewrite <- T in i.
      apply weqstn0toempty in i. apply fromempty. assumption.
    - change (0 < n) with (n > 0) in F.
      destruct n.
      + apply isirreflnatgth in F. apply fromempty. assumption.
      + apply natgthtoneq in F. reflexivity.
  Defined.

  Lemma stn_implies_ngt0 { n : nat} (i : ⟦ n ⟧%stn) : n > 0.
  Proof.
    exact (natneq0to0lth n (stn_implies_nneq0 i)).
  Defined.

  Definition decrement_stn_by_m { n : nat } ( i : (⟦ n ⟧)%stn ) (m : nat) : ⟦ n ⟧%stn. (* (⟦ n ⟧)%stn.*)
  Proof.
    induction (natgehchoice m 0).
    - assert ( p :  ((pr1 i) - m) < n).
        {  unfold stn in i. set (p0 := pr2 i). assert (pr1 i < n).
           - exact (pr2 i).
           - assert ((pr1 i - m <= ( pr1 i))). {apply (natminuslehn ). }
              apply (natlehlthtrans (pr1 i - m) (pr1 i) ).
              + assumption.
              + assumption.
        }
      exact (pr1 i - m,, p).
    - exact i.
    - reflexivity.
  Defined.

  Local Definition mltntommin1ltn { n m : nat } (p : m < n) : (m - 1 < n).
  Proof.
    apply natlthtolthm1. assumption.
  Defined.


  Definition set_stn_vector_el { n : nat } (vec : Vector (⟦ n ⟧%stn) n) (idx : ⟦ n ⟧%stn) (el : (⟦ n ⟧%stn)) : Vector (⟦ n ⟧%stn) n.
  Proof.
  intros i.
  induction (stn_eq_or_neq i idx).
  + exact el.
  + exact (vec i).
  Defined.

  Definition nat_lt_minmn_to_stnm_stnn {m n : nat} (i : nat) (p : i < min' m n) : ⟦ m ⟧%stn × ⟦ n ⟧%stn.
  Proof.
   (* unfold min in p. *)
    assert (min n n = n).
      { unfold min.  induction n. reflexivity. unfold natgtb. destruct n. { reflexivity. }

    assert (i < n).
    (* cbn in p. *)
    induction (natgehchoice m n) as [MGT | NGE].
      - unfold min in p.

  Abort.

  (*
  Definition decrement_stn_by_m { n : nat } ( i : (⟦ n ⟧)%stn ) (m : nat) : ⟦ n ⟧%stn. (* (⟦ n ⟧)%stn.*)
  Proof.
    induction (natgehchoice m 0).
    - assert ( p :  ((pr1 i) - m) < n).
        {  unfold stn in i. set (p0 := pr2 i). assert (pr1 i < n).
           - exact (pr2 i).
           - assert ((pr1 i - m <= ( pr1 i))). {apply (natminuslehn ). }
              apply (natlehlthtrans (pr1 i - m) (pr1 i) ).
              + assumption.
              + assumption.
        }
      exact (pr1 i - m,, p).
    - exact i.
    - reflexivity.
  Defined.
  *)

  Definition stnn_to_stn_sminusn1 { n : nat } ( i : (⟦ n ⟧)%stn ) : ((⟦ S (n - 1) ⟧)%stn).
  Proof.
    intros.
    induction (natgehchoice n 0).
    3 : { exact (natgehn0 n). }
    2 : { apply stn_implies_ngt0 in i.
          apply natgthtoneq in i.
          rewrite b in i.
          contradiction i.
    }
    assert (e : n = S (n - 1)). (* Small proof taken verbatim from stnsum. *)
    { change (S (n - 1)) with (1 + (n - 1)). rewrite natpluscomm.
      apply pathsinv0. apply minusplusnmm. assumption.
    }
    rewrite <- e.
    assumption.
  Defined.

  (* TODO this should just be a matter of rewriting using above ? *)
  Definition stn_sminusn1_to_stnn { n : nat }  (i : (⟦ S (n - 1) ⟧)%stn) (p : n > 0) : (⟦ n ⟧%stn).
  Proof.
    intros.
    induction (natgehchoice (S (n - 1)) 0). (*(natgehchoice (S (n - 1)) 0). *)
      3 : { exact (natgehn0 n ). }
      2 : { rewrite b in i.
            apply (stn_implies_ngt0) in i.
            apply isirreflnatgth in i.
            apply fromempty. assumption.
      }
    assert (e : n = S (n - 1)). (* Small proof taken verbatim from stnsum. *)
    { change (S (n - 1)) with (1 + (n - 1)). rewrite natpluscomm.
      apply pathsinv0. rewrite minusplusnmm.
      - apply idpath.
      - apply p. }
    rewrite <- e in i.
    assumption.
  Defined.


End PrelStn.


Section Matrices.


  Context { R : rig }.

  Definition matunel2 { n : nat } := @identity_matrix R n.

  Local Notation  Σ := (iterop_fun rigunel1 op1).


  (* Identical to transport_stnsum but with Σ , R*)
  Lemma transport_rigsum {m n : nat} (e: m = n) (g: ⟦ n ⟧%stn -> R) :
     Σ g =  Σ (λ i, g (transportf stn e i)).
  Proof.
    intros.
    induction e.
    apply idpath.
  Defined.


  (* Is there some tactical way to re-use previous proofs
     with a few changes? *)
  Lemma rigsum_eq {n : nat} (f g : ⟦ n ⟧%stn -> R) : f ~ g ->  Σ f =  Σ g.
  Proof.
    intros h.
    induction n as [|n IH].
    - apply idpath.
    - rewrite 2? iterop_fun_step. 2: { apply riglunax1. }
                                  2: { apply riglunax1. }
      induction (h lastelement).
      apply (maponpaths (λ i, op1 i (f lastelement))).
      apply IH.
      intro x.
      apply h.
  Defined.

  Lemma rigsum_step {n : nat} (f : ⟦ S n ⟧%stn -> R) :
    Σ f = op1 (Σ (f ∘ (dni lastelement))) (f lastelement).
  Proof.
    intros.
    apply iterop_fun_step.
    apply riglunax1.
  Defined.


  Lemma rigsum_left_right :
  ∏ (m n : nat) (f : (⟦ m + n ⟧)%stn → R),
   Σ f =  op1 (Σ (f ∘ stn_left m n)) (Σ (f ∘ stn_right m n)).
  Proof.
    intros.
    induction n as [| n IHn].
    (*unfold stn_left. unfold stn_right.*)
    { change (Σ  _) with (@rigunel1 R) at 3.
      set (a := m + 0). assert (a = m). { apply natplusr0. } (* In the stnsum case,
                                                                this can affect ⟦ m ⟧
                                                                and zeroes elsewhere *)
      assert (e := ! natplusr0 m).
      rewrite (transport_rigsum e).
      unfold funcomp.
      rewrite  rigrunax1.
      apply maponpaths. apply pathsinv0.
      apply funextfun. intros i.
      rewrite <- stn_left_0.
      reflexivity.
    }
    rewrite rigsum_step.
    assert (e : S (m + n) = m + S n).
    { apply pathsinv0. apply natplusnsm. }
    rewrite (transport_rigsum e).
    rewrite rigsum_step.
    rewrite <- rigassoc1. apply map_on_two_paths.
    { rewrite IHn; clear IHn. apply map_on_two_paths.
      { apply rigsum_eq; intro i. unfold funcomp.
        apply maponpaths. apply subtypePath_prop.
        rewrite stn_left_compute. induction e.
        rewrite idpath_transportf. rewrite dni_last.
        apply idpath. }
      { apply rigsum_eq; intro i. unfold funcomp.
        apply maponpaths. apply subtypePath_prop.
        rewrite stn_right_compute. unfold stntonat. induction e.   (* we have stn_right instead of stn_left? *)
        rewrite idpath_transportf. rewrite 2? dni_last.
        apply idpath. } }
    unfold funcomp. apply maponpaths. apply subtypePath_prop.
    induction e. apply idpath.
  Defined.

  (* stnsum_dni with
     stnsum -> Σ
     transport_stnsum -> transport_rigsum
     stnsum_left_right -> rigsum_left_right
     natplusassoc -> rigassoc1*)
  Lemma rigsum_dni {n : nat} (f : ⟦ S n ⟧%stn -> R) (j : ⟦ S n ⟧%stn ) :
    Σ f = op1 (Σ (f ∘ dni j)) (f j).
Proof.
  intros.
  induction j as [j J].
  assert (e2 : j + (n - j) = n).
  { rewrite natpluscomm. apply minusplusnmm. apply natlthsntoleh. exact J. }
  assert (e : (S j) + (n - j) = S n).
  { change (S j + (n - j)) with (S (j + (n - j))). apply maponpaths. exact e2. }
  intermediate_path (Σ  (λ i, f (transportf stn e i))).
  - apply (transport_rigsum e).
  - rewrite (rigsum_left_right (S j) (n - j)); unfold funcomp.
    apply pathsinv0. rewrite (transport_rigsum e2).
    rewrite (rigsum_left_right j (n-j)); unfold funcomp.
    rewrite (rigsum_step (λ x, f (transportf stn e _))); unfold funcomp.
    apply pathsinv0.
    rewrite rigassoc1. rewrite (@rigcomm1 R (f _) ). rewrite  <- rigassoc1. (* natpluss to @ R ... *)
    apply map_on_two_paths.
    + apply map_on_two_paths.
      * apply rigsum_eq; intro i. induction i as [i I].
        apply maponpaths. apply subtypePath_prop.
        induction e. rewrite idpath_transportf. rewrite stn_left_compute.
        unfold dni,di, stntonat; simpl.
        induction (natlthorgeh i j) as [R'|R'].
        -- unfold stntonat; simpl; rewrite transport_stn; simpl.
           induction (natlthorgeh i j) as [a|b].
           ++ apply idpath.
           ++ contradicts R' (natlehneggth b).
        -- unfold stntonat; simpl; rewrite transport_stn; simpl.
           induction (natlthorgeh i j) as [V|V].
           ++ contradicts I (natlehneggth R').
           ++ apply idpath.
      * apply rigsum_eq; intro i. induction i as [i I]. apply maponpaths.
        unfold dni,di, stn_right, stntonat; repeat rewrite transport_stn; simpl.
        induction (natlthorgeh (j+i) j) as [X|X].
        -- contradicts (negnatlthplusnmn j i) X.
        -- apply subtypePath_prop. simpl. apply idpath.
    + apply maponpaths.
      rewrite transport_stn; simpl.
      apply subtypePath_prop.
      apply idpath.
Defined.


(* Should be n not S n *)
  Lemma pulse_function_sums_to_point_rig { n : nat }  (f : ⟦ S n ⟧%stn -> R) :
  ∏ (i : ⟦ S n ⟧%stn ), (f i != 0%rig) -> (∏ (j : ⟦ S n ⟧%stn), ((i ≠ j) -> (f j = 0%rig))) ->  (Σ f = f i).
  Proof.
    intros i. intros f_i_neq_0 j.  (*impj0.*)
    rewrite (rigsum_dni f i).
    rewrite zero_function_sums_to_zero.
    { rewrite riglunax1. apply idpath. }
    apply funextfun.
    intros k.
    unfold funcomp.

    replace (const_vec 0%rig k) with (@rigunel1 R). 2: { reflexivity. }
    assert (i_neq_dni : i ≠ dni i k) . {exact (dni_neq_i i k). }
    - intros. destruct (stn_eq_or_neq i (dni i k) ).
        + apply (stnneq_iff_nopath i (dni i k)) in p.
          apply weqtoempty. intros. apply p. assumption.
          exact (dni_neq_i i k). (* Move up *)
        + apply j. exact h.
  Defined.


(* TODO: possibly write special case [v ∧ (pulse j a) = a * (v j)]. *)

  Definition is_pulse_function { n : nat } ( i : ⟦ n ⟧%stn )  (f : ⟦ n ⟧%stn -> R) :=
   ∏ (j: ⟦ n ⟧%stn), (f i != 0%rig) -> (i ≠ j) -> (f j = 0%rig).
    (*(∏ (j : ⟦ n ⟧%stn), ((i ≠ j) -> (f j = 0%rig))) ->  (Σ f = f i).*) (* TODO : use us this one ?) *)

  Lemma pulse_function_sums_to_point_rig' { n : nat } ( i : ⟦ n ⟧%stn ) {f : ⟦ n ⟧%stn -> R}
    (p : is_pulse_function i f) : (Σ f = f i).
  Proof.
    unfold is_pulse_function in p.
    assert (e : n = S (n - 1)).
    (* TODO: this is used three times might as well upstream? *)
    { induction (natlthorgeh n 1) as [n_le_1 | n_geq_1].
      + apply natlth1tois0 in n_le_1.
        remember i as i'. clear Heqi'.
        rewrite n_le_1 in i.
        apply weqstn0toempty in i. apply fromempty. assumption.
      + change (S (n - 1)) with (1 + (n - 1)). rewrite natpluscomm.
        apply pathsinv0. apply minusplusnmm. assumption. }
    rewrite (transport_rigsum (!e) f).
    assert (e' : (⟦ n ⟧%stn = ⟦ S (n - 1) ⟧%stn)).
    { rewrite <- e. apply idpath. }
  Admitted.

  (* ~ point of interest ~ *)
  Lemma pulse_function_sums_to_point_rig'' { n : nat }  (f : ⟦ n ⟧%stn -> R) (p : n > 0) :
  ∏ (i : ⟦ n ⟧%stn ), (f i != 0%rig) -> (∏ (j : ⟦ n ⟧%stn), ((i ≠ j) -> (f j = 0%rig))) ->  (Σ f = f i).
  Proof.
    intros ? ? ?.
    assert (e : n = S (n - 1)).
    (* TODO: this is used three times might as well upstream? *)
    { induction (natlthorgeh n 1) as [n_le_1 | n_geq_1].
      + apply natlth1tois0 in n_le_1.
        remember i as i'. clear Heqi'.
        rewrite n_le_1 in i.
        apply weqstn0toempty in i. apply fromempty. assumption.
      + change (S (n - 1)) with (1 + (n - 1)). rewrite natpluscomm.
        apply pathsinv0. apply minusplusnmm. assumption. }

    rewrite (transport_rigsum (!e) f).
    assert (e' : (⟦ n ⟧%stn = ⟦ S (n - 1) ⟧%stn)).
    { rewrite <- e. apply idpath. }

Abort.


  (*
  Lemma rigsum_drop { n : nat } ( f : ⟦ S n ⟧%stn -> R) ( i : ⟦ n ⟧%stn ) :
    Σ f = op2 (Σ (drop_el f i)) (f i ).
  *)

  (* TODO: upstream - Vector equivalent of drop_el for "vecs"? *)
  Definition drop_el_vector { n : nat } (f : ⟦ S n ⟧%stn -> R) (i : ⟦ S n ⟧%stn) :
    ⟦ n ⟧%stn -> R.
  Proof.
    intros X.
    induction (natlthorgeh X i) as [X_le_i | X_geq_i].
    - assert (e : X < S n ).
      { set (p := pr2 X).
        apply (istransnatgth (S n) n X (natgthsnn n) (pr2 X)).
      }
      exact (f ((pr1  X),, e)).

    - assert (e :S ( X ) < S n ).
      { set (p := pr2 X).
        apply p. }
      exact (f (S X,, e)).
  Defined.

  (* Used to be in PAdics *)
  Lemma minussn1 ( n : nat ) : ( S n ) - 1 ≥ n.
  Proof.
    intros. destruct n. apply idpath.
    assert (e : (S (S n)) > (S n)).
    { apply natgthsnn. }
    apply natgthtogehm1 in e. assumption.
  Defined.


  (* TODO : This proof is a shambles !*)
  Definition drop_idx_vector { n : nat } ( i : ⟦ S n ⟧%stn ) ( drop : ⟦ S n ⟧%stn ) (p : n > 0) :
    ⟦ n ⟧%stn.
  Proof.
    intros.
    induction (natlthorgeh i drop) as [i_le_drop | i_geq_drop].
    - assert (e: drop ≤ n).
      { apply (pr2 drop). }
      assert (e': i < n). {
        apply (natlthlehtrans i drop (n) ).
        + assumption.
        + assumption. }
      exact (pr1 i,, e').
    -
      assert (e: (pr1 i) < S n). {exact (pr2 i). }
      assert ((pr1 i) - 1 < n). {
      apply natltminus1 in e.
      change (S n) with (1 + n) in e.
      replace (1 + n - 1) with (n + 1 - 1) in e.
      2: { rewrite plusminusnmm. rewrite natpluscomm.
           rewrite plusminusnmm. reflexivity.
      }
      rewrite plusminusnmm in e.
      assert ( e': (pr1 i < n + 1)).
      { intros.
        apply natlehtolthsn  in e.
        rewrite natpluscomm.
        change (1 + n) with (S n).
        assumption.
      }

      induction (natlthorgeh (pr1 i) n) as [i_le_n | i_geq_n].
      + apply natlthtolthm1 in i_le_n. assumption.
      +
      - apply natlthp1toleh  in e'.
        apply (isantisymmnatgeh) in e'.
        2 : {assumption. }
        symmetry in e'.
        rewrite e'.
        rewrite <- e'.
        apply natminuslthn.
        { assumption. }
        reflexivity.
      }
      exact (i - 1,, X).
  Defined.


  (* TODO: standardize name according to conventions *)
  (* And clean up the shambles proof ...*)
  Lemma nlesn_to_nminus1_len { n m : nat} (e : m < S n) (p : n > 0) : m - 1 < n.
  Proof.
    intros.
      apply natltminus1 in e.
      change (S n) with (1 + n) in e.
      replace (1 + n - 1) with (n + 1 - 1) in e.
      2: { rewrite plusminusnmm. rewrite natpluscomm.
           rewrite plusminusnmm. reflexivity.
      }
      rewrite plusminusnmm in e.
      assert ( e': (m < n + 1)).
      { intros.
        apply natlehtolthsn  in e.
        rewrite natpluscomm.
        change (1 + n) with (S n).
        assumption.
      }

      induction (natlthorgeh (m) n) as [i_le_n | i_geq_n].
      + apply natlthtolthm1 in i_le_n. assumption.
      +
      - apply natlthp1toleh  in e'.
        apply (isantisymmnatgeh) in e'.
        2 : {assumption. }
        symmetry in e'.
        rewrite e'.
        rewrite <- e'.
        apply natminuslthn.
        { assumption. }
        reflexivity.
  Defined.

  Lemma dnisum_dropsum : ∏ (n : nat) (f : (⟦ S n ⟧)%stn → R) (j : (⟦ S n ⟧)%stn),
                         Σ ((drop_el_vector f j)) = Σ ((f ∘ (dni j) )).
  Proof.
    intros.
    apply maponpaths.
    unfold funcomp, dni, di.  unfold drop_el_vector.
    apply funextfun. intros k.
    destruct (natlthorgeh k j).
    - do 2 rewrite coprod_rect_compute_1.
      unfold natgthtogths.
      apply maponpaths.
      reflexivity.
    - do 2 rewrite coprod_rect_compute_2.
      apply idpath.
  Defined.

  Lemma rigsum_drop_el : ∏ (n : nat) (f : (⟦ S n ⟧)%stn → R) (j : (⟦ S n ⟧)%stn),
    Σ f = (Σ ((drop_el_vector f j)) + f j)%ring.
  Proof.
    intros.
    rewrite (rigsum_dni f j).
    rewrite dnisum_dropsum.
    apply idpath.
  Defined.

  (*  ~ point of interest ~ *)
  Lemma two_pulse_function_sums_to_point_rig { n : nat }  (f : ⟦ S n ⟧%stn -> R) (p : n > 0) :
  ∏ (i : ⟦ S n ⟧%stn ), (f i != 0%rig) -> ∏ (j : ⟦ S n ⟧%stn), (f j  != 0%rig) -> (∏ (k: ⟦ S n ⟧%stn), ((k ≠ i) -> (k ≠ j) -> (f k = 0%rig))) ->  (Σ f = op1 (f i) (f j)).
  Proof.
    intros i f_i_neq_0 j f_j_neq_0 X.
    rewrite (rigsum_dni f i).
    rewrite <- (rigcomm1).
    apply maponpaths.
    set (p' := @nlesn_to_nminus1_len n (pr1 j) (pr2 j) p).
    destruct (natlthorgeh (pr1 j) (pr1 i)) as [j_leq_i | j_geq_i].
    - (* Next two nested proofs just to bound j. TODO improve ? *)
      assert (e : (pr1 j) ≤ (pr1 i) - 1). {
        apply natltminus1. assumption.
      }
      assert (e' : (pr1 j) < n). {
        set (p'' := pr2 i).
        (apply nlesn_to_nminus1_len in p'').
        2 : { exact p. }

        apply (natlthlehtrans (pr1 j) (pr1 i) n). {assumption. }
        set (p''' := nlesn_to_nminus1_len (pr2 i) p ).
        apply natltminus1 in p'''.
        apply (natlthsntoleh (pr1 i) n (pr2 i)).
      }
      set (j' := @make_stn n (pr1 j) e').
      rewrite  (pulse_function_sums_to_point_rig' j' ).
      + unfold drop_el_vector.
        unfold funcomp, dni, di.
        destruct (natlthorgeh j' i).
        * rewrite coprod_rect_compute_1.
          assert (natgthtogths n j' (pr2 j') = (natlthtolths j' n (pr2 j'))).
          { apply idpath. }
          apply maponpaths. apply subtypePath_prop.
          reflexivity.
        * rewrite coprod_rect_compute_2.
          apply natlthtonegnatgeh in j_leq_i.
          contradicts h j_leq_i.
      + unfold funcomp. unfold is_pulse_function.
        intros. unfold dni, di.
        destruct (natlthorgeh j' i) as [j'_le_i | j'_geq_i].
        (** rewrite coprod_rect_compute_1.*)
  Abort.


  Lemma id_math_row_is_pf { n : nat }  : ∏ (r : ⟦ n ⟧%stn), (is_pulse_function r (identity_matrix r) ).
  Proof.
    unfold is_pulse_function.
    intros r i rr_neq_0 r_neq_j.
    unfold identity_matrix.
    destruct (stn_eq_or_neq r i) as [T | F].
    - rewrite T in r_neq_j.
      apply isirrefl_natneq in r_neq_j. apply fromempty. assumption.
    - rewrite coprod_rect_compute_2.
      reflexivity.
  Defined.

    (* Is n ≥ 1 necessary ? *)
  Definition vector_n_to_vector_snm1 { n : nat } (v : Vector R n) (p : n ≥ 1) : (Vector R (S ( n - 1 ))).
  Proof.
    unfold Vector in v.
    unfold Vector.
    change (S (n - 1)) with (1 + (n - 1)). rewrite natpluscomm.
    rewrite minusplusnmm. 2 : {exact p. }
    exact v.
  Defined.


  (* This should be trivially true but how do we correctly formulate / prove it ? *)
  (* TODO: inline? *)
  Lemma isirrefl_rigunel1_to_empty {X} (x:X) : (x != x) -> ∅.
  Proof.
    intros H; apply H, idpath.
  Defined.

  Lemma matlunel2 : ∏ (n : nat) (mat : Matrix R n n),
    (identity_matrix ** mat) = mat.
  Proof.
    intros.
    apply funextfun. intros i.
    apply funextfun. intros j.

    - unfold "**". unfold row. unfold "^".

      assert (X: is_pulse_function i (λ i0 : (⟦ n ⟧)%stn, op2 (identity_matrix i i0) (col mat j i0))).
      { unfold is_pulse_function.

        intros k id_ii_m_neq_0 i_neq_k.
        unfold identity_matrix.
        destruct (stn_eq_or_neq i k) as [i_eq_k | i_neq_k'].
        - rewrite i_eq_k in i_neq_k.
          apply isirrefl_natneq in i_neq_k.
          apply fromempty. assumption.
        - rewrite coprod_rect_compute_2.
          apply rigmult0x.
      }
      set (f :=  (λ i0 : (⟦ n ⟧)%stn, op2 (identity_matrix i i0) (col mat j i0)) ).
      unfold f.
      rewrite (pulse_function_sums_to_point_rig' i X).
      unfold identity_matrix.
      destruct (stn_eq_or_neq i i).
      + rewrite coprod_rect_compute_1.
        apply riglunax2.
      + (*apply isirrefl_natneq in h. *)
        rewrite coprod_rect_compute_2.
        apply isirrefl_natneq in h.
        apply fromempty. assumption.

  Defined.

  Lemma matrunel2 : ∏ (n : nat) (mat : Matrix R n n),
    (mat ** identity_matrix) = mat.
  Admitted.

  Definition matrix_is_invertible {n : nat} (A : Matrix R n n) :=
    ∑ (B : Matrix R n n), ((A ** B) = identity_matrix) × ((B ** A) = identity_matrix).

  (* TODO: name as e.g. [matrix_right_inverse] since gives choice of inverse? and similar vice versa below. *)
  Definition matrix_is_invertible_left {n : nat} (A : Matrix R n n) :=
    ∑ (B : Matrix R n n), ((A ** B) = identity_matrix).

  Definition matrix_is_invertible_right {n : nat} (A : Matrix R n n) :=
    ∑ (B : Matrix R n n), ((B ** A) = identity_matrix).



  (* The product of two invertible matrices being invertible *)
  Lemma inv_matrix_prod_is_inv {n : nat} (A : Matrix R n n)
    (A' : Matrix R n n) (pa : matrix_is_invertible A) (pb : matrix_is_invertible A') :
    (matrix_is_invertible (A ** A')).
  Proof.
    intros.
    use tpair. { exact ((pr1 pb) ** (pr1 pa)). }
    use tpair.
    - rewrite matrix_mult_assoc.
      rewrite <- (matrix_mult_assoc A' _ _).
      replace (A' ** pr1 pb) with (@identity_matrix R n).
      + rewrite matlunel2.
        replace (A ** pr1 pa) with (@identity_matrix R n).
        2 : { symmetry.
              set (p := (pr1 (pr2 pa))). rewrite p.
              reflexivity.
        }
        reflexivity.
      + rewrite <- matrunel2.
        replace (A' ** pr1 pb) with (@identity_matrix R n).
        { rewrite matlunel2.
          reflexivity. }
        set (p := pr1 (pr2 pb)). rewrite p.
        reflexivity.
    - simpl.
      rewrite <- matrix_mult_assoc.
      rewrite  (matrix_mult_assoc (pr1 pb) _ _).
      replace (pr1 pa ** A) with (@identity_matrix R n).
      2 : { symmetry. rewrite (pr2 (pr2 pa)). reflexivity. }
      replace (pr1 pb ** identity_matrix) with (pr1 pb).
      2 : { rewrite matrunel2. reflexivity. }
      rewrite (pr2 (pr2 pb)).
      reflexivity.
  Defined.

  Lemma identity_is_inv { n : nat } : matrix_is_invertible (@identity_matrix _ n).
  Proof.
    unfold matrix_is_invertible.
    use tpair. { exact identity_matrix. }
    use tpair.
    - apply matlunel2.
    - apply matlunel2.
  Defined.
  (*
  Definition eq_set_invar_by_invmatrix_mm { n : nat } ( A : Matrix R n n )
    (C : Matrix R n n)
    (x : Matrix R n 1) (b : Matrix R n 1) : (A ** x) = b -> ((C ** A) ** x) = (C ** b).
  Proof.

  Abort.
  *)

End Matrices.


Section MatricesF.

  Context { R : rig }.

  (* Not really a clamp but setting every element at low indices to zero.  *)
  Local Definition clamp_f {n : nat} (f : ⟦ n ⟧%stn -> hq) (cutoff : ⟦ n ⟧%stn) : (⟦ n ⟧%stn -> hq).
    intros i.
    induction (natlthorgeh i cutoff) as [LT | GTH].
    - exact 0%hq.
    - exact (f i).
  Defined.


  Definition zero_vector_hq (n : nat) : ⟦ n ⟧%stn -> hq :=
    λ i : ⟦ n ⟧%stn, 0%hq.

  Definition zero_vector_nat (n : nat) : ⟦ n ⟧%stn -> nat :=
    λ i : ⟦ n ⟧%stn, 0%nat.

  (* This is not really a zero vector, it might be [0 1 2 3] ... Serves the purpose of a placeholder however. *)
  Definition zero_vector_stn (n : nat) : ⟦ n ⟧%stn -> ⟦ n ⟧%stn.
  Proof.
    intros i.
    assumption.
  Defined.


  (* The following definitions set up helper functions on finite sets which are then used in formalizing Gaussian Elimination*)

  Definition max_hq (a b : hq) : hq.
    induction (hqgthorleh a b).
    - exact a.
    - exact b.
  Defined.

  Definition max_hq_one_arg (a : hq) : hq -> hq := max_hq a.

  (* This should exist somewhere *)
  Definition tl' { n : nat }  (vec: Vector F n) : Vector F (n - 1).
    induction (natgtb n 0).
     assert  ( b: (n - 1 <= n)). { apply (natlehtolehm1 n n). apply isreflnatleh. }
    + exact (λ i : (⟦ n - 1 ⟧%stn), vec (stnmtostnn (n - 1) n b i)).
    + exact (λ i : (⟦ n - 1 ⟧%stn), 0%hq). (* ? *)
  Defined.




  (* We can generalize this to just ordered sets *)
  Definition max_hq_index { n : nat } (ei ei' : hq × ⟦ n ⟧%stn) : hq × ⟦ n ⟧%stn.
    induction (hqgthorleh (pr1 ei) (pr1 ei')).
    - exact ei.
    - exact ei'.
  Defined.

  Definition max_hq_index_one_arg { n : nat } (ei : hq × ⟦ n ⟧%stn) : (hq × ⟦ n ⟧%stn) -> (hq × ⟦ n ⟧%stn)
    := max_hq_index ei.

  (* Some of the following lemmata are very specific and could be better without the general definition form, or we
     could write these as local definitions *)
  Definition max_argmax_stnhq {n : nat} (vec : Vector F n) (pn : n > 0) : hq × (⟦ n ⟧)%stn.
  Proof.
    set (max_and_idx := (foldleft (0%hq,,(0%nat,,pn)) max_hq_index (λ i : (⟦ n ⟧%stn), (vec i) ,, i))).
    exact (max_and_idx).
  Defined.



  (*TODO: This is mostly a repetition of the rig equivalent. Can we generalize ? *)
  Lemma zero_function_sums_to_zero_hq:
    ∏ (n : nat) (f : (⟦ n ⟧)%stn -> F),
    (λ i : (⟦ n ⟧)%stn, f i) = const_vec 0%hq ->
    (Σ (λ i : (⟦ n ⟧)%stn, f i) ) = 0%hq.
  Proof.
    intros n f X.
    rewrite X.
    unfold const_vec.
    induction n.
    - reflexivity.
    - intros. rewrite iterop_fun_step.
      + rewrite hqplusr0.
        unfold "∘".
        rewrite -> IHn with ((λ _ : (⟦ n ⟧)%stn, 0%hq)).
        reflexivity.
        reflexivity.
      + unfold islunit. intros.
        rewrite hqplusl0.
        apply idpath.
  Defined.


End MatricesF.



Section Gauss.
  (* Gaussian elimination over the field of rationals *)

  (* TODO better (or any) comments for all these functions including assumptions*)

  (* TODO Carot operator is used similarly throughout the document, move out *)
  Local Notation Σ := (iterop_fun 0%hq op1).
  Local Notation "R1 ^ R2" := ((pointwise _ op2) R1 R2).

  Context { R : rig }.
  (* Gaussian elimination over the field of rationals *)


  Definition gauss_add_row { m n : nat } ( mat : Matrix F m n )
    ( s : F ) ( r1 r2 : ⟦ m ⟧%stn ) : ( Matrix F m n ).
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r1).
    - exact ( op1 ( mat r1 j )  ( op2 s ( mat r2 j ))).
    - exact ( mat r1 j ).
  Defined.

  (* Is stating this as a Lemma more in the style of other UniMath work?*)
  Local Definition identity_matrix { n : nat } : ( Matrix F n n ).
  Proof.
    apply ( @identity_matrix hq ).
  Defined.


  (* Need again to restate several definitions to use the identity on rationals*)
  (*Local Notation Σ := (iterop_fun 0%hq op1).*)(*
  Local Notation "R1 ^ R2" := ((pointwise _ op2) R1 R2).*)

  (* TODO: replace with upstream version? *)
  Local Definition matrix_mult {m n : nat} (mat1 : Matrix F m n)
    {p : nat} (mat2 : Matrix F n p) : (Matrix F m p) :=
    λ i j, Σ ((row mat1 i) ^ (col mat2 j)).

  Local Notation "A ** B" := (matrix_mult A B) (at level 80).

  (* Which by left multiplication corresponds to adding r1 to r2 *)
  (* TODO verify this is right *)
  Definition make_add_row_matrix { n : nat } (r1 r2 : ⟦ n ⟧%stn) (s : F)  : Matrix F n n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r1).
    - induction (stn_eq_or_neq j r2).
      + exact s.
      + exact (identity_matrix i j).
    - exact (identity_matrix i j).
  Defined.

  Definition add_row_by_matmul { n m : nat } ( r1 r2 : ⟦ m ⟧%stn ) (mat : Matrix F m n) (s : F) : Matrix F m n :=
    (make_add_row_matrix r1 r2 s ) **  mat.

  Definition gauss_scalar_mult_row { m n : nat} (mat : Matrix F m n)
    (s : F) (r : ⟦ m ⟧%stn): Matrix F m n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r).
    - exact (s * (mat i j))%rig.
    - exact (mat i j).
  Defined.

  (* These could really be m x n ...*)
  Definition make_scalar_mult_row_matrix { n : nat}
    (s : F) (r : ⟦ n ⟧%stn): Matrix F n n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i j).
      - induction (stn_eq_or_neq i r).
        + exact s.
        + exact 1%hq.
      - exact 0%hq.
  Defined.

  Definition gauss_switch_row {m n : nat} (mat : Matrix F m n)
             (r1 r2 : ⟦ m ⟧%stn) : Matrix F m n.
  Proof.
    intros i j.
    induction (stn_eq_or_neq i r1).
    - exact (mat r2 j).
    - induction (stn_eq_or_neq i r2).
      + exact (mat r1 j).
      + exact (mat i j).
  Defined.

  Definition make_gauss_switch_row_matrix (n : nat)  (r1 r2 : ⟦ n ⟧ %stn) : Matrix F n n.
  Proof.
    intros i.
    induction (stn_eq_or_neq i r1).
    - exact (identity_matrix r2).
    - induction (stn_eq_or_neq i r2).
      + exact (identity_matrix r1).
      + exact (identity_matrix i).
  Defined.


  Definition test_row_switch_statement {m n : nat} (mat : Matrix F m n)
    (r1 r2 : ⟦ m ⟧%stn) : (gauss_switch_row (gauss_switch_row mat r1 r2) r1 r2) = mat.
  Proof.
    use funextfun; intros i.
    use funextfun; intros j.
    unfold gauss_switch_row.
    destruct (stn_eq_or_neq i r1) as [ e_ir1 | ne_ir1 ]; simpl.
    - destruct (stn_eq_or_neq r2 r1) as [ e_r1r2 | ne_r1r2 ]; simpl.
      + destruct e_ir1, e_r1r2. apply idpath.
      + destruct (stn_eq_or_neq r2 r2) as [ ? | absurd ]; simpl.
        * destruct e_ir1. apply idpath.
        * set (H := isirrefl_natneq _ absurd). destruct H.
    - destruct (stn_eq_or_neq i r2) as [ e_ir2 | ne_ir2 ]; simpl.
      + destruct e_ir2; simpl.
        destruct (stn_eq_or_neq r1 r1) as [ ? | absurd ]; simpl.
        * reflexivity.
        * destruct (stn_eq_or_neq r1 i) as [ e_ir1 | ne_ir1' ]; simpl.
        -- rewrite e_ir1. apply idpath.
        -- set (H := isirrefl_natneq _ absurd). destruct H.
      + reflexivity.
  Defined.


  (* TODO: look for other places this can simplify proofs! and upstream? *)
  Lemma stn_neq_or_neq_refl {n} {i : ⟦ n ⟧%stn} : stn_eq_or_neq i i = inl (idpath i).
  Proof.
  Admitted.

  (* The following three lemmata test the equivalence of multiplication by elementary matrices
     to swaps of indices. *)
  Lemma matrix_scalar_mult_is_elementary_row_op {n : nat} (mat : Matrix F n n) (s : F) (r : ⟦ n ⟧%stn) :
    ((make_scalar_mult_row_matrix s r) ** mat) = gauss_scalar_mult_row mat s r.
  Proof.
    use funextfun. intros i.
    use funextfun. intros j.
    unfold make_scalar_mult_row_matrix. unfold gauss_scalar_mult_row.
    unfold "**". unfold "^". unfold col. unfold transpose. unfold row. unfold flip.
    unfold coprod_rect. unfold identity_matrix.
    destruct (stn_eq_or_neq i r) as [? | ?] ; simpl.
    - rewrite p.
      (* apply pulse_function_sums_to_point.*)
  Abort.



  Definition unit_vector { n : nat } (i : ⟦ n ⟧%stn) : Vector R n.
  Proof.
    intros j.
    induction (stn_eq_or_neq i j) as [T | F].
    - exact (1%rig).
    - exact (0%rig).
  Defined.

  Lemma weq_mat_vector {X : UU} { n : nat } : (Matrix X 1 n ) ≃ Vector X n.
    (*unfold Matrix. unfold Vector.*)
  Abort.


  (*
  Lemma mult_by_ei { n : nat } (v : Vector R n) (i : ⟦ n ⟧%stn) {e : unit_vector i}
    : e_i
   *)
  (*
  Lemma coprod_rect_compute_id
   *)

   (* TODO: naming ? upstream?  Certainly rename p, p0. *)
   Lemma stn_eq_or_neq_left : ∏ {n : nat} {i j: (⟦ n ⟧)%stn} (p : (i = j)),
                              stn_eq_or_neq i j = inl p.
   Proof.
     intros ? ? ? p. rewrite p. apply stn_neq_or_neq_refl.
   Defined.

   Lemma stn_eq_or_neq_right : ∏ {n : nat} {i j : (⟦ n ⟧)%stn} (p : (i ≠ j)),
     stn_eq_or_neq i j = inr p.
   Proof.
     intros ? ? ? p. unfold stn_eq_or_neq.
     destruct (nat_eq_or_neq i j).
     -  apply fromempty. rewrite p0 in p.
        apply isirrefl_natneq in p.
        assumption.
     -  apply isapropcoprod.
        + apply stn_ne_iff_neq in p. apply isdecpropfromneg.  assumption.
        (*apply stn_ne_iff_neq in p.*)
        + apply negProp_to_isaprop.
        + intros i_eq_j.
          rewrite i_eq_j in p.
          apply isirrefl_natneq in p.
          apply fromempty. assumption.
   Defined.

  (* TODO : F should also be a general field, not short-hand for rationals specifically.
            This does not mandate any real change in any proofs ?*)
  Lemma scalar_mult_matrix_is_inv { n : nat } ( i : ⟦ n ⟧%stn ) ( s : F ) ( ne : hqneq s 0%hq ) :
    @matrix_is_invertible F n (make_scalar_mult_row_matrix s i ).
  Proof.
    (*unfold matrix_is_invertible.
    unfold make_scalar_mult_row_matrix.*)
    use tpair.
    { exact (make_scalar_mult_row_matrix (hqmultinv s ) i). }
    use tpair.
    - apply funextfun. intros k.
      apply funextfun. intros l.
      destruct (stn_eq_or_neq k l) as [T' | F'].
      + (*rewrite T.*)
        unfold gauss_scalar_mult_row.
        unfold identity_matrix.
        unfold make_scalar_mult_row_matrix.
        unfold Matrix.matrix_mult.
        unfold row. unfold col. unfold transpose. unfold "^". unfold flip.
        unfold Matrix.identity_matrix.
        destruct (stn_eq_or_neq l i).
        * destruct (stn_eq_or_neq l l).
          2 : { apply isirrefl_natneq in h.
                apply fromempty. assumption. }
          -- rewrite T'. rewrite p.
             destruct (stn_eq_or_neq i i).
             ++ do 2 rewrite coprod_rect_compute_1.
                rewrite (@pulse_function_sums_to_point_rig' F n l).
                rewrite p.
                destruct (stn_eq_or_neq i i).
                ** do 3 rewrite coprod_rect_compute_1.
                   apply (hqisrinvmultinv). assumption.
                ** do 2 rewrite coprod_rect_compute_2.
                   apply isirrefl_natneq in h.
                   apply fromempty. assumption.
                ** unfold is_pulse_function.
                   intros q X l_neq_q.
                   rewrite <- p.
                   destruct (stn_eq_or_neq l q) as [l_eq_q' | l_neq_q'].
                   --- rewrite l_eq_q' in l_neq_q.
                       apply isirrefl_natneq in l_neq_q.
                       apply fromempty. assumption.
                   --- rewrite coprod_rect_compute_2.
                       apply rigmult0x.
             ++ remember h as h'. clear Heqh'.
                apply isirrefl_natneq in h.
                apply fromempty. assumption.
        * rewrite <- T' in h.
          destruct (stn_eq_or_neq k i).
          -- rewrite coprod_rect_compute_1.
             destruct (stn_eq_or_neq k l).
             ++ rewrite coprod_rect_compute_1.
                rewrite(@pulse_function_sums_to_point_rig' F n k).
                ** destruct (stn_eq_or_neq k l).
                   --- rewrite coprod_rect_compute_1.
                       destruct (stn_eq_or_neq k k).
                       +++ rewrite coprod_rect_compute_1.
                           destruct (stn_eq_or_neq k i).
                           *** rewrite coprod_rect_compute_1.
                               apply hqisrinvmultinv.
                               assumption.
                           *** rewrite coprod_rect_compute_2.
                               rewrite p in h0.
                               apply isirrefl_natneq in h0.
                               apply fromempty. assumption.
                       +++ remember h0 as h0'. clear Heqh0'.
                           apply isirrefl_natneq in h0.
                           apply fromempty. assumption.
                   --- rewrite  coprod_rect_compute_2.
                       rewrite <- p0 in h0.
                       apply isirrefl_natneq in h0.
                       apply fromempty. assumption.
                ** rewrite p in h.
                   apply isirrefl_natneq in h.
                   apply fromempty. assumption.
             ++ remember h0 as h0'. clear Heqh0'.
                rewrite T' in h0.
                apply isirrefl_natneq in h0.
                apply fromempty. assumption.
          --
            rewrite coprod_rect_compute_2.
            destruct (stn_eq_or_neq k l) as [k_eq_l | k_neq_l] .
            2 : { remember k_neq_l as k_neq_l'.
                  clear Heqk_neq_l'.
                  rewrite T' in k_neq_l.
                  apply isirrefl_natneq in k_neq_l.
                  apply fromempty. assumption. }
            rewrite coprod_rect_compute_1.
            rewrite (@pulse_function_sums_to_point_rig' F n k).
            ++ destruct (stn_eq_or_neq k k) as [k_eq_k | k_neq_k].
               2 : { rewrite coprod_rect_compute_2.
                     apply isirrefl_natneq in k_neq_k.
                     apply fromempty. assumption.
               }
               destruct (stn_eq_or_neq k l) as [ ? | cntr].
               2 : { rewrite coprod_rect_compute_2.
                     rewrite k_eq_l in cntr.
                     apply isirrefl_natneq in cntr.
                     apply fromempty. assumption.
               }
               do 2rewrite coprod_rect_compute_1.
               destruct (stn_eq_or_neq k i) as [cntr | k_neq_i].
               { rewrite cntr in h. apply isirrefl_natneq in h.
                 apply fromempty. assumption.
               }
               rewrite coprod_rect_compute_2.
               apply riglunax2.
            ++ unfold is_pulse_function.
               intros q f l_neq_q.
               rewrite <- k_eq_l.
               destruct (stn_eq_or_neq l q) as [l_eq_q' | l_neq_q'].
               --- rewrite k_eq_l in l_neq_q.
                   rewrite l_eq_q' in l_neq_q.
                   apply isirrefl_natneq in l_neq_q.
                   apply fromempty. assumption.
               --- destruct (stn_eq_or_neq q k) as [ ? | ? ].
                 +++
                   rewrite coprod_rect_compute_1.
                   rewrite p in l_neq_q.
                   apply isirrefl_natneq in l_neq_q.
                   apply fromempty. assumption.
                 +++ rewrite coprod_rect_compute_2.
                     destruct (stn_eq_or_neq k q).
                     *** rewrite coprod_rect_compute_1.
                         apply rigmultx0.
                     *** rewrite coprod_rect_compute_2.
                         apply rigmultx0.
      + unfold make_scalar_mult_row_matrix.
        unfold Matrix.identity_matrix.
        destruct (stn_eq_or_neq k l) as [cntr | dup ].
        { rewrite cntr in F'. (* really should have a one_liner *)
          apply isirrefl_natneq in F'.
          apply fromempty. assumption.
        }
        rewrite coprod_rect_compute_2.
        unfold Matrix.matrix_mult.
        unfold col. unfold row. unfold "^".
        unfold transpose. unfold flip.
        destruct (stn_eq_or_neq k i) as [k_eq_i | k_neq_i] .
        * rewrite coprod_rect_compute_1.
          rewrite (@pulse_function_sums_to_point_rig' F n i).
          -- destruct (stn_eq_or_neq k i) as [ ? | cntr ].
             rewrite coprod_rect_compute_1.
             destruct (stn_eq_or_neq i i) as [? | cntr ].
             ++ destruct (stn_eq_or_neq i l) as [i_eq_l | i_neq_l].
                **
                  do 2 rewrite coprod_rect_compute_1.
                  rewrite <- k_eq_i in i_eq_l.
                  rewrite i_eq_l in F'.
                  apply isirrefl_natneq in F'.
                  apply fromempty. assumption.
                ** rewrite coprod_rect_compute_2.
                   apply rigmultx0.
             ++ rewrite coprod_rect_compute_2.
                apply isirrefl_natneq in cntr.
                apply fromempty. assumption.
             ++ rewrite coprod_rect_compute_2.
                rewrite k_eq_i in cntr.
                apply isirrefl_natneq in cntr.
                apply fromempty. assumption.
          -- unfold is_pulse_function.
             intros q f i_neq_q.
             rewrite k_eq_i.
             destruct (stn_eq_or_neq q i ) as [q_eq_i | q_neq_i] .
             ++ rewrite q_eq_i in i_neq_q.
                apply isirrefl_natneq in i_neq_q.
                apply fromempty. assumption.
             ++ destruct (stn_eq_or_neq i q) as [i_eq_q | i_neq_q'].
                { rewrite i_eq_q in i_neq_q.
                  apply isirrefl_natneq in i_neq_q.
                  apply fromempty. assumption.
                }
                do 2 rewrite coprod_rect_compute_2.
                destruct (stn_eq_or_neq q l) as [q_eq_l | q_neq_l].
                ** apply rigmult0x.
                ** apply rigmult0x.
      * rewrite coprod_rect_compute_2.
        rewrite (@pulse_function_sums_to_point_rig' F n k).
        -- destruct (stn_eq_or_neq k k) as [? | cntr].
           2 : { rewrite coprod_rect_compute_2.
                 apply isirrefl_natneq in cntr.
                 apply fromempty. assumption.
           }
           destruct (stn_eq_or_neq k l) as [k_eq_l | k_neq_l] .
           { rewrite k_eq_l in F'.  apply isirrefl_natneq in F'.
             apply fromempty. assumption.
           }
           rewrite coprod_rect_compute_2. rewrite coprod_rect_compute_1.
           apply rigmultx0.

        -- unfold is_pulse_function.
           intros j f k_neq_j.
           destruct (stn_eq_or_neq k j) as [k_eq_j | k_neq_j'].
           { rewrite k_eq_j in k_neq_j. apply isirrefl_natneq in k_neq_j.
             apply fromempty. assumption.
           }
           destruct (stn_eq_or_neq j l) as [j_eq_l | j_neq_l].
           ++ rewrite coprod_rect_compute_1.
             rewrite coprod_rect_compute_2.
             apply rigmult0x.
           ++ apply rigmult0x.
    - simpl.
      (* Here in the second half, we try to be slightly more efficient *)
      unfold make_scalar_mult_row_matrix.
      unfold Matrix.identity_matrix.
      unfold matrix_mult.
      unfold Matrix.matrix_mult.
      unfold row. unfold col. unfold transpose. unfold flip.
      unfold "^".
      apply funextfun. intros k.
      apply funextfun. intros l.
      destruct (stn_eq_or_neq k i) as [ k_eq_i | k_neq_i ].
      +
        destruct (stn_eq_or_neq k l) as [k_eq_l | k_neq_l ].
        * rewrite coprod_rect_compute_1.
          rewrite <- k_eq_l.
          rewrite <- k_eq_i.
          rewrite (pulse_function_sums_to_point_rig' k).
          -- rewrite stn_neq_or_neq_refl.
            do 3 rewrite coprod_rect_compute_1.
            apply (hqislinvmultinv).
            assumption.
          -- unfold is_pulse_function.
             intros q f k_neq_q.
             rewrite stn_neq_or_neq_refl in f.
             do 3 rewrite coprod_rect_compute_1 in f.
             rewrite (stn_eq_or_neq_right k_neq_q).
             rewrite coprod_rect_compute_2.
             apply rigmult0x.
        * rewrite coprod_rect_compute_2.
          rewrite (pulse_function_sums_to_point_rig' k). (* Didn't we just do this ? *)
          -- rewrite (stn_eq_or_neq_right k_neq_l).
             rewrite coprod_rect_compute_2.
             rewrite (stn_neq_or_neq_refl).
             rewrite coprod_rect_compute_1.
             rewrite rigmultx0. apply idpath.
          -- unfold is_pulse_function.
             intros q f k_neq_q.
             rewrite stn_neq_or_neq_refl in f.
             do 1 rewrite coprod_rect_compute_1 in f.
             rewrite (stn_eq_or_neq_left k_eq_i) in f.
             rewrite coprod_rect_compute_1 in f.
             rewrite (stn_eq_or_neq_right k_neq_l) in f.
             rewrite coprod_rect_compute_2 in f.
             rewrite (rigmultx0) in f. (* Why do we arrive at this strange place ? *)
             assert (irrefl : ∏ X , ∏ (x : X),  (x != x) -> ∅).
             { intros ? ? H. apply H, idpath. }
             apply irrefl in f. apply fromempty. assumption.
      + rewrite (pulse_function_sums_to_point_rig' k).
        * rewrite (stn_neq_or_neq_refl).
          rewrite (stn_eq_or_neq_right k_neq_i).
          rewrite coprod_rect_compute_1.
          do 2 rewrite coprod_rect_compute_2.
          destruct (stn_eq_or_neq k l).
          -- do 2 rewrite coprod_rect_compute_1.
             rewrite rigrunax2. apply idpath.
          -- do 2 rewrite coprod_rect_compute_2.
             rewrite rigmultx0. apply idpath.
        * unfold is_pulse_function.
          intros q f k_neq_q .
          clear f.
          rewrite (stn_eq_or_neq_right k_neq_q). rewrite coprod_rect_compute_2.
          destruct (stn_eq_or_neq q l) as [q_eq_l | q_neq_l].
          -- apply rigmult0x.
          -- apply rigmult0x.
  Defined.

  (*
  Lemma test { n : nat } (n : ⟦ n ⟧%stn ) (f : ⟦ n ⟧%stn -> R) is_pulse_function (dni
  *)

  (*
  Lemma sum_over_coprod_rect : ∏ (A B : UU) (P : A ⨿ B → UU) (f : ∏ a : A, P (inl a))
(g : ∏ b : B, P (inr b)) (a : A), (iterop_fun 0%rig op1) (coprod_rect P f g (inl a)) = (iterop_fun 0%rig op1) f a.
   *)

  (* ~ point of interest ~ *)
  Lemma add_row_matrix_is_inv { n : nat } ( r1 r2 : ⟦ n ⟧%stn ) ( s : F ) (p : (s != 0)%hq) :
    @matrix_is_invertible F n (make_add_row_matrix r1 r2 s ).
  Proof.
    unfold matrix_is_invertible.
    unfold make_add_row_matrix.
    use tpair.
    { exact (make_add_row_matrix r1 r2 (- s)%hq). }
    use tpair.
    - unfold make_add_row_matrix.
      unfold identity_matrix.
      unfold gauss_add_row.
      unfold Matrix.matrix_mult.
      unfold "^". unfold row. unfold col. unfold transpose.
      unfold flip.
      unfold identity_matrix.
      unfold Matrix.identity_matrix.
      apply funextfun. intros i.
      apply funextfun. intros j.
      destruct (stn_eq_or_neq i j) as [i_eq_j | i_neq_j].
      + rewrite <- i_eq_j.
        rewrite coprod_rect_compute_1.
  Abort.

  Lemma switch_row_matrix_is_inv { n : nat } ( i j : ⟦ n ⟧%stn ) ( s : F ) ( ne : hqneq s 0%hq ) :
    @matrix_is_invertible F n (make_add_row_matrix i j s).
  Proof.
    intros.
  Admitted.

  Lemma add_row_matrix_is_inv { n : nat } ( i j : ⟦ n ⟧%stn ) :
    @matrix_is_invertible F n ( make_gauss_switch_row_matrix n i j).
  Proof.
    intros.
  Admitted.



  (* TODO: make R paramater/local section variable so that this can be stated *)
  (*
  Lemma matrix_scalar_multt_is_invertible { n : nat } (Mat : Matrix F n n) (s : F) (r : ⟦ n ⟧%stn) : matrix_is_invertible (make_scalar_mult_row_matrix s r).
  *)

  (* Order of arguments should be standardized... *)
  Lemma matrix_row_mult_is_elementary_row_op {n : nat} (r1 r2 : ⟦ n ⟧%stn) (mat : Matrix F n n) (s : F) :
    ((make_add_row_matrix r1 r2 s) ** mat) = gauss_add_row mat s r1 r2.
  Proof.
    intros.
  Abort.

  Lemma matrix_switch_row_is_elementary_row_op {n : nat} (mat : Matrix F n n) (r1 r2 : ⟦ n ⟧%stn) :
    gauss_switch_row mat r1 r2 = ((make_gauss_switch_row_matrix n r1 r2) ** mat).
  Proof.
    intros.
  Abort.

  (* The following three lemmata test the correctness of elementary row operations, i.e. they do not affect the solution set. *)
  Lemma eq_sol_invar_under_scalar_mult {n : nat} (A : Matrix F n n) (x : Matrix F n 1) (b : Matrix F 1 n) (s : F) (r : ⟦ n ⟧%stn) :
    (A ** x) = (transpose b) -> ((make_scalar_mult_row_matrix s r) ** A ** x)  = ((make_scalar_mult_row_matrix s r) ** (transpose b)).
  Proof.
    intros.
  Abort.

  (* s != 0 ... *)
  Lemma eq_sol_invar_under_row_add {n : nat} (A : Matrix F n n) (x : Matrix F n 1) (b : Matrix F 1 n) (s : F) (r1 r2 : ⟦ n ⟧%stn) :
    (A ** x) = (transpose b) -> ((make_add_row_matrix r1 r2 s) ** A ** x)  = ((make_add_row_matrix r1 r2 s)  ** (transpose b)).
  Proof.
    intros.
  Abort.

  (* s != 0 ... *)
  Lemma eq_sol_invar_under_row_switch {n : nat} (A : Matrix F n n) (x : Matrix F n 1) (b : Matrix F 1 n) (s : F) (r1 r2 : ⟦ n ⟧%stn) :
    (A ** x) = (transpose b) -> ((make_gauss_switch_row_matrix n r1 r2) ** A ** x)  = ((make_gauss_switch_row_matrix n r1 r2) ** (transpose b)).
  Proof.
    intros.
  Abort.


  (*
  Definition truncate_max_argmax_stnhq { n : nat } (f : ⟦ n ⟧%stn -> F) : ⟦ n ⟧%stn.
  Proof.
    induction (natlthorgeh
   *)

  (* TODO: do we need pn ? *)
  Definition max_hq_index_bounded { n : nat } (k : ⟦ n ⟧%stn) (f : ⟦ n ⟧%stn -> F) (ei ei' : hq × (⟦ n ⟧%stn)): hq × (⟦ n ⟧%stn).
  Proof.
    set (hq_index := max_hq_index ei ei').
    induction (natlthorgeh (pr2 ei') k).
    - induction (natlthorgeh (pr2 ei) k ).
      + exact (f k,, k).
      + exact ei. (* This case should not occur in our use *)
    - induction (natlthorgeh (pr2 ei) k).
      + exact ei'.
      + exact (max_hq_index ei ei').

  Defined.

  (* A lemma for max_hq_index is needed *)

  Lemma max_hq_index_bounded_geq_k { n : nat } (k : ⟦ n ⟧%stn) (f : ⟦ n ⟧%stn -> F)
    (ei ei' : hq × (⟦ n ⟧%stn)): pr2 (max_hq_index_bounded k f ei ei') >= k.
  Proof.
    unfold max_hq_index_bounded.
    destruct (natlthorgeh (pr2 ei') k).
    - rewrite coprod_rect_compute_1.
      destruct (natlthorgeh (pr2 ei) k).
      + rewrite coprod_rect_compute_1. apply isreflnatleh.
      + rewrite coprod_rect_compute_2. assumption.
    - rewrite coprod_rect_compute_2.
      unfold max_hq_index.
      destruct (natlthorgeh (pr2 ei) k).
      + rewrite coprod_rect_compute_1.
        assumption.
      + rewrite coprod_rect_compute_2.
        destruct (hqgthorleh (pr1 ei) (pr1 ei')).
        * rewrite coprod_rect_compute_1.
          assumption.
        * rewrite coprod_rect_compute_2.
          assumption.
  Defined.

  Definition max_argmax_stnhq_bounded { n : nat } (vec : Vector F n) (pn : n > 0 ) (k : ⟦ n ⟧%stn) :=
  foldleft (0%hq,, (0,, pn)) (max_hq_index_bounded k vec) (λ i : (⟦ n ⟧)%stn, vec i,, i).


  Definition max_argmax_stnhq_bounded_geq_k  { n : nat } (vec : Vector F n) (pn : n > 0 ) (k : ⟦ n ⟧%stn) : pr2 (max_argmax_stnhq_bounded  vec pn k) ≥ k.
  Proof.
  Abort. (* A bit hard reasoning over fold *)


  Definition select_pivot_row {m n : nat} (mat : Matrix F m n) ( k : ⟦ m ⟧%stn ) (pm : m > 0)
    (pn : n > 0) : ⟦ m ⟧%stn.
   Proof.
     exact (pr2 (max_argmax_stnhq_bounded  ( ( λ i : (⟦ m ⟧%stn),  pr1 (max_argmax_stnhq ( ( mat) i) pn)) )  pm k ) ).
   Defined.

   (* Having an index variable k  0 .. n - 1,
     we want to certify that the selected pivot is >= k. *)
  Lemma pivot_idx_geq_k {m n : nat} (mat : Matrix F m n) ( k : ⟦ m ⟧%stn ) (pm : m > 0 )
    (pn : n > 0) : pr1 ( select_pivot_row mat k pm pn ) >= k.
  Proof.
    unfold select_pivot_row.
    unfold max_argmax_stnhq.
    unfold truncate_pr1.
    unfold max_argmax_stnhq_bounded. simpl.
  Abort.

  (* Helper Lemma. Possibly unecessary. *)
  Local Definition opt_matrix_op {n : nat} (b : bool) (mat : Matrix F n n) (f : Matrix F n n -> Matrix F n n) : Matrix F n n.
  Proof.
    induction b.
    - exact (f mat).
    - exact mat.
  Defined.


  (* Stepwise Gaussian Elimination definitions *)

  (* We can probably assert at this point that m and n are > 0, as the base cases can be handled by caller *)
  (* Performed k times . *)
  (* We should be able to assert n, m > 0 wherever needed, by raa.*)
  Definition gauss_step  { n : nat } (k : (⟦ n ⟧%stn)) (mat : Matrix F n n) : Matrix F n n × ⟦ n ⟧%stn.
  Proof.
    assert (pn : (n > 0)). { exact (stn_implies_ngt0 k). }
    set (ik := (select_pivot_row mat k pn pn)).
    use tpair. 2: {exact ik. }
    intros i j.
    destruct (natlthorgeh i k) as [LT | GTH]. {exact ((mat i j)). }
    set (mat' := gauss_switch_row mat k ik).
    set (mat'' := gauss_scalar_mult_row mat' ((- 1%hq)%hq * (hqmultinv ( mat' k k )))%hq i%nat).
    (*
    destruct (natgtb j k).
    - exact (((mat'' i j) + (mat'' i k) * (mat k j))%hq).
    - exact (mat'' i j).*)
    destruct (natlthorgeh (S j) k).
    - exact (mat'' i j).
    - exact (((mat'' i j) + (mat'' i k) * (mat k j))%hq).
  Defined.

  (*
  Lemma sol_invariant_under_gauss_step { n : nat } (k : (⟦ n ⟧%stn)) (mat : Matrix F n n) :
  *)

  Lemma gauss_step_clears_diagonal { n : nat } ( k : (⟦ n ⟧%stn)) (mat : Matrix F n n) :
    ∏ (i j: ⟦ n ⟧%stn), (i > k) -> ((n - k) > j) -> mat i k = 0%hq ->
    ∏ (i' j' : ⟦ n ⟧%stn), (i' >= k) -> ((n - k) >= j') -> (pr1 (gauss_step k mat)) i' j' = 0%hq.
  Proof.
    intros i j i_geq_k nmk_geq_j mat_ik_eq_0 i' j' i'_geq_k nmk_geq_j'.
    unfold gauss_step. simpl.
    (*destruct (natgehchoice i' k) as [ ? | ?]. assumption.*)
    destruct (natlthorgeh i' k) as [i'_le_k | i'_geq_k' ].
    { apply  natlthtonegnatgeh in i'_le_k. contradiction. }
    destruct (natlthorgeh (S j') k) as [ sj_le_k | sj_geq_k ].
    - unfold gauss_scalar_mult_row.
      unfold select_pivot_row. (* Why does this give i = i u i != i ? *)
      destruct (stn_eq_or_neq i' i') as [ ? | cntr ].
      2 : { rewrite coprod_rect_compute_2.
            apply isirrefl_natneq in cntr.
            apply fromempty. assumption.
      }
      rewrite coprod_rect_compute_1.
      unfold max_argmax_stnhq.
      unfold foldleft.
      unfold gauss_switch_row.
  Abort. (* We want to show that the pivot selection selects a pivot >= k *)

  (* ( i,, i < n) to (i-1,, i-1 < n *)
  Definition decrement_stn { n : nat } ( i : (⟦ n ⟧)%stn ) : ⟦ n ⟧%stn. (* (⟦ n ⟧)%stn.*)
  Proof.
    induction (natgtb (pr1 i) 0).
    (*- assert ( p : ((pr1 i) - 1) < n). {  unfold stn in i. apply natlthtolthm1. apply i.  }*)
    - assert ( p :  ((pr1 i) - 1) < n). {  unfold stn in i. apply natlthtolthm1. apply i.  }
      exact ((pr1 i) - 1,, p).
    - exact i.
  Defined.


  Definition switch_vector_els { n : nat } (vec : Vector F n) (e1 e2 : ⟦ n ⟧%stn) : Vector F n.
  Proof.
    intros i.
    induction (stn_eq_or_neq i e1).
    - exact (vec e2).
    - induction (stn_eq_or_neq i e2).
      + exact (vec e1).
      + exact (vec i).
  Defined.

  (* k  : 1 -> n - 1 *)
  Definition vec_row_ops_step { n : nat } (k pivot_ik: ⟦ n ⟧%stn)  (mat : Matrix F n n) (vec : Vector F n) : Vector F n.
  Proof.
    intros i.
    induction (natlthorgeh i k). 2 : {exact (vec i). }
    set (vec' := switch_vector_els vec pivot_ik k).
    assert (pr2stn1 : 0 < 1). { reflexivity. }
    set ( j := make_stn 1 0 pr2stn1).
    exact (  ((((vec' i)) + ((vec' k)) * (mat i k))%hq)).  (* Would like to verify this construction works*)
  Defined.


  (* This one especially needs to be checked for correctness (use of indices) *)
  Definition back_sub_step { n : nat } ( iter : ⟦ n ⟧%stn ) (mat : Matrix F n n) (vec : Vector F n) : Vector F n.
  Proof.
    intros i.
    set ( m := pr1 i ).
    induction (natlehchoice ((S (pr1 iter)) ) (n)) as [LT | GTH].
    - exact ((((vec i) - Σ (clamp_f vec i)) * (hqmultinv (mat i i)))%hq).
    - exact ((vec i) * (hqmultinv (mat i i)))%hq.
    - unfold stn in i.
      apply (pr2 iter).
  Defined.




  (* Now, three fixpoint definitions for three subroutines.
     Partial pivoting on "A", defining b according to pivots on A,
     then back-substitution. *)
  Definition gauss_iterate
     ( pr1i : nat ) { n : nat }
     (start_idx : ⟦ n ⟧%stn ) (mat : Matrix F n n) (pivots : Vector (⟦ n ⟧%stn) n)
    : (Matrix F n n) × (Vector (⟦ n ⟧%stn) n).
  Proof.
    revert mat pivots.
    induction pr1i as [ | m gauss_iterate_IH ]; intros mat pivots.
    { (* pr1i = 0 *) exact (mat,,pivots). }
    set (current_idx := decrement_stn_by_m start_idx (n - (S m))).
    set (idx_nat := pr1 current_idx).
    set (proof   := pr2 current_idx).
    set (mat_vec_tup := ((gauss_step current_idx mat))).
    set (mat' := pr1 mat_vec_tup).
    set (piv  := (pr2 mat_vec_tup)).
    set (pivots' := set_stn_vector_el pivots current_idx piv).
    exact (gauss_iterate_IH mat' pivots').
  Defined.

  Definition gauss_clears_diagonal : True.
  Proof.
  Abort.



  Fixpoint vec_ops_iterate ( iter : nat ) { n : nat }  ( start_idx : ⟦ n ⟧%stn) (b : Vector F n) ( pivots : Vector (⟦ n ⟧%stn) n) (mat : Matrix F n n) { struct iter }: Vector F n :=
    let current_idx := decrement_stn_by_m start_idx (n - iter)  in
    match iter with
    | 0 => b
    | S m => vec_ops_iterate m start_idx (vec_row_ops_step current_idx (pivots current_idx) mat b) pivots mat
    end.

  Fixpoint back_sub_iterate ( iter : nat ) { n : nat }  ( start_idx : ⟦ n ⟧%stn) (b : Vector F n) ( pivots : Vector (⟦ n ⟧%stn) n) (mat : Matrix F n n) { struct iter }: Vector F n :=
    let current_idx := decrement_stn_by_m start_idx (n - iter)  in
    match iter with
    | 0 => b
    | S m => back_sub_iterate m start_idx ( back_sub_step current_idx mat b) pivots mat
    end.


  (* The main definition using above Fixpoints, which in turn use stepwise definitions.*)
  Definition gaussian_elimination { n : nat } (mat : Matrix F n n) (b : Vector F n) (pn : n > 0) : Matrix F n n × Vector F n.
  Proof.
    set (A_and_pivots := gauss_iterate n (0,,pn) mat (zero_vector_stn n)).
    set (A  := pr1 A_and_pivots).
    set (pv := pr2 A_and_pivots).
    set (b'  := vec_ops_iterate 0 (0,,pn) b pv A).
    set (b'' := back_sub_iterate n (0,, pn) b' pv A).
    exact (A,, b').
  Defined.

  Definition gauss_solution_invar : True.
  Proof.
  Abort.


  (* Some properties on the above procedure which we would like to prove. *)

  Definition is_upper_triangular { m n : nat } (mat : Matrix F m n) :=
    ∏ i : ⟦ m ⟧%stn, ∏ j : ⟦ n ⟧%stn, i < j -> mat i j = 0%hq.

  Lemma gauss_upper_trianglar : True.
  Proof.
  Abort.

  Definition is_upper_triangular_to_k { m n : nat} ( k : nat ) (mat : Matrix F m n) :=
    ∏ i : ⟦ m ⟧%stn, ∏ j : ⟦ n ⟧%stn, i < k -> i < j -> mat i j = 0%hq.


  Lemma gauss_step_clears_row  { n : nat } (k : (⟦ n ⟧%stn)) (mat : Matrix F n n) :
    is_upper_triangular_to_k (pr1 k) (pr1 (gauss_step k mat)).
  Proof.
    intros.
  Abort.

  Lemma A_is_upper_triangular { n : nat} ( temp_proof_0_lt_n : 0 < n ) (mat : Matrix F n n) :
    is_upper_triangular (pr1 (gauss_iterate 0 (0,, temp_proof_0_lt_n) mat (zero_vector_stn n))).
  Proof.
    intros.
  Abort.


  (* Reliance on pn, coercing matrices could be done away with. *)
  Lemma sol_is_invariant_under_gauss  {n : nat} (A : Matrix F n n) (x : Matrix F n 1) (b : Matrix F 1 n)  (pn : n > 0) (pn' : 1 > 0) :
    (A ** x) = (transpose b) -> ((pr1 (gaussian_elimination A (b (0,, pn')) pn)) ** A ** x)  = ((pr1 (gaussian_elimination A (b (0,, pn')) pn)) ** (transpose b)).
  Proof.
    intros.
  Abort.





  (* Determinants, minors, minor expansions ... *)

  (* TODO : Verify this is close to accurate ... *)
  Definition make_minor {n : nat} ( i j : ⟦ S n ⟧%stn )  (mat : Matrix F (S n) (S n)) : Matrix F n n.
  Proof.
    intros i' j'.
    assert (bound_si : (S i') < (S n)). {exact (pr2 i'). }
    assert (bound_sj : (S j') < (S n)). {exact (pr2 j'). }
    set (stn_si := make_stn (S n) (S i') bound_si).
    set (stn_sj := make_stn (S n) (S j') bound_sj).
    induction (natgtb i'  (i - 1)).
    - induction (natgtb j' (j - 1)).
      + exact (mat (stnmtostnn n (S n) (natlehnsn n) i') (stnmtostnn n ( S n) (natlehnsn n) j')).
      + exact (mat ((stnmtostnn n (S n) (natlehnsn n) i')) stn_sj).
    - induction (natgtb j' (j - 1)).
      + exact (mat stn_si  (stnmtostnn n ( S n) (natlehnsn n) j')).
      + exact (mat stn_si stn_sj).
  Defined.


  (* TODO: need to figure out the recursive step ! *)
  (*
  Definition determinant_step { n : nat} (mat : Matrix F (S n) (S n)) : (Matrix F n n) × F.
  Proof.
    set (exp_row := 0).
    use tpair.
    - (* Minors *)
      intros i j.
      (* Carefully do induction on S n, not n. *)
      induction (natlthorgeh n 2) as [L | G]. (* Possibly better using natneqchoice on n != 2 *)
        + (* n ∈ ⦃0, 1⦄ *)
(*
          assert (x  : 0 < (S n)). {apply (istransnatgth (S n) n 0).
                                    - apply natlthnsn.
                                    - apply (istransnatgth n 1 0).
                                      + apply
G.
                                      + reflexivity.
                                   }
*)
           induction (nat_eq_or_neq n 1) as [T' | F'].
           * exact 1%hq.
           * exact 0%hq.
        + induction (nat_eq_or_neq n 2) as [T' | F'].
          * exact 1%hq.
          * assert (x  : 0 < (S n)). {apply (istransnatgth (S n) n 0).
                                       - apply natlthnsn.
                                       - apply (istransnatgth n 1 0).
                                         + apply G.
                                         + reflexivity.
                                     }
            assert (x' : 1 < (S n)). {apply (istransnatgth (S n) n 1).
                                       - apply natlthnsn.
                                       - apply G. }
            assert (pexp : exp_row < S n). { reflexivity. }
            assert (psj : (pr1 j) < S n). {  apply natlthtolths. exact (pr2 j). }.
            set (stn_0 := make_stn (S n) 0 x ).
            set (stn_1 := make_stn (S n) 1 x').
            set (cof := 1%hq). (* TODO : this is a dummy for (-1)^(i + j) *)
            exact (Σ (λ j : (⟦ S n ⟧%stn), cof * (mat (exp_row,, pexp) (j)))%hq).
    - (* Scalar terms *)
      intros i j.
      set (exp_row := 0).
      induction (natlthorgeh n 2) as [L | G]. (* Possibly better using natneqchoice on n != 2 *)
        + (* n ∈ ⦃0, 1⦄ *)
           induction (nat_eq_or_neq n 1) as [T' | F'].
           * exact 1%hq.
           * exact 0%hq.
        + induction (nat_eq_or_neq n 2) as [T' | F'].

    induction (natgtb n 1) as [T | F].
    - induction (nat_eq_or_neq n 2) as [T' | F'].
      assert (x :  0 < (S n)). {rewrite T'. reflexivity.}.
      assert (x' : 1 < (S n)). {rewrite T'. reflexivity.}.
      set (stn_0 := make_stn (S n) 0 x).
      set (stn_1 := make_stn (S n) 1 x').
      + exact (1%hq,, (mat stn_0 stn_0) * (mat stn_1 stn_1) - (mat stn_0 stn_1) * (mat stn_1 stn_0))%hq).
      + set (cof := 1). (* TODO : this is a dummy for (-1)^(i + j) *)
        exact (Σ (λ j : (⟦ n ⟧%stn), cof * mat ( exp_row j) (determinant ( make_minor i j mat)))).  (* TODO *)
    - induction (nat_eq_or_neq n 0).
      + exact 0%hq.
      + assert (x :  0 < n). {apply natneq0togth0. assumption.}
        set (stn_0 := make_stn n 0 x).
        exact (mat stn_0 stn_0).
  Defined.
  *)

  (*How do we produce either a smaller matrix or scalar value? *)
  (*
  Fixpoint determinant_iter {n : nat} (mat : Matrix F (S n) (S n)) := Matrix F n n.
  *)


End Gauss.





Section SmithNF.
 (* Generalized elimination over the ring of integers *)

  Local Definition I := hz.

  (* Such code might go intro Matrix.v *)
  Definition is_diagonal { m n : nat } (mat : Matrix R m n) :=
    ∏ (i : ⟦ m ⟧%stn ) (j : ⟦ n ⟧%stn ),  (stntonat _ i != (stntonat _ j)) -> (mat i j) = 0%rig.



  Definition MinAij {m n : nat} (A : Matrix I m n) (s : nat) (p : s < min m n) : I.
  Proof.
  Abort.


End SmithNF.

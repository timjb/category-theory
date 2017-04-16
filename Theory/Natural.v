Require Import Category.Lib.
Require Export Category.Theory.Functor.
Require Export Category.Theory.Isomorphism.
Require Import Category.Instance.Sets.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.
Set Shrink Obligations.

Section Natural.

Context `{C : Category}.
Context `{D : Category}.
Context `{F : C ⟶ D}.
Context `{G : C ⟶ D}.

Class Natural := {
  transform {X} : F X ~> G X;

  natural_transformation {X Y} (f : X ~> Y) :
    fmap f ∘ transform ≈ transform ∘ fmap f
}.

Global Program Instance Natural_Setoid : Setoid Natural.

End Natural.

Notation "F ⟹ G" := (@Natural _ _ F G) (at level 90, right associativity).

Notation "transform[ F ]" := (@transform _ _ _ _ F)
  (at level 9, format "transform[ F ]").

(* Natural transformations can be applied directly to functorial values to
   perform the functor mapping they imply. *)
Coercion transform : Natural >-> Funclass.

Section Nat.

Context `{C : Category}.
Context `{D : Category}.

Program Instance fobj_respects `{F : C ⟶ D} {A : C} :
  Proper (Isomorphism ==> Isomorphism) (@fobj C D F).
Next Obligation.
  repeat intro.
  destruct F; simpl in *.
  destruct X; simpl in *.
  eapply {| to   := fmap x y to
          ; from := fmap y x from |}.
  Unshelve.
  - rewrite <- fmap_comp.
    rewrite iso_to_from; cat.
  - rewrite <- fmap_comp.
    rewrite iso_from_to; cat.
Defined.

Program Instance fobj_setoid `{F : C ⟶ Sets} {A : C} :
  Setoid (F A).

Definition functor_equiv : crelation (C ⟶ D) :=
  fun F G => (∀ X : C, F X ≅ G X)%type.

Global Program Definition functor_equiv_equivalence :
  Equivalence functor_equiv.
Proof.
  unfold functor_equiv.
  constructor; cat; repeat intro; cat.
  - symmetry; apply X.
  - transitivity (y X1); auto.
Defined.

Global Program Instance functor_Setoid : Setoid (C ⟶ D) := {
  equiv := functor_equiv;
  setoid_equiv := functor_equiv_equivalence
}.

Program Definition nat_equiv `{F : C ⟶ D} `{G : C ⟶ D} : crelation (F ⟹ G) :=
  fun n m => @equiv _ _ (transform[n]) (transform[m]).
Next Obligation.
  pose proof (@homset D) as HD.
  eapply {| equiv := fun X Y : ∀ X, F X ~> G X =>
                       forall A, X A ≈ Y A|}.
  Unshelve.
  - apply HD.
  - constructor; cat.
    intros ??????.
    transitivity (y A); auto.
Defined.

Global Program Definition nat_equiv_equivalence `{F : C ⟶ D} `{G : C ⟶ D} :
  Equivalence (@nat_equiv F G).
Proof.
  constructor; cat; repeat intro; cat.
  transitivity (y A); auto.
Defined.

Global Program Instance nat_Setoid `{F : C ⟶ D} `{G : C ⟶ D} :
  Setoid (F ⟹ G) := {
  equiv := nat_equiv;
  setoid_equiv := nat_equiv_equivalence
}.

Global Program Definition nat_identity `{F : C ⟶ D} : F ⟹ F := {|
  transform := fun X => fmap (@id C X)
|}.
Obligation 1. cat. Defined.

Global Program Definition nat_compose `{F : C ⟶ D} `{G : C ⟶ D} `{K : C ⟶ D}
  (f : G ⟹ K) (g : F ⟹ G) : F ⟹ K := {|
  transform := fun X => transform[f] X ∘ transform[g] X
|}.
Obligation 1.
  intros.
  rewrite comp_assoc.
  rewrite natural_transformation.
  rewrite <- comp_assoc.
  rewrite natural_transformation.
  rewrite comp_assoc.
  reflexivity.
Defined.

Global Program Definition nat_compose_respects
       `{F : C ⟶ D} `{G : C ⟶ D} `{K : C ⟶ D} :
  Proper (equiv ==> equiv ==> equiv) (@nat_compose F G K).
Proof.
  intros ?? HA ?? HB ?.
  simpl in *.
  destruct x, y, x0, y0.
  unfold nat_equiv in *; simpl in *.
  rewrite HA, HB.
  reflexivity.
Defined.

(* Nat is the category whose morphisms are natural transformations between
   Functors from C ⟶ D. *)

Global Program Instance Nat : Category := {
  ob      := C ⟶ D;
  hom     := @Natural C D;
  id      := @nat_identity;
  compose := @nat_compose;

  compose_respects := @nat_compose_respects
}.
Next Obligation.
  unfold nat_compose, nat_identity, nat_equiv; simpl; intros; cat.
Defined.
Next Obligation.
  unfold nat_compose, nat_identity, nat_equiv; simpl; intros; cat.
Defined.
Next Obligation.
  unfold nat_compose, nat_identity, nat_equiv; simpl; intros; cat.
  rewrite comp_assoc; reflexivity.
Defined.

End Nat.

Notation "[ C , D ]" := (@Nat C D)
  (at level 90, right associativity, format "[ C ,  D ]").
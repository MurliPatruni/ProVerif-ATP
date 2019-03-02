(* Copyright (C) Di Long, Li
 *
 **)

open Types

type clause_type = Axiom | Conjecture

let preamble = {|%--------------------------------------------------------------------------
% File     : No information
% Domain   : No information
% Problem  : No information
% Version  : No information
% English  : No information

% Refs     : No information
% Source   : No information
% Names    : No information

% Status   : Unknown
% Rating   : ?
% Syntax   : No information

% Comments : File generated by ProVerif
%--------------------------------------------------------------------------
|}

let convert_ident s =
  let hex_of_int x = Printf.sprintf "%X" x in
  let acc = ref [] in
  String.iter (fun c ->
      if (c <= '0') || ((c > '9') && (c < 'A')) || ((c > 'Z') && (c < '_')) ||
         ((c > '_') && (c < 'a')) || (c > 'z') then
        let code = int_of_char c in
        let hex = hex_of_int code in
        acc := (Printf.sprintf "0x%s" hex) :: !acc;
      else
        acc := (Printf.sprintf "%c" c) :: !acc;
    ) s;
  String.concat "" (List.rev !acc)

let fun_to_str f =
  match f.f_cat with
  | Tuple -> Printf.sprintf "tuple_%s"
               (if f.f_name = "" then
                  let arity = List.length (fst f.f_type) in
                  if (arity = 0) || (Param.get_ignore_types ()) then
                    string_of_int arity
                  else
                    Terms.tl_to_string "_" (fst f.f_type)
                else
                  f.f_name
               )
  | Name _ -> Printf.sprintf "name_%s" (convert_ident f.f_name)
  | Eq _   -> Printf.sprintf "constr_%s" (convert_ident f.f_name)
  | Failure ->
    Parsing_helper.user_error "The symbol fail cannot be handled by Spass. Stopping the translation"
   | _ ->
       Parsing_helper.internal_error "function symbols of these categories should not appear in rules"

let pred_to_str p =
  Printf.sprintf "pred_%s" p.p_name

let var_to_str v =
  if v.unfailing then
    Parsing_helper.user_error "May-fail variables cannot be handled by Spass. Stopping the translation";
  (* convert_ident (String.uppercase_ascii v.sname) *)
  String.uppercase_ascii
    (convert_ident (Printf.sprintf "var_%s_%s"
                      v.sname
                      (string_of_int v.vname)))

let rec term_to_str t =
  match t with
  | Var v -> var_to_str v
  | FunApp(f, l) ->
    Printf.sprintf "%s%s" (fun_to_str f)
      (match l with
       | [] -> ""
       | l  -> terms_to_str l)
and terms_to_str ?(add_paren : bool = true) l =
  Printf.sprintf "%s%s%s"
    (if add_paren then "(" else "")
    (String.concat ", "
       (List.map term_to_str l))
    (if add_paren then ")" else "")

let fact_to_str f =
  match f with
  | Pred(p, l) ->
    Printf.sprintf "%s%s" (pred_to_str p) (terms_to_str l)
  | Out _ -> Parsing_helper.internal_error "internal error output_fact"

(* let body_to_str (hyp, concl, _, constra) =
 *   match hyp with
 *   | []  -> fact_to_str concl
 *   | [a] -> Printf.sprintf "%s => %s" (fact_to_str a) (fact_to_str concl)
 *   | _   -> Printf.sprintf "implies(and(%s), %s)"
 *              (String.concat ", " (List.map fact_to_str hyp))
 *              (fact_to_str concl) *)

let vars_in_term (t : term) : binder list =
  let rec aux t =
    match t with
    | Var v         -> [v]
    | FunApp (_, l) -> List.concat (List.map aux l)
  in
  List.sort_uniq compare (aux t)

let vars_in_terms (l : term list) : binder list =
  List.sort_uniq compare
    (List.concat (List.map vars_in_term l))

let vars_in_fact (f : fact) : binder list =
  let rec aux f =
    match f with
    | Pred(p, l) -> vars_in_terms l
    | _ -> Parsing_helper.internal_error "var_set_fact of Out"
  in
  List.sort_uniq compare (aux f)

let vars_in_facts (l : fact list) : binder list =
    List.sort_uniq compare
      (List.concat (List.map vars_in_fact l))

let wrap_into_fof : clause_type -> string -> string =
  let axiom_count = ref 0 in
  let conj_count  = ref 0 in
  (fun t body ->
     match t with
     | Axiom ->
       let c = !axiom_count in
       axiom_count := c + 1;
       Printf.sprintf "fof(ax%d, axiom,\n%s).\n" c body
     | Conjecture ->
       let c = !conj_count in
       conj_count := c + 1;
       Printf.sprintf "fof(co%d, conjecture,\n%s).\n" c body
  )

let eq_to_str (t1, t2 : term * term) =
  let vars =
    List.sort_uniq compare (vars_in_term t1 @ vars_in_term t2)
  in
  let main_eq = Printf.sprintf "%s = %s" (term_to_str t1) (term_to_str t2) in
  match vars with
  | [] -> main_eq
  | vs -> Printf.sprintf "![%s] : (%s)"
            (String.concat ", " (List.map var_to_str vars)) main_eq

let constraint_to_str (c : Types.constraints) =
  match c with
  | Neq(t1, t2) -> Printf.sprintf "%s != %s" (term_to_str t1) (term_to_str t2)

let rule_to_str (hyp, concl, _, constra) =
  let hyp = List.filter (function
      | Pred _ -> true
      | Out _ -> false) hyp
  in
  let vars_facts = vars_in_facts (concl :: hyp) in
  let hyp =
    match constra with
    | [] -> List.map fact_to_str hyp
    | l ->
      (List.map constraint_to_str (List.concat l)) @ (List.map fact_to_str hyp)
  in
  let body =
    match hyp with
    | []  -> fact_to_str concl
    | [a] -> Printf.sprintf "%s => %s" a (fact_to_str concl)
    | _   -> Printf.sprintf "(%s) => %s"
               (String.concat " & " hyp)
               (fact_to_str concl)
  in
  match vars_facts with
  | [] -> body
  | vs -> Printf.sprintf "![%s] : (%s)"
            (String.concat ", " (List.map var_to_str vs)) body

let output_rules oc rules =
  List.iter (fun rule ->
      output_string oc
        (wrap_into_fof Axiom (rule_to_str rule))
    ) rules

let get_free_or_const_names rules =
  let names = ref [] in
  let add_name s = names := s :: !names in

  let rec collect_names_from_term term =
    match term with
    | Var _ -> ()
    | FunApp(f, l) ->
      (match l with
       | [] -> (match f.f_cat with
           | Name _ | Eq _ -> add_name (fun_to_str f)
           | _ -> ()
         )
       | _ -> ()
      );
      List.iter collect_names_from_term l
  in

  let collect_names_from_fact fact =
    match fact with
    | Pred(_, l) -> List.iter collect_names_from_term l
    | _ -> ()
  in

  List.iter (fun (hyp, concl, _, _constra) ->
      List.iter collect_names_from_fact hyp;
      collect_names_from_fact concl;
    ) rules;

  List.sort_uniq compare !names

let output_eqs_about_names_being_neq oc names =
  let rec aux names =
    match names with
    | [] -> ()
    | x :: xs ->
      List.iter (fun y -> wrap_into_fof Axiom (Printf.sprintf "%s != %s" x y) |> output_string oc) xs;
      aux xs
  in

  aux names

let output_eqs oc eqs =
  List.iter (fun eqs ->
      List.iter (fun eq ->
          output_string oc
            (wrap_into_fof Axiom (eq_to_str eq))
        ) eqs
    ) eqs

let output_query oc query =
  output_string oc
    (wrap_into_fof Conjecture (fact_to_str query))

let main (filename : string) (eqs : ((term * term) list * eq_info) list) (rules : reduction list) (queries : fact list) =
  let rules = List.filter (fun (_, concl, _, _) ->
      match concl with
      | Pred(_, l) ->
        List.for_all (function
              FunApp({f_cat = Failure}, []) -> false
            | _ -> true) l
      | _ -> true) rules
  in
  let eqs_without_info = (List.map (fun (p, _) -> p) eqs) in
  let free_or_const_names = get_free_or_const_names rules in
  let n = ref 1 in
  List.iter (fun query ->
      let filename' = if !n = 1 then filename else (filename ^ "_" ^ (string_of_int (!n))) in
      let oc = open_out filename' in

      output_string oc preamble;

      output_eqs_about_names_being_neq oc free_or_const_names;

      output_eqs   oc eqs_without_info;
      output_rules oc rules;
      output_query oc query;
    ) queries
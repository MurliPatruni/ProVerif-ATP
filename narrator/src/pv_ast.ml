type visibility =
  | Public
  | Private

type unary_op = Not

type binary_op =
  | Eq
  | Neq
  | And
  | Or

type ty = string

type name_ty =
  { name : string
  ; ty : string }

type term =
  | T_name of string
  | T_tuple of term list
  | T_app of string * term list
  | T_unaryOp of unary_op * term
  | T_binaryOp of binary_op * term * term

and pterm =
  | PT_name of string
  | PT_tuple of pterm list
  | PT_app of string * pterm list
  | PT_unaryOp of unary_op * pterm
  | PT_binaryOp of binary_op * pterm * pterm
  | PT_new of
      { name : name_ty
      ; next : pterm }
  | PT_conditional of
      { cond : pterm
      ; true_branch : pterm
      ; false_branch : pterm option }
  | PT_eval of
      { let_bind_pat : pattern
      ; let_bind_term : pterm
      ; true_branch : pterm
      ; false_branch : pterm option }
  | PT_insert of
      { name : string
      ; terms : pterm list
      ; next : pterm }
  | PT_get of
      { name : string
      ; pats : pattern list
      ; next : (pterm * pterm option) option }
  | PT_event of
      { name : string
      ; terms : pterm list
      ; next : pterm option }

and pattern =
  | Pat_var of string
  | Pat_typed_var of name_ty
  | Pat_tuple of pattern list
  | Pat_app of string * pattern list
  | Pat_eq of term

and mayfailterm =
  | MFT_term of term
  | MFT_fail

and process =
  | Proc_null
  | Proc_macro of string * pterm list
  | Proc_parallel of process * process
  | Proc_replicate of process
  | Proc_new of
      { names : string list
      ; ty : string
      ; next : process }
  | Proc_conditional of
      { cond : pterm
      ; true_branch : process
      ; false_branch : process }
  | Proc_in of
      { channel : pterm
      ; message : pattern
      ; next : process }
  | Proc_out of
      { channel : pterm
      ; message : pterm
      ; next : process }
  | Proc_eval of
      { let_bind_pat : pattern
      ; let_bind_term : pterm
      ; true_branch : process
      ; false_branch : process }
  | Proc_insert of
      { name : string
      ; terms : pterm list
      ; next : process }
  | Proc_get of
      { name : string
      ; pats : pattern list
      ; next : (process * process option) option }
  | Proc_event of
      { name : string
      ; terms : pterm list
      ; next : process option }

and decl =
  | Decl_ty of string * string list
  | Decl_channel of string list
  | Decl_free of
      { names : string list
      ; ty : string
      ; options : string list }
  | Decl_const of
      { names : string list
      ; ty : string
      ; options : string list }
  | Decl_fun of
      { name : string
      ; arg_tys : string list
      ; ret_ty : string
      ; options : string list }
  | Decl_equation of
      { eqs : (name_ty list * term * term) list
      ; options : string list }
  | Decl_pred of
      { name : string
      ; arg_tys : string list }
  | Decl_table of
      { name : string
      ; tys : string list }
  | Decl_let_proc of
      { name : string
      ; args : name_ty list
      ; process : process }
  | Decl_event of
      { name : string
      ; args : name_ty list }
  | Decl_query of
      { name_tys : name_ty list
      ; query : query }

and query = query_single list

and query_single = Q_term of gterm

and gterm =
  | GT_name of string
  | GT_app of string * gterm list
  | GT_binaryOp of binary_op * gterm * gterm
  | GT_event of gterm list
  | GT_tuple of gterm list
  | GT_let of
      { name : string
      ; term : gterm
      ; next : gterm }

let unary_op_to_string = function Not -> "~"

let binary_op_to_string = function
  | Eq ->
    "="
  | Neq ->
    "<>"
  | And ->
    "&&"
  | Or ->
    "||"

let name_ty_to_string {name; ty} = Printf.sprintf "%s : %s" name ty

let rec term_to_string t =
  match t with
  | T_name s ->
    s
  | T_tuple ts ->
    Printf.sprintf "(%s)" (String.concat ", " (List.map term_to_string ts))
  | T_app (name, args) ->
    Printf.sprintf "%s%s" name
      (Misc_utils.map_list_to_string_w_opt_paren term_to_string args)
  | T_unaryOp (op, t) ->
    Printf.sprintf "%s%s" (unary_op_to_string op)
      ( match t with
        | T_name _ | T_app _ | T_unaryOp _ ->
          term_to_string t
        | _ ->
          Printf.sprintf "(%s)" (term_to_string t) )
  | T_binaryOp (op, l, r) ->
    Printf.sprintf "%s %s %s"
      ( match l with
        | T_name _ | T_app _ | T_unaryOp _ ->
          term_to_string l
        | _ ->
          Printf.sprintf "(%s)" (term_to_string l) )
      (binary_op_to_string op)
      ( match r with
        | T_name _ | T_app _ | T_unaryOp _ ->
          term_to_string l
        | _ ->
          Printf.sprintf "(%s)" (term_to_string r) )

let rec pattern_to_string p =
  match p with
  | Pat_typed_var {name; ty} ->
    Printf.sprintf "%s : %s" name ty
  | Pat_var s ->
    s
  | Pat_tuple ps ->
    Misc_utils.map_list_to_string_w_opt_paren pattern_to_string ps
  | Pat_app (f, ps) ->
    Printf.sprintf "%s%s" f
      (Misc_utils.map_list_to_string_w_opt_paren pattern_to_string ps)
  | Pat_eq t ->
    Printf.sprintf "=%s" (term_to_string t)

let rec pterm_to_string t =
  match t with
  | PT_name s ->
    s
  | PT_tuple ts ->
    Misc_utils.map_list_to_string_w_opt_paren pterm_to_string ts
  | PT_app (name, args) ->
    Printf.sprintf "%s(%s)" name
      (Misc_utils.map_list_to_string_w_opt_paren pterm_to_string args)
  | PT_unaryOp (op, t) ->
    Printf.sprintf "%s%s" (unary_op_to_string op)
      ( match t with
        | PT_name _ | PT_app _ | PT_unaryOp _ ->
          pterm_to_string t
        | _ ->
          Printf.sprintf "(%s)" (pterm_to_string t) )
  | PT_binaryOp (op, l, r) ->
    Printf.sprintf "%s %s %s"
      ( match l with
        | PT_name _ | PT_app _ | PT_unaryOp _ ->
          pterm_to_string l
        | _ ->
          Printf.sprintf "(%s)" (pterm_to_string l) )
      (binary_op_to_string op)
      ( match r with
        | PT_name _ | PT_app _ | PT_unaryOp _ ->
          pterm_to_string r
        | _ ->
          Printf.sprintf "(%s)" (pterm_to_string r) )
  | PT_new {name; next} ->
    Printf.sprintf "new %s : %s;\n%s" name.name name.ty
      (pterm_to_string next)
  | PT_conditional {cond; true_branch; false_branch} -> (
      match false_branch with
      | None ->
        Printf.sprintf "if %s then\n%s" (pterm_to_string cond)
          (pterm_to_string true_branch)
      | Some false_branch ->
        Printf.sprintf "if %s then\n%s\nelse\n%s" (pterm_to_string cond)
          (pterm_to_string true_branch)
          (pterm_to_string false_branch) )
  | PT_eval {let_bind_pat; let_bind_term; true_branch; false_branch} -> (
      match false_branch with
      | None ->
        Printf.sprintf "let %s = %s in\n%s"
          (pattern_to_string let_bind_pat)
          (pterm_to_string let_bind_term)
          (pterm_to_string true_branch)
      | Some false_branch ->
        Printf.sprintf "let %s = %s in\n%s\nelse\n%s"
          (pattern_to_string let_bind_pat)
          (pterm_to_string let_bind_term)
          (pterm_to_string true_branch)
          (pterm_to_string false_branch) )
  | PT_insert {name; terms; next} ->
    Printf.sprintf "insert(%s, %s);\n%s" name
      (Misc_utils.map_list_to_string_w_opt_paren pterm_to_string terms)
      (pterm_to_string next)
  | PT_get {name; pats; next} -> (
      match next with
      | None ->
        Printf.sprintf "get(%s, %s)" name
          (Misc_utils.map_list_to_string_w_opt_paren pattern_to_string pats)
      | Some (true_branch, false_branch) -> (
          match false_branch with
          | None ->
            Printf.sprintf "get(%s, %s) in\n%s" name
              (Misc_utils.map_list_to_string_w_opt_paren pattern_to_string pats)
              (pterm_to_string true_branch)
          | Some false_branch ->
            Printf.sprintf "get(%s, %s) in\n%s\nelse\n%s" name
              (Misc_utils.map_list_to_string_w_opt_paren pattern_to_string pats)
              (pterm_to_string true_branch)
              (pterm_to_string false_branch) ) )
  | PT_event {name; terms; next} -> (
      let term_str =
        Misc_utils.map_list_to_string_w_opt_paren pterm_to_string terms
      in
      match next with
      | None ->
        Printf.sprintf "event%s%s" name term_str
      | Some next ->
        Printf.sprintf "event%s%s;\n%s" name term_str (pterm_to_string next)
    )

let mayfailterm_to_string t =
  match t with MFT_term t -> term_to_string t | MFT_fail -> "fail"

let rec gterm_to_string t =
  match t with
  | GT_name s ->
    s
  | GT_app (name, terms) ->
    Printf.sprintf "%s(%s)" name
      (Misc_utils.map_list_to_string gterm_to_string terms)
  | GT_binaryOp (op, l, r) ->
    Printf.sprintf "%s %s %s" (gterm_to_string l) (binary_op_to_string op)
      (gterm_to_string r)
  | GT_event terms ->
    Printf.sprintf "event(%s)"
      (Misc_utils.map_list_to_string gterm_to_string terms)
  | GT_tuple terms ->
    Printf.sprintf "(%s)"
      (Misc_utils.map_list_to_string gterm_to_string terms)
  | GT_let {name; term; next} ->
    Printf.sprintf "let %s = %s in %s" name (gterm_to_string term)
      (gterm_to_string next)

let query_single_to_string_debug q =
  match q with Q_term t -> gterm_to_string t

let query_to_string_debug qs =
  String.concat ";" (List.map query_single_to_string_debug qs)

module Print_context = struct
  type process_structure_type =
    | Null
    | Macro
    | Parallel
    | Replicate
    | New
    | Conditional
    | In
    | Out
    | Eval
    | Insert
    | Get
    | Event

  type decl_structure_type =
    | Ty
    | Channel
    | Free
    | Const
    | Fun
    | Equation
    | Pred
    | Table
    | LetProc
    | Event
    | Query

  let indent_space_count = 2

  type t =
    { mutable proc_name : string option
    ; mutable prev_decl_struct_ty : decl_structure_type option
    ; mutable cur_decl_struct_ty : decl_structure_type option
    ; mutable prev_proc_struct_ty : process_structure_type option
    ; mutable cur_proc_struct_ty : process_structure_type option
    ; mutable in_count : int
    ; mutable out_count : int
    ; mutable indent : int
    ; mutable buffer : (int * string) list }

  let make () =
    { proc_name = None
    ; prev_decl_struct_ty = None
    ; cur_decl_struct_ty = None
    ; prev_proc_struct_ty = None
    ; cur_proc_struct_ty = None
    ; in_count = 0
    ; out_count = 0
    ; indent = 0
    ; buffer = [] }

  let reset ctx =
    ctx.proc_name <- None;
    ctx.prev_decl_struct_ty <- None;
    ctx.cur_decl_struct_ty <- None;
    ctx.prev_proc_struct_ty <- None;
    ctx.cur_proc_struct_ty <- None;
    ctx.out_count <- 1;
    ctx.indent <- 0;
    ctx.buffer <- []

  let set_decl_struct_ty ctx ty =
    ctx.prev_decl_struct_ty <- ctx.cur_decl_struct_ty;
    ctx.cur_decl_struct_ty <- Some ty

  let set_proc_struct_ty ctx ty =
    ctx.prev_proc_struct_ty <- ctx.cur_proc_struct_ty;
    ctx.cur_proc_struct_ty <- Some ty

  let set_proc_name ctx x =
    ctx.proc_name <- Some x;
    ctx.prev_proc_struct_ty <- None;
    ctx.cur_proc_struct_ty <- None;
    ctx.in_count <- 0;
    ctx.out_count <- 0

  let set_proc_name_none ctx =
    ctx.proc_name <- None;
    ctx.prev_proc_struct_ty <- None;
    ctx.cur_proc_struct_ty <- None;
    ctx.in_count <- 0;
    ctx.out_count <- 0

  let incre_indent ctx = ctx.indent <- ctx.indent + 1

  let decre_indent ctx = ctx.indent <- ctx.indent - 1

  let incre_in_count ctx = ctx.in_count <- ctx.in_count + 1

  let incre_out_count ctx = ctx.out_count <- ctx.out_count + 1

  let push ctx (s : string) = ctx.buffer <- (ctx.indent, s) :: ctx.buffer

  let insert_blank_line_if_diff_decl_struct_ty ctx =
    match (ctx.prev_decl_struct_ty, ctx.cur_decl_struct_ty) with
    | Some ty1, Some ty2 when ty1 <> ty2 ->
      push ctx ""
    | _ ->
      ()

  let insert_blank_line_anyway_decl_struct_ty ctx =
    match ctx.prev_decl_struct_ty with Some _ -> push ctx "" | None -> ()

  let insert_blank_line_if_diff_proc_struct_ty ctx =
    match (ctx.prev_proc_struct_ty, ctx.cur_proc_struct_ty) with
    | Some ty1, Some ty2 when ty1 <> ty2 ->
      push ctx ""
    | _ ->
      ()

  let insert_blank_line_anyway_proc_struct_ty ctx =
    match ctx.prev_proc_struct_ty with Some _ -> push ctx "" | None -> ()

  let finish ctx =
    String.concat "\n"
      (List.fold_left
         (fun acc (indent, s) ->
            let padding = String.make (indent * indent_space_count) ' ' in
            Printf.sprintf "%s%s" padding s :: acc)
         [] ctx.buffer)
end

let rec process_to_string_debug p =
  match p with
  | Proc_null ->
    "0"
  | Proc_macro (name, args) ->
    Printf.sprintf "%s%s" name
      (Misc_utils.map_list_to_string_w_opt_paren pterm_to_string args)
  | Proc_parallel (p1, p2) ->
    Printf.sprintf "%s | %s"
      (process_to_string_debug p1)
      (process_to_string_debug p2)
  | Proc_replicate p ->
    Printf.sprintf "! %s" (process_to_string_debug p)
  | Proc_new {names; ty; next} ->
    Printf.sprintf "new %s : %s;\n%s" (String.concat ", " names) ty
      (process_to_string_debug next)
  | Proc_conditional {cond; true_branch; false_branch} ->
    Printf.sprintf "if %s then\n%s\nelse\n%s" (pterm_to_string cond)
      (process_to_string_debug true_branch)
      (process_to_string_debug false_branch)
  | Proc_in {channel; message; next} ->
    Printf.sprintf "in(%s, %s);\n%s" (pterm_to_string channel)
      (pattern_to_string message)
      (process_to_string_debug next)
  | Proc_out {channel; message; next} ->
    Printf.sprintf "out(%s, %s);\n%s" (pterm_to_string channel)
      (pterm_to_string message)
      (process_to_string_debug next)
  | Proc_eval {let_bind_pat; let_bind_term; true_branch; false_branch} ->
    Printf.sprintf "let %s = %s in\n%s\nelse\n%s"
      (pattern_to_string let_bind_pat)
      (pterm_to_string let_bind_term)
      (process_to_string_debug true_branch)
      (process_to_string_debug false_branch)
  | Proc_insert {name; terms; next} ->
    Printf.sprintf "insert %s(%s);\n%s" name
      (Misc_utils.map_list_to_string pterm_to_string terms)
      (process_to_string_debug next)
  | Proc_get {name; pats; next} -> (
      match next with
      | None ->
        Printf.sprintf "get %s(%s)" name
          (Misc_utils.map_list_to_string pattern_to_string pats)
      | Some (true_branch, false_branch) -> (
          match false_branch with
          | None ->
            Printf.sprintf "get %s(%s) in\n%s" name
              (Misc_utils.map_list_to_string pattern_to_string pats)
              (process_to_string_debug true_branch)
          | Some false_branch ->
            Printf.sprintf "get %s(%s) in\n%s\nelse\n%s" name
              (Misc_utils.map_list_to_string pattern_to_string pats)
              (process_to_string_debug true_branch)
              (process_to_string_debug false_branch) ) )
  | Proc_event {name; terms; next} -> (
      match next with
      | None ->
        Printf.sprintf "get %s(%s)" name
          (Misc_utils.map_list_to_string pterm_to_string terms)
      | Some next ->
        Printf.sprintf "event %s%s;\n%s" name
          (Misc_utils.map_list_to_string_w_opt_paren pterm_to_string terms)
          (process_to_string_debug next) )

let decl_to_string_debug d =
  match d with
  | Decl_ty (ty, options) -> (
      match options with
      | [] ->
        Printf.sprintf "type %s." ty
      | l ->
        Printf.sprintf "type %s %s." ty
          (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id l) )
  | Decl_channel l ->
    Printf.sprintf "channel %s." (String.concat ", " l)
  | Decl_free {names; ty; options} ->
    Printf.sprintf "free %s : %s%s." (String.concat ", " names) ty
      (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options)
  | Decl_const {names; ty; options} ->
    Printf.sprintf "const %s : %s%s." (String.concat ", " names) ty
      (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options)
  | Decl_fun {name; arg_tys; ret_ty; options} ->
    Printf.sprintf "fun %s(%s) : %s%s." name
      (String.concat ", " arg_tys)
      ret_ty
      (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options)
  | Decl_equation {eqs; _} ->
    Printf.sprintf "equation%s"
      (String.concat ";"
         (List.map
            (fun (name_tys, left, right) ->
               ( match name_tys with
                 | [] ->
                   ""
                 | l ->
                   Printf.sprintf "forall %s"
                     (String.concat ", "
                        (List.map
                           (fun {name; ty} ->
                              Printf.sprintf "%s : %s" name ty)
                           l)) )
               ^ term_to_string left ^ " = " ^ term_to_string right)
            eqs))
  | Decl_pred {name; arg_tys} ->
    Printf.sprintf "pred %s(%s)." name (String.concat ", " arg_tys)
  | Decl_table {name; tys} ->
    Printf.sprintf "table %s(%s)." name (String.concat ", " tys)
  | Decl_let_proc {name; args; process} ->
    Printf.sprintf "let %s%s = \n%s" name
      (Misc_utils.map_list_to_string_w_opt_paren
         (fun {name; ty} -> Printf.sprintf "%s : %s" name ty)
         args)
      (process_to_string_debug process)
  | Decl_event {name; args} ->
    Printf.sprintf "event %s%s." name
      (Misc_utils.map_list_to_string_w_opt_paren
         (fun {name; ty} -> Printf.sprintf "%s : %s" name ty)
         args)
  | Decl_query {name_tys; query} ->
    Printf.sprintf "query %s%s."
      ( match name_tys with
        | [] ->
          ""
        | l ->
          Printf.sprintf "%s;"
            (Misc_utils.map_list_to_string name_ty_to_string name_tys) )
      (query_to_string_debug query)

let process_to_string ?(ctx = Print_context.make ()) p =
  let rec aux p =
    match p with
    | Proc_null ->
      Print_context.set_proc_struct_ty ctx Print_context.Null;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.push ctx "0"
    | Proc_macro (name, args) ->
      Print_context.set_proc_struct_ty ctx Print_context.Macro;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.push ctx
        (Printf.sprintf "%s%s" name
           (Misc_utils.map_list_to_string_w_opt_paren pterm_to_string args))
    | Proc_parallel (p1, p2) ->
      Print_context.set_proc_struct_ty ctx Print_context.Parallel;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.incre_indent ctx;
      aux p1;
      Print_context.decre_indent ctx;
      Print_context.push ctx "|";
      Print_context.incre_indent ctx;
      aux p2;
      Print_context.decre_indent ctx
    | Proc_replicate p ->
      Print_context.set_proc_struct_ty ctx Print_context.Replicate;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.push ctx "!";
      Print_context.incre_indent ctx;
      aux p;
      Print_context.decre_indent ctx
    | Proc_new {names; ty; next} ->
      Print_context.set_proc_struct_ty ctx Print_context.New;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.push ctx
        (Printf.sprintf "new %s : %s" (String.concat ", " names) ty);
      aux next
    | Proc_conditional {cond; true_branch; false_branch} -> (
        Print_context.set_proc_struct_ty ctx Print_context.Conditional;
        Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
        Print_context.push ctx
          (Printf.sprintf "if %s then" (pterm_to_string cond));
        match false_branch with
        | Proc_null ->
          aux true_branch
        | _ ->
          Print_context.incre_indent ctx;
          aux true_branch;
          Print_context.decre_indent ctx;
          Print_context.push ctx "else";
          Print_context.incre_indent ctx;
          aux false_branch;
          Print_context.decre_indent ctx )
    | Proc_in {channel; message; next} ->
      Print_context.set_proc_struct_ty ctx Print_context.In;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.incre_in_count ctx;
      let proc_name =
        match ctx.proc_name with Some name -> name | None -> ""
      in
      let proc_step = ctx.in_count + ctx.out_count in
      Print_context.push ctx
        (Printf.sprintf "%d. I -> %s IN  on %s : %s;" proc_step proc_name
           (pterm_to_string channel)
           (pattern_to_string message));
      aux next
    | Proc_out {channel; message; next} ->
      Print_context.set_proc_struct_ty ctx Print_context.Out;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.incre_in_count ctx;
      let proc_name =
        match ctx.proc_name with Some name -> name | None -> ""
      in
      let proc_step = ctx.in_count + ctx.out_count in
      Print_context.push ctx
        (Printf.sprintf "%d. %s -> I OUT on %s : %s;" proc_step proc_name
           (pterm_to_string channel) (pterm_to_string message));
      aux next
    | Proc_eval {let_bind_pat; let_bind_term; true_branch; false_branch} -> (
        Print_context.set_proc_struct_ty ctx Print_context.Eval;
        Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
        Print_context.push ctx
          (Printf.sprintf "let %s = %s in"
             (pattern_to_string let_bind_pat)
             (pterm_to_string let_bind_term));
        match false_branch with
        | Proc_null ->
          aux true_branch
        | _ ->
          Print_context.incre_indent ctx;
          aux true_branch;
          Print_context.decre_indent ctx;
          Print_context.push ctx "else";
          Print_context.incre_indent ctx;
          aux false_branch;
          Print_context.decre_indent ctx )
    | Proc_insert {name; terms; next} ->
      Print_context.set_proc_struct_ty ctx Print_context.Insert;
      Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
      Print_context.push ctx
        (Printf.sprintf "insert %s(%s)" name
           (String.concat ", " (List.map pterm_to_string terms)));
      aux next
    | Proc_get {name; pats; next} -> (
        Print_context.set_proc_struct_ty ctx Print_context.Get;
        Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
        Print_context.push ctx
          (Printf.sprintf "get %s(%s)" name
             (String.concat ", " (List.map pattern_to_string pats)));
        match next with
        | None ->
          ()
        | Some (true_branch, None) | Some (true_branch, Some Proc_null) ->
          aux true_branch
        | Some (true_branch, Some false_branch) ->
          Print_context.incre_indent ctx;
          aux true_branch;
          Print_context.decre_indent ctx;
          Print_context.push ctx "else";
          Print_context.incre_indent ctx;
          aux false_branch;
          Print_context.decre_indent ctx )
    | Proc_event {name; terms; next} -> (
        Print_context.set_proc_struct_ty ctx Print_context.Event;
        Print_context.insert_blank_line_if_diff_proc_struct_ty ctx;
        Print_context.push ctx
          (Printf.sprintf "event %s(%s)" name
             (String.concat ", " (List.map pterm_to_string terms)));
        match next with None -> () | Some next -> aux next )
  in
  aux p; Print_context.finish ctx

let decl_to_string ?(ctx = Print_context.make ()) d =
  match d with
  | Decl_ty (ty, options) ->
    Print_context.set_decl_struct_ty ctx Print_context.Ty;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "type %s%s." ty
         (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options))
  | Decl_channel l ->
    Print_context.set_decl_struct_ty ctx Print_context.Channel;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "channel %s." (String.concat ", " l))
  | Decl_free {names; ty; options} ->
    Print_context.set_decl_struct_ty ctx Print_context.Free;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "free %s : %s%s." (String.concat ", " names) ty
         (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options))
  | Decl_const {names; ty; options} ->
    Print_context.set_decl_struct_ty ctx Print_context.Const;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "const %s : %s%s." (String.concat ", " names) ty
         (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options))
  | Decl_fun {name; arg_tys; ret_ty; options} ->
    Print_context.set_decl_struct_ty ctx Print_context.Fun;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "fun %s(%s) : %s%s." name
         (String.concat ", " arg_tys)
         ret_ty
         (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id options))
  | Decl_equation {eqs; options} ->
    Print_context.set_decl_struct_ty ctx Print_context.Equation;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx "equation";
    Print_context.incre_indent ctx;
    List.iter
      (fun (name_tys, l, r) ->
         match name_tys with
         | [] ->
           Print_context.push ctx
             (Printf.sprintf "%s = %s%s." (term_to_string l)
                (term_to_string r)
                (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id
                   options))
         | _ ->
           Print_context.push ctx
             (Printf.sprintf "forall %s; %s = %s%s."
                (Misc_utils.map_list_to_string name_ty_to_string name_tys)
                (term_to_string l) (term_to_string r)
                (Misc_utils.map_list_to_string_w_opt_brack Misc_utils.id
                   options)))
      eqs;
    Print_context.decre_indent ctx
  | Decl_pred {name; arg_tys} ->
    Print_context.set_decl_struct_ty ctx Print_context.Pred;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "pred %s(%s)." name (String.concat ", " arg_tys))
  | Decl_table {name; tys} ->
    Print_context.set_decl_struct_ty ctx Print_context.Table;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "table %s(%s)." name (String.concat ", " tys))
  | Decl_let_proc {name; args; process} ->
    Print_context.set_decl_struct_ty ctx Print_context.LetProc;
    Print_context.insert_blank_line_anyway_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "let %s%s =" name
         (Misc_utils.map_list_to_string_w_opt_paren name_ty_to_string args));
    Print_context.incre_indent ctx;
    Print_context.set_proc_name ctx name;
    process_to_string ~ctx process |> ignore;
    Print_context.set_proc_name_none ctx;
    Print_context.decre_indent ctx
  | Decl_event {name; args} ->
    Print_context.set_decl_struct_ty ctx Print_context.Event;
    Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
    Print_context.push ctx
      (Printf.sprintf "event %s%s." name
         (Misc_utils.map_list_to_string_w_opt_paren name_ty_to_string args))
  | Decl_query {name_tys; query} -> (
      Print_context.set_decl_struct_ty ctx Print_context.Query;
      Print_context.insert_blank_line_if_diff_decl_struct_ty ctx;
      Print_context.push ctx "query";
      match name_tys with
      | [] ->
        Print_context.push ctx (query_to_string_debug query)
      | _ ->
        Print_context.push ctx
          (Printf.sprintf "%s; %s"
             (Misc_utils.map_list_to_string name_ty_to_string name_tys)
             (query_to_string_debug query)) )

let decls_to_string decls =
  let ctx = Print_context.make () in
  List.iter (decl_to_string ~ctx) decls;
  Print_context.finish ctx

let main_process_to_string p =
  let ctx = Print_context.make () in
  Print_context.incre_indent ctx;
  process_to_string ~ctx p

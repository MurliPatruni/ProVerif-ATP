%--------------------------------------------------------------------------
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
fof(ax0, axiom,
constr_B_STEP_1 != constr_CONST_0x30).
fof(ax1, axiom,
constr_B_STEP_1 != constr_CONST_1).
fof(ax2, axiom,
constr_B_STEP_1 != constr_CONST_2).
fof(ax3, axiom,
constr_B_STEP_1 != constr_CONST_3).
fof(ax4, axiom,
constr_B_STEP_1 != constr_CONST_4).
fof(ax5, axiom,
constr_B_STEP_1 != constr_ZERO).
fof(ax6, axiom,
constr_B_STEP_1 != constr_enc_oracle_STEP_1).
fof(ax7, axiom,
constr_B_STEP_1 != name_Kab).
fof(ax8, axiom,
constr_B_STEP_1 != name_c).
fof(ax9, axiom,
constr_B_STEP_1 != name_objective).
fof(ax10, axiom,
constr_B_STEP_1 != name_v).
fof(ax11, axiom,
constr_CONST_0x30 != constr_CONST_1).
fof(ax12, axiom,
constr_CONST_0x30 != constr_CONST_2).
fof(ax13, axiom,
constr_CONST_0x30 != constr_CONST_3).
fof(ax14, axiom,
constr_CONST_0x30 != constr_CONST_4).
fof(ax15, axiom,
constr_CONST_0x30 != constr_ZERO).
fof(ax16, axiom,
constr_CONST_0x30 != constr_enc_oracle_STEP_1).
fof(ax17, axiom,
constr_CONST_0x30 != name_Kab).
fof(ax18, axiom,
constr_CONST_0x30 != name_c).
fof(ax19, axiom,
constr_CONST_0x30 != name_objective).
fof(ax20, axiom,
constr_CONST_0x30 != name_v).
fof(ax21, axiom,
constr_CONST_1 != constr_CONST_2).
fof(ax22, axiom,
constr_CONST_1 != constr_CONST_3).
fof(ax23, axiom,
constr_CONST_1 != constr_CONST_4).
fof(ax24, axiom,
constr_CONST_1 != constr_ZERO).
fof(ax25, axiom,
constr_CONST_1 != constr_enc_oracle_STEP_1).
fof(ax26, axiom,
constr_CONST_1 != name_Kab).
fof(ax27, axiom,
constr_CONST_1 != name_c).
fof(ax28, axiom,
constr_CONST_1 != name_objective).
fof(ax29, axiom,
constr_CONST_1 != name_v).
fof(ax30, axiom,
constr_CONST_2 != constr_CONST_3).
fof(ax31, axiom,
constr_CONST_2 != constr_CONST_4).
fof(ax32, axiom,
constr_CONST_2 != constr_ZERO).
fof(ax33, axiom,
constr_CONST_2 != constr_enc_oracle_STEP_1).
fof(ax34, axiom,
constr_CONST_2 != name_Kab).
fof(ax35, axiom,
constr_CONST_2 != name_c).
fof(ax36, axiom,
constr_CONST_2 != name_objective).
fof(ax37, axiom,
constr_CONST_2 != name_v).
fof(ax38, axiom,
constr_CONST_3 != constr_CONST_4).
fof(ax39, axiom,
constr_CONST_3 != constr_ZERO).
fof(ax40, axiom,
constr_CONST_3 != constr_enc_oracle_STEP_1).
fof(ax41, axiom,
constr_CONST_3 != name_Kab).
fof(ax42, axiom,
constr_CONST_3 != name_c).
fof(ax43, axiom,
constr_CONST_3 != name_objective).
fof(ax44, axiom,
constr_CONST_3 != name_v).
fof(ax45, axiom,
constr_CONST_4 != constr_ZERO).
fof(ax46, axiom,
constr_CONST_4 != constr_enc_oracle_STEP_1).
fof(ax47, axiom,
constr_CONST_4 != name_Kab).
fof(ax48, axiom,
constr_CONST_4 != name_c).
fof(ax49, axiom,
constr_CONST_4 != name_objective).
fof(ax50, axiom,
constr_CONST_4 != name_v).
fof(ax51, axiom,
constr_ZERO != constr_enc_oracle_STEP_1).
fof(ax52, axiom,
constr_ZERO != name_Kab).
fof(ax53, axiom,
constr_ZERO != name_c).
fof(ax54, axiom,
constr_ZERO != name_objective).
fof(ax55, axiom,
constr_ZERO != name_v).
fof(ax56, axiom,
constr_enc_oracle_STEP_1 != name_Kab).
fof(ax57, axiom,
constr_enc_oracle_STEP_1 != name_c).
fof(ax58, axiom,
constr_enc_oracle_STEP_1 != name_objective).
fof(ax59, axiom,
constr_enc_oracle_STEP_1 != name_v).
fof(ax60, axiom,
name_Kab != name_c).
fof(ax61, axiom,
name_Kab != name_objective).
fof(ax62, axiom,
name_Kab != name_v).
fof(ax63, axiom,
name_c != name_objective).
fof(ax64, axiom,
name_c != name_v).
fof(ax65, axiom,
name_objective != name_v).
fof(ax66, axiom,
![VAR_X_15, VAR_Y_16] : (constr_split(constr_concat(VAR_X_15, VAR_Y_16)) = tuple_2(VAR_X_15, VAR_Y_16))).
fof(ax67, axiom,
![VAR_X1_0X30, VAR_X2_0X30, VAR_Y1_0X30, VAR_Y2_0X30] : (constr_xor(constr_concat(VAR_X1_0X30, VAR_Y1_0X30), constr_concat(VAR_X2_0X30, VAR_Y2_0X30)) = constr_concat(constr_xor(VAR_X1_0X30, VAR_X2_0X30), constr_xor(VAR_Y1_0X30, VAR_Y2_0X30)))).
fof(ax68, axiom,
![VAR_X_13, VAR_Y_14] : (constr_C(constr_xor(VAR_X_13, VAR_Y_14)) = constr_xor(constr_C(VAR_X_13), constr_C(VAR_Y_14)))).
fof(ax69, axiom,
![VAR_X_12] : (constr_xor(VAR_X_12, VAR_X_12) = constr_ZERO)).
fof(ax70, axiom,
![VAR_X_11] : (constr_xor(VAR_X_11, constr_ZERO) = VAR_X_11)).
fof(ax71, axiom,
![VAR_X_9, VAR_Y_10X30] : (constr_xor(VAR_X_9, VAR_Y_10X30) = constr_xor(VAR_Y_10X30, VAR_X_9))).
fof(ax72, axiom,
![VAR_X_8, VAR_Y_0X30, VAR_Z_0X30] : (constr_xor(VAR_X_8, constr_xor(VAR_Y_0X30, VAR_Z_0X30)) = constr_xor(constr_xor(VAR_X_8, VAR_Y_0X30), VAR_Z_0X30))).
fof(ax73, axiom,
![VAR_X_28] : (pred_eq(VAR_X_28, VAR_X_28))).
fof(ax74, axiom,
![VAR_V_35, VAR_V_36] : ((pred_attacker(VAR_V_35) & pred_attacker(VAR_V_36)) => pred_attacker(constr_xor(VAR_V_35, VAR_V_36)))).
fof(ax75, axiom,
pred_attacker(tuple_true)).
fof(ax76, axiom,
![VAR_V_38] : (pred_attacker(VAR_V_38) => pred_attacker(constr_split(VAR_V_38)))).
fof(ax77, axiom,
pred_attacker(tuple_false)).
fof(ax78, axiom,
pred_attacker(constr_enc_oracle_STEP_1)).
fof(ax79, axiom,
![VAR_V_42, VAR_V_43] : ((pred_attacker(VAR_V_42) & pred_attacker(VAR_V_43)) => pred_attacker(constr_concat(VAR_V_42, VAR_V_43)))).
fof(ax80, axiom,
pred_attacker(constr_ZERO)).
fof(ax81, axiom,
![VAR_V_46, VAR_V_47] : ((pred_attacker(VAR_V_46) & pred_attacker(VAR_V_47)) => pred_attacker(constr_RC4(VAR_V_46, VAR_V_47)))).
fof(ax82, axiom,
pred_attacker(constr_CONST_4)).
fof(ax83, axiom,
pred_attacker(constr_CONST_3)).
fof(ax84, axiom,
pred_attacker(constr_CONST_2)).
fof(ax85, axiom,
pred_attacker(constr_CONST_1)).
fof(ax86, axiom,
pred_attacker(constr_CONST_0x30)).
fof(ax87, axiom,
![VAR_V_49] : (pred_attacker(VAR_V_49) => pred_attacker(constr_C(VAR_V_49)))).
fof(ax88, axiom,
pred_attacker(constr_B_STEP_1)).
fof(ax89, axiom,
![VAR_V_56, VAR_V_57] : ((pred_attacker(VAR_V_56) & pred_attacker(VAR_V_57)) => pred_attacker(tuple_2(VAR_V_56, VAR_V_57)))).
fof(ax90, axiom,
![VAR_V_64, VAR_V_65] : (pred_attacker(tuple_2(VAR_V_64, VAR_V_65)) => pred_attacker(VAR_V_64))).
fof(ax91, axiom,
![VAR_V_67, VAR_V_68] : (pred_attacker(tuple_2(VAR_V_67, VAR_V_68)) => pred_attacker(VAR_V_68))).
fof(ax92, axiom,
![VAR_V_70X30, VAR_V_71] : ((pred_mess(VAR_V_71, VAR_V_70X30) & pred_attacker(VAR_V_71)) => pred_attacker(VAR_V_70X30))).
fof(ax93, axiom,
![VAR_V_72, VAR_V_73] : ((pred_attacker(VAR_V_73) & pred_attacker(VAR_V_72)) => pred_mess(VAR_V_73, VAR_V_72))).
fof(ax94, axiom,
pred_attacker(name_c)).
fof(ax95, axiom,
![VAR_V_75] : (pred_equal(VAR_V_75, VAR_V_75))).
fof(ax96, axiom,
![VAR_V_76] : (pred_attacker(name_new0x2Dname(VAR_V_76)))).
fof(ax97, axiom,
![VAR_M_124] : (pred_attacker(VAR_M_124) => pred_attacker(tuple_2(tuple_2(name_v, constr_xor(constr_concat(VAR_M_124, constr_C(VAR_M_124)), constr_RC4(name_v, name_Kab))), constr_enc_oracle_STEP_1)))).
fof(ax98, axiom,
pred_attacker(tuple_2(tuple_2(name_v, constr_xor(constr_concat(name_objective, constr_C(name_objective)), constr_RC4(name_v, name_Kab))), constr_B_STEP_1))).
fof(co0, conjecture,
pred_attacker(name_objective)).
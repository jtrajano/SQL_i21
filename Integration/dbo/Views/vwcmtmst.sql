CREATE VIEW [dbo].[vwcmtmst]
AS
SELECT
vwcmt_cus_no				=agcmt_cus_no
,vwcmt_com_typ				=agcmt_com_typ
,vwcmt_com_cd				=CAST(agcmt_com_cd AS CHAR(4))
,vwcmt_com_seq				=CAST(agcmt_com_seq AS CHAR(4))
,vwcmt_data					=agcmt_data
,vwcmt_payee_1				=agcmt_payee_1
,vwcmt_payee_2				=agcmt_payee_2
,vwcmt_rc_lic_no			=agcmt_rc_lic_no
,vwcmt_rc_exp_rev_dt		=agcmt_rc_exp_rev_dt
,vwcmt_rc_comment			=agcmt_rc_comment
,vwcmt_rc_custom_yn			=CAST(agcmt_rc_custom_yn AS CHAR(4))
,vwcmt_tr_ins_no			=agcmt_tr_ins_no
,vwcmt_tr_exp_rev_dt		=agcmt_tr_exp_rev_dt
,vwcmt_tr_comment			=agcmt_tr_comment
,vwcmt_ord_comment1			=agcmt_ord_comment1
,vwcmt_ord_comment2			=CAST(agcmt_ord_comment2 AS CHAR(60))
,vwcmt_fax_contact			=agcmt_fax_contact
,vwcmt_fax_to_fax_num		=agcmt_fax_to_fax_num
,vwcmt_eml_contact			=agcmt_eml_contact
,vwcmt_eml_address			=agcmt_eml_address
,vwcmt_stl_lic_no			=agcmt_stl_lic_no
,vwcmt_stl_exp_rev_dt		=agcmt_stl_exp_rev_dt
,vwcmt_stl_comment			=agcmt_stl_comment
,vwcmt_user_id				=agcmt_user_id
,vwcmt_user_rev_dt			=agcmt_user_rev_dt
,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
FROM agcmtmst
GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcmtmst')
	DROP VIEW vwcmtmst
GO
--AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
	EXEC ('
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
		,intConcurrencyId = 0
		FROM agcmtmst
		')

GO

-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwcmtmst]
		AS
		SELECT
			vwcmt_cus_no				=ptcmt_cus_no
			,vwcmt_com_typ				=ptcmt_type
			,vwcmt_com_cd				=CAST(NULL AS CHAR(4))
			,vwcmt_com_seq				=CAST(ptcmt_seq_no AS CHAR(2))  
			,vwcmt_data					=CAST(ptcmt_comment AS CHAR(60))
			,vwcmt_payee_1				=CAST(NULL AS CHAR(30))
			,vwcmt_payee_2				=CAST(NULL AS CHAR(30)) 
			,vwcmt_rc_lic_no			=CAST(NULL AS CHAR(12))
			,vwcmt_rc_exp_rev_dt		=NULL
			,vwcmt_rc_comment			=CAST(NULL AS CHAR(30))
			,vwcmt_rc_custom_yn			=CAST(NULL AS CHAR(4))
			,vwcmt_tr_ins_no			=CAST(NULL AS CHAR(12))
			,vwcmt_tr_exp_rev_dt		=NULL
			,vwcmt_tr_comment			=CAST(NULL AS CHAR(30))
			,vwcmt_ord_comment1			=CAST(NULL AS CHAR(30))
			,vwcmt_ord_comment2			=CAST(ptcmt_comment AS CHAR(60))
			,vwcmt_fax_contact			=CAST(NULL AS CHAR(30))
			,vwcmt_fax_to_fax_num		=CAST(NULL AS CHAR(24))
			,vwcmt_eml_contact			=CAST(NULL AS CHAR(30))
			,vwcmt_eml_address			=CAST(NULL AS CHAR(39))
			,vwcmt_stl_lic_no			=CAST(NULL AS CHAR(15))
			,vwcmt_stl_exp_rev_dt		=NULL
			,vwcmt_stl_comment			=CAST(NULL AS CHAR(30)) 
			,vwcmt_user_id				=CAST(NULL AS CHAR(16))
			,vwcmt_user_rev_dt			=NULL
			,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
			,intConcurrencyId = 0
			FROM ptcmtmst
		
		')
GO


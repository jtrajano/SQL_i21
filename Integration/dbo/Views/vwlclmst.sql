IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlclmst')
	DROP VIEW vwlclmst

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwlclmst]
		AS
		SELECT
		vwlcl_tax_state	=	aglcl_tax_state,
		vwlcl_tax_auth_id1	=	aglcl_tax_auth_id1,
		vwlcl_tax_auth_id2	=	aglcl_tax_auth_id2,
		vwlcl_auth_id1_desc	=	aglcl_auth_id1_desc,
		vwlcl_auth_id2_desc	=	aglcl_auth_id2_desc,
		vwlcl_fet_ivc_desc	=	aglcl_fet_ivc_desc,
		vwlcl_set_ivc_desc	=	aglcl_set_ivc_desc,
		vwlcl_lc1_ivc_desc	=	aglcl_lc1_ivc_desc,
		vwlcl_lc2_ivc_desc	=	aglcl_lc2_ivc_desc,
		vwlcl_lc3_ivc_desc	=	aglcl_lc3_ivc_desc,
		vwlcl_lc4_ivc_desc	=	aglcl_lc4_ivc_desc,
		vwlcl_lc5_ivc_desc	=	aglcl_lc5_ivc_desc
		,vwlcl_lc6_ivc_desc	=	aglcl_lc6_ivc_desc
		,vwlcl_user_id	=	aglcl_user_id
		,vwlcl_user_rev_dt	=	aglcl_user_rev_dt
		,A4GLIdentity	=	CAST(A4GLIdentity   AS INT)
		FROM aglclmst
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwlclmst]
		AS
		SELECT
		vwlcl_tax_state	=	ptlcl_state,
		vwlcl_tax_auth_id1	=	ptlcl_local1_id,
		vwlcl_tax_auth_id2	=	ptlcl_local2_id,
		vwlcl_auth_id1_desc	=	ptlcl_desc,
		vwlcl_auth_id2_desc	=	CAST(NULL AS CHAR(30)),
		vwlcl_fet_ivc_desc	=	CAST(NULL AS CHAR(20)),  
		vwlcl_set_ivc_desc	=	CAST(NULL AS CHAR(20)),
		vwlcl_lc1_ivc_desc	=	ptlcl_local1_desc,
		vwlcl_lc2_ivc_desc	=	ptlcl_local2_desc,
		vwlcl_lc3_ivc_desc	=	ptlcl_local3_desc,
		vwlcl_lc4_ivc_desc	=	ptlcl_local4_desc,
		vwlcl_lc5_ivc_desc	=	ptlcl_local5_desc
		,vwlcl_lc6_ivc_desc	=	ptlcl_local6_desc
		,vwlcl_user_id	=	CAST(NULL AS CHAR(16))
		,vwlcl_user_rev_dt	=	NULL
		,A4GLIdentity	=	CAST(A4GLIdentity   AS INT)
		FROM ptlclmst
		')

GO

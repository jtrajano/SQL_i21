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
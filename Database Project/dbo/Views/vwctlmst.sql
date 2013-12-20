CREATE VIEW [dbo].[vwctlmst]
AS
SELECT
A4GLIdentity		=CAST(A4GLIdentity   AS INT)
,vwctl_key			=CAST (agctl_key AS INT)
,vwcar_per1_desc	=CAST(agcar_per1_desc AS CHAR(20))
,vwcar_per2_desc	=CAST(agcar_per2_desc AS CHAR(20))
,vwcar_per3_desc	=CAST(agcar_per3_desc AS CHAR(20))
,vwcar_per4_desc	=CAST(agcar_per4_desc AS CHAR(20))
,vwcar_per5_desc	=CAST(agcar_per5_desc AS CHAR(20))
,vwcar_future_desc	=agcar_future_desc	
,vwctl_sa_cost_ind	=agctl_sa_cost_ind
,vwctl_stmt_close_rev_dt =(SELECT agctl_stmt_close_rev_dt FROM agctlmst WHERE agctl_key=1)
FROM agctlmst

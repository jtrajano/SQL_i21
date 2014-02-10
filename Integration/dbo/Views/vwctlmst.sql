IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwctlmst')
	DROP VIEW vwctlmst
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
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
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwctlmst]
		AS
		SELECT
			A4GLIdentity		=CAST(A4GLIdentity   AS INT)
			,vwctl_key			=CAST(ptctl_key AS INT)
			,vwcar_per1_desc	=CAST(pt4cf_per_desc_1 AS CHAR(20))
			,vwcar_per2_desc	=CAST(pt4cf_per_desc_2 AS CHAR(20)) 
			,vwcar_per3_desc	=CAST(pt4cf_per_desc_3 AS CHAR(20))
			,vwcar_per4_desc	=CAST(pt4cf_per_desc_4 AS CHAR(20))
			,vwcar_per5_desc	=CAST(pt4cf_per_desc_5 AS CHAR(20))  
			,vwcar_future_desc	=CAST(NULL AS CHAR(12)) 	
			,vwctl_sa_cost_ind	=CAST(pt4cf_per_desc_1 AS CHAR(1))
			,vwctl_stmt_close_rev_dt =pt3cf_eom_business_rev_dt
			FROM ptctlmst
		')
GO

GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwtrmmst')
	DROP VIEW vwtrmmst
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwtrmmst]
		AS
		SELECT 
		vwtrm_key_n = CAST(agtrm_key_n AS INT)
		,vwtrm_desc = agtrm_desc
		,A4GLIdentity= CAsT(A4GLIdentity AS INT)
		FROM
		agtrmmst
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwtrmmst]
		AS
		SELECT 
		vwtrm_key_n = CAST(pttrm_code AS INT)
		,vwtrm_desc = pttrm_desc
		,A4GLIdentity= CAsT(A4GLIdentity AS INT)
		FROM
		pttrmmst

		')
GO


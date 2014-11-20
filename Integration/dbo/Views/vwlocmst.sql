GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlocmst')
	DROP VIEW vwlocmst
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwlocmst]
		AS
		SELECT
			agloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
			agloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
			agloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
			CAST(A4GLIdentity AS INT) as A4GLIdentity,	
			intConcurrencyId = 0
		FROM aglocmst
		')
		
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwlocmst]
		AS
		SELECT
			ptloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
			ptloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
			ptloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
			CAST(A4GLIdentity AS INT) as A4GLIdentity,
			intConcurrencyId = 0
		FROM ptlocmst
		')
GO

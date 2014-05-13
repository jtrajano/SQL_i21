GO


-- DELETE OLD VIEW
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPAgcusMst')
	DROP VIEW vwCPAgcusMst
GO
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPAgcusMst')
	DROP VIEW vyuCPAgcusMst
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPAgcusMst]
			AS SELECT
			agcus_key			COLLATE Latin1_General_CI_AS as strCustomerNo,
			agcus_first_name	COLLATE Latin1_General_CI_AS as strCustomerFirstName,
			agcus_last_name		COLLATE Latin1_General_CI_AS as strCustomerLastName,
			CAST(A4GLIdentity AS INT) as A4GLIdentity	
		FROM agcusmst
		')
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPAgcusMst]
			AS SELECT
			ptcus_cus_no			COLLATE Latin1_General_CI_AS as strCustomerNo,
			ptcus_first_name	COLLATE Latin1_General_CI_AS as strCustomerFirstName,
			ptcus_last_name		COLLATE Latin1_General_CI_AS as strCustomerLastName,
			CAST(A4GLIdentity AS INT) as A4GLIdentity	
		FROM ptcusmst
		')
GO

GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginDegreeOption')
	DROP VIEW vyuTMOriginDegreeOption
GO

-- AG VIEW
IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 AND EXISTS(SELECT TOP 1 1 FROM adctlmst))
	EXEC ('
			CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
			AS  
			SELECT  
				vwctl_ser_dt_desc_1 = ISNULL(adctl_ser_dt_desc_1,'')
				,vwctl_ser_dt_desc_2 = ISNULL(adctl_ser_dt_desc_2,'')
				,vwctl_ser_dt_desc_3 = ISNULL(adctl_ser_dt_desc_3,'')
				,vwctl_ser_dt_desc_4 = ISNULL(adctl_ser_dt_desc_4,'')
				,vwctl_ser_dt_desc_5 = ISNULL(adctl_ser_dt_desc_5,'')
				,vwctl_ser_dt_desc_6 = ISNULL(adctl_ser_dt_desc_6,'')
				,vwctl_ser_dt_desc_7 = ISNULL(adctl_ser_dt_desc_7,'')
				,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
			FROM adctlmst

		')
GO
-- PT VIEW
IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1 AND EXISTS(SELECT TOP 1 1 FROM pdctlmst))
	EXEC ('
		CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
		AS  
		SELECT  
			vwctl_ser_dt_desc_1 = ISNULL(pdctl_ser_dt_desc_1,'')
			,vwctl_ser_dt_desc_2 = ISNULL(pdctl_ser_dt_desc_2,'')
			,vwctl_ser_dt_desc_3 = ISNULL(pdctl_ser_dt_desc_3,'')
			,vwctl_ser_dt_desc_4 = ISNULL(pdctl_ser_dt_desc_4,'')
			,vwctl_ser_dt_desc_5 = ''
			,vwctl_ser_dt_desc_6 = ''
			,vwctl_ser_dt_desc_7 = ''
			,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
		FROM pdctlmst
		')
GO
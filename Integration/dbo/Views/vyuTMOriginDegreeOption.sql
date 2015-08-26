
GO
PRINT  'BEGIN Create vyuTMOriginDegreeOption '

GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginDegreeOption')
	DROP VIEW vyuTMOriginDegreeOption
GO

IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
BEGIN
	-- AG VIEW
	IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 AND EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'adctlmst'))
	BEGIN
		EXEC ('
				CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
				AS  
				SELECT  
					vwctl_ser_dt_desc_1 = ISNULL(adctl_ser_dt_desc_1,'''')
					,vwctl_ser_dt_desc_2 = ISNULL(adctl_ser_dt_desc_2,'''')
					,vwctl_ser_dt_desc_3 = ISNULL(adctl_ser_dt_desc_3,'''')
					,vwctl_ser_dt_desc_4 = ISNULL(adctl_ser_dt_desc_4,'''')
					,vwctl_ser_dt_desc_5 = ISNULL(adctl_ser_dt_desc_5,'''')
					,vwctl_ser_dt_desc_6 = ISNULL(adctl_ser_dt_desc_6,'''')
					,vwctl_ser_dt_desc_7 = ISNULL(adctl_ser_dt_desc_7,'''')
					,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
				FROM adctlmst

			')
	END
	-- PT VIEW
	IF  ((SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1 AND EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'pdctlmst'))
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
			AS  
			SELECT  
				vwctl_ser_dt_desc_1 = ISNULL(pdctl_ser_dt_desc_1,'''')
				,vwctl_ser_dt_desc_2 = ISNULL(pdctl_ser_dt_desc_2,'''')
				,vwctl_ser_dt_desc_3 = ISNULL(pdctl_ser_dt_desc_3,'''')
				,vwctl_ser_dt_desc_4 = ISNULL(pdctl_ser_dt_desc_4,'''')
				,vwctl_ser_dt_desc_5 = ''''
				,vwctl_ser_dt_desc_6 = ''''
				,vwctl_ser_dt_desc_7 = ''''
				,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
			FROM pdctlmst
			')
	END
	
END
ELSE
BEGIN
	EXEC ('
			CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
			AS  
			SELECT  
				vwctl_ser_dt_desc_1 = ''''
				,vwctl_ser_dt_desc_2 = ''''
				,vwctl_ser_dt_desc_3 = ''''
				,vwctl_ser_dt_desc_4 = ''''
				,vwctl_ser_dt_desc_5 = ''''
				,vwctl_ser_dt_desc_6 = ''''
				,vwctl_ser_dt_desc_7 = ''''
				,intOriginDegreeOption = 0
			WHERE 1 = 0
		')
			
END

GO
PRINT  'END Create vyuTMOriginDegreeOption '

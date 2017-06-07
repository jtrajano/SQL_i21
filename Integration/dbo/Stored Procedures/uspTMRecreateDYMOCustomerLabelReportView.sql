GO
	PRINT 'START OF CREATING [uspTMRecreateDYMOCustomerLabelReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDYMOCustomerLabelReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDYMOCustomerLabelReportView
GO

CREATE PROCEDURE uspTMRecreateDYMOCustomerLabelReportView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDYMOCustomerLabelReport') 
	BEGIN
		DROP VIEW vyuTMDYMOCustomerLabelReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMDYMOCustomerLabelReport]
				AS

				SELECT 
					strCustomerNumber = vwcus_key COLLATE Latin1_General_CI_AS
					,strCustomerName = (CASE WHEN vwcus_co_per_ind_cp = ''C'' 
																THEN RTRIM(vwcus_last_name) + RTRIM(vwcus_first_name) + RTRIM(vwcus_mid_init) + RTRIM(vwcus_name_suffix)   
															WHEN vwcus_first_name IS NULL OR RTRIM(vwcus_first_name) = ''''  
																THEN     RTRIM(vwcus_last_name) + RTRIM(vwcus_name_suffix)    
															ELSE     RTRIM(vwcus_last_name) + RTRIM(vwcus_name_suffix) + '', '' + RTRIM(vwcus_first_name) + RTRIM(vwcus_mid_init)
															END)  COLLATE Latin1_General_CI_AS
					,strCustomerCity = RTRIM(vwcus_city) COLLATE Latin1_General_CI_AS
					,strCustomerState = RTRIM(vwcus_state) COLLATE Latin1_General_CI_AS
					,strZipCode = RTRIM (vwcus_zip) COLLATE Latin1_General_CI_AS
					,strCustomerCityState = (CASE WHEN vwcus_city IS NOT NULL OR vwcus_city = '''' 
													THEN '', '' + RTRIM (vwcus_state) 
													ELSE RTRIM(vwcus_state) 
											END)
					,strCustomerStateZip = (CASE WHEN vwcus_state IS NOT NULL OR vwcus_state = '''' 
												THEN '' '' + RTRIM (vwcus_zip)
												ELSE RTRIM (vwcus_zip) 
											END) COLLATE Latin1_General_CI_AS
					,strAddress = (CASE WHEN (RTRIM(vwcus_addr) IS NOT NULL AND RTRIM (vwcus_addr2) IS NOT NULL) OR (RTRIM (vwcus_addr) ! = '''' AND RTRIM (vwcus_addr2) ! = '''')
										THEN RTRIM (vwcus_addr) + CHAR (13) + RTRIM (vwcus_addr2) 
								   WHEN RTRIM (vwcus_addr) IS NULL 
										THEN RTRIM (vwcus_addr2) 
								   WHEN RTRIM(vwcus_addr2) IS NULL 
										THEN RTRIM (vwcus_addr) 
								   END) COLLATE Latin1_General_CI_AS
					,strLocation = vwcus_bus_loc_no COLLATE Latin1_General_CI_AS
					,ysnActive = CAST((CASE WHEN vwcus_active_yn = ''Y'' THEN 1 ELSE 0 END) AS BIT)
				FROM vwcusmst 
				')
		END
		ELSE
		BEGIN
			GOTO TMNoOrigin
		END
	END
	ELSE
	BEGIN
		TMNoOrigin:
		EXEC ('
			CREATE VIEW [dbo].[vyuTMDYMOCustomerLabelReport]
			AS

			SELECT 
				strCustomerNumber = Ent.strEntityNo
				,strCustomerName = Ent.strName
				,strCustomerCity = Loc.strCity
				,strCustomerState = Loc.strState
				,strZipCode = Loc.strZipCode
				,strCustomerCityState = (CASE WHEN Loc.strCity IS NOT NULL OR Loc.strCity = '''' 
												THEN '', '' + RTRIM (Loc.strState) 
												ELSE RTRIM(Loc.strState) 
										END)
				,strCustomerStateZip = (CASE WHEN Loc.strState IS NOT NULL OR Loc.strState = '''' 
											THEN '' '' + RTRIM (Loc.strZipCode)
											ELSE RTRIM (Loc.strZipCode) 
										END)
				,strAddress = Loc.strAddress
				,strLocation = Loc.strLocationName
				,ysnActive = Cus.ysnActive
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblEMEntityToContact CustToCon 
				ON Cus.intEntityId = CustToCon.intEntityId 
					and CustToCon.ysnDefaultContact = 1
			INNER JOIN tblEMEntity Con 
				ON CustToCon.intEntityContactId = Con.intEntityId
			INNER JOIN tblEMEntityLocation Loc 
				ON Ent.intEntityId = Loc.intEntityId 
					and Loc.ysnDefaultLocation = 1
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateDYMOCustomerLabelReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateDYMOCustomerLabelReportView'
GO 
	EXEC ('uspTMRecreateDYMOCustomerLabelReportView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateDYMOCustomerLabelReportView'
GO


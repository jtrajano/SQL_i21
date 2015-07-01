GO
	PRINT 'START OF CREATING [uspTMRecreateSalesPersonView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateSalesPersonView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateSalesPersonView
GO

CREATE PROCEDURE uspTMRecreateSalesPersonView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwslsmst')
	BEGIN
		DROP VIEW vwslsmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwslsmst]  
					AS  
					SELECT   	  
						vwsls_slsmn_id   = agsls_slsmn_id  
						,vwsls_name    =  RTRIM(ISNULL(agsls_name, ''''))
						,vwsls_addr1   = agsls_addr1  
						,vwsls_addr2   = agsls_addr2  
						,vwsls_city    = agsls_city  
						,vwsls_state   = agsls_state  
						,vwsls_zip    = agsls_zip  
						,vwsls_country   = CAST(agsls_country AS CHAR(4))  
						,vwsls_phone   = agsls_phone  
						,vwsls_sales_ty_1  = agsls_sales_ty_1  
						,vwsls_sales_ty_2  = agsls_sales_ty_2  
						,vwsls_sales_ty_3  = agsls_sales_ty_3  
						,vwsls_sales_ty_4  = agsls_sales_ty_4  
						,vwsls_sales_ty_5  = agsls_sales_ty_5  
						,vwsls_sales_ty_6  = agsls_sales_ty_6  
						,vwsls_sales_ty_7  = agsls_sales_ty_7  
						,vwsls_sales_ty_8  = agsls_sales_ty_8  
						,vwsls_sales_ty_9  = agsls_sales_ty_9  
						,vwsls_sales_ty_10  = agsls_sales_ty_10  
						,vwsls_sales_ty_11  = agsls_sales_ty_11  
						,vwsls_sales_ty_12  = agsls_sales_ty_12  
						,vwsls_sales_ly_1  = agsls_sales_ly_1  
						,vwsls_sales_ly_2  = agsls_sales_ly_2  
						,vwsls_sales_ly_3  = agsls_sales_ly_3  
						,vwsls_sales_ly_4  = agsls_sales_ly_4  
						,vwsls_sales_ly_5  = agsls_sales_ly_5  
						,vwsls_sales_ly_6  = agsls_sales_ly_6  
						,vwsls_sales_ly_7  = agsls_sales_ly_7  
						,vwsls_sales_ly_8  = agsls_sales_ly_8  
						,vwsls_sales_ly_9  = agsls_sales_ly_9  
						,vwsls_sales_ly_10  = agsls_sales_ly_10  
						,vwsls_sales_ly_11  = agsls_sales_ly_11  
						,vwsls_sales_ly_12  = agsls_sales_ly_12  
						,vwsls_profit_ty_1  = agsls_profit_ty_1  
						,vwsls_profit_ty_2  = agsls_profit_ty_2  
						,vwsls_profit_ty_3  = agsls_profit_ty_3  
						,vwsls_profit_ty_4  = agsls_profit_ty_4  
						,vwsls_profit_ty_5  = agsls_profit_ty_5  
						,vwsls_profit_ty_6  = agsls_profit_ty_6  
						,vwsls_profit_ty_7  = agsls_profit_ty_7  
						,vwsls_profit_ty_8  = agsls_profit_ty_8  
						,vwsls_profit_ty_9  = agsls_profit_ty_9  
						,vwsls_profit_ty_10  = agsls_profit_ty_10  
						,vwsls_profit_ty_11  = agsls_profit_ty_11  
						,vwsls_profit_ty_12  = agsls_profit_ty_12  
						,vwsls_profit_ly_1  = agsls_profit_ly_1  
						,vwsls_profit_ly_2  = agsls_profit_ly_2  
						,vwsls_profit_ly_3  = agsls_profit_ly_3  
						,vwsls_profit_ly_4  = agsls_profit_ly_4  
						,vwsls_profit_ly_5  = agsls_profit_ly_5  
						,vwsls_profit_ly_6  = agsls_profit_ly_6  
						,vwsls_profit_ly_7  = agsls_profit_ly_7  
						,vwsls_profit_ly_8  = agsls_profit_ly_8  
						,vwsls_profit_ly_9  = agsls_profit_ly_9  
						,vwsls_profit_ly_10  = agsls_profit_ly_10  
						,vwsls_profit_ly_11  = agsls_profit_ly_11  
						,vwsls_profit_ly_12  = agsls_profit_ly_12  
						,vwsls_email   = agsls_email  
						,vwsls_textmsg_email = agsls_textmsg_email  
						,vwsls_dispatch_email = CAST(agsls_dispatch_email AS CHAR(4))  
						,vwsls_user_id   = agsls_user_id  
						,vwsls_user_rev_dt  = agsls_user_rev_dt  
						,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
						,intConcurrencyId = 0
					FROM agslsmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwslsmst]  
					AS  
					SELECT  
						vwsls_slsmn_id   = ptsls_slsmn_id  
						,vwsls_name    =  RTRIM(ISNULL(ptsls_name, ''''))
						,vwsls_addr1   = ptsls_addr1  
						,vwsls_addr2   = ptsls_addr2  
						,vwsls_city    = ptsls_city  
						,vwsls_state   = ptsls_state  
						,vwsls_zip    = ptsls_zip  
						,vwsls_country   = CAST(NULL AS CHAR(4))
						,vwsls_phone   = CAST(ptsls_phone AS CHAR(15))  
						,vwsls_sales_ty_1  = ptsls_sales_ty_1  
						,vwsls_sales_ty_2  = ptsls_sales_ty_2  
						,vwsls_sales_ty_3  = ptsls_sales_ty_3  
						,vwsls_sales_ty_4  = ptsls_sales_ty_4  
						,vwsls_sales_ty_5  = ptsls_sales_ty_5  
						,vwsls_sales_ty_6  = ptsls_sales_ty_6  
						,vwsls_sales_ty_7  = ptsls_sales_ty_7  
						,vwsls_sales_ty_8  = ptsls_sales_ty_8  
						,vwsls_sales_ty_9  = ptsls_sales_ty_9  
						,vwsls_sales_ty_10  = ptsls_sales_ty_10  
						,vwsls_sales_ty_11  = ptsls_sales_ty_11  
						,vwsls_sales_ty_12  = ptsls_sales_ty_12  
						,vwsls_sales_ly_1  = ptsls_sales_ly_1  
						,vwsls_sales_ly_2  = ptsls_sales_ly_2  
						,vwsls_sales_ly_3  = ptsls_sales_ly_3  
						,vwsls_sales_ly_4  = ptsls_sales_ly_4  
						,vwsls_sales_ly_5  = ptsls_sales_ly_5  
						,vwsls_sales_ly_6  = ptsls_sales_ly_6  
						,vwsls_sales_ly_7  = ptsls_sales_ly_7  
						,vwsls_sales_ly_8  = ptsls_sales_ly_8  
						,vwsls_sales_ly_9  = ptsls_sales_ly_9  
						,vwsls_sales_ly_10  = ptsls_sales_ly_10  
						,vwsls_sales_ly_11  = ptsls_sales_ly_11  
						,vwsls_sales_ly_12  = ptsls_sales_ly_12  
						,vwsls_profit_ty_1  = ptsls_profit_ty_1  
						,vwsls_profit_ty_2  = ptsls_profit_ty_2  
						,vwsls_profit_ty_3  = ptsls_profit_ty_3  
						,vwsls_profit_ty_4  = ptsls_profit_ty_4  
						,vwsls_profit_ty_5  = ptsls_profit_ty_5  
						,vwsls_profit_ty_6  = ptsls_profit_ty_6  
						,vwsls_profit_ty_7  = ptsls_profit_ty_7  
						,vwsls_profit_ty_8  = ptsls_profit_ty_8  
						,vwsls_profit_ty_9  = ptsls_profit_ty_9  
						,vwsls_profit_ty_10  = ptsls_profit_ty_10  
						,vwsls_profit_ty_11  = ptsls_profit_ty_11  
						,vwsls_profit_ty_12  = ptsls_profit_ty_12  
						,vwsls_profit_ly_1  = ptsls_profit_ly_1  
						,vwsls_profit_ly_2  = ptsls_profit_ly_2  
						,vwsls_profit_ly_3  = ptsls_profit_ly_3  
						,vwsls_profit_ly_4  = ptsls_profit_ly_4  
						,vwsls_profit_ly_5  = ptsls_profit_ly_5  
						,vwsls_profit_ly_6  = ptsls_profit_ly_6  
						,vwsls_profit_ly_7  = ptsls_profit_ly_7  
						,vwsls_profit_ly_8  = ptsls_profit_ly_8  
						,vwsls_profit_ly_9  = ptsls_profit_ly_9  
						,vwsls_profit_ly_10  = ptsls_profit_ly_10  
						,vwsls_profit_ly_11  = ptsls_profit_ly_11  
						,vwsls_profit_ly_12  = ptsls_profit_ly_12  
						,vwsls_email   = CAST(ptsls_email AS CHAR(50))  
						,vwsls_textmsg_email = CAST(ptsls_textmsg_email AS CHAR(50))  
						,vwsls_dispatch_email = CAST(ptsls_dispatch_email AS CHAR(4))  
						,vwsls_user_id   = CAST(NULL AS CHAR(16))  
						,vwsls_user_rev_dt  = 0   
						,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
						,intConcurrencyId = 0
					FROM ptslsmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwslsmst]
			AS
			SELECT  
				vwsls_slsmn_id   = A.strEntityNo
				,vwsls_name    =  A.strName
				,vwsls_addr1   = B.strAddress
				,vwsls_addr2   = ''''
				,vwsls_city    = B.strCity
				,vwsls_state   = B.strState
				,vwsls_zip    = B.strZipCode
				,vwsls_country   = B.strCountry
				,vwsls_phone   = B.strPhone  
				,vwsls_sales_ty_1  = 0.0  
				,vwsls_sales_ty_2  = 0.0
				,vwsls_sales_ty_3  = 0.0
				,vwsls_sales_ty_4  = 0.0
				,vwsls_sales_ty_5  = 0.0
				,vwsls_sales_ty_6  = 0.0
				,vwsls_sales_ty_7  = 0.0
				,vwsls_sales_ty_8  = 0.0
				,vwsls_sales_ty_9  = 0.0
				,vwsls_sales_ty_10  = 0.0
				,vwsls_sales_ty_11  = 0.0
				,vwsls_sales_ty_12  = 0.0
				,vwsls_sales_ly_1  = 0.0
				,vwsls_sales_ly_2  = 0.0
				,vwsls_sales_ly_3  = 0.0
				,vwsls_sales_ly_4  = 0.0
				,vwsls_sales_ly_5  = 0.0
				,vwsls_sales_ly_6  = 0.0
				,vwsls_sales_ly_7  = 0.0
				,vwsls_sales_ly_8  = 0.0
				,vwsls_sales_ly_9  = 0.0
				,vwsls_sales_ly_10  = 0.0
				,vwsls_sales_ly_11  = 0.0
				,vwsls_sales_ly_12  = 0.0
				,vwsls_profit_ty_1  = 0.0
				,vwsls_profit_ty_2  = 0.0
				,vwsls_profit_ty_3  = 0.0
				,vwsls_profit_ty_4  = 0.0
				,vwsls_profit_ty_5  = 0.0
				,vwsls_profit_ty_6  = 0.0
				,vwsls_profit_ty_7  = 0.0
				,vwsls_profit_ty_8  = 0.0
				,vwsls_profit_ty_9  = 0.0
				,vwsls_profit_ty_10  = 0.0
				,vwsls_profit_ty_11  = 0.0
				,vwsls_profit_ty_12  = 0.0
				,vwsls_profit_ly_1  = 0.0
				,vwsls_profit_ly_2  = 0.0
				,vwsls_profit_ly_3  = 0.0
				,vwsls_profit_ly_4  = 0.0
				,vwsls_profit_ly_5  = 0.0
				,vwsls_profit_ly_6  = 0.0
				,vwsls_profit_ly_7  = 0.0
				,vwsls_profit_ly_8  = 0.0
				,vwsls_profit_ly_9  = 0.0
				,vwsls_profit_ly_10  = 0.0
				,vwsls_profit_ly_11  = 0.0
				,vwsls_profit_ly_12  = 0.0
				,vwsls_email   = A.strEmail
				,vwsls_textmsg_email = ''''
				,vwsls_dispatch_email = ''Y''
				,vwsls_user_id   = ''''
				,vwsls_user_rev_dt  = 0   
				,A4GLIdentity  = CAST(A.intEntityId   AS INT)
				,intConcurrencyId = 0
			FROM tblEntity A
			LEFT JOIN tblEntityLocation B
				ON A.intEntityId = B.intEntityId
					AND B.ysnDefaultLocation = 1
			INNER JOIN tblEntityType C
				ON A.intEntityId = C.intEntityId
			WHERE strType = ''Salesperson''
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateSalesPersonView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateSalesPersonView'
GO 
	EXEC ('uspTMRecreateSalesPersonView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateSalesPersonView'
GO
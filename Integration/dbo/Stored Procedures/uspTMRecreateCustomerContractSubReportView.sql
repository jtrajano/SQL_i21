GO
	PRINT 'START OF CREATING [uspTMRecreateCustomerContractSubReportView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateCustomerContractSubReportView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateCustomerContractSubReportView
GO

CREATE PROCEDURE uspTMRecreateCustomerContractSubReportView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMCustomerContractSubReport') 
	BEGIN
		DROP VIEW vyuTMCustomerContractSubReport
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcntmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMCustomerContractSubReport]
				AS  
					SELECT 
						intCustomerId = C.intCustomerID
						,strContractNumber = A.vwcnt_cnt_no COLLATE Latin1_General_CI_AS 
						,dblUnitBalance = A.vwcnt_un_bal
						,dblUnitPrice =  A.vwcnt_un_prc
					FROM vwcntmst A
					INNER JOIN vwcusmst B
						ON A.vwcnt_cus_no = B.vwcus_key
					INNER JOIN tblTMCustomer C
						ON B.A4GLIdentity = C.intCustomerNumber
					WHERE CAST (A.vwcnt_due_rev_dt as datetime)>= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
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
			CREATE VIEW [dbo].[vyuTMCustomerContractSubReport]
			AS  
				SELECT 
					intCustomerId = C.intCustomerID
					,strContractNumber = A.strContractNumber
					,dblUnitBalance = B.dblBalance
					,dblUnitPrice =  B.dblCashPrice
				FROM tblCTContractHeader A
				INNER JOIN tblCTContractDetail B
					ON A.intContractHeaderId = B.intContractHeaderId
				INNER JOIN tblEMEntity B
					ON A.intEntityId = B.intEntityId
				INNER JOIN tblTMCustomer C
					ON B.intEntityId = C.intCustomerNumber
				WHERE DATEADD(dd, DATEDIFF(dd, 0, B.dtmEndDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateCustomerContractSubReportView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateCustomerContractSubReportView'
GO 
	EXEC ('uspTMRecreateCustomerContractSubReportView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateCustomerContractSubReportView'
GO


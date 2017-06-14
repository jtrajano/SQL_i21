
GO
PRINT 'START OF CREATING [uspTMUpdateCustomerBudgetOrigin] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMUpdateCustomerBudgetOrigin]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMUpdateCustomerBudgetOrigin
GO

CREATE PROCEDURE [dbo].[uspTMUpdateCustomerBudgetOrigin]
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
	
	SELECT 
		D.A4GLIdentity
		,dblBudget = SUM(ISNULL(A.dblEstimatedBudget,0.0))
	INTO #tmpCustomerBudget
	FROM tblTMBudgetCalculationSite A
	INNER JOIN tblTMSite B
		ON A.intSiteId = B.intSiteID
	INNER JOIN tblTMCustomer C
		ON C.intCustomerID = B.intCustomerID
	INNER JOIN vwcusmst D
		ON C.intCustomerNumber = D.A4GLIdentity	
	GROUP BY A4GLIdentity
	
	IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	BEGIN
		UPDATE agcusmst
		SET agcus_budget_amt = A.dblBudget
		FROM  #tmpCustomerBudget A
		WHERE A.A4GLIdentity = agcusmst.A4GLIdentity
	END
	
	IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	BEGIN
		UPDATE ptcusmst
		SET  ptcus_budget_amt = A.dblBudget
		FROM  #tmpCustomerBudget A
		WHERE A.A4GLIdentity = ptcusmst.A4GLIdentity
	END
		
END
GO
PRINT 'END OF CREATING [uspTMUpdateCustomerBudgetOrigin] SP'
GO
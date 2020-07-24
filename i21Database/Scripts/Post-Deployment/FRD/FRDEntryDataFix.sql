
--=====================================================================================================================================
-- 	UPDATE NEW FORIEGN KEYS

-- FIELD MAPPING
	-- tblRowDesignCalculation
		-- intRefNoId			=	intRowDetailId
		-- intRefNoCalc			=	intRowDetailRefNo
		-- intRowId
	-- tblFRRowDesignFilterAccount
		-- intRowDetailId		=	intRowDetailId
	-- tblColumnDesignCalculation
		-- intRefNoId			=	intColumnDetailId
		-- intRefNoCalc			=	intColumnDetailRefNo
		-- intColumnId
	-- tblFRColumnDesignSegment
		-- intColumnDetailId	=	intColumnDetailId
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN UPDATE NEW FORIEGN KEYS'
GO

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailId = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoId),
		intRowDetailRefNo = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignCalculation.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)
	WHERE intRowDetailId IS NULL

UPDATE tblFRRowDesignFilterAccount 
	SET intRowDetailId = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowId = tblFRRowDesignFilterAccount.intRowId and tblFRRowDesign.intRefNo = tblFRRowDesignFilterAccount.intRefNoId)
	WHERE intRowDetailId IS NULL

UPDATE tblFRColumnDesignCalculation 
	SET intColumnDetailId = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoId),
		intColumnDetailRefNo = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignCalculation.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignCalculation.intRefNoCalc)
	WHERE intColumnDetailId IS NULL

UPDATE tblFRColumnDesignSegment 
	SET intColumnDetailId = (SELECT TOP 1 intColumnDetailId FROM tblFRColumnDesign WHERE tblFRColumnDesign.intColumnId = tblFRColumnDesignSegment.intColumnId and tblFRColumnDesign.intRefNo = tblFRColumnDesignSegment.intRefNo)
	WHERE intColumnDetailId IS NULL

GO
	PRINT N'END UPDATE NEW FORIEGN KEYS'
GO


--=====================================================================================================================================
-- 	RENAME COLUMN HEADER AND COLUMN DESCRIPTION TO COLUMN NAME
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME'
GO

UPDATE tblFRRowDesign SET strRowType = 'Column Name' WHERE strRowType = 'Description Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Center Align' WHERE strRowType = 'Center Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Left Align' WHERE strRowType = 'Left Title'
UPDATE tblFRRowDesign SET strRowType = 'Row Name - Right Align' WHERE strRowType = 'Right Title'
UPDATE tblFRColumnDesign SET strColumnType = 'Row Name' WHERE strColumnType = 'Row Description'
UPDATE tblFRColumnDesign SET strColumnCaption = 'Column Name' WHERE strColumnCaption = 'Column Header'

GO
	PRINT N'END RENAME'
GO


--=====================================================================================================================================
-- 	REMOVE BALANCE SIDE FOR NON-CALCULATION TYPES
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN REMOVE'
GO

UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strRowType NOT IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts','Current Year Earnings','Retained Earnings','Percentage') AND strBalanceSide <> ''

GO
	PRINT N'END REMOVE'
GO


--=====================================================================================================================================
-- 	RENAME ROW TYPES
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME ROW TYPES'
GO

UPDATE tblFRRowDesign SET strRowType = 'Filter Accounts' WHERE strRowType = 'Calculation'
UPDATE tblFRRowDesign SET strRowType = 'Row Calculation' WHERE strRowType like '%Total Calculation%'

GO
	PRINT N'END RENAME ROW TYPES'
GO


--=====================================================================================================================================
-- 	DROP TABLE tblFRGroupsDetail
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN DROP TABLE tblFRGroupsDetail'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRGroupsDetail]') AND type in (N'U')) 
BEGIN
	DROP TABLE tblFRGroupsDetail
END

GO
	PRINT N'END DROP TABLE tblFRGroupsDetail'
GO


--=====================================================================================================================================
-- 	SET DEFAULT VALUE FOR NEW FIELD
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN SET VALUE'
GO

UPDATE tblFRRowDesign SET strSource = '' 
	WHERE strRowType NOT IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts','Current Year Earnings','Retained Earnings') AND strSource IS NULL

UPDATE tblFRRowDesign SET strSource = 'Column' 
	WHERE strRowType IN ('Calculation','Hidden','Cash Flow Activity','Filter Accounts','Current Year Earnings','Retained Earnings') AND strSource IS NULL

GO
	PRINT N'END SET VALUE'
GO


--=====================================================================================================================================
-- 	RENAME COLUMN TYPE
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME COLUMN TYPE'
GO

UPDATE tblFRColumnDesign SET strColumnType = 'GL Amounts' 
	WHERE strColumnType IN ('Calculation','Segment Filter')

GO
	PRINT N'END RENAME COLUMN TYPE'
GO


--=====================================================================================================================================
-- 	RENAME REPORT TYPE
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN RENAME REPORT TYPE'
GO

UPDATE tblFRReport SET strReportType = 'Single' 
	WHERE strReportType = 'Report'

GO
	PRINT N'END RENAME REPORT TYPE'
GO


--=====================================================================================================================================
-- 	FIX: NULL value to EMPTY String
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN NULL TO EMPTY STRING'
GO

UPDATE tblFRRowDesign SET strDescription = '' 
	WHERE strDescription IS NULL
UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strBalanceSide IS NULL
UPDATE tblFRRowDesign SET strRelatedRows = '' 
	WHERE strRelatedRows IS NULL
UPDATE tblFRRowDesign SET strAccountsUsed = '' 
	WHERE strAccountsUsed IS NULL
UPDATE tblFRRowDesign SET strOverrideFormatMask = '' 
	WHERE strOverrideFormatMask IS NULL

GO
	PRINT N'END NULL TO EMPTY STRING'
GO


--=====================================================================================================================================
-- 	FIX: RELATIONSHIP TO SEGMENT FILTER ID
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT 'BEGIN FRD UPDATE SEGMENT CODE'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentFilterGroupId' AND OBJECT_ID = OBJECT_ID(N'tblFRColumnDesign')) 
BEGIN

	UPDATE tblFRColumnDesign SET intSegmentFilterGroupId = NULL WHERE intSegmentFilterGroupId NOT IN (SELECT intSegmentFilterGroupId FROM tblFRSegmentFilterGroup) AND intSegmentFilterGroupId IS NOT NULL

END
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intSegmentCode' AND OBJECT_ID = OBJECT_ID(N'tblFRReport')) 
BEGIN

	UPDATE tblFRReport SET intSegmentCode = NULL WHERE intSegmentCode NOT IN (SELECT intSegmentFilterGroupId FROM tblFRSegmentFilterGroup) AND intSegmentCode IS NOT NULL

END
GO

GO
	PRINT 'END FRD UPDATE SEGMENT CODE'
GO


--=====================================================================================================================================
-- 	FIX: NULL value to EMPTY String
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN NULL TO EMPTY STRING'
GO

UPDATE tblFRRowDesign SET strDescription = '' 
	WHERE strDescription IS NULL
UPDATE tblFRRowDesign SET strBalanceSide = '' 
	WHERE strBalanceSide IS NULL
UPDATE tblFRRowDesign SET strRelatedRows = '' 
	WHERE strRelatedRows IS NULL
UPDATE tblFRRowDesign SET strAccountsUsed = '' 
	WHERE strAccountsUsed IS NULL

GO
	PRINT N'END NULL TO EMPTY STRING'
GO


--=====================================================================================================================================
-- 	FIX: ORPHAN(NULL) ID
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'BEGIN FIX ORPHAN(NULL) ID'
GO

UPDATE tblFRRowDesignCalculation 
	SET intRowDetailRefNo = (SELECT TOP 1 intRowDetailId FROM tblFRRowDesign WHERE 
			tblFRRowDesign.intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign B WHERE B.intRowDetailId =tblFRRowDesignCalculation.intRowDetailId) 
				and tblFRRowDesign.intRefNo = tblFRRowDesignCalculation.intRefNoCalc)
		WHERE intRowDetailRefNo IS NULL

GO
	PRINT N'END FIX ORPHAN(NULL) ID'
GO


--=====================================================================================================================================
-- 	MOVE GL BUDGET DATA TO FRD BUDGET TABLES
---------------------------------------------------------------------------------------------------------------------------------------

--GO
--	PRINT N'MOVE GL BUDGET TO FRD BUDGET TABLES'
--GO
 
--SET IDENTITY_INSERT tblFRBudgetCode ON
--GO

--INSERT INTO tblFRBudgetCode (intBudgetCode,ysnDefault,strBudgetCode,strBudgetEnglishDescription,intConcurrencyId)
--SELECT  intBudgetCode
--		,ysnDefault
--		,strBudgetCode
--		,strBudgetEnglishDescription + '- GL IMPORTED'
--		,1 
--FROM tblGLBudgetCode
--WHERE strBudgetEnglishDescription NOT LIKE '%GL IMPORTED%'

--SET IDENTITY_INSERT tblFRBudgetCode OFF
--GO

--CREATE TABLE #Budgets (
--	[cntId] [int] IDENTITY(1, 1) PRIMARY KEY,
--	[intBudgetId] [int],
--	[intBudgetCode] [int],
--	[intFiscalYearId] [int],
--	[intAccountId] [int],
--	[curBudget] [numeric](18,6),
--	[dtmStartDate] [datetime],
--	[dtmEndDate] [datetime]	
--);

--SELECT * INTO #BudgetCode FROM tblGLBudgetCode WHERE strBudgetEnglishDescription NOT LIKE '%GL IMPORTED%'

--WHILE EXISTS(SELECT 1 FROM #BudgetCode)
--BEGIN 
--	DECLARE @intBudgetCode as INT = (SELECT TOP 1 intBudgetCode FROM #BudgetCode)

--	INSERT INTO #Budgets SELECT intBudgetId, intBudgetCode, intFiscalYearId, intAccountId, curBudget, dtmStartDate, dtmEndDate FROM tblGLBudget WHERE intBudgetCode = @intBudgetCode	

--	WHILE EXISTS(SELECT 1 FROM #Budgets)
--	BEGIN
--		DECLARE @cntLine as INT = 1
--		DECLARE @intAccountId_OLD as INT = 0
--		DECLARE @SQLString as NVARCHAR(MAX) = ''
--		DECLARE @fieldBudgetPeriod as NVARCHAR(MAX) = ''
--		DECLARE @valueBudgetPeriod as NVARCHAR(MAX) = ''

--		DECLARE @intBudgetId as INT = (SELECT TOP 1 intBudgetId FROM #Budgets)
--		DECLARE @intAccountId as INT = (SELECT TOP 1 intAccountId FROM #Budgets WHERE intBudgetId = @intBudgetId)

--		WHILE EXISTS(SELECT 1 FROM #Budgets WHERE intAccountId = @intAccountId)
--		BEGIN			
--			SET @intBudgetId = (SELECT TOP 1 intBudgetId FROM #Budgets WHERE intAccountId = @intAccountId)

--			DECLARE @intFiscalYearId as INT = (SELECT TOP 1 intFiscalYearId FROM #Budgets WHERE intAccountId = @intAccountId)
--			DECLARE @dtmStartDate as DATETIME = (SELECT TOP 1 dtmStartDate FROM #Budgets WHERE intAccountId = @intAccountId)
--			DECLARE @dtmEndDate as DATETIME = (SELECT TOP 1 dtmEndDate FROM #Budgets WHERE intAccountId = @intAccountId)
--			DECLARE @curBudget as NUMERIC (18,6) = (SELECT TOP 1 curBudget FROM #Budgets WHERE intAccountId = @intAccountId)
--			DECLARE @intGLFiscalYearPeriodId as INT = (SELECT TOP 1 intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod WHERE dtmStartDate = @dtmStartDate and dtmEndDate = @dtmEndDate)
			
--			SET @fieldBudgetPeriod = @fieldBudgetPeriod + ',dblBudget' + CAST(@cntLine as NVARCHAR(10)) + ',intPeriod' + CAST(@cntLine as NVARCHAR(10))
--			SET @valueBudgetPeriod = @valueBudgetPeriod + ',' + CAST(@curBudget as NVARCHAR(50)) + ',' + CAST(@intGLFiscalYearPeriodId as NVARCHAR(20))

--			SET @cntLine = @cntLine + 1
--			DELETE #Budgets WHERE intBudgetId = @intBudgetId

--			IF (NOT EXISTS(SELECT 1 FROM #Budgets WHERE intAccountId = @intAccountId) OR @cntLine > 12)
--			BEGIN
--				SET @SQLString = 'INSERT INTO tblFRBudget (intBudgetCode,intAccountId' + @fieldBudgetPeriod + ',dtmDate,intConcurrencyId) ' +
--									' SELECT ' + CAST(@intBudgetCode as NVARCHAR(10)) + ',' + CAST(@intAccountId as NVARCHAR(10)) + @valueBudgetPeriod + ',CAST(''' + CAST(GETDATE() as NVARCHAR(50))  + ''' as DATETIME), 1'				
--				EXEC(@SQLString)

--				UPDATE tblFRBudgetCode SET intFiscalYearId = @intFiscalYearId WHERE intBudgetCode = @intBudgetCode

--				IF(@cntLine > 12)
--				BEGIN
--					SET @cntLine = 1
--					BREAK
--				END
--			END
--		END	
--	END

--	DELETE #BudgetCode WHERE intBudgetCode = @intBudgetCode
--END

--UPDATE tblGLBudgetCode SET strBudgetEnglishDescription = strBudgetEnglishDescription + '- GL IMPORTED' WHERE strBudgetEnglishDescription NOT LIKE '%GL IMPORTED%'

--DROP TABLE #Budgets
--DROP TABLE #BudgetCode

--GO
--	PRINT N'MOVE GL BUDGET TO FRD BUDGET TABLES'
--GO


--=====================================================================================================================================
-- 	ROW: CORRECT ORPHAN REFNO CALC
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE tblFRRowDesignCalculation SET intRefNoCalc = (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
									    ,intRowId = (SELECT TOP 1 intRowId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)
							WHERE intRowDetailRefNo IN (SELECT intRowDetailId FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo) 
							   AND intRefNoCalc NOT IN (SELECT intRefNo FROM tblFRRowDesign WHERE tblFRRowDesign.intRowDetailId = tblFRRowDesignCalculation.intRowDetailRefNo)


--=====================================================================================================================================
-- 	ROW: HIDDEN OPTION
---------------------------------------------------------------------------------------------------------------------------------------

UPDATE tblFRRowDesign SET ysnHidden = 0 WHERE strRowType <> 'Hidden' AND ysnHidden IS NULL
UPDATE tblFRRowDesign SET ysnHidden = 1 WHERE strRowType = 'Hidden' AND ysnHidden IS NULL
UPDATE tblFRRowDesign SET strRowType = 'Filter Accounts' WHERE strRowType = 'Hidden'


--=====================================================================================================================================
-- 	COLUMN: OFFSET DATE
---------------------------------------------------------------------------------------------------------------------------------------

update tblFRColumn set dtmRunDate = GETDATE() WHERE dtmRunDate IS NULL

UPDATE tblFRColumnDesign SET strStartOffset = 'Custom', strEndOffset = 'Custom' WHERE strFilterType = 'Custom' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '0' WHERE strFilterType = 'As Of' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = 'EOY-1yr' WHERE strFilterType = 'As Of Previous Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = 'EOY' WHERE strFilterType = 'As Of Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '12' WHERE strFilterType = 'As Of Next Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '-3' WHERE strFilterType = 'As Of Previous Quarter' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '3' WHERE strFilterType = 'As Of Next Quarter' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '0' WHERE strFilterType = 'As Of This Quarter' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY-1yr', strEndOffset = 'EOY-1yr' WHERE strFilterType = 'Previous Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY', strEndOffset = 'EOY' WHERE strFilterType = 'Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Fiscal Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '-1' WHERE strFilterType = 'As Of Previous Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '0' WHERE strFilterType = 'As Of This Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '1' WHERE strFilterType = 'As Of Next Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = 'EOY-1yr' WHERE strFilterType = 'As Of Previous Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = 'EOY' WHERE strFilterType = 'As Of This Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOT', strEndOffset = '12' WHERE strFilterType = 'As Of Next Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '-1', strEndOffset = '-1' WHERE strFilterType = 'Previous Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'This Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '1', strEndOffset = '1' WHERE strFilterType = 'Next Month' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY-1yr', strEndOffset = 'EOY-1yr' WHERE strFilterType = 'Previous Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY', strEndOffset = 'EOY' WHERE strFilterType = 'This Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Year' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY-1yr', strEndOffset = '-12' WHERE strFilterType = 'Previous Fiscal Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY', strEndOffset = '0' WHERE strFilterType = 'Fiscal Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Fiscal Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '-12', strEndOffset = '-12' WHERE strFilterType = 'Previous Year Quarter To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Quarter To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Year Quarter To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY-1yr', strEndOffset = '-12' WHERE strFilterType = 'Previous Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = 'BOY', strEndOffset = '0' WHERE strFilterType = 'Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Year To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '-12', strEndOffset = '-12' WHERE strFilterType = 'Previous Year Month To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Month To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '12', strEndOffset = '12' WHERE strFilterType = 'Next Year Month To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'As Of Previous Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'As Of This Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'As Of Next Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Previous Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'This Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Next Period' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Previous Year Period To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Period To Date' AND strStartOffset IS NULL
UPDATE tblFRColumnDesign SET strStartOffset = '0', strEndOffset = '0' WHERE strFilterType = 'Next Year Period To Date' AND strStartOffset IS NULL


--=====================================================================================================================================
-- 	ROW: DEFAULT DATA FOR ROW ACCOUNTS TYPE (strAccountsType)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'DEFAULT DATA FOR ROW ACCOUNTS TYPE (strAccountsType)'
GO

CREATE TABLE #tempFRDGLAccount (
		[strAccountType]	NVARCHAR(MAX)
	);

SELECT * INTO #tempFRDRowDesign FROM tblFRRowDesign WHERE strAccountsType IS NULL AND LEN(strAccountsUsed) > 3

WHILE EXISTS(SELECT 1 FROM #tempFRDRowDesign)
	BEGIN
		DECLARE @RowDetailID INT  = (SELECT TOP 1 intRowDetailId FROM #tempFRDRowDesign)
		DECLARE @AccountsUsed NVARCHAR(MAX)  = (SELECT TOP 1 strAccountsUsed FROM #tempFRDRowDesign)
		DECLARE @queryString NVARCHAR(MAX) = ''

		SET @queryString = 'SELECT TOP 1 strAccountType FROM vyuGLAccountView where ' + REPLACE(REPLACE(REPLACE(REPLACE(@AccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ORDER BY strAccountId'

		BEGIN TRY
			INSERT INTO #tempFRDGLAccount
			EXEC (@queryString)
		END TRY
		BEGIN CATCH
		END CATCH;

		IF((ISNULL((SELECT TOP 1 1 FROM #tempFRDGLAccount),0) < 1) and (CHARINDEX('strAccountGroup',@queryString) > 0) and (CHARINDEX(' Or ',@queryString) < 1))
		BEGIN
			SET @queryString = 'SELECT TOP 1 strAccountType FROM tblGLAccountGroup where ' + REPLACE(REPLACE(REPLACE(REPLACE(@AccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription')

			BEGIN TRY
				INSERT INTO #tempFRDGLAccount
				EXEC (@queryString)
			END TRY
			BEGIN CATCH
			END CATCH;
		END
		
		IF(ISNULL((SELECT TOP 1 1 FROM #tempFRDGLAccount),0) < 1)
		BEGIN
			UPDATE tblFRRowDesign SET strAccountsType = 'BS' WHERE intRowDetailId = @RowDetailID
		END

		WHILE EXISTS(SELECT 1 FROM #tempFRDGLAccount)
		BEGIN
			DECLARE @strAccountType NVARCHAR(MAX) = ''
			SELECT TOP 1 @strAccountType = [strAccountType] FROM #tempFRDGLAccount

			IF(@strAccountType = 'Asset')
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = 'BS' WHERE intRowDetailId = @RowDetailID
			END
			ELSE IF(@strAccountType = 'Equity')
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = 'BS' WHERE intRowDetailId = @RowDetailID
			END
			ELSE IF(@strAccountType = 'Expense')
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = 'IS' WHERE intRowDetailId = @RowDetailID
			END
			ELSE IF(@strAccountType = 'Liability')
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = 'BS' WHERE intRowDetailId = @RowDetailID
			END
			ELSE IF(@strAccountType = 'Revenue')
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = 'IS' WHERE intRowDetailId = @RowDetailID
			END
			ELSE
			BEGIN
				UPDATE tblFRRowDesign SET strAccountsType = '' WHERE intRowDetailId = @RowDetailID
			END
			
			DELETE #tempFRDGLAccount
		END

		DELETE #tempFRDRowDesign WHERE intRowDetailId = @RowDetailID
	END
	
DROP TABLE #tempFRDRowDesign
DROP TABLE #tempFRDGLAccount

GO
	PRINT N'DEFAULT DATA FOR ROW ACCOUNTS TYPE (strAccountsType)'
GO


--=====================================================================================================================================
-- 	ROW: CHANGE Current Year Earnings and  Retained Earnings to  Filter Accounts
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'CHANGE Current Year Earnings and  Retained Earnings to  Filter Accounts'
GO

UPDATE tblFRRowDesign SET strRowType = 'Filter Accounts' WHERE strRowType IN ('Current Year Earnings','Retained Earnings')

GO
	PRINT N'CHANGE Current Year Earnings and  Retained Earnings to  Filter Accounts'
GO

--=====================================================================================================================================
-- 	ROW: DEFAULT Date Override (strDateOverride) to NONE
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'DEFAULT Date Override (strDateOverride) to NONE'
GO

UPDATE tblFRRowDesign SET strDateOverride = 'None' WHERE strRowType IN ('Filter Accounts','Cash Flow Activity','Percentage') and (strDateOverride IS NULL or strDateOverride = '')

GO
	PRINT N'DEFAULT Date Override (strDateOverride) to NONE'
GO

--=====================================================================================================================================
-- 	REPORT BUILDER: DEFAULT Rounding Option (ysnRoundingOption) to 0
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'DEFAULT Rounding Option (ysnRoundingOption) to 0'
GO

UPDATE tblFRReport SET ysnRoundingOption = 0 WHERE ysnRoundingOption IS NULL

GO
	PRINT N'DEFAULT Rounding Option (ysnRoundingOption) to 0'
GO

--=====================================================================================================================================
-- 	COLUMN DESIGNER: Set existing data (strColumnType) to User Defined
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'Set existing data (strColumnType) to User Defined'
GO

UPDATE tblFRColumn SET strColumnType = 'User Defined' WHERE strColumnType IS NULL

GO
	PRINT N'Set existing data (strColumnType) to User Defined'
GO

--=====================================================================================================================================
-- 	ROW DESIGNER: Set existing data (strRowType) value from 'Percentage' to 'Filter Accounts' with (strPercentage) = (strRelatedRows)
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'Set existing data (strRowType) value from Percentage to Filter Accounts with (strPercentage) = (strRelatedRows)'
GO

UPDATE tblFRRowDesign SET strPercentage = strRelatedRows WHERE strRowType = 'Percentage'
UPDATE tblFRRowDesign SET strRelatedRows = '' WHERE strRowType = 'Percentage'
UPDATE tblFRRowDesign SET strRowType = 'Filter Accounts' WHERE strRowType = 'Percentage'
UPDATE tblFRRowDesign SET strPercentage = '' WHERE strPercentage IS NULL

GO
	PRINT N'Set existing data (strRowType) value from Percentage to Filter Accounts with (strPercentage) = (strRelatedRows)'
GO

--=====================================================================================================================================
-- 	SEGMENT FILTER GROUP: Insert System Data
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'Insert System Data'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM tblFRSegmentFilterGroup WHERE strSegmentFilterGroup = 'All Segment') 
BEGIN
	INSERT INTO tblFRSegmentFilterGroup (strSegmentFilterGroup,strFilterString,strSegmentString) values ('All Segment','','')
END

GO
	PRINT N'Insert System Data'
GO

--=====================================================================================================================================
-- 	BUDGET SUMMARY: Insert Budget Data to Summary Table
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'Insert Budget Data'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblFRBudgetSummary]') AND type in (N'U')) 
BEGIN
	SELECT * INTO #FRDBudgetCode FROM tblFRBudgetCode where tblFRBudgetCode.intBudgetCode NOT IN (SELECT DISTINCT intBudgetCode FROM tblFRBudgetSummary)

	WHILE EXISTS(SELECT 1 FROM #FRDBudgetCode)
	BEGIN 
		DECLARE @intBudgetCode as INT = (SELECT TOP 1 intBudgetCode FROM #FRDBudgetCode)	

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget1, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod1) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod1) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget2, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod2) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod2) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget3, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod3) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod3) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget4, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod4) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod4) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget5, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod5) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod5) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget6, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod6) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod6) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget7, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod7) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod7) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget8, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod8) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod8) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget9, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod9) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod9) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget10, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod10) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod10) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget11, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod11) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod11) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget12, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod12) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod12) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode

		INSERT INTO tblFRBudgetSummary (intBudgetCode, intBudgetId, intAccountId, dblBalance, dtmStartDate, dtmEndDate)
		SELECT intBudgetCode, 
			   intBudgetId, 
			   intAccountId, 
			   dblBudget13, 
			   (select top 1 dtmStartDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod13) as dtmStartDate,  
			   (select top 1 dtmEndDate from tblGLFiscalYearPeriod where intGLFiscalYearPeriodId = intPeriod13) as dtmEndDate
		FROM tblFRBudget where intBudgetCode = @intBudgetCode and intPeriod13 IS NOT NULL

		DELETE #FRDBudgetCode WHERE intBudgetCode = @intBudgetCode

	END

	DROP TABLE #FRDBudgetCode

END

GO
	PRINT N'Insert Budget Data'
GO

--=====================================================================================================================================
-- 	ROW DESIGNER: UPDATE NULL AND EMPTY
---------------------------------------------------------------------------------------------------------------------------------------

GO
	PRINT N'UPDATE Default Value'
GO


UPDATE tblFRRowDesign SET strAccountsType = 'BS'
WHERE (strAccountsType = '' or strAccountsType IS NULL) and strRowType IN ('Filter Accounts', 'Cash Flow Activity')

UPDATE tblFRRowDesign SET strSource = 'Column' 
WHERE (strSource = '' or strSource IS NULL) and strRowType IN ('Filter Accounts', 'Cash Flow Activity')


GO
	PRINT N'UPDATE Default Value'
GO
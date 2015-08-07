CREATE PROCEDURE [dbo].[uspFRDCashFlowStatementDetail]
	@intRowId				AS INT	= ''		
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @intRowDetailId INT
DECLARE @intRefNo INT = 1
DECLARE @intSort INT = 1
DECLARE @strRelatedRows NVARCHAR(MAX) = ''

DECLARE @intRowDetailId_CY INT
DECLARE @intRefNo_CY INT

DECLARE @strAccountId NVARCHAR(150)
DECLARE @strAccountDescription NVARCHAR(500)
DECLARE @strRowDescription NVARCHAR(500)
DECLARE @strRowFilter NVARCHAR(500)

CREATE TABLE #tmpRelatedRows (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);
CREATE TABLE #tmpRelatedRowsHidden (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);
CREATE TABLE #tmpRelatedRowsCashFlow (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Line',	'',	'', '',	'',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Column Name',	'',	'', '',	'',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;


--++++++++++++++++++++++++++++++++++++++++++++++
--				DEBIT SECTION
--++++++++++++++++++++++++++++++++++++++++++++++
WITH tmpAccountType AS
(
  SELECT 'Asset' AS AccountType, 1 AS cntID, 'Debit' as BalanceSide
)
SELECT * INTO #TempDebit FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempDebit)
BEGIN 
	
	DECLARE @BalanceSide NVARCHAR(50)
	DECLARE @strAccountType NVARCHAR(50)

	SELECT TOP 1 @strAccountType = AccountType, @BalanceSide = BalanceSide FROM #TempDebit ORDER BY cntID
	SELECT * INTO #TempGLAccountDebit FROM vyuGLAccountView where strAccountType = @strAccountType ORDER BY strAccountId
	
	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, 'Debits:', 'Row Name - Left Align', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort
	
	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	WHILE EXISTS(SELECT 1 FROM #TempGLAccountDebit)
	BEGIN

		SET @strAccountId = ''
		SET @strAccountDescription = ''
		SET @strRowDescription = ''
		SET @strRowFilter = ''

		SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription FROM #TempGLAccountDebit ORDER BY strAccountId

		SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
		SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Filter Accounts', @BalanceSide, 'Column', '', @strRowFilter, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
		
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'
				
		DELETE #TempGLAccountDebit WHERE strAccountId = @strAccountId

		IF (SELECT TOP 1 1 FROM #TempGLAccountDebit) = 1
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')
				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1
			END
		ELSE
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')

				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1			

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Row Calculation', '', '', @strRelatedRows, '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort	
				
				SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

				WHILE EXISTS(SELECT 1 FROM #tmpRelatedRows)
				BEGIN
					DECLARE @intSort_Calculation INT = 1
					DECLARE @cntID INT
					DECLARE @intRefNo_Calculation INT
					DECLARE @strAction NVARCHAR(150) = ''
					DECLARE @intRowDetailRefNo INT
					
					SELECT TOP 1 @cntID = cntID, @intRefNo_Calculation = intRefNo, @strAction = strAction FROM #tmpRelatedRows ORDER BY cntID
					SELECT TOP 1 @intRowDetailRefNo = intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId AND intRefNo = @intRefNo_Calculation

					EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailRefNo, @intRowId, @intRefNo, @intRefNo_Calculation, @strAction, @intSort_Calculation	

					DELETE FROM #tmpRelatedRows WHERE cntID = @cntID
				END

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	
				SET @strRelatedRows = ''

			END
	END

	DROP TABLE #TempGLAccountDebit

	DELETE #TempDebit WHERE AccountType = @strAccountType
END

DROP TABLE #TempDebit;


--++++++++++++++++++++++++++++++++++++++++++++++
--				CREDIT SECTION
--++++++++++++++++++++++++++++++++++++++++++++++
WITH tmpAccountType AS
(
  SELECT 'Liability' AS AccountType, 1 AS cntID, 'Credit' as BalanceSide UNION
  SELECT 'Equity', 2, 'Credit'
)
SELECT * INTO #TempCredit FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempCredit)
BEGIN 
	
	SET @BalanceSide = ''
	SET @strAccountType = ''

	SELECT TOP 1 @strAccountType = AccountType, @BalanceSide = BalanceSide FROM #TempCredit ORDER BY cntID
	SELECT * INTO #TempGLAccountCredit FROM vyuGLAccountView where strAccountType = @strAccountType ORDER BY strAccountId
	
	IF(@strAccountType = 'Liability')
	BEGIN
		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, 'Credits:', 'Row Name - Left Align', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort			
	END

	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	WHILE EXISTS(SELECT 1 FROM #TempGLAccountCredit)
	BEGIN

		SET @strAccountId = ''
		SET @strAccountDescription = ''
		SET @strRowDescription = ''
		SET @strRowFilter = ''

		SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription FROM #TempGLAccountCredit ORDER BY strAccountId

		SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
		SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Filter Accounts', @BalanceSide, 'Column', '', @strRowFilter, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
		
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'
				
		DELETE #TempGLAccountCredit WHERE strAccountId = @strAccountId

		IF (SELECT TOP 1 1 FROM #TempGLAccountCredit) = 1
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')
				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1
			END
		ELSE IF(@strAccountType = 'Equity')
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')

				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '     Current Year Earnings', 'Filter Accounts', 'Credit', 'Column', '', '[Type]  =  ''Revenue'' Or [Type]  =  ''Expense''', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
				SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
				EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'Type', '=', 'Revenue', '', 'Or'
				EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'Type', '=', 'Expense', '', 'Or'

				SET @intRowDetailId_CY = @intRowDetailId
				SET @intRefNo_CY = @intRefNo

				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')
				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1					

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Row Calculation', '', '', @strRelatedRows, '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort	

				SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

				WHILE EXISTS(SELECT 1 FROM #tmpRelatedRows)
				BEGIN
					SET @intSort_Calculation = 1
					SET @cntID = 0 
					SET @intRefNo_Calculation = 0
					SET @strAction = ''
					SET @intRowDetailRefNo = 0
					
					SELECT TOP 1 @cntID = cntID, @intRefNo_Calculation = intRefNo, @strAction = strAction FROM #tmpRelatedRows ORDER BY cntID
					SELECT TOP 1 @intRowDetailRefNo = intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId AND intRefNo = @intRefNo_Calculation

					EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailRefNo, @intRowId, @intRefNo, @intRefNo_Calculation, @strAction, @intSort_Calculation	

					DELETE FROM #tmpRelatedRows WHERE cntID = @cntID
				END

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	
				SET @strRelatedRows = ''

			END
	END

	DROP TABLE #TempGLAccountCredit

	DELETE #TempCredit WHERE AccountType = @strAccountType
END

DROP TABLE #TempCredit;


--++++++++++++++++++++++++++++++++++++++++++++++
--				CASH FLOW SECTION
--++++++++++++++++++++++++++++++++++++++++++++++
WITH tmpCashFlowType AS
(
  SELECT 'Operations' AS CashFlowType, 1 AS cntID, '' as BalanceSide UNION
  SELECT 'Investments', 2, '' UNION
  SELECT 'Finance', 3, ''
)
SELECT * INTO #TempCashFlow FROM tmpCashFlowType

WHILE EXISTS(SELECT 1 FROM #TempCashFlow)
BEGIN 	
	SET @BalanceSide = ''
	SET @strAccountType = ''

	SELECT TOP 1 @strAccountType = CashFlowType, @BalanceSide = BalanceSide FROM #TempCashFlow ORDER BY cntID
	SELECT * INTO #TempGLAccountCashFlow FROM vyuGLAccountView where intAccountId IN (SELECT intAccountId FROM tblGLAccount WHERE strCashFlow = @strAccountType) AND strAccountType NOT IN ('Expense','Revenue') ORDER BY strAccountId
	
	IF(@strAccountType = 'Operations')
	BEGIN
		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, 'Cash Flow from Operating Activities:', 'Row Name - Left Align', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort
	
		SET @intRefNo = @intRefNo + 1
		SET @intSort = @intSort + 1

		DECLARE @netFormula NVARCHAR(100) = 'R' + CAST(@intRefNo_CY as NVARCHAR(100))

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '     Net Income', 'Row Calculation', '', '', @netFormula, '', 1, 1, 0, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
				
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_CY, @intRowId, @intRefNo, @intRefNo_CY, @strAction, 1	

		INSERT INTO #tmpRelatedRowsCashFlow (intRefNo, strAction) VALUES (@intRefNo, '+')
		SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			

	END
	ELSE IF(@strAccountType = 'Investments')
	BEGIN
		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, 'Cash Flow from Investing Activities:', 'Row Name - Left Align', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort
	END
	ELSE IF(@strAccountType = 'Finance')
	BEGIN
		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, 'Cash Flow from Financing Activities:', 'Row Name - Left Align', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort
	END		

	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	WHILE EXISTS(SELECT 1 FROM #TempGLAccountCashFlow)
	BEGIN
		SET @strAccountId = ''
		SET @strAccountDescription = ''
		SET @strRowDescription = ''
		SET @strRowFilter = ''
		DECLARE @AccountType AS NVARCHAR(100) = ''

		SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription, @AccountType = strAccountType FROM #TempGLAccountCashFlow ORDER BY strAccountId

		SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
		SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''
		SET @BalanceSide = 'Credit'

		IF(@AccountType = 'Asset' or @AccountType = 'Expense')
		BEGIN
			SET @BalanceSide = 'Debit'
		END

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Cash Flow Activity', @BalanceSide, 'Column', '', @strRowFilter, 1, 1, 0, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
		
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'
		
		DELETE #TempGLAccountCashFlow WHERE strAccountId = @strAccountId

		IF (SELECT TOP 1 1 FROM #TempGLAccountCashFlow) = 1
			BEGIN
				INSERT INTO #tmpRelatedRowsCashFlow (intRefNo, strAction) VALUES (@intRefNo, '+')
				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1
			END
		ELSE
			BEGIN
				INSERT INTO #tmpRelatedRowsCashFlow (intRefNo, strAction) VALUES (@intRefNo, '')

				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1
								
				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	
				--SET @strRelatedRows = ''
			END
	END

	DROP TABLE #TempGLAccountCashFlow

	DELETE #TempCashFlow WHERE CashFlowType = @strAccountType
END

DROP TABLE #TempCashFlow


--++++++++++++++++++++++++++++++++++++++++++++++
--				SUMMARY
--++++++++++++++++++++++++++++++++++++++++++++++
EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', 1, 1, 0, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort								

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1			

IF(@strRelatedRows like '% + ')
BEGIN
	SET @strRelatedRows = SUBSTRING(@strRelatedRows,1,LEN(@strRelatedRows)-1)
END

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Row Calculation', '', '', @strRelatedRows, '', 1, 1, 0, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort	
				
SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

WHILE EXISTS(SELECT 1 FROM #tmpRelatedRowsCashFlow)
BEGIN
	SET @intSort_Calculation = 1
	SET @cntID = 1
	SET @intRefNo_Calculation = 1
	SET @strAction = ''
	SET @intRowDetailRefNo = 1
					
	SELECT TOP 1 @cntID = cntID, @intRefNo_Calculation = intRefNo, @strAction = strAction FROM #tmpRelatedRowsCashFlow ORDER BY cntID
	SELECT TOP 1 @intRowDetailRefNo = intRowDetailId FROM tblFRRowDesign WHERE intRowId = @intRowId AND intRefNo = @intRefNo_Calculation

	EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailRefNo, @intRowId, @intRefNo, @intRefNo_Calculation, @strAction, @intSort_Calculation	

	DELETE FROM #tmpRelatedRowsCashFlow WHERE cntID = @cntID
END

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1	

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', 1, 1, 0, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1	

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDCashFlowStatementDetail] 178

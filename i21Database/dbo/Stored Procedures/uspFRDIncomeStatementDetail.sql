CREATE PROCEDURE [dbo].[uspFRDIncomeStatementDetail]
	@intRowId				AS INT
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

DECLARE @intRowDetailId_Expense INT
DECLARE @intRowDetailId_Revenue INT

DECLARE @intRefNo_Expense INT
DECLARE @intRefNo_Revenue INT

CREATE TABLE #tmpRelatedRows (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Column Name',	'',	'',	'',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;

WITH tmpAccountType AS
(
  SELECT 'Expense' AS AccountType, 1 AS cntID, 'Debit' as BalanceSide UNION
  SELECT 'Revenue', 3, 'Credit'
)
SELECT * INTO #TempAccountType FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempAccountType)
BEGIN 
	
	DECLARE @BalanceSide NVARCHAR(50)
	DECLARE @strAccountType NVARCHAR(50)

	SELECT TOP 1 @strAccountType = AccountType, @BalanceSide = BalanceSide FROM #TempAccountType ORDER BY cntID
	SELECT * INTO #TempGLAccount FROM vyuGLAccountView where strAccountType = @strAccountType ORDER BY strAccountId
	
	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strAccountType, 'Row Name - Left Align', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
	
	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
	BEGIN

		DECLARE @strAccountId NVARCHAR(150)
		DECLARE @strAccountDescription NVARCHAR(500)

		DECLARE @strRowDescription NVARCHAR(500)
		DECLARE @strRowFilter NVARCHAR(500)

		SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription FROM #TempGLAccount ORDER BY strAccountId

		SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
		SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Filter Accounts', @BalanceSide, '', @strRowFilter, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
		
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'
				
		DELETE #TempGLAccount WHERE strAccountId = @strAccountId

		IF (SELECT TOP 1 1 FROM #TempGLAccount) = 1
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '+')
				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1
			END
		ELSE
			BEGIN
				INSERT INTO #tmpRelatedRows (intRefNo, strAction) VALUES (@intRefNo, '')

				SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1			

				SET @strRowDescription = '          Total ' + @strAccountType + ' :'

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Row Calculation', '', @strRelatedRows, '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort	
				
				SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

				IF(@strAccountType = 'Expense')
				BEGIN
					SET @intRowDetailId_Expense = @intRowDetailId
					SET @intRefNo_Expense = @intRefNo
				END
				ELSE IF(@strAccountType = 'Revenue')
				BEGIN					
					SET @intRowDetailId_Revenue = @intRowDetailId
					SET @intRefNo_Revenue = @intRefNo
				END
				
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

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
				
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort	
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	
				SET @strRelatedRows = ''

			END
	END

	DROP TABLE #TempGLAccount

	DELETE #TempAccountType WHERE AccountType = @strAccountType


	IF (SELECT TOP 1 1 FROM #TempAccountType) IS NULL
		BEGIN
			SET @strRowFilter = 'R' + CAST(@intRefNo_Expense as NVARCHAR(25)) + ' - R' + CAST(@intRefNo_Revenue as NVARCHAR(25))
			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '          NET PROFIT(LOSS) :', 'Row Calculation', '', @strRowFilter, '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, @intSort
			
			SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
			
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_Expense, @intRowId, @intRefNo, @intRefNo_Expense, '-', 1
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_Revenue, @intRowId, @intRefNo, @intRefNo_Revenue, '+', 2
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1	

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
		END


END

DROP TABLE #TempAccountType
DROP TABLE #tmpRelatedRows


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDIncomeStatementDetail] 81

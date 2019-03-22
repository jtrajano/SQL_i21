CREATE PROCEDURE [dbo].[uspFRDTrialBalancePrintEach]
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

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Column Name - Page Header',	'',	'',	'',	'', '',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;

WITH tmpAccountType AS
(
  SELECT 'Asset' AS AccountType, 1 AS cntID, 'Debit' as BalanceSide, 'BS' as AccountsTypeRow UNION
  SELECT 'Liability', 2, 'Credit', 'BS' UNION
  SELECT 'Equity', 3, 'Credit', 'RE' UNION
  SELECT 'Revenue', 4, 'Credit', 'IS' UNION
  SELECT 'Expense', 5, 'Debit', 'IS'
)
SELECT * INTO #TempAccountType FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempAccountType)
BEGIN

	DECLARE @strAccountType NVARCHAR(50)
	DECLARE @strAccountsType_Row NVARCHAR(50)
	DECLARE @BalanceSide NVARCHAR(50)	
	DECLARE @strRowFilter NVARCHAR(500)

	SELECT TOP 1 @strAccountType = AccountType, @BalanceSide = BalanceSide, @strAccountsType_Row = AccountsTypeRow FROM #TempAccountType ORDER BY cntID

	SET @strRowFilter = '[Type] = ''' + @strAccountType + ''''

	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strAccountType, 'Filter Accounts', 'Debit', 'Column', '', @strRowFilter, @strAccountsType_Row, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
	
	SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
	
	EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'Type', '=', @strAccountType, '', 'Or'				

	DELETE #TempAccountType WHERE AccountType = @strAccountType

	IF @strRelatedRows = ''
		BEGIN
			SET @strRelatedRows = 'SUM(' + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ':'
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE IF (SELECT TOP 1 1 FROM #TempAccountType) = 1
		BEGIN
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE
		BEGIN
			SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ')'
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', '', 1, 1, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
								
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1			

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '          Total :', 'Row Calculation', '', '', @strRelatedRows, '', '', 1, 1, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, 1, @intSort
				
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', '', 1, 1, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort	
				
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
			SET @strRelatedRows = ''

		END

	UPDATE tblFRRowDesign SET ysnPrintEach = 1 WHERE strRowType = 'Filter Accounts' AND intRowId = @intRowId

END

DROP TABLE #TempAccountType


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDTrialBalancePrintEach] 81

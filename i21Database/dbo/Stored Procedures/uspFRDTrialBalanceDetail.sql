CREATE PROCEDURE [dbo].[uspFRDTrialBalanceDetail]
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

CREATE TABLE #tmpRelatedRows (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Column Name',	'',	'',	'',	'',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;

SELECT strAccountId, strDescription, strAccountType INTO #TempGLAccount FROM vyuGLAccountView ORDER BY strAccountId

WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
BEGIN

	DECLARE @strAccountId NVARCHAR(150)
	DECLARE @strAccountDescription NVARCHAR(500)	
	DECLARE @strAccountType NVARCHAR(50)
	DECLARE @BalanceSide NVARCHAR(50)
	
	DECLARE @strRowDescription NVARCHAR(500)
	DECLARE @strRowFilter NVARCHAR(500)

	SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription, @strAccountType = strAccountType FROM #TempGLAccount ORDER BY strAccountId

	IF(@strAccountType = 'Asset' or  @strAccountType = 'Expense')
	BEGIN
		SET @BalanceSide = 'Debit'
	END
	ELSE IF(@strAccountType = 'Liability' or @strAccountType = 'Equity' or @strAccountType = 'Revenue')
	BEGIN
		SET @BalanceSide = 'Credit'
	END
	
	SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
	SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''

	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Filter Accounts', @BalanceSide, 'Column', '', @strRowFilter, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
	
	SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

	EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'				

	DELETE #TempGLAccount WHERE strAccountId = @strAccountId

	IF @strRelatedRows = ''
		BEGIN
			SET @strRelatedRows = 'SUM(' + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ':'
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE IF (SELECT TOP 1 1 FROM #TempGLAccount) = 1
		BEGIN
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE
		BEGIN
			SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ')'
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', 1, 1, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
								
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1			

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '          Total :', 'Row Calculation', '', '', @strRelatedRows, '', 1, 1, 0, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, 1, @intSort
				
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', 1, 1, 0, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort	
				
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort	
								
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1	
			SET @strRelatedRows = ''

		END

END

DROP TABLE #TempGLAccount
DROP TABLE #tmpRelatedRows


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDTrialBalanceDetail] 81

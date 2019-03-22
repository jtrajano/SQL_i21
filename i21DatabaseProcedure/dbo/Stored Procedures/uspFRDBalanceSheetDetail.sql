CREATE PROCEDURE [dbo].[uspFRDBalanceSheetDetail]
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

DECLARE @intRowDetailId_Liability INT
DECLARE @intRowDetailId_Equity INT
DECLARE @intRowDetailId_CY INT
DECLARE @intRowDetailId_TotalEquity INT

DECLARE @intRefNo_Liability INT
DECLARE @intRefNo_Equity INT
DECLARE @intRefNo_CY INT
DECLARE @intRefNo_TotalEquity INT

CREATE TABLE #tmpRelatedRows (
	[cntID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[intRefNo] [int],
	[strAction] [nvarchar](10)
);

EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Column Name',	'',	'', '',	'',	'',	0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1;

WITH tmpAccountType AS
(
  SELECT 'Asset' AS AccountType, 1 AS cntID, 'Debit' as BalanceSide UNION
  SELECT 'Liability', 2, 'Credit' UNION
  SELECT 'Equity', 3, 'Credit'
)
SELECT * INTO #TempAccountType FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempAccountType)
BEGIN 
	
	DECLARE @BalanceSide NVARCHAR(50)
	DECLARE @strAccountType NVARCHAR(50)
	DECLARE @strAccountsType_Row NVARCHAR(50)	

	SELECT TOP 1 @strAccountType = AccountType, @BalanceSide = BalanceSide FROM #TempAccountType ORDER BY cntID
	SELECT * INTO #TempGLAccount FROM vyuGLAccountView where strAccountType = @strAccountType ORDER BY strAccountId
	
	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strAccountType, 'Row Name - Left Align', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
	
	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1	

	WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
	BEGIN

		DECLARE @strAccountId NVARCHAR(150)
		DECLARE @strAccountDescription NVARCHAR(500)
		DECLARE @strAccountGroup NVARCHAR(250)

		DECLARE @strRowDescription NVARCHAR(500)
		DECLARE @strRowFilter NVARCHAR(500)
		DECLARE @rowType NVARCHAR(50) = 'Filter Accounts'
		DECLARE @REAccount NVARCHAR(50) = ''

		SELECT TOP 1 @strAccountId = strAccountId, @strAccountDescription = strDescription, @strAccountGroup = strAccountGroup FROM #TempGLAccount ORDER BY strAccountId

		SET @strRowDescription = '     ' + @strAccountId + ' - ' + REPLACE(@strAccountDescription,'''','')
		SET @strRowFilter = '[ID] = ''' + @strAccountId + ''''		

		IF(@strAccountType = 'Asset' OR @strAccountType = 'Liability' OR @strAccountType = 'Equity')
		BEGIN
			SET @strAccountsType_Row = 'BS'
		END
		ELSE IF(@strAccountType = 'Revenue' OR @strAccountType = 'Expense')
		BEGIN
			SET @strAccountsType_Row = 'IS'
		END

		SET @REAccount = (SELECT TOP 1 ISNULL(strAccountId,'') FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearId = (SELECT TOP 1 intFiscalYearId FROM tblGLCurrentFiscalYear)))

		IF(@REAccount = '')
		BEGIN
			SET @REAccount = (SELECT TOP 1 ISNULL(strAccountId,'') FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear))
		END

		IF(@REAccount = @strAccountId)
		BEGIN
			SET @strAccountsType_Row = 'RE'
		END	

		EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, @rowType, @BalanceSide, 'Column', '', @strRowFilter, @strAccountsType_Row, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
		
		SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccountId, '', 'Or'
				
		DELETE #TempGLAccount WHERE strAccountId = @strAccountId

		IF (@strRelatedRows = '' and (SELECT TOP 1 1 FROM #TempGLAccount) = 1)
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
				IF (CHARINDEX('SUM',@strRelatedRows) < 1)
				BEGIN
					SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
				END
				ELSE
				BEGIN
					SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ')'
				END

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1			

				SET @strRowDescription = '          Total ' + REPLACE(REPLACE(@strAccountType,'Asset','Assets'),'Liability','Liabilities') + ' :'

				DECLARE @_AccountsType NVARCHAR(50) = ''
				IF(@strAccountType = 'Asset')
				BEGIN
					SET @_AccountsType = 'BS - Assets'
				END

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Row Calculation', '', '', @strRelatedRows, '', @_AccountsType, 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, 1, @intSort
				
				SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

				IF(@strAccountType = 'Liability')
				BEGIN
					SET @intRowDetailId_Liability = @intRowDetailId
					SET @intRefNo_Liability = @intRefNo
				END
				ELSE IF(@strAccountType = 'Equity')
				BEGIN					
					SET @intRowDetailId_Equity = @intRowDetailId
					SET @intRefNo_Equity = @intRefNo
				END
				
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1

				IF(@strAccountType != 'Liability' and @strAccountType != 'Equity')
				BEGIN
					EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort	
				
					SET @intRefNo = @intRefNo + 1
					SET @intSort = @intSort + 1
				END			

				EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort	
								
				SET @intRefNo = @intRefNo + 1
				SET @intSort = @intSort + 1	
				SET @strRelatedRows = ''

			END
	END

	DROP TABLE #TempGLAccount

	DELETE #TempAccountType WHERE AccountType = @strAccountType
END

DROP TABLE #TempAccountType


--+++++++++++++++++++++++++++++++++++++
--			CY AND TOTALS
--+++++++++++++++++++++++++++++++++++++
DELETE #tmpRelatedRows;
SET @strRelatedRows = '';

WITH tmpAccountType AS
(
  SELECT 'Revenue' AS AccountType, 1 AS cntID, 'Credit' as BalanceSide UNION
  SELECT 'Expense', 2, 'Debit'
)
SELECT * INTO #TempAccountType_Hidden FROM tmpAccountType

WHILE EXISTS(SELECT 1 FROM #TempAccountType_Hidden)
BEGIN 

	DECLARE @BalanceSide_Hidden NVARCHAR(50)
	DECLARE @strRowFilter_Hidden NVARCHAR(500)
	DECLARE @strAccountType_Hidden NVARCHAR(50)

	SELECT TOP 1 @strAccountType_Hidden = AccountType, @BalanceSide_Hidden = BalanceSide FROM #TempAccountType_Hidden ORDER BY cntID

	IF(@strAccountType_Hidden = 'Asset' OR @strAccountType_Hidden = 'Liability' OR @strAccountType_Hidden = 'Equity')
	BEGIN
		SET @strAccountsType_Row = 'BS'
	END
	ELSE IF(@strAccountType_Hidden = 'Revenue' OR @strAccountType_Hidden = 'Expense')
	BEGIN
		SET @strAccountsType_Row = 'IS'
	END	
	
	SET @strRowFilter_Hidden = '[Type] = ''' + @strAccountType_Hidden + ''''

	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strAccountType_Hidden, 'Filter Accounts', @BalanceSide_Hidden, 'Column', '', @strRowFilter_Hidden, 'CY', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort		

	SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)

	EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'Type', '=', @strAccountType_Hidden, '', 'Or'			

	DELETE #TempAccountType_Hidden WHERE AccountType = @strAccountType_Hidden

	IF @strRelatedRows = ''
		BEGIN
			SET @strRelatedRows = 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' - '
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE IF (SELECT TOP 1 1 FROM #TempAccountType_Hidden) = 1
		BEGIN
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
		END
	ELSE
		BEGIN				
			SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1			

			-- Current Year Earning
			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '     Current Year Earning :', 'Row Calculation', '', '', @strRelatedRows, '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 1, @intSort
			
			SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
			SET @intRowDetailId_CY = @intRowDetailId
			SET @intRefNo_CY = @intRefNo		
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1

			-- Total Equity
			SET @strRowFilter_Hidden = 'R' + CAST(@intRefNo_Equity as NVARCHAR(25)) + ' + R' + CAST(@intRefNo_CY as NVARCHAR(25))
			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '          Total Equity :', 'Row Calculation', '', '', @strRowFilter_Hidden, '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, 0, @intSort
						
			SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
			SET @intRowDetailId_TotalEquity = @intRowDetailId
			SET @intRefNo_TotalEquity = @intRefNo
						
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_Equity, @intRowId, @intRefNo, @intRefNo_Equity, '+', 1
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_CY, @intRowId, @intRefNo, @intRefNo_CY, '+', 2
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1	

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Underscore', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1
			
			-- Total Liabilities and Equity
			SET @strRowFilter_Hidden = 'R' + CAST(@intRefNo_Liability as NVARCHAR(25)) + ' + R' + CAST(@intRefNo_TotalEquity as NVARCHAR(25))
			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '          Total Liabilities and Equity :', 'Row Calculation', '', '', @strRowFilter_Hidden, '', 'BS - Liability and Equity', 0, 0, 1, 0, 3.000000, 'Arial', 'Bold', 'Black', 9, '', 0, 0, @intSort
			
			SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
			
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_Liability, @intRowId, @intRefNo, @intRefNo_Liability, '+', 1
			EXEC [dbo].[uspFRDCreateRowCalculation] @intRowDetailId, @intRowDetailId_TotalEquity, @intRowId, @intRefNo, @intRefNo_TotalEquity, '+', 2
			
			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1	

			EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'Double Underscore', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

			SET @intRefNo = @intRefNo + 1
			SET @intSort = @intSort + 1	
			SET @strRelatedRows = ''

			--EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, '', 'None', '', '', '', '', '', 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, 0, @intSort

		END	
END

DROP TABLE #TempAccountType_Hidden

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDBalanceSheetDetail] 73
				
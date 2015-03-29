CREATE PROCEDURE [dbo].[uspFRDGenerateDrillDownRows]
	@intRowId			AS INT,
	@Side				AS NVARCHAR(50)	=	'',
	@Source				AS NVARCHAR(10)	=	'',
	@Param				AS NVARCHAR(MAX)	=	''
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

CREATE TABLE #TempGLAccount (
	[strAccount]		[nvarchar](100),
	[strDescription]	[nvarchar](max),
	[strAccountType]	[nvarchar](100)
);

SELECT @intRefNo = ISNULL(MAX(intRefNo), 0) + 1 FROM tblFRRowDesignDrillDown WHERE intRowId = @intRowId
SELECT @intSort = ISNULL(MAX(intSort), 0) + 1 FROM tblFRRowDesignDrillDown WHERE intRowId = @intRowId

INSERT INTO #TempGLAccount EXEC (@Param)

DELETE tblFRRowDesignDrillDown WHERE intRowId = @intRowId

INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								'',
								'Column Name',
								'',
								'',
								'',
								'',
								0,
								0,
								1,
								1,
								3.000000,
								'Arial',
								'Normal',
								'Black',
								8,
								'',
								0,
								@intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort+1

WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
BEGIN

	DECLARE @strAccount NVARCHAR(150)
	DECLARE @strAccountDescription NVARCHAR(500)
	DECLARE @strAccountType NVARCHAR(50)
	
	DECLARE @strRowDescription NVARCHAR(500)
	DECLARE @strRowFilter NVARCHAR(500)

	SELECT TOP 1 @strAccount = strAccount, @strAccountDescription = strDescription, @strAccountType = strAccountType FROM #TempGLAccount ORDER BY strAccount

	SET @strRowDescription = @strAccount + ' - ' + REPLACE(@strAccountDescription,'''','')
	SET @strRowFilter = '[ID] = ''' + @strAccount + ''''

	INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								@strRowDescription,
								'Filter Accounts',
								@Side,
								@Source,
								'',
								@strRowFilter,
								0,
								0,
								1,
								1,
								3.000000,
								'Arial',
								'Normal',
								'Black',
								8,
								'',
								0,
								@intSort
	
	SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '			
	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	DELETE #TempGLAccount WHERE strAccount = @strAccount

END

SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))

INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								'',
								'Underscore',
								'',
								'',
								'',
								'',
								0,
								0,
								1,
								0,
								3.000000,
								'Arial',
								'Normal',
								'Black',
								8,
								'',
								0,
								@intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1

INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								'          Total: ',
								'Row Calculation',
								'',
								'',
								@strRelatedRows,
								'',
								0,
								0,
								1,
								0,
								3.000000,
								'Arial',
								'Bold',
								'Black',
								9,
								'',
								0,
								@intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1

INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								'',
								'Double Underscore',
								@Side,
								'',
								'',
								'',
								0,
								0,
								1,
								0,
								3.000000,
								'Arial',
								'Normal',
								'Black',
								8,
								'',
								0,
								@intSort

SET @intRefNo = @intRefNo + 1
SET @intSort = @intSort + 1

INSERT INTO tblFRRowDesignDrillDown (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								'',
								'None',
								'',
								'',
								'',
								'',
								0,
								0,
								1,
								0,
								3.000000,
								'Arial',
								'Normal',
								'Black',
								8,
								'',
								0,
								@intSort

DROP TABLE #TempGLAccount


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDGenerateRows] 7

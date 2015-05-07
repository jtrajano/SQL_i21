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
DECLARE @intRefNo INT = 0
DECLARE @intSort INT = 0
DECLARE @strRelatedRows NVARCHAR(MAX) = ''

CREATE TABLE #TempGLAccount (
	[strAccount]		[nvarchar](100),
	[strDescription]	[nvarchar](max),
	[strAccountType]	[nvarchar](100)
);

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
								@intRefNo + 100000,
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

WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
BEGIN

	DECLARE @strAccount NVARCHAR(150)
	DECLARE @strAccountDescription NVARCHAR(500)
	DECLARE @strAccountType NVARCHAR(50)
	
	DECLARE @strRowDescription NVARCHAR(500)
	DECLARE @strRowFilter NVARCHAR(500)

	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

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
	
	IF((SELECT COUNT(*) FROM #TempGLAccount) > 1)
	BEGIN
		SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25)) + ' + '
	END
	ELSE
	BEGIN
		SET @strRelatedRows =  @strRelatedRows + 'R' + CAST(@intRefNo as NVARCHAR(25))
	END

	DELETE #TempGLAccount WHERE strAccount = @strAccount

END

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
								@intRefNo + 200000,
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
								@intRefNo + 300000,
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
								@intRefNo + 400000,
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

--EXEC [dbo].[uspFRDGenerateDrillDownRows] 67

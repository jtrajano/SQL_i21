CREATE PROCEDURE [dbo].[uspFRDGenerateRows]
	@intRowId			AS INT,
	@ysnFull			AS BIT				=	0,
	@Description		AS NVARCHAR(MAX)	=	'',
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

CREATE TABLE #TempGLAccount (
	[strAccount]		[nvarchar](100),
	[strDescription]	[nvarchar](max),
	[strAccountType]	[nvarchar](100)
);

SELECT @intRefNo = ISNULL(MAX(intRefNo), 0) + 1 FROM tblFRRowDesign WHERE intRowId = @intRowId
SELECT @intSort = ISNULL(MAX(intSort), 0) + 1 FROM tblFRRowDesign WHERE intRowId = @intRowId

INSERT INTO #TempGLAccount EXEC (@Param)

WHILE EXISTS(SELECT 1 FROM #TempGLAccount)
BEGIN

	DECLARE @strAccount NVARCHAR(150)
	DECLARE @strAccountDescription NVARCHAR(500)
	DECLARE @strAccountType NVARCHAR(50)
	DECLARE @BalanceSide NVARCHAR(50)
	
	DECLARE @strRowDescription NVARCHAR(500)
	DECLARE @strRowFilter NVARCHAR(500)

	SELECT TOP 1 @strAccount = strAccount, @strAccountDescription = strDescription, @strAccountType = strAccountType FROM #TempGLAccount ORDER BY strAccount

	IF(@strAccountType = 'Asset' or  @strAccountType = 'Expense')
	BEGIN
		SET @BalanceSide = 'Debit'
	END
	ELSE IF(@strAccountType = 'Liability' or @strAccountType = 'Equity' or @strAccountType = 'Revenue')
	BEGIN
		SET @BalanceSide = 'Credit'
	END

	IF(@Description != '')
	BEGIN
		SET @strRowDescription = @Description
	END
	ELSE
	BEGIN
		SET @strRowDescription = @strAccount + ' - ' + REPLACE(@strAccountDescription,'''','')
	END
	
	IF(@ysnFull = 1)
	BEGIN		
		SET @strRowFilter = '[ID] = ''' + @strAccount + ''''
	END
	ELSE
	BEGIN
		SET @strRowFilter = '[Primary Account] = ''' + @strAccount + ''''
	END
	
	EXEC [dbo].[uspFRDCreateRowDesign] @intRowId, @intRefNo, @strRowDescription, 'Filter Accounts', @BalanceSide, 'Column', '', @strRowFilter, 0, 0, 1, 0, 3.000000, 'Arial', 'Normal', 'Black', 8, '', 0, @intSort
	
	SET @intRowDetailId = (SELECT MAX(intRowDetailId) FROM tblFRRowDesign WHERE intRowId =  @intRowId)
	
	IF(@ysnFull = 1)
	BEGIN
		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'ID', '=', @strAccount, '', 'Or'				
	END
	ELSE
	BEGIN
		EXEC [dbo].[uspFRDCreateRowFilter] @intRowDetailId, @intRowId, @intRefNo, 'Primary Account', '=', @strAccount, '', 'Or'
	END

	SET @intRefNo = @intRefNo + 1
	SET @intSort = @intSort + 1

	DELETE #TempGLAccount WHERE strAccount = @strAccount

END

DROP TABLE #TempGLAccount


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDGenerateRows] 7

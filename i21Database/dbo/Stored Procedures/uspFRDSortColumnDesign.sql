CREATE PROCEDURE [dbo].[uspFRDSortColumnDesign]
	@ColumnId				AS INT,
	@ColumnDetailId		AS NVARCHAR(MAX)	=	'',
	@ReOrder			AS BIT				=	0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @SplitOn			NVARCHAR(10) = ':'
Declare @SORT				INT			 = 1
DECLARE @intColumnDetailId		INT			 = 0
DECLARE @intRefNoCurrent	INT			 = 0

CREATE TABLE #TempColumnDesign (
	[ColumnDetailId]		INT,
	[RefNo]				INT,
	[Sort]				INT
);

WHILE (CHARINDEX(@SplitOn,@ColumnDetailId)>0)
BEGIN
	IF((SELECT TOP 1 1 FROM tblFRColumnDesign WHERE intColumnId = @ColumnId and intColumnDetailId = LTRIM(RTRIM(SUBSTRING(@ColumnDetailId,1,CHARINDEX(@SplitOn,@ColumnDetailId)-1)))) = 1)
	BEGIN
		INSERT INTO #TempColumnDesign ([ColumnDetailId],[RefNo],[Sort])
			SELECT ColumnID = LTRIM(RTRIM(SUBSTRING(@ColumnDetailId,1,CHARINDEX(@SplitOn,@ColumnDetailId)-1))), (SELECT TOP 1 intRefNo FROM tblFRColumnDesign WHERE intColumnId = @ColumnId and intColumnDetailId = LTRIM(RTRIM(SUBSTRING(@ColumnDetailId,1,CHARINDEX(@SplitOn,@ColumnDetailId)-1)))), @SORT

		SET @SORT = @SORT + 1
	END

	SET @ColumnDetailId = SUBSTRING(@ColumnDetailId,CHARINDEX(@SplitOn,@ColumnDetailId)+1,LEN(@ColumnDetailId))
END

INSERT INTO #TempColumnDesign ([ColumnDetailId],[RefNo],[Sort])
	SELECT ColumnID = LTRIM(RTRIM(@ColumnDetailId)), (SELECT TOP 1 intRefNo FROM tblFRColumnDesign WHERE intColumnId = @ColumnId and intColumnDetailId = LTRIM(RTRIM(@ColumnDetailId))), @SORT

WHILE EXISTS(SELECT 1 FROM #TempColumnDesign)
BEGIN
	SELECT TOP 1 @intColumnDetailId = [ColumnDetailId], @intRefNoCurrent = [RefNo], @SORT = [Sort] FROM #TempColumnDesign ORDER BY [Sort]

	SELECT  @intColumnDetailId, @intRefNoCurrent, @SORT

	UPDATE tblFRColumnDesign SET intSort = @SORT, intRefNo = @SORT WHERE intColumnId = @ColumnId and intColumnDetailId = @intColumnDetailId	
	UPDATE tblFRColumnDesignCalculation SET intRefNoId = @SORT WHERE intColumnId = @ColumnId and intColumnDetailId = @intColumnDetailId
	UPDATE tblFRColumnDesignCalculation SET intRefNoCalc = @SORT WHERE intColumnId = @ColumnId and intColumnDetailRefNo = @intColumnDetailId
	
	UPDATE tblFRColumnDesign SET strColumnFormula = REPLACE(REPLACE(REPLACE(		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' ' + REPLACE(strColumnFormula,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'),'(',' ('),')',' )'),':',' :')		,'C',' C'),'C' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ','X' + CAST(@SORT AS NVARCHAR(15)) + ' '),' ','') WHERE intColumnId = @ColumnId and strColumnType = 'Column Calculation'

	DELETE #TempColumnDesign WHERE [ColumnDetailId] = @intColumnDetailId
END

UPDATE tblFRColumnDesign SET strColumnFormula = REPLACE(strColumnFormula,'X','C') WHERE intColumnId = @ColumnId and strColumnType = 'Column Calculation'
UPDATE tblFRColumnDesign SET strColumnFormula = SUBSTRING(REPLACE(strColumnFormula,' ',''),2,LEN(REPLACE(strColumnFormula,' ','')))  WHERE intColumnId = @ColumnId and strColumnType = 'Column Calculation' and (REPLACE(strColumnFormula,' ','') like '+%' OR REPLACE(strColumnFormula,' ','') like '-%' OR REPLACE(strColumnFormula,' ','') like '*%' OR REPLACE(strColumnFormula,' ','') like '/%')
UPDATE tblFRColumnDesign SET strColumnFormula = '(' + strColumnFormula WHERE intColumnId = @ColumnId and strColumnType = 'Column Calculation' and strColumnFormula like '%)%' and strColumnFormula not like '%(%'
UPDATE tblFRColumnDesign SET strColumnFormula = strColumnFormula + ')' WHERE intColumnId = @ColumnId and strColumnType = 'Column Calculation' and strColumnFormula like '%(%' and strColumnFormula not like '%)%'


DROP TABLE #TempColumnDesign

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDSortColumnDesign] '38276:38277:38278:38279'

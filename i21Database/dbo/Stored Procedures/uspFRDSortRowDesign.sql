
CREATE PROCEDURE [dbo].[uspFRDSortRowDesign]
	@RowId				AS INT,
	@RowDetailId		AS NVARCHAR(MAX)	=	''
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @SplitOn			NVARCHAR(10) = ':'
Declare @SORT				INT			 = 1
DECLARE @intRowDetailId		INT			 = 0
DECLARE @intRefNoCurrent	INT			 = 0

CREATE TABLE #TempRowDesign (
	[RowDetailId]		INT,
	[RefNo]				INT,
	[Sort]				INT
);

WHILE (CHARINDEX(@SplitOn,@RowDetailId)>0)
BEGIN
	IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1)))) = 1)
	BEGIN
		INSERT INTO #TempRowDesign ([RowDetailId],[RefNo],[Sort])
			SELECT RowID = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1))), (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1)))), @SORT

		SET @SORT = @SORT + 1
	END

	SET @RowDetailId = SUBSTRING(@RowDetailId,CHARINDEX(@SplitOn,@RowDetailId)+1,LEN(@RowDetailId))
END

INSERT INTO #TempRowDesign ([RowDetailId],[RefNo],[Sort])
	SELECT RowID = LTRIM(RTRIM(@RowDetailId)), (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(@RowDetailId))), @SORT

WHILE EXISTS(SELECT 1 FROM #TempRowDesign)
BEGIN
	SELECT TOP 1 @intRowDetailId = [RowDetailId], @intRefNoCurrent = [RefNo], @SORT = [Sort] FROM #TempRowDesign ORDER BY [Sort]

	SELECT  @intRowDetailId, @intRefNoCurrent, @SORT

	UPDATE tblFRRowDesign SET intSort = @SORT, intRefNo = @SORT WHERE intRowId = @RowId and intRowDetailId = @intRowDetailId	
	UPDATE tblFRRowDesignCalculation SET intRefNoId = @SORT WHERE intRowId = @RowId and intRowDetailId = @intRowDetailId
	UPDATE tblFRRowDesignCalculation SET intRefNoCalc = @SORT WHERE intRowId = @RowId and intRowDetailRefNo = @intRowDetailId
	
	UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(REPLACE(REPLACE(		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' ' + REPLACE(strRelatedRows,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'),')',' )'),':',' :')		,'R',' R'),'R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ','X' + CAST(@SORT AS NVARCHAR(15)) + ' '),' ','') WHERE intRowId = @RowId and strRowType = 'Row Calculation'
	
	DELETE #TempRowDesign WHERE [RowDetailId] = @intRowDetailId
END

UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'X','R') WHERE intRowId = @RowId and strRowType = 'Row Calculation'

DROP TABLE #TempRowDesign

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDSortRowDesign] '38276:38277:38278:38279'

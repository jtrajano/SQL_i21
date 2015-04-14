
CREATE PROCEDURE [dbo].[uspFRDSortRowDesign]
	@RowId				AS INT,
	@RowDetailId		AS NVARCHAR(MAX)	=	''
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @SplitOn	NVARCHAR(10) = ':'
Declare @CNT		INT			 = 1
Declare @SORT		INT			 = 1

CREATE TABLE #TempRowDesign (
	[RowDetailId]		INT
);

WHILE (CHARINDEX(@SplitOn,@RowDetailId)>0)
BEGIN
    INSERT INTO #TempRowDesign ([RowDetailId])
		SELECT RowID = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1)))

    SET @RowDetailId = SUBSTRING(@RowDetailId,CHARINDEX(@SplitOn,@RowDetailId)+1,LEN(@RowDetailId))
    SET @CNT = @CNT + 1
END

INSERT INTO #TempRowDesign ([RowDetailId])
	SELECT RowID = LTRIM(RTRIM(@RowDetailId))

WHILE EXISTS(SELECT 1 FROM #TempRowDesign)
BEGIN
	DECLARE @intRowDetailId INT = (SELECT TOP 1 [RowDetailId] FROM #TempRowDesign)

	UPDATE tblFRRowDesign SET intSort = @SORT WHERE intRowId = @RowId and intRowDetailId = @intRowDetailId
	SET @SORT = @SORT + 1

	DELETE #TempRowDesign WHERE [RowDetailId] = @intRowDetailId
END

DROP TABLE #TempRowDesign

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDSortRowDesign] '38276:38277:38278:38279'

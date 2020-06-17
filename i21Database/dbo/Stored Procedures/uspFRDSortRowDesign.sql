CREATE PROCEDURE [dbo].[uspFRDSortRowDesign]
	@RowId				AS INT,
	@RowDetailId		AS NVARCHAR(MAX)	=	'',
	@ReOrder			AS BIT				=	0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @SplitOn			NVARCHAR(10) = ':'
DECLARE @Formula			NVARCHAR(MAX) = ''
Declare @SORT				INT			 = 1
DECLARE @intRowDetailId		INT			 = 0
DECLARE @intRefNoCurrent	INT			 = 0

DECLARE @intRefNo_1			INT			 = 0
DECLARE @intRefNo_2			INT			 = 0

CREATE TABLE #TempRowDesign (
	[RowDetailId]		INT,
	[RefNo]				INT,
	[Sort]				INT
);

CREATE TABLE #TempSUMRows (
	[RowDetailId]		INT,
	[RefNo]				INT,
	[Formula]			NVARCHAR(MAX),
	[Sort]				INT
);

WHILE (CHARINDEX(@SplitOn,@RowDetailId)>0)
BEGIN
	IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1)))) = 1)
	BEGIN
		INSERT INTO #TempRowDesign ([RowDetailId],[RefNo],[Sort])
			SELECT RowID = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1))), 
					(SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(SUBSTRING(@RowDetailId,1,CHARINDEX(@SplitOn,@RowDetailId)-1)))), 
					@SORT

		SET @SORT = @SORT + 1
	END

	SET @RowDetailId = SUBSTRING(@RowDetailId,CHARINDEX(@SplitOn,@RowDetailId)+1,LEN(@RowDetailId))
END

INSERT INTO #TempRowDesign ([RowDetailId],[RefNo],[Sort])
	SELECT RowID = LTRIM(RTRIM(@RowDetailId)), (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowId = @RowId and intRowDetailId = LTRIM(RTRIM(@RowDetailId))), @SORT

SELECT * INTO #TempRowDesign2 FROM #TempRowDesign

WHILE EXISTS(SELECT 1 FROM #TempRowDesign)
BEGIN
	SELECT TOP 1 @intRowDetailId = [RowDetailId], @intRefNoCurrent = [RefNo], @SORT = [Sort] FROM #TempRowDesign ORDER BY [Sort]
		
	UPDATE tblFRRowDesign SET intSort = @SORT, intRefNo = @SORT WHERE intRowId = @RowId and intRowDetailId = @intRowDetailId	
	UPDATE tblFRRowDesignCalculation SET intRefNoId = @SORT WHERE intRowId = @RowId and intRowDetailId = @intRowDetailId
	UPDATE tblFRRowDesignCalculation SET intRefNoCalc = @SORT WHERE intRowId = @RowId and intRowDetailRefNo = @intRowDetailId
	
	UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(REPLACE(REPLACE(		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' ' + REPLACE(strRelatedRows,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'),'(',' ('),')',' )'),':',' :') ,'R',' R'),'R' + 
	CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ','X' + CAST(@SORT AS NVARCHAR(15)) + ' '),' ','') WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows not like '%SUM%'
	
	UPDATE tblFRRowDesign SET strPercentage = REPLACE(REPLACE(REPLACE(		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(' ' + REPLACE(strPercentage,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'),'(',' ('),')',' )'),':',' :')	,'R',' R'),'R' + 
	CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ','X' + CAST(@SORT AS NVARCHAR(15)) + ' '),' ','') WHERE intRowId = @RowId and strRowType IN ('Filter Accounts') and strPercentage not like '%SUM%'

	UPDATE tblFRRowDesign SET strRelatedRows = REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(REPLACE(REPLACE(' ' + REPLACE(strRelatedRows,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'), ' +R' + 
	CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' +X' + CAST(@SORT AS NVARCHAR(15))) + ' ', ' -R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' -X' + CAST(@SORT AS NVARCHAR(15))) + ' ', ' *R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' *X' 
	+ CAST(@SORT AS NVARCHAR(15))) + ' ', ' /R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' /X' + CAST(@SORT AS NVARCHAR(15)) + ' ' ) WHERE intRowId = @RowId and strRowType IN ('Row Calculation')  and strRelatedRows like '%SUM%'

	UPDATE tblFRRowDesign SET strRelatedRows = REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(REPLACE(REPLACE(' ' + REPLACE('+'+strRelatedRows,' ','') + ' ','/',' /'),'*',' *'),'-',' -'),'+',' +'), ' +R' + 
	CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' +X' + CAST(@SORT AS NVARCHAR(15))) + ' ', ' -R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' -X' + CAST(@SORT AS NVARCHAR(15))) + ' ', ' *R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' *X' 
	+ CAST(@SORT AS NVARCHAR(15))) + ' ', ' /R' + CAST(@intRefNoCurrent AS NVARCHAR(15)) + ' ', ' /X' + CAST(@SORT AS NVARCHAR(15)) + ' ' ) WHERE intRowId = @RowId and strRowType IN ('Row Calculation') 
	and (strRelatedRows like '%+SUM%' or strRelatedRows like '%-SUM%' or strRelatedRows like '%*SUM%' or strRelatedRows like '%/SUM%')

	DELETE #TempRowDesign WHERE [RowDetailId] = @intRowDetailId
END

UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,' ','') WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows like '%SUM%'
UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'X','R') WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows not like '%SUM%'
UPDATE tblFRRowDesign SET strRelatedRows = SUBSTRING(REPLACE(strRelatedRows,' ',''),2,LEN(REPLACE(strRelatedRows,' ','')))  WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and 
(REPLACE(strRelatedRows,' ','') like '+%' OR REPLACE(strRelatedRows,' ','') like '-%' OR REPLACE(strRelatedRows,' ','') like '*%' OR REPLACE(strRelatedRows,' ','') like '/%')

UPDATE tblFRRowDesign SET strRelatedRows = '(' + strRelatedRows WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows like '%)%' and strRelatedRows not like '%(%'
UPDATE tblFRRowDesign SET strRelatedRows = strRelatedRows + ')' WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows like '%(%' and strRelatedRows not like '%)%'

UPDATE tblFRRowDesign SET strPercentage = REPLACE(strPercentage,' ','') WHERE intRowId = @RowId and strRowType IN ('Filter Accounts') and strPercentage like '%SUM%'
UPDATE tblFRRowDesign SET strPercentage = REPLACE(strPercentage,'X','R') WHERE intRowId = @RowId and strRowType IN ('Filter Accounts')
UPDATE tblFRRowDesign SET strPercentage = SUBSTRING(REPLACE(strPercentage,' ',''),2,LEN(REPLACE(strPercentage,' ','')))  WHERE intRowId = @RowId and strRowType IN ('Filter Accounts') and 
(REPLACE(strPercentage,' ','') like '+%' OR REPLACE(strPercentage,' ','') like '-%' OR REPLACE(strPercentage,' ','') like '*%' OR REPLACE(strPercentage,' ','') like '/%')

UPDATE tblFRRowDesign SET strPercentage = '(' + strPercentage WHERE intRowId = @RowId and strRowType IN ('Filter Accounts') and strPercentage like '%)%' and strPercentage not like '%(%'
UPDATE tblFRRowDesign SET strPercentage = strPercentage + ')' WHERE intRowId = @RowId and strRowType IN ('Filter Accounts') and strPercentage like '%(%' and strPercentage not like '%)%'

-- SUM FUNCTION
INSERT INTO #TempSUMRows ([RowDetailId],[RefNo],[Formula],[Sort])
	SELECT intRowDetailId, intRefNo, strRelatedRows, intSort FROM tblFRRowDesign WHERE intRowId = @RowId and strRelatedRows like '%SUM%'

WHILE EXISTS(SELECT 1 FROM #TempSUMRows)
BEGIN
	DECLARE @MainFormula NVARCHAR(MAX)
	DECLARE @sumCount INT = 0

	SELECT TOP 1 @intRowDetailId = [RowDetailId], @Formula = [Formula], @MainFormula = [Formula], @intRefNoCurrent = [RefNo], @SORT = [Sort] FROM #TempSUMRows ORDER BY [Sort]

	WHILE (CHARINDEX('SUM',@MainFormula)>0)
	BEGIN
		DECLARE @counter_position INT = 1
		DECLARE @position_1_value INT = 0
		DECLARE @position_2_value INT = 0

		SET @Formula = SUBSTRING(@MainFormula,CHARINDEX('S',@MainFormula),(CHARINDEX(')',@MainFormula)-CHARINDEX('S',@MainFormula))+1)
		SET @Formula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Formula,' ',''),'SUM(',''),')',''),'R',''), CHAR(13), ''), CHAR(10), '') + ':'
		SET @sumCount = CHARINDEX(')',@MainFormula)

		WHILE (CHARINDEX(@SplitOn,@Formula)>0)
		BEGIN
			DECLARE @new_intRefNo INT

			IF((SELECT TOP 1 1 FROM #TempRowDesign2 WHERE RefNo = LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1)))) = 1)
			BEGIN						
				SET @new_intRefNo = (SELECT TOP 1 intRefNo FROM tblFRRowDesign WHERE intRowDetailId = (SELECT TOP 1 RowDetailId FROM #TempRowDesign2 WHERE RefNo = LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1)))))

				IF(@counter_position = 1)
				BEGIN
					IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @new_intRefNo AND strRowType IN ('Filter Accounts','Hidden','Cash Flow Activity','Current Year Earnings','Retained Earnings','Percentage','Row Calculation')) IS NULL)
					BEGIN
						SET @new_intRefNo = @new_intRefNo + 1
						SET @position_1_value = @new_intRefNo

						--PRINT 'counter pos 1 A'
						IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @new_intRefNo AND strRowType IN ('Filter Accounts','Hidden','Cash Flow Activity','Current Year Earnings','Retained Earnings','Percentage','Row Calculation')) IS NULL)
							BEGIN
								--PRINT 'counter pos 1 - A'
								SET @position_1_value = 0				
							END
						ELSE
							BEGIN
								--PRINT 'counter pos 1 - B'
								UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'(R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),'(R' + CAST(@new_intRefNo as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId
							END
					END
					ELSE
						BEGIN
							UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'(R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),'(R' + CAST(@new_intRefNo as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId					
						END
					SET @intRefNo_1 = @new_intRefNo
				END
				IF(@counter_position = 2)
				BEGIN				

					--PRINT 'counter pos 2'
					IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @new_intRefNo AND strRowType IN ('Filter Accounts','Hidden','Cash Flow Activity','Current Year Earnings','Retained Earnings','Percentage','Row Calculation')) IS NULL)
					BEGIN
						SET @new_intRefNo = @new_intRefNo - 1
						SET @position_2_value = @new_intRefNo

						--PRINT 'counter pos 2 - A'

						IF((SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @new_intRefNo AND strRowType IN ('Filter Accounts','Hidden','Cash Flow Activity','Current Year Earnings','Retained Earnings','Percentage','Row Calculation')) IS NULL)
						BEGIN
							--PRINT 'counter pos 2 - A1'
							SET @position_2_value = 0
							UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,':R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),':R' + CAST(@new_intRefNo - 1 as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId
						END
						ELSE
							BEGIN
								--PRINT 'counter pos 2 - A2'
								UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,':R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),':R' + CAST(@new_intRefNo as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId
							END
					END
					ELSE
						BEGIN
							--PRINT 'counter pos 2 - B'
							UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,':R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),':R' + CAST(@new_intRefNo as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId
						END
				END			
			END
			ELSE
			BEGIN
				SET @new_intRefNo = LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1)))
				WHILE (@new_intRefNo >= @intRefNo_1)
				BEGIN
					IF((SELECT TOP 1 1 FROM #TempRowDesign2 WHERE RefNo = @new_intRefNo) = 1 AND (SELECT TOP 1 1 FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @new_intRefNo 
							AND strRowType IN ('Filter Accounts','Hidden','Cash Flow Activity','Current Year Earnings','Retained Earnings','Percentage','Row Calculation')) IS NOT NULL)
					BEGIN
						UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,':R' + LTRIM(RTRIM(SUBSTRING(@Formula,1,CHARINDEX(@SplitOn,@Formula)-1))),':R' + CAST(@new_intRefNo as NVARCHAR(50))) WHERE intRowDetailId = @intRowDetailId
						SET @new_intRefNo = @intRefNo_1
					END
				
					SET @new_intRefNo =  @new_intRefNo- 1
				END
			END

			SET @Formula = SUBSTRING(@Formula,CHARINDEX(@SplitOn,@Formula)+1,LEN(@Formula))
			SET @counter_position = 2
		END

		SET @MainFormula = REPLACE(@MainFormula, SUBSTRING(@MainFormula,0, @sumCount+1), '')
	END

	DELETE #TempSUMRows WHERE RowDetailId = @intRowDetailId	
END

DROP TABLE #TempRowDesign


UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'X','R') WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows like '%SUM%'
UPDATE tblFRRowDesign SET strRelatedRows = REPLACE(strRelatedRows,'++','') WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and (strRelatedRows like '%+SUM%' or strRelatedRows like '%-SUM%' or strRelatedRows like '%*SUM%' or strRelatedRows like '%/SUM%')
UPDATE tblFRRowDesign SET strRelatedRows = SUBSTRING(strRelatedRows,2,LEN(strRelatedRows)) WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and (strRelatedRows like '+SUM%' or strRelatedRows like '-SUM%' or strRelatedRows like '*SUM%' or strRelatedRows like '/SUM%')
UPDATE tblFRRowDesign SET strRelatedRows = RIGHT(strRelatedRows, LEN(strRelatedRows) - 1) WHERE intRowId = @RowId and strRowType IN ('Row Calculation') and strRelatedRows like '+R%' 
and (strRelatedRows like '%+SUM%' or strRelatedRows like '%-SUM%' or strRelatedRows like '%*SUM%' or strRelatedRows like '%/SUM%')


END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDSortRowDesign] '38276:38277:38278:38279'


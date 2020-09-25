CREATE PROCEDURE [dbo].[uspFRDGetAccountsUsedForTotalCalculation]
	@RowId				AS INT,
	@RowDetailId		AS INT,
	@FilterString		NVARCHAR(MAX) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--BEGIN

DECLARE @SplitOn			NVARCHAR(10) = ':'
DECLARE @Formula			NVARCHAR(MAX) = ''
DECLARE @intRefNo			INT
DECLARE @BuildString		NVARCHAR(MAX) = ''
DECLARE @FormulaToReplace	NVARCHAR(MAX) = ''

CREATE TABLE #TempCalculationRowDesign (
	[Item]				NVARCHAR(1000)
);

-- +++++++++++++++++++++++++
--     NO SUM FORMULA
-- +++++++++++++++++++++++++
SELECT @Formula = strRelatedRows FROM tblFRRowDesign WHERE intRowDetailId = @RowDetailId
SET @FormulaToReplace = REPLACE(@Formula,'R',' R')
SET @Formula = REPLACE(REPLACE(REPLACE(@Formula, ' ',''), CHAR(13), ''), CHAR(10), '')

DECLARE @TempFormula	NVARCHAR(MAX) = ''
WHILE (CHARINDEX('SUM',@Formula)>0)
BEGIN	
	SELECT @TempFormula = SUBSTRING(@Formula,CHARINDEX('SUM',@Formula,0),CHARINDEX(')',@Formula,0))
	SET @Formula = REPLACE(@Formula,@TempFormula,'')
END

SET @Formula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Formula,':',''),'SUM(',''),')',''), CHAR(13), ''), CHAR(10), '')
SET @Formula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Formula,' ',''),'/',''),'*',''),'-',''),'+',''),'(',''),')','')

INSERT INTO #TempCalculationRowDesign (Item) SELECT * FROM dbo.fnSplitStringWithTrim(@Formula, 'R')

WHILE EXISTS(SELECT 1 FROM #TempCalculationRowDesign WHERE Item != '')
BEGIN
	SELECT TOP 1 @intRefNo = Item FROM #TempCalculationRowDesign WHERE Item != ''

	SELECT		TOP 1 @BuildString = strAccountsUsed
				FROM tblFRRowDesign 
				WHERE intRowId = @RowId AND intRefNo = @intRefNo

	SET @FormulaToReplace = REPLACE(@FormulaToReplace,' R' + CAST(@intRefNo as NVARCHAR(100)),' (' + @BuildString + ') ')

	DELETE TOP (1) FROM #TempCalculationRowDesign WHERE Item = @intRefNo
END

-- +++++++++++++++++++++++++
--       SUM FORMULA
-- +++++++++++++++++++++++++
SELECT @Formula = strRelatedRows FROM tblFRRowDesign WHERE intRowDetailId = @RowDetailId
SET @Formula = REPLACE(REPLACE(@Formula, CHAR(13), ''), CHAR(10), '')
SET @Formula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Formula,' ',''),'/',''),'*',''),'-',''),'+','')

WHILE (CHARINDEX('SUM',@Formula)>0)
BEGIN	
	DECLARE @FilterFormula		NVARCHAR(MAX)
	DECLARE @Filter				NVARCHAR(MAX)
	DECLARE @firstRef			INT
	DECLARE @secondRef			INT
	DECLARE @dataXML			XML
	DECLARE @data				NVARCHAR(MAX)

	SELECT @FilterFormula = SUBSTRING(@Formula,CHARINDEX('SUM',@Formula,0),CHARINDEX(')',@Formula,0))
	SET @Filter = REPLACE(REPLACE(REPLACE(@FilterFormula,':',''),'SUM(',''),')','')
	
	DELETE #TempCalculationRowDesign
	INSERT INTO #TempCalculationRowDesign (Item) SELECT * FROM dbo.fnSplitStringWithTrim(@Filter, 'R')

	SELECT @firstRef = Item FROM (SELECT TOP 1 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesign WHERE Item != '') AS tbl WHERE rownum = 1;
	SELECT @secondRef = Item FROM (SELECT TOP 2 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesign WHERE Item != '') AS tbl WHERE rownum = 2;

	SELECT @dataXML = (SELECT strAccountsUsed + ' or ' FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo >= @firstRef AND intRefNo <= @secondRef FOR XML PATH(''))
	SET @data = CAST(@dataXML AS NVARCHAR(MAX))

	SET @BuildString = @BuildString + @data
	SET @Formula = REPLACE(@Formula,@FilterFormula,'')

	SET @FormulaToReplace = REPLACE(@FormulaToReplace,'SUM( R' + CAST(@firstRef as NVARCHAR(100)) + ': R' +  + CAST(@secondRef as NVARCHAR(100)) + ')', ' (' + SUBSTRING(@BuildString,0,LEN(@BuildString)-2) + ') ')
END

--SET @BuildString = SUBSTRING(@BuildString,0,LEN(@BuildString)-2)
--SET @FormulaToReplace = SUBSTRING(@FormulaToReplace,0,LEN(@FormulaToReplace)-3) + ')'
SELECT @FilterString = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@FormulaToReplace,'(',''),')',''),'/',' or '),'*',' or '),'-',' or '),'+',' or ')


GO



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDGenerateCalculationDrillDownRows] 42, 6746


--DECLARE @FilterStringx NVARCHAR(MAX)
--EXEC dbo.uspFRDGenerateCalculationDrillDownRows @RowId = 42, @RowDetailId = 6746, @FilterString = @FilterStringx  OUTPUT

--SELECT @FilterStringx AS 'TEST'


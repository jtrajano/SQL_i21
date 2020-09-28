CREATE PROCEDURE [dbo].[uspFRDGenerateCalculationDrillDownRows]
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
DECLARE @FormulaSUM			NVARCHAR(MAX) = ''
DECLARE @intRefNo			INT
DECLARE @BuildString		NVARCHAR(MAX) = ''
DECLARE @FormulaToReplace	NVARCHAR(MAX) = ''
DECLARE @BalanceSide		NVARCHAR(100) = ''
DECLARE @GLSide				NVARCHAR(100) = 'ISNULL(SUM(dblDebit-dblCredit),0)'

DECLARE @FilterFormula		NVARCHAR(MAX)
DECLARE @Filter				NVARCHAR(MAX)
DECLARE @RowType			NVARCHAR(MAX)
DECLARE @firstRef			INT
DECLARE @secondRef			INT
DECLARE @dataXML			XML
DECLARE @data				NVARCHAR(MAX)

CREATE TABLE #TempCalculationRowDesign (
	[Item]				NVARCHAR(1000)
);
CREATE TABLE #TempCalculationRowDesignSUM (
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
SELECT * FROM #TempCalculationRowDesign
WHILE EXISTS(SELECT 1 FROM #TempCalculationRowDesign WHERE Item != '')
BEGIN
	SELECT TOP 1 @intRefNo = Item FROM #TempCalculationRowDesign WHERE Item != ''

	SELECT		TOP 1 @BuildString = strAccountsUsed, @BalanceSide = strBalanceSide, @RowType = strRowType
				FROM tblFRRowDesign 
				WHERE intRowId = @RowId AND intRefNo = @intRefNo

	IF(@BalanceSide = 'Credit')
	BEGIN
		SET @GLSide = 'ISNULL(SUM(dblCredit-dblDebit),0)'
	END
	ELSE
	BEGIN
		SET @GLSide = 'ISNULL(SUM(dblDebit-dblCredit),0)'
	END


	IF(@RowType = 'Row Calculation')
	BEGIN

		-- +++++++++++++++++++++++++
		--       SUM FORMULA
		-- +++++++++++++++++++++++++
		SELECT @FormulaSUM = strRelatedRows FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo = @intRefNo		
		SET @FormulaSUM = REPLACE(REPLACE(@FormulaSUM, CHAR(13), ''), CHAR(10), '')
		SET @FormulaSUM = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@FormulaSUM,' ',''),'/',''),'*',''),'-',''),'+','')
		SET @FormulaSUM = REPLACE(REPLACE(REPLACE(@FormulaSUM,'R',' R'), CHAR(13), ''), CHAR(10), '')

		WHILE (CHARINDEX('SUM',@FormulaSUM)>0)
		BEGIN	
			SET @FilterFormula	= ''
			SET @Filter			= ''
			SET @RowType		= ''
			SET @firstRef		= NULL
			SET @secondRef		= NULL
			SET @dataXML		= NULL
			SET @data			= ''

			SELECT @FilterFormula = SUBSTRING(@FormulaSUM,CHARINDEX('SUM',@FormulaSUM,0),CHARINDEX(')',@FormulaSUM,0))
			SET @Filter = REPLACE(REPLACE(REPLACE(@FilterFormula,':',''),'SUM(',''),')','')
	
			DELETE #TempCalculationRowDesignSUM
			INSERT INTO #TempCalculationRowDesignSUM (Item) SELECT * FROM dbo.fnSplitStringWithTrim(@Filter, 'R')

			SELECT @firstRef = Item FROM (SELECT TOP 1 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesignSUM WHERE Item != '') AS tbl WHERE rownum = 1;
			SELECT @secondRef = Item FROM (SELECT TOP 2 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesignSUM WHERE Item != '') AS tbl WHERE rownum = 2;

			SELECT @dataXML = (SELECT strAccountsUsed + ' or ' FROM tblFRRowDesign WHERE intRowId = @RowId AND intRefNo >= @firstRef AND intRefNo <= @secondRef FOR XML PATH(''))
			SET @data = CAST(@dataXML AS NVARCHAR(MAX))

			SET @BuildString = @BuildString + @data
			

			SELECT		TOP 1 @BalanceSide = strBalanceSide, @RowType = strRowType
						FROM tblFRRowDesign 
						WHERE intRowId = @RowId AND intRefNo = @firstRef

			IF(@BalanceSide = 'Credit')
			BEGIN
				SET @GLSide = 'ISNULL(SUM(dblCredit-dblDebit),0)'
			END
			ELSE
			BEGIN
				SET @GLSide = 'ISNULL(SUM(dblDebit-dblCredit),0)'
			END

			--SELECT @FormulaSUM as Formula
			--SELECT 'SUM( R' + CAST(@firstRef as NVARCHAR(100)) + ': R' +  + CAST(@secondRef as NVARCHAR(100)) + ')' as toFindFormula
			--SELECT '(SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + SUBSTRING(@BuildString,0,LEN(@BuildString)-2) + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) ' as toReplaceFormula

			--SELECT REPLACE(@FormulaSUM,'SUM( R' + CAST(@firstRef as NVARCHAR(100)) + ': R' +  + CAST(@secondRef as NVARCHAR(100)) + ')', '(SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + SUBSTRING(@BuildString,0,LEN(@BuildString)-2) + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) ') as rightString
			SET @FormulaToReplace = REPLACE( @FormulaToReplace, ' R' + CAST(@intRefNo as NVARCHAR(100)), REPLACE(@FormulaSUM,'SUM( R' + CAST(@firstRef as NVARCHAR(100)) + ': R' +  + CAST(@secondRef as NVARCHAR(100)) + ')', '(SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + SUBSTRING(@BuildString,0,LEN(@BuildString)-2) + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) '))
			--SELECT @FormulaToReplace as strUpdatedString

			SET @FormulaSUM = REPLACE(@Formula,@FilterFormula,'')
		END

	END
	ELSE
	BEGIN
		--SELECT @FormulaToReplace as R20String
		--SELECT ' (SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + @BuildString + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) ' as forNOTSUM
		--SELECT 'R' + CAST(@intRefNo as NVARCHAR(100)) as toFINDNOTSUM
		SET @FormulaToReplace = REPLACE(@FormulaToReplace,'R' + CAST(@intRefNo as NVARCHAR(100)),' (SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + @BuildString + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) ')
	END

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
	SET @FilterFormula	= ''
	SET @Filter			= ''
	SET @RowType		= ''
	SET @firstRef		= NULL
	SET @secondRef		= NULL
	SET @dataXML		= NULL
	SET @data			= ''

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

	SELECT		TOP 1 @BalanceSide = strBalanceSide, @RowType = strRowType
				FROM tblFRRowDesign 
				WHERE intRowId = @RowId AND intRefNo = @firstRef

	IF(@BalanceSide = 'Credit')
	BEGIN
		SET @GLSide = 'ISNULL(SUM(dblCredit-dblDebit),0)'
	END
	ELSE
	BEGIN
		SET @GLSide = 'ISNULL(SUM(dblDebit-dblCredit),0)'
	END

	SET @FormulaToReplace = REPLACE(@FormulaToReplace,'SUM( R' + CAST(@firstRef as NVARCHAR(100)) + ': R' +  + CAST(@secondRef as NVARCHAR(100)) + ')', '(SELECT ' + @GLSide + ' FROM vyuGLSummary WHERE (' + SUBSTRING(@BuildString,0,LEN(@BuildString)-2) + ') AND (INSERT_HIERARCHY) AND (INSERT_FILTERS_HERE) ) ')
END

--SET @BuildString = SUBSTRING(@BuildString,0,LEN(@BuildString)-2)
--SET @FormulaToReplace = SUBSTRING(@FormulaToReplace,0,LEN(@FormulaToReplace)-3) + ')'
SELECT @FilterString = @FormulaToReplace


GO



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDGenerateCalculationDrillDownRows] 42, 6746


--DECLARE @FilterStringx NVARCHAR(MAX)
--EXEC dbo.uspFRDGenerateCalculationDrillDownRows @RowId = 42, @RowDetailId = 6746, @FilterString = @FilterStringx  OUTPUT

--SELECT @FilterStringx AS 'TEST'


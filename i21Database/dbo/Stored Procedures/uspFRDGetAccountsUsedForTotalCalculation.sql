CREATE PROCEDURE [dbo].[uspFRDGetAccountsUsedForTotalCalculation]
	@RowId				AS INT,
	@RowDetailId		AS INT,
	@FilterString		NVARCHAR(MAX) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SplitOn			NVARCHAR(10) = ':'
DECLARE @Formula			NVARCHAR(MAX) = ''
DECLARE @FormulaR			NVARCHAR(MAX) = ''
DECLARE @R_AccountUsed		NVARCHAR(MAX) = ''
DECLARE @R_Formula			NVARCHAR(MAX) = ''
DECLARE @intRefNo			INT
DECLARE @BuildString		NVARCHAR(MAX) = ''
DECLARE @FormulaToReplace	NVARCHAR(MAX) = ''
DECLARE @BalanceSide		NVARCHAR(100) = ''
DECLARE @GLSide				NVARCHAR(100) = 'ISNULL(SUM(dblDebit-dblCredit),0)'
DECLARE @FilterFormula		NVARCHAR(MAX)

DECLARE @FormulaSUMBuild	NVARCHAR(MAX)
DECLARE @FormulaSUM			NVARCHAR(MAX)
DECLARE @Filter				NVARCHAR(MAX)
DECLARE @RowType			NVARCHAR(MAX)
DECLARE @tempfirstRef		INT
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

SET @FilterString = ''
SELECT @Formula = strRelatedRows, @FormulaToReplace = strRelatedRows FROM tblFRRowDesign WHERE intRowDetailId = @RowDetailId

-- +++++++++++++++++++++++++++++++++++++++++++++++++
--	  REMOVE INVALID CHARACTERS AND POSITiON "R"
-- +++++++++++++++++++++++++++++++++++++++++++++++++
SET @Formula = REPLACE(REPLACE(REPLACE(@Formula, ' ',''), CHAR(13), ''), CHAR(10), '')
SET @Formula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Formula,' ',''),'/',' / '),'*',' * '),'-',' - '),'+',' + '),'(',' ( '),')',' ) ')
SET @Formula = REPLACE(@Formula,'R',' R')
SET @Formula = @Formula + ' '
SET @FormulaToReplace = @Formula
select @Formula

-- +++++++++++++++++++++++++++++++++++++++++++++++++
--			 REPLACE R with Rs to Xs
-- +++++++++++++++++++++++++++++++++++++++++++++++++
DECLARE @TempFormula	NVARCHAR(MAX) = @FormulaToReplace
WHILE (CHARINDEX(' R',@TempFormula)>0)
BEGIN
	
	IF(CHARINDEX(' R',@TempFormula,0) > CHARINDEX('SUM',@TempFormula,0) AND CHARINDEX('SUM',@TempFormula,0) > 0)
	BEGIN
		IF(CHARINDEX('SUM',@TempFormula)>0)
		BEGIN
			DECLARE @_SumFormula AS NVARCHAR(MAX) = ''

			SET @_SumFormula = @TempFormula			
			SET @_SumFormula = REPLACE(REPLACE(@_SumFormula, CHAR(13), ''), CHAR(10), '')
			SET @_SumFormula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_SumFormula,' ',''),'/',''),'*',''),'-',''),'+','')
			SET @_SumFormula = REPLACE(@_SumFormula,'R',' R')
			SET @_SumFormula = SUBSTRING(@_SumFormula,CHARINDEX('SUM',@_SumFormula,0),(CHARINDEX(')',@_SumFormula,CHARINDEX('SUM',@_SumFormula,0)) + 1)-CHARINDEX('SUM',@_SumFormula,0))
			
			WHILE (CHARINDEX('SUM',@_SumFormula)>0)
			BEGIN	
				SET @FormulaSUM		= ''
				SET @Filter			= ''
				SET @RowType		= ''
				SET @tempfirstRef	= NULL
				SET @firstRef		= NULL
				SET @secondRef		= NULL
				SET @FormulaSUMBuild = ''

				SELECT @FormulaSUM = SUBSTRING(@_SumFormula,CHARINDEX('SUM',@_SumFormula,0),CHARINDEX(')',@_SumFormula,0))
				SET @Filter = REPLACE(REPLACE(REPLACE(@FormulaSUM,':',''),'SUM(',''),')','')
	
				DELETE #TempCalculationRowDesign
				INSERT INTO #TempCalculationRowDesign (Item) SELECT * FROM dbo.fnSplitStringWithTrim(@Filter, 'R')

				SELECT @firstRef = Item FROM (SELECT TOP 1 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesign WHERE Item != '') AS tbl WHERE rownum = 1;
				SELECT @secondRef = Item FROM (SELECT TOP 2 Item, Row_Number() OVER (ORDER BY Item) AS rownum FROM #TempCalculationRowDesign WHERE Item != '') AS tbl WHERE rownum = 2;

				IF(@firstRef>@secondRef)
				BEGIN
					SET @tempfirstRef = @firstRef
					SET @firstRef = @secondRef
					SET @secondRef = @tempfirstRef
				END

				WHILE(@firstRef<=@secondRef)
				BEGIN
					SET @FormulaSUMBuild = @FormulaSUMBuild + ' R' + CAST(@firstRef as NVARCHAR(10)) + ' + '
					SET @firstRef = @firstRef + 1
				END				

				SET @TempFormula = REPLACE(@TempFormula,' ','')
				SET @FormulaSUMBuild = REPLACE(@FormulaSUMBuild,' ','')
				SET @_SumFormula = REPLACE(@_SumFormula,' ','')
				
				SET @TempFormula = REPLACE(@TempFormula,@_SumFormula,'('+SUBSTRING(@FormulaSUMBuild,0,LEN(@FormulaSUMBuild)) + ')')
				SET @TempFormula = REPLACE(REPLACE(REPLACE(@TempFormula, ' ',''), CHAR(13), ''), CHAR(10), '')
				SET @TempFormula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TempFormula,' ',''),'/',' / '),'*',' * '),'-',' - '),'+',' + '),'(',' ( '),')',' ) '),':',' : ')
				SET @TempFormula = REPLACE(@TempFormula,'R',' R') + ' '
				SET @_SumFormula = ''
			END
		END
	END
	ELSE
	BEGIN
		SELECT @FormulaR = SUBSTRING(@TempFormula,CHARINDEX(' R',@TempFormula,0),(CHARINDEX(' ',@TempFormula,(CHARINDEX(' R',@TempFormula,0)+1))-CHARINDEX(' R',@TempFormula,0)))
		SELECT @intRefNo = CAST(REPLACE(REPLACE(@FormulaR,'R',''),' ','') as INT)

		SELECT		TOP 1 @R_AccountUsed = strAccountsUsed, @R_Formula = strRelatedRows, @RowType = strRowType
					FROM tblFRRowDesign 
					WHERE intRowId = @RowId AND intRefNo = @intRefNo

		IF(@RowType = 'Row Calculation')
		BEGIN
			SET @TempFormula = REPLACE(@TempFormula,@FormulaR + ' ', ' ( ' + @R_Formula + ' ) ')
			SET @TempFormula = REPLACE(REPLACE(REPLACE(@TempFormula, ' ',''), CHAR(13), ''), CHAR(10), '')
			SET @TempFormula = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@TempFormula,' ',''),'/',' / '),'*',' * '),'-',' - '),'+',' + '),'(',' ( '),')',' ) ')
			SET @TempFormula = REPLACE(@TempFormula,'R',' R') + ' '
		END
		ELSE
		BEGIN
			SET @TempFormula = REPLACE(@TempFormula,@FormulaR + ' ',REPLACE(@FormulaR,'R','X') + ' ')
		END
	END
	
END

SET @FilterFormula = @TempFormula
SELECT @FilterFormula


-- BUILD QUERY STRING
WHILE (CHARINDEX(' X',@TempFormula)>0)
BEGIN
	SELECT @FormulaR = SUBSTRING(@TempFormula,CHARINDEX(' X',@TempFormula,0),(CHARINDEX(' ',@TempFormula,(CHARINDEX(' X',@TempFormula,0)+1))-CHARINDEX(' X',@TempFormula,0)))
	SELECT @intRefNo = CAST(REPLACE(REPLACE(@FormulaR,'X',''),' ','') as INT)

	SELECT		TOP 1 @R_AccountUsed = strAccountsUsed, @R_Formula = strRelatedRows, @RowType = strRowType
				FROM tblFRRowDesign 
				WHERE intRowId = @RowId AND intRefNo = @intRefNo

	IF(@RowType = 'Filter Accounts')
	BEGIN
		SET @TempFormula = REPLACE(@TempFormula,' X' + CAST(@intRefNo as NVARCHAR(100)) + ' ',' ')	
		SET @FilterString = @FilterString + @R_AccountUsed + ' or '
	END
	
END

SELECT @FilterString = SUBSTRING(@FilterString,0,LEN(@FilterString)-2)
SELECT @FilterString

GO



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDGetAccountsUsedForTotalCalculation] 42, 6746


--DECLARE @FilterStringx NVARCHAR(MAX)
--EXEC dbo.uspFRDGetAccountsUsedForTotalCalculation @RowId = 42, @RowDetailId = 6746, @FilterString = @FilterStringx  OUTPUT

--SELECT @FilterStringx AS 'TEST'


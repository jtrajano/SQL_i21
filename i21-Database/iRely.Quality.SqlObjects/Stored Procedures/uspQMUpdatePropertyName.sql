CREATE PROCEDURE uspQMUpdatePropertyName
	@strOldName NVARCHAR(MAX)
	,@strNewName NVARCHAR(MAX)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @SQL NVARCHAR(MAX)
	,@SQL1 NVARCHAR(MAX)

-- Updating property name in Template formula
SELECT @SQL = 'UPDATE tblQMProductProperty SET strFormulaField = REPLACE(REPLACE(REPLACE(REPLACE(strFormulaField,''{' + @strOldName + ','', ''{' + @strNewName + ',''), '',' + @strOldName + '}'', '',' + @strNewName + '}''), '',' + @strOldName + ','', '',' + @strNewName + ',''),''{' + @strOldName + '}'',''{' + @strNewName + '}'') WHERE ISNULL(strFormulaField, '''') <> '''''

EXEC (@SQL)

-- Updating property name in Test Result formula
SELECT @SQL1 = 'UPDATE tblQMTestResult SET strFormula = REPLACE(REPLACE(REPLACE(REPLACE(strFormula,''{' + @strOldName + ','', ''{' + @strNewName + ',''), '',' + @strOldName + '}'', '',' + @strNewName + '}''), '',' + @strOldName + ','', '',' + @strNewName + ',''),''{' + @strOldName + '}'',''{' + @strNewName + '}'') WHERE ISNULL(strFormula, '''') <> '''''

EXEC (@SQL1)

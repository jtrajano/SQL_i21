CREATE PROCEDURE [dbo].[uspSMGetLogoPreference]
	@intCompanyLocationId INT,
	@reportName NVARCHAR(MAX)
AS
	DECLARE @sqlQuery NVARCHAR(MAX)

	SET @sqlQuery = 'SELECT [intLogoPreferenceId]
      ,[strLogoName]
      ,[imgLogo]
      ,[ysnDefault]
      ,[ysnARInvoice]
      ,[ysnARStatement]
      ,[ysnContract]
      ,[ysnAllOtherReports]
      ,[intCompanyLocationId]
      ,[intConcurrencyId] FROM tblSMLogoPreference WHERE intCompanyLocationId = @intCompanyLocationId '

SET @sqlQuery = REPLACE(@sqlQuery, '@intCompanyLocationId', @intCompanyLocationId)

IF @reportName = 'AR Invoice'
	BEGIN
		SET @sqlQuery = @sqlQuery + ' AND ysnARInvoice = 1'
	END
ELSE IF @reportName = 'AR Statement'
	BEGIN
		SET @sqlQuery = @sqlQuery + ' AND ysnARStatement = 1'
	END
ELSE IF @reportName = 'Contract'
	BEGIN
		SET @sqlQuery = @sqlQuery + ' AND ysnContract = 1'
	END
ELSE IF @reportName = 'Other Report'
	BEGIN
		SET @sqlQuery = @sqlQuery + ' AND ysnAllOtherReports = 1'
	END
ELSE
	BEGIN
		SET @sqlQuery = @sqlQuery + ' AND ysnDefault = 1'
	END

CREATE TABLE #tmpTable (intLogoPreferenceId INT, strLogoName NVARCHAR(MAX), imgLogo varbinary(MAX), ysnDefault BIT, ysnARInvoice BIT, ysnARStatement BIT, ysnContract BIT, ysnAllOtherReports BIT, intCompanyLocationId INT, intConcurrencyId INT)
EXEC('INSERT INTO #tmpTable ' + @sqlQuery)


IF EXISTS(SELECT TOP 1 * FROM #tmpTable)
	BEGIN
		SELECT * FROM #tmpTable
	END
ELSE
	BEGIN
		SELECT * FROM tblSMLogoPreference WHERE intCompanyLocationId = @intCompanyLocationId AND ysnDefault = 1
	END

DROP TABLE #tmpTable

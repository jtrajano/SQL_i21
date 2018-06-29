CREATE FUNCTION [dbo].[fnSMGetDefaultCurrency] (@type NVARCHAR(15))
RETURNS INT
AS
BEGIN
	DECLARE @currencyId INT = NULL

	IF UPPER(@type) = 'FUNCTIONAL'
		SELECT @currencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	ELSE IF UPPER(@type) = 'REPORTING'
		SELECT @currencyId = intDefaultReportingCurrencyId FROM tblSMCompanyPreference
	
	RETURN @currencyId
END
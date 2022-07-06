CREATE FUNCTION [dbo].[fnFAGetDefaultCurrencyExchangeRateTypeId]()
RETURNS INT
AS
BEGIN
	DECLARE @intDefaultRateTypeId INT = NULL
	SELECT TOP 1 @intDefaultRateTypeId = intFixedAssetsRateTypeId FROM tblSMMultiCurrency

	IF (@intDefaultRateTypeId IS NULL)
		SELECT TOP 1 @intDefaultRateTypeId = intCurrencyExchangeRateTypeId FROM tblSMCurrencyExchangeRateType WHERE strCurrencyExchangeRateType = 'Spot'

	RETURN @intDefaultRateTypeId
END

CREATE FUNCTION [dbo].[fnRKGetCurrencyConvertion]
(
	@intFromCurrencyId INT
	,@intToCurrencyId INT	
)
RETURNS NUMERIC(18, 6)
AS
BEGIN
	DECLARE @numRate AS NUMERIC(18, 6)
	IF (@intFromCurrencyId<>@intToCurrencyId)
	BEGIN
		SELECT @numRate=numRate from tblSMCurrencyExchangeRate er
		JOIN tblSMCurrencyExchangeRateDetail rd on er.intCurrencyExchangeRateId=rd.intCurrencyExchangeRateId
		WHERE intFromCurrencyId=@intFromCurrencyId and intToCurrencyId=@intToCurrencyId
	END
	ELSE
	BEGIN
	SET @numRate=1
	END
	 
	RETURN @numRate
END
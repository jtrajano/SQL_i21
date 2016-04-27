CREATE FUNCTION [dbo].[fnRKGetCurrencyConversionRate]
(
	@intFromCurrencyId	INT,
	@intToCurrencyId	int,
	@intItemId int,
	@intFromUom int,
	@intToUom int,
	@Price numeric(18,6) 
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	
	DECLARE @dblResult numeric(18,6),
	@intFromCurrencyId1 int
	declare @ysnSubCurrency bit
	select @ysnSubCurrency=ysnSubCurrency from tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1

	IF EXISTS(select * from tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1)
			SELECT @Price = @Price/100

	IF EXISTS (SELECT * FROM tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1)
		BEGIN
			SELECT @intFromCurrencyId=intMainCurrencyId FROM tblSMCurrency  WHERE intCurrencyID=@intFromCurrencyId
		END 

	if (@intFromCurrencyId <>@intToCurrencyId)
			BEGIN

				SELECT	TOP 1 @dblResult = @Price* RD.[dblRate] 
				FROM	tblSMCurrencyExchangeRate ER
				JOIN	tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE	(ER.intFromCurrencyId = @intFromCurrencyId AND ER.intToCurrencyId = @intToCurrencyId) 
				ORDER BY RD.dtmValidFromDate DESC

			END
			ELSE 
			SELECT @dblResult=@Price
			
	
	SELECT @dblResult= dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId,@intToUom,@intFromUom,@dblResult)
	

	RETURN @dblResult
	
END

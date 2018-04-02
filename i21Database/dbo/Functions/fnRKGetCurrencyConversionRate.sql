CREATE FUNCTION [dbo].[fnRKGetCurrencyConversionRate]
(
	@intContractDetailId INT,
	@intToCurrencyId	int,
	@intToUom int,
	@Price numeric(18,6),
	@intCostCurrencyId INT = NULL
) 
RETURNS NUMERIC(38,20)
AS 
BEGIN 	
	DECLARE @dblResult numeric(18,6)
	DECLARE @intFromCurrencyId1 int
	DECLARE @ysnSubCurrency bit
	DECLARE @intFromCurrencyId	INT
	DECLARE @intItemId INT
	DECLARE @intFromUom INT 
	DECLARE @dblRate numeric(18,6)
	DECLARE @intCurrencyExchangeRateId INT
	DECLARE @intExchangeRateFromId INT
	DECLARE @intExchangeRateToId INT
	
	SELECT  @intFromCurrencyId=case when isnull(@intCostCurrencyId,0)<> 0 then @intCostCurrencyId else intCurrencyId end, @intItemId=intItemId ,
			@intFromUom=intPriceUnitMeasureId ,@dblRate = dblRate ,@intCurrencyExchangeRateId=intCurrencyExchangeRateId
	FROM  vyuRKPositionByPeriodContDetView WHERE intContractDetailId=@intContractDetailId
	
	IF (ISNULL(@intCurrencyExchangeRateId,0)<>0)
	BEGIN
	SELECT @intExchangeRateFromId=intFromCurrencyId, @intExchangeRateToId= intToCurrencyId 
	FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId=@intCurrencyExchangeRateId
	END
	ELSE
	BEGIN
				
		SELECT top 1 @intCurrencyExchangeRateId=intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate WHERE intFromCurrencyId= @intFromCurrencyId 
				AND intToCurrencyId=@intToCurrencyId
		IF (ISNULL(@intCurrencyExchangeRateId,0)=0)
		BEGIN
			SELECT top 1 @intCurrencyExchangeRateId=intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate WHERE intFromCurrencyId= @intToCurrencyId 
				AND intToCurrencyId=@intFromCurrencyId
		END
		
		SELECT @intExchangeRateFromId=intFromCurrencyId, @intExchangeRateToId= intToCurrencyId 
		FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId=@intCurrencyExchangeRateId
	END

	SELECT @ysnSubCurrency=ysnSubCurrency FROM tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1

	IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1)
			SELECT @Price = @Price/100

	IF EXISTS (SELECT * FROM tblSMCurrency WHERE intCurrencyID=@intFromCurrencyId and ysnSubCurrency=1)
		BEGIN
			SELECT @intFromCurrencyId=intMainCurrencyId FROM tblSMCurrency  WHERE intCurrencyID=@intFromCurrencyId
		END 

	IF (@intFromCurrencyId <> @intToCurrencyId)
			BEGIN
			
				if (@intExchangeRateFromId = @intFromCurrencyId)
					BEGIN
					
						IF (isnull(@dblRate,0)<> 0)
						BEGIN
							SELECT @dblResult = @Price* @dblRate
						END
						ELSE
						BEGIN
							SELECT	TOP 1 @dblResult = @Price * RD.[dblRate]
							FROM	tblSMCurrencyExchangeRate ER
							JOIN	tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
							WHERE	ER.intCurrencyExchangeRateId=@intCurrencyExchangeRateId
							ORDER BY RD.dtmValidFromDate DESC
						END
					END
					ELSE
					BEGIN
					
						IF (isnull(@dblRate,0)<> 0)
						BEGIN
							SELECT @dblResult = @Price/@dblRate
						END
						ELSE
						BEGIN
						
							SELECT	TOP 1 @dblResult = @Price/ RD.[dblRate]
							FROM	tblSMCurrencyExchangeRate ER
							JOIN	tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
							WHERE	ER.intCurrencyExchangeRateId=@intCurrencyExchangeRateId
							ORDER BY RD.dtmValidFromDate DESC
						END

					END
			END
			ELSE 
			SELECT @dblResult=@Price		
	SELECT @dblResult= dbo.[fnCTConvertQuantityToTargetItemUOM](@intItemId,@intToUom,@intFromUom,@dblResult)	
	RETURN @dblResult	
END
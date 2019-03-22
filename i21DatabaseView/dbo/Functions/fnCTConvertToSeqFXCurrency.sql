CREATE FUNCTION [dbo].[fnCTConvertToSeqFXCurrency]
(
	@intContractDetailId	INT,
	@intValueCurrencyId		INT,
	@intValueUOMId			INT,
	@dblValue				NUMERIC(18,6)
)

RETURNS	NUMERIC(18,6)

AS
BEGIN

	DECLARE		@dblResult				NUMERIC(18,6)	=	@dblValue,
				@dblRate				NUMERIC(18,6),
				@intFXPriceUOMId		INT,
				@intExchangeRateId		INT,
				@dblMainValuePrice		NUMERIC(18,6)	=	@dblValue,
				@intMainValueCurrencyId	INT				=	@intValueCurrencyId,
				@ysnUseFXPrice			BIT

	IF EXISTS(SELECT * FROM tblSMCurrency WHERE intCurrencyID =@intValueCurrencyId AND ysnSubCurrency = 1)
	BEGIN
		SELECT @intMainValueCurrencyId = intMainCurrencyId,@dblMainValuePrice = @dblValue/100 FROM tblSMCurrency WHERE intCurrencyID =@intValueCurrencyId AND ysnSubCurrency = 1
	END


	SELECT		@dblRate			=	CD.dblRate,
				@intFXPriceUOMId	=	CD.intFXPriceUOMId,
				@intExchangeRateId	=	CD.intCurrencyExchangeRateId,
				@ysnUseFXPrice		=	CD.ysnUseFXPrice

	FROM		tblCTContractDetail CD
	LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID	= CD.intCurrencyId
	LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId		= CD.intPriceItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN	tblICItemUOM		FU	ON	FU.intItemUOMId		= CD.intFXPriceUOMId
	LEFT JOIN	tblICUnitMeasure	FM	ON	FM.intUnitMeasureId = FU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		AY	ON	AY.intCurrencyID	= CD.intBasisCurrencyId
	WHERE		intContractDetailId = @intContractDetailId


	IF	ISNULL(@ysnUseFXPrice,0) = 1 AND @intExchangeRateId IS NOT NULL AND @dblRate IS NOT NULL AND @intFXPriceUOMId IS NOT NULL
	BEGIN
		IF EXISTS(SELECT * FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intToCurrencyId = @intMainValueCurrencyId)
		BEGIN
			SELECT @dblRate = 1 / CASE WHEN ISNULL(@dblRate,0) = 0 THEN 1 ELSE @dblRate END
		END

		SELECT @dblResult =	dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intValueUOMId,@dblMainValuePrice) * @dblRate
				
	END

	RETURN @dblResult;

END

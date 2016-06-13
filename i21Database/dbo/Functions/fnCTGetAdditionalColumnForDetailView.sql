﻿CREATE FUNCTION [dbo].[fnCTGetAdditionalColumnForDetailView]
(
	@intContractDetailId	INT
)

RETURNS	@returntable	TABLE
(
	intSeqCurrencyId	INT,
	ysnSeqSubCurrency	BIT,
	intSeqPriceUOMId	INT,
	dblSeqPrice			NUMERIC(18,6),
	strSeqCurrency		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strSeqPriceUOM		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblQtyToPriceUOMConvFactor NUMERIC(18,6)
)

AS
BEGIN

	DECLARE		@dblCashPrice		NUMERIC(18,6),
				@intCurrencyId		INT,
				@intPriceItemUOMId	INT,
				@dblRate			NUMERIC(18,6),
				@intFXPriceUOMId	INT,
				@intExchangeRateId	INT,
				@intSeqCurrencyId	INT,
				@strSeqCurrency		NVARCHAR(100),
				@intItemUOMId		INT,
				@ysnSubCurrency		BIT,
				@dblMainCashPrice	NUMERIC(18,6),
				@strCurrency		NVARCHAR(100),
				@strPriceUOM		NVARCHAR(100),
				@strFXPriceUOM		NVARCHAR(100),
				@intMainCurrencyId	INT,
				@ysnUseFXPrice		BIT


	SELECT		@dblCashPrice		=	CD.dblCashPrice,
				@dblMainCashPrice	=	CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(intCent,1) ELSE 1 END,
				@intCurrencyId		=	CD.intCurrencyId,
				@intMainCurrencyId	=	ISNULL(CY.intMainCurrencyId,CD.intCurrencyId),
				@ysnSubCurrency		=	CY.ysnSubCurrency,
				@intPriceItemUOMId	=	CD.intPriceItemUOMId,
				@dblRate			=	CD.dblRate,
				@intFXPriceUOMId	=	CD.intFXPriceUOMId,
				@intExchangeRateId	=	CD.intCurrencyExchangeRateId,
				@intItemUOMId		=	CD.intItemUOMId,
				@strCurrency		=	CY.strCurrency,
				@strPriceUOM		=	UM.strUnitMeasure,
				@strFXPriceUOM		=	FM.strUnitMeasure,
				@ysnUseFXPrice		=	ysnUseFXPrice
	FROM		tblCTContractDetail CD
	LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID	= CD.intCurrencyId
	LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId		= CD.intPriceItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN	tblICItemUOM		FU	ON	FU.intItemUOMId		= CD.intFXPriceUOMId
	LEFT JOIN	tblICUnitMeasure	FM	ON	FM.intUnitMeasureId = FU.intUnitMeasureId
	WHERE		intContractDetailId = @intContractDetailId


	IF	ISNULL(@ysnUseFXPrice,0) = 1 AND @intExchangeRateId IS NOT NULL AND @dblRate IS NOT NULL AND @intFXPriceUOMId IS NOT NULL
	BEGIN
		IF EXISTS(SELECT * FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intFromCurrencyId = @intMainCurrencyId)
		BEGIN
			SELECT @intSeqCurrencyId = intToCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intFromCurrencyId = @intMainCurrencyId
			SELECT @dblRate = 1/@dblRate
		END
		ELSE
		BEGIN
			SELECT @intSeqCurrencyId = intFromCurrencyId FROM tblSMCurrencyExchangeRate WHERE intCurrencyExchangeRateId = @intExchangeRateId AND intToCurrencyId = @intMainCurrencyId
		END

		SELECT @strSeqCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intSeqCurrencyId

		INSERT INTO @returntable
		SELECT	@intSeqCurrencyId,
				0,
				@intFXPriceUOMId,
				dbo.fnCTConvertQtyToTargetItemUOM(@intFXPriceUOMId,@intPriceItemUOMId,@dblMainCashPrice) * @dblRate,
				@strSeqCurrency,
				@strFXPriceUOM,
				dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intFXPriceUOMId,1)
	END
	ELSE
	BEGIN
		INSERT INTO @returntable
		SELECT	@intCurrencyId,
				@ysnSubCurrency,
				@intPriceItemUOMId,
				@dblCashPrice,
				@strCurrency,
				@strPriceUOM,
				dbo.fnCTConvertQtyToTargetItemUOM(@intItemUOMId,@intPriceItemUOMId,1)
	END

	RETURN;
END
CREATE FUNCTION [dbo].[fnLGGetTotalAmountPerLoad]
	(@intLoadId INT)
RETURNS @returntable TABLE (
	dblTotalAmount NUMERIC(18, 6)
	,dblTotalQtyInPriceUOM NUMERIC(18, 6)
	,intAmountCurrency INT
	,strAmountCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblTotalCostPerContainer NUMERIC(18, 6)
	,intContainerRateCurrency INT
	,dblCurrencyExchangeRate NUMERIC(18, 6)
	,dblBrokerage NUMERIC(18, 6)
	)
AS
BEGIN
	DECLARE @result NUMERIC(26, 16)
		,@intItemId INT
		,@IntFromUnitMeasureId INT
		,@intToUnitMeasureId INT
		,@dblUnitQtyTo NUMERIC(26, 16)
		,@intShippingLineEntityId INT
		,@dtmScheduledDate DATETIME
		,@dblTotalCostPerContainer NUMERIC(26, 16)
		,@intTotalCostPerContainerCurrency INT

	SELECT @intShippingLineEntityId = intShippingLineEntityId
		,@dtmScheduledDate = dtmScheduledDate
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @dblTotalCostPerContainer = dblTotalCostPerContainer
		,@intTotalCostPerContainerCurrency = intCurrencyId
	FROM tblLGFreightRateMatrix
	WHERE intEntityId = @intShippingLineEntityId
		AND @dtmScheduledDate BETWEEN dtmValidFrom
			AND dtmValidTo

	INSERT INTO @returntable
	SELECT SUM(dblTotalAmount) AS dblTotalAmount
		,SUM(dblTotalQtyInPriceUOM) AS dblTotalQtyInPriceUOM
		,intAmountCurrency
		,strAmountCurrency
		,ISNULL(@dblTotalCostPerContainer, 0)
		,@intTotalCostPerContainerCurrency
		,dblCurrencyExchangeRate
		,dblBrokerage * SUM(dblTotalAmount)
	FROM (
		SELECT dblNet
			,UM.intUnitMeasureId
			,ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId, AD.intSeqPriceUOMId, 1) * dblNet, 2) dblTotalQtyInPriceUOM
			,ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId, AD.intSeqPriceUOMId, 1) * dblNet, 2) * AD.dblSeqPrice AS dblTotalPrice
			,LD.intWeightItemUOMId
			,UM.strUnitMeasure AS dblWeightUOM
			,AD.intSeqPriceUOMId
			,AD.dblCostUnitQty
			,AD.dblSeqPrice
			,AD.strSeqCurrency
			,AD.intSeqCurrencyId
			,AD.strSeqPriceUOM
			,dblTotalAmount = CASE 
				WHEN ISNULL(CU.ysnSubCurrency, 0) = 1
					THEN (ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId, AD.intSeqPriceUOMId, 1) * dblNet, 2) * AD.dblSeqPrice) / 100
				ELSE ROUND(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId, AD.intSeqPriceUOMId, 1) * dblNet, 2) * AD.dblSeqPrice
				END
			,intAmountCurrency = CASE 
				WHEN ISNULL(CU.ysnSubCurrency, 0) = 1
					THEN MCU.intCurrencyID
				ELSE CU.intCurrencyID
				END
			,strAmountCurrency = CASE 
				WHEN ISNULL(CU.ysnSubCurrency, 0) = 1
					THEN MCU.strCurrency
				ELSE CU.strCurrency
				END
			,dblCurrencyExchangeRate = 1
			,dblBrokerage = (
				SELECT TOP 1 dblRate
				FROM tblCTContractCost CC
				JOIN tblICItem I ON I.intItemId = CC.intItemId
				WHERE intContractDetailId = CD.intContractDetailId
					AND I.strItemNo = 'Brokerage'
				)
		FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intWeightItemUOMId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		JOIN tblSMCurrency CU ON CU.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN tblSMCurrency MCU ON MCU.intCurrencyID = CU.intMainCurrencyId
		WHERE LD.intLoadId = @intLoadId
		) t
	GROUP BY intAmountCurrency
		,strAmountCurrency
		,t.dblCurrencyExchangeRate
		,dblBrokerage

	RETURN;
END
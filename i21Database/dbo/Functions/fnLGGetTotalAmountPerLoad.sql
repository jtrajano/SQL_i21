CREATE FUNCTION [dbo].[fnLGGetTotalAmountPerLoad]
	(@intLoadId INT)
RETURNS @returntable TABLE (
	dblTotalAmount NUMERIC(18, 6)
	,dblTotalQtyInPriceUOM NUMERIC(18, 6)
	,intAmountCurrency INT
	,strAmountCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblTotalCostPerContainer NUMERIC(18, 6)
	,intContainerRateCurrency INT
	,strContainerRateCurrency NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		,@strOriginPort NVARCHAR(100)
		,@strDestinationCity NVARCHAR(100)
		,@strTotalCostPerContainerCurrency NVARCHAR(100)
		,@dblCurrencyExchangeRate NUMERIC(26,16)

	SELECT @intShippingLineEntityId = intShippingLineEntityId
		,@dtmScheduledDate = dtmScheduledDate
		,@strOriginPort = strOriginPort
		,@strDestinationCity = strDestinationCity 
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @dblTotalCostPerContainer = dblTotalCostPerContainer
		,@intTotalCostPerContainerCurrency = intCurrencyId
		,@strTotalCostPerContainerCurrency = CU.strCurrency
	FROM tblLGFreightRateMatrix FRM
	JOIN tblSMCurrency CU ON CU.intCurrencyID = FRM.intCurrencyId
	WHERE intEntityId = @intShippingLineEntityId
		AND strOriginPort = @strOriginPort
		AND strDestinationCity = @strDestinationCity
		AND @dtmScheduledDate BETWEEN dtmValidFrom
			AND dtmValidTo
	
	SELECT @dblCurrencyExchangeRate = CASE 
			WHEN ISNULL(CD.intInvoiceCurrencyId,0) = @intTotalCostPerContainerCurrency
				THEN dblRate
			ELSE 1
			END
	FROM tblCTContractDetail CD
	JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
	WHERE LD.intLoadId = @intLoadId

	INSERT INTO @returntable
	SELECT SUM(dblTotalAmount) AS dblTotalAmount
		,SUM(dblTotalQtyInPriceUOM) AS dblTotalQtyInPriceUOM
		,intAmountCurrency
		,strAmountCurrency
		,ISNULL(@dblTotalCostPerContainer, 0)
		,ISNULL(@intTotalCostPerContainerCurrency,intAmountCurrency)
		,ISNULL(@strTotalCostPerContainerCurrency,strAmountCurrency)
		,ISNULL(dblCurrencyExchangeRate,1)
		,SUM(dblBrokerage * dblTotalAmount)
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
			,dblCurrencyExchangeRate = @dblCurrencyExchangeRate
            ,dblBrokerage = (
								SELECT SUM(CASE 
											WHEN  BCU.ysnSubCurrency = 1
												THEN (CC.dblRate / 100)/dbo.fnCTConvertQtyToTargetItemUOM(CC.intItemUOMId, CON.intNetWeightUOMId,1)
											ELSE (CC.dblRate )/dbo.fnCTConvertQtyToTargetItemUOM(CC.intItemUOMId, CON.intNetWeightUOMId,1)
											END)
								FROM tblCTContractCost CC
								JOIN tblICItem I ON I.intItemId = CC.intItemId
								JOIN tblCTContractDetail CON ON CON.intContractDetailId = CC.intContractDetailId
								LEFT JOIN tblSMCurrency BCU ON BCU.intCurrencyID = CC.intCurrencyId
								WHERE CC.intContractDetailId = CD.intContractDetailId
									AND I.strCostType = 'Commission'
							)
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId 
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

	RETURN;
END
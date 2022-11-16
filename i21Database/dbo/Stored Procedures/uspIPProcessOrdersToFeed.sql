CREATE PROCEDURE uspIPProcessOrdersToFeed @intLoadId INT
	,@intLoadDetailId INT
	,@intEntityId INT
	,@strRowState NVARCHAR(50) = '' --Cancel / Delete Status Flag
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dblLeadTime NUMERIC(18,6)

	SELECT @strRowState = 'Added'

	SELECT TOP 1 @dblLeadTime = ISNULL(LLT.dblPurchaseToShipment, 0) + ISNULL(LLT.dblPortToPort, 0) + ISNULL(LLT.dblPortToMixingUnit, 0) + ISNULL(LLT.dblMUToAvailableForBlending, 0)
	FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
	JOIN dbo.tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
		AND LD.intLoadDetailId = @intLoadDetailId
	JOIN tblICItem IM WITH (NOLOCK) ON IM.intItemId = CD.intItemId
	JOIN dbo.tblMFLocationLeadTime LLT WITH (NOLOCK) ON LLT.intPortOfDispatchId = CD.intLoadingPortId
		AND LLT.intPortOfArrivalId = CD.intDestinationPortId
		AND LLT.intBuyingCenterId = LD.intPCompanyLocationId
		AND LLT.intOriginId = ISNULL(IM.intOriginId, LLT.intOriginId)

	--DELETE FROM tblIPContractFeed WHERE intLoadDetailId = @intLoadDetailId AND intStatusId IS NULL

	INSERT INTO tblIPContractFeed
	(
			intLoadId,				intLoadDetailId,			intContractHeaderId,		intContractDetailId,
			intSampleId,			intBatchId,					intCompanyLocationId,		strLoadNumber,
			strVendorAccountNum,	strLocationName,			strCommodityCode,			strContractNumber,
			intContractSeq,			strERPContractNumber,		strERPPONumber,				strERPItemNumber,
			strItemNo,				dblQuantity,				strQuantityUOM,				dblNetWeight,
			strNetWeightUOM,		strPricingType,				dblCashPrice,				strPriceUOM,
			strPriceCurrency,		dtmStartDate,				dtmEndDate,					dtmPlannedAvailabilityDate,
			dtmUpdatedAvailabilityDate, strPurchasingGroup,		strPackingDescription,		strVirtualPlant,
			strLoadingPoint,		strDestinationPoint,		dblLeadTime,				strBatchId,
			intEntityId,			strRowState
	)
	SELECT	@intLoadId,				@intLoadDetailId,			CD.intContractHeaderId,		CD.intContractDetailId,
			NULL intSampleId,		NULL intBatchId,			LD.intPCompanyLocationId,	L.strLoadNumber,
			VE.strVendorAccountNum,	CL.strLocationName,			CO.strCommodityCode,		CH.strContractNumber,
			CD.intContractSeq,		CH.strCustomerContract,		CD.strERPPONumber,			CD.strERPItemNumber,
			I.strItemNo,			LD.dblQuantity,				UOM.strUnitMeasure,			LD.dblNet,
			WUOM.strUnitMeasure,	PT.strPricingType,			LD.dblUnitPrice,			PUOM.strUnitMeasure,
			CU.strCurrency,			CD.dtmStartDate,			CD.dtmEndDate,				CD.dtmPlannedAvailabilityDate,
			CD.dtmUpdatedAvailabilityDate, PG.strName,			CD.strPackingDescription,	NULL strVirtualPlant,
			LP.strCity,				DP.strCity,					@dblLeadTime,				NULL strBatchId,
			@intEntityId,			@strRowState
	FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
	JOIN dbo.tblLGLoad L WITH (NOLOCK) ON L.intLoadId = LD.intLoadId
		AND LD.intLoadDetailId = @intLoadDetailId
	JOIN dbo.tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN dbo.tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN dbo.tblAPVendor VE ON VE.intEntityId = CH.intEntityId
	JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
	JOIN dbo.tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
	JOIN dbo.tblICItem I ON I.intItemId = LD.intItemId
	LEFT JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM WIUOM ON WIUOM.intItemUOMId = LD.intWeightItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
	LEFT JOIN dbo.tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	LEFT JOIN dbo.tblICItemUOM PIUOM ON PIUOM.intItemUOMId = LD.intPriceUOMId
	LEFT JOIN dbo.tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
	LEFT JOIN dbo.tblSMCurrency	CU ON CU.intCurrencyID = LD.intPriceCurrencyId
	LEFT JOIN dbo.tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	LEFT JOIN dbo.tblSMCity LP ON LP.intCityId = CD.intLoadingPortId
	LEFT JOIN dbo.tblSMCity DP ON DP.intCityId = CD.intDestinationPortId
	WHERE LD.intLoadDetailId = @intLoadDetailId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH

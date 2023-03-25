CREATE PROCEDURE uspIPProcessOrdersToFeed @intLoadId INT
	,@intLoadDetailId INT
	,@intEntityId INT
	,@strRowState NVARCHAR(50) = '' --Added / Modified / Cancelled / Deleted
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dblLeadTime NUMERIC(18, 6)
		,@strMarketZoneCode NVARCHAR(50)

	SELECT @dblLeadTime = NULL
		,@strMarketZoneCode = NULL

	IF ISNULL(@strRowState, '') = ''
		SELECT @strRowState = 'Modified'

	DELETE
	FROM tblIPContractFeed
	WHERE intLoadDetailId = @intLoadDetailId
		AND ISNULL(strFeedStatus,'') = ''
		AND ISNULL(intStatusId, 1) = 1

	SELECT @strMarketZoneCode = strMarketZoneCode
	FROM dbo.tblLGLoad L WITH (NOLOCK)
	JOIN dbo.tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = L.intMarketZoneId
	WHERE intLoadId = @intLoadId

	IF EXISTS (SELECT *FROM tblLGLoadDetail WHERE intLoadDetailId=@intLoadDetailId AND intPContractDetailId IS NULL)
	BEGIN
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
				intEntityId,			strRowState,				strMarketZoneCode,			intDetailNumber
		)
		SELECT	@intLoadId,				@intLoadDetailId,			NULL,						NULL,
				B.intSampleId,			LD.intBatchId,				B.intBuyingCenterLocationId,L.strLoadNumber,
				VE.strVendorAccountNum,	CL.strLocationName,			CO.strCommodityCode,		S.strSampleNumber,
				NULL,					NULL,						L.strExternalShipmentNumber,LD.strExternalShipmentItemNumber,
				I.strItemNo,			LD.dblQuantity,				UOM.strUnitMeasure,			LD.dblNet,
				WUOM.strUnitMeasure,	'Cash',						LD.dblUnitPrice,			PUOM.strUnitMeasure,
				CU.strCurrency,			NULL,						NULL,						NULL,
				NULL,					CL.strOregonFacilityNumber,	NULL,						CL1.strOregonFacilityNumber,
				NULL,					NULL,						NULL,						B.strBatchId,
				@intEntityId,			@strRowState,				@strMarketZoneCode,			LD.intDetailNumber
		FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
		JOIN dbo.tblLGLoad L WITH (NOLOCK) ON L.intLoadId = LD.intLoadId
			AND LD.intLoadDetailId = @intLoadDetailId
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = LD.intItemId
		JOIN dbo.tblICCommodity CO WITH (NOLOCK) ON CO.intCommodityId = I.intCommodityId
		JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON IUOM.intItemUOMId = LD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		JOIN dbo.tblICItemUOM WIUOM WITH (NOLOCK) ON WIUOM.intItemUOMId = LD.intWeightItemUOMId
		JOIN dbo.tblICUnitMeasure WUOM WITH (NOLOCK) ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM PIUOM WITH (NOLOCK) ON PIUOM.intItemUOMId = LD.intPriceUOMId
		LEFT JOIN dbo.tblICUnitMeasure PUOM WITH (NOLOCK) ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency CU WITH (NOLOCK) ON CU.intCurrencyID = LD.intPriceCurrencyId
		JOIN dbo.tblMFBatch B WITH (NOLOCK) ON B.intBatchId = LD.intBatchId
		LEFT JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = B.intBuyingCenterLocationId
		LEFT JOIN dbo.tblSMCompanyLocation CL1 WITH (NOLOCK) ON CL1.intCompanyLocationId = B.intMixingUnitLocationId
		JOIN dbo.tblQMSample S WITH (NOLOCK) ON S.intSampleId = B.intSampleId
		LEFT JOIN dbo.tblAPVendor VE WITH (NOLOCK) ON VE.intEntityId = S.intEntityId
		--LEFT JOIN dbo.tblSMPurchasingGroup PG WITH (NOLOCK) ON PG.intPurchasingGroupId = S.intPurchaseGroupId
		WHERE LD.intLoadDetailId = @intLoadDetailId
	END
	ELSE
	BEGIN
		SELECT TOP 1 @dblLeadTime = ISNULL(LLT.dblPurchaseToShipment, 0) + ISNULL(LLT.dblPortToPort, 0) + ISNULL(LLT.dblPortToMixingUnit, 0) + ISNULL(LLT.dblMUToAvailableForBlending, 0)
		FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
		JOIN dbo.tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
			AND LD.intLoadDetailId = @intLoadDetailId
		JOIN tblICItem IM WITH (NOLOCK) ON IM.intItemId = LD.intItemId
		LEFT JOIN tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = IM.intOriginId
		JOIN dbo.tblMFLocationLeadTime LLT WITH (NOLOCK) ON LLT.intPortOfDispatchId = CD.intLoadingPortId
			AND LLT.intPortOfArrivalId = CD.intDestinationPortId
			AND LLT.intBuyingCenterId = LD.intPCompanyLocationId
			AND LLT.intOriginId = ISNULL(CA.intCountryID, LLT.intOriginId)

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
				intEntityId,			strRowState,				strMarketZoneCode,			intDetailNumber
		)
		SELECT	@intLoadId,				@intLoadDetailId,			CD.intContractHeaderId,		CD.intContractDetailId,
				B.intSampleId,			LD.intBatchId,				B.intBuyingCenterLocationId,L.strLoadNumber,
				VE.strVendorAccountNum,	CL.strLocationName,			CO.strCommodityCode,		CH.strContractNumber,
				CD.intContractSeq,		CH.strCustomerContract,		L.strExternalShipmentNumber,LD.strExternalShipmentItemNumber,
				I.strItemNo,			LD.dblQuantity,				UOM.strUnitMeasure,			LD.dblNet,
				WUOM.strUnitMeasure,	ISNULL(PT.strPricingType, 'Cash'),LD.dblUnitPrice,		PUOM.strUnitMeasure,
				CU.strCurrency,			CD.dtmStartDate,			CD.dtmEndDate,				CD.dtmPlannedAvailabilityDate,
				CD.dtmUpdatedAvailabilityDate,CL.strOregonFacilityNumber,CD.strPackingDescription,	CL1.strOregonFacilityNumber,
				LP.strCity,				DP.strCity,					@dblLeadTime,				B.strBatchId,
				@intEntityId,			@strRowState,				@strMarketZoneCode,			LD.intDetailNumber
		FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
		JOIN dbo.tblLGLoad L WITH (NOLOCK) ON L.intLoadId = LD.intLoadId
			AND LD.intLoadDetailId = @intLoadDetailId
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = LD.intItemId
		JOIN dbo.tblICCommodity CO WITH (NOLOCK) ON CO.intCommodityId = I.intCommodityId
		JOIN dbo.tblICItemUOM IUOM WITH (NOLOCK) ON IUOM.intItemUOMId = LD.intItemUOMId
		JOIN dbo.tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		JOIN dbo.tblICItemUOM WIUOM WITH (NOLOCK) ON WIUOM.intItemUOMId = LD.intWeightItemUOMId
		JOIN dbo.tblICUnitMeasure WUOM WITH (NOLOCK) ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM PIUOM WITH (NOLOCK) ON PIUOM.intItemUOMId = LD.intPriceUOMId
		LEFT JOIN dbo.tblICUnitMeasure PUOM WITH (NOLOCK) ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency CU WITH (NOLOCK) ON CU.intCurrencyID = LD.intPriceCurrencyId
		JOIN dbo.tblMFBatch B WITH (NOLOCK) ON B.intBatchId = LD.intBatchId
		LEFT JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = B.intBuyingCenterLocationId
		LEFT JOIN dbo.tblSMCompanyLocation CL1 WITH (NOLOCK) ON CL1.intCompanyLocationId = B.intMixingUnitLocationId
		JOIN dbo.tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN dbo.tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN dbo.tblAPVendor VE WITH (NOLOCK) ON VE.intEntityId = CH.intEntityId
		LEFT JOIN dbo.tblCTPricingType PT WITH (NOLOCK) ON PT.intPricingTypeId = CD.intPricingTypeId
		--LEFT JOIN dbo.tblSMPurchasingGroup PG WITH (NOLOCK) ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
		LEFT JOIN dbo.tblSMCity LP WITH (NOLOCK) ON LP.intCityId = CD.intLoadingPortId
		LEFT JOIN dbo.tblSMCity DP WITH (NOLOCK) ON DP.intCityId = CD.intDestinationPortId
		WHERE LD.intLoadDetailId = @intLoadDetailId
	END
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

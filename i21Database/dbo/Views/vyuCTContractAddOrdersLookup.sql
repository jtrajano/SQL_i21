CREATE VIEW [dbo].[vyuCTContractAddOrdersLookup]
AS
SELECT	  CD.intContractDetailId
		, CD.intContractSeq
		, CH.strContractNumber
		, CH.dtmContractDate
		, U1.strUnitMeasure	AS strItemUOM
		, CH.ysnLoad
		, CD.intNoOfLoad
		, CD.dblQuantity AS	dblDetailQuantity
		, CAST(ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalance,0) AS INT) AS intLoadReceived
		, CD.dblBalance
		, ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0) AS dblAvailableQty
		, PT.strPricingType
		, CD.intCompanyLocationId
		, CH.intEntityId
		, CD.intItemUOMId
		, CD.intNetWeightUOMId
		, CD.intItemId
		, CD.intPriceItemUOMId
		, CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT) AS ysnAllowedToShow
		, CH.strContractType
		, VR.strVendorId
		, CH.strEntityName
		, CH.intContractHeaderId
		, Item.strItemNo
		, Item.strDescription AS strItemDescription
		, AD.dblSeqPrice
		, AD.intSeqPriceUOMId
		, AD.strSeqPriceUOM
		, Item.intLifeTime
		, Item.strLifeTimeType
		, Item.strLotTracking
		, Item.intCommodityId
		, CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS ysnSubCurrency
		, SL.intCompanyLocationSubLocationId 
		, SL.strSubLocationName
		, STL.intStorageLocationId
		, STL.strName AS strStorageLocationName
		, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0))	AS	dblAvailableNetWeight
		, CD.intRateTypeId
		, RT.strCurrencyExchangeRateType
		, dblRate = CAST(NULL AS NUMERIC(18, 6)) -- CD.dblRate
		, ysnBundleItem = CAST(CASE WHEN Item.strType = 'Bundle' THEN 1 ELSE 0 END AS BIT) 
		, Item.strBundleType
		, CL.strLocationName
		, CH.strEntityNumber
		, dblItemUOMCF = ISNULL(IU.dblUnitQty, 0)
		, dblAllocatedQty = ISNULL(PA.dblAllocatedQty,0) + ISNULL(SA.dblAllocatedQty,0)	
		, dblPricePerUnit = 
					-- AD.dblSeqPrice
					CASE 
						WHEN	CD.ysnUseFXPrice = 1 
								AND CD.intCurrencyExchangeRateId IS NOT NULL 
								AND CD.dblRate IS NOT NULL 
								AND CD.intFXPriceUOMId IS NOT NULL 
						THEN 
							dbo.fnCTConvertQtyToTargetItemUOM(
								CD.intFXPriceUOMId
								,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)
								,(
									CD.dblCashPrice / CASE WHEN CU.ysnSubCurrency = 1 THEN CASE WHEN ISNULL(intCent,0) = 0 THEN 1 ELSE intCent END ELSE 1 END			
								)
							) * CD.dblRate

						ELSE
							CD.dblCashPrice
					END 
					* 
					-- AD.dblQtyToPriceUOMConvFactor
					CASE 
						WHEN	CD.ysnUseFXPrice = 1 
								AND CD.intCurrencyExchangeRateId IS NOT NULL 
								AND CD.dblRate IS NOT NULL 
								AND CD.intFXPriceUOMId IS NOT NULL 
						THEN 
							dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intFXPriceUOMId,1)
						ELSE
							dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId),1)
					END 
		, CH.strGrade
		, CH.intGradeId
		, CH.strWeight
		, CH.intWeightId
		, CD.intCurrencyId
		, Terms.intFreightTermId
		, Terms.strFreightTerm

FROM	tblCTContractDetail CD	
	CROSS APPLY tblCTCompanyPreference CP
	LEFT JOIN vyuCTContractHeaderView CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId					
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId =	CD.intItemUOMId				
	LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblAPVendor VR ON VR.[intEntityId] = CD.intBillTo
	LEFT JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IL.intSubLocationId
	LEFT JOIN tblICStorageLocation STL ON STL.intStorageLocationId = IL.intStorageLocationId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType	RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	OUTER APPLY (
			SELECT		ISNULL(SUM(dblPAllocatedQty),0) AS dblAllocatedQty
			FROM		tblLGAllocationDetail 
			WHERE		intPContractDetailId = CD.intContractDetailId
		) PA 
		OUTER APPLY (
			SELECT		ISNULL(SUM(dblSAllocatedQty),0) AS dblAllocatedQty
			FROM		tblLGAllocationDetail 
			WHERE		intSContractDetailId = CD.intContractDetailId
		) SA 
	LEFT JOIN tblSMFreightTerms Terms
		ON Terms.intFreightTermId = CD.intFreightTermId
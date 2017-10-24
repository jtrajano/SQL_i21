CREATE VIEW [dbo].[vyuCTContractAddOrdersLookup]
AS
SELECT	  CD.intContractDetailId
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
		, CD.dblRate
FROM	tblCTContractDetail CD	
	CROSS APPLY tblCTCompanyPreference CP
	LEFT JOIN vyuCTContractHeaderView CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId					
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId =	CD.intItemUOMId				
	LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblAPVendor VR ON VR.[intEntityId] = CD.intBillTo
	LEFT JOIN tblICItem Item ON Item.intItemId = CD.intItemId
	LEFT JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = IL.intSubLocationId
	LEFT JOIN tblICStorageLocation STL ON STL.intStorageLocationId = IL.intStorageLocationId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateType	RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
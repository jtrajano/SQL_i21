CREATE VIEW vyuLGLoadContainerPurchaseContractsLookup
AS
SELECT
	  intLoadDetailId				= LD.intLoadDetailId
	, intLoadId						= L.intLoadId
	, strLoadNumber					= L.strLoadNumber
	, intPContractDetailId			= LD.intPContractDetailId
	, intPContractHeaderId			= CT.intContractHeaderId
	, intPContractSeq				= CT.intContractSeq
	, strPContractNumber			= CH.strContractNumber
	, intPSubLocationId				= LD.intPSubLocationId
	, intPCommodityId				= Item.intCommodityId
	, intItemId						= LD.intItemId
	, intPLifeTime					= Item.intLifeTime
	, strPLifeTimeType				= Item.strLifeTimeType
	, intItemUOMId					= CT.intItemUOMId
	, intCompanyLocationId			= L.intCompanyLocationId
	, dblQuantity					= LDCL.dblQuantity
	, dblDeliveredQuantity			= ISNULL(LDCL.dblReceivedQty, 0)
	, dblBalanceToReceive			= LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0)
	, dblGross						= (LC.dblGrossWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity
	, dblTare						= (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity
	, dblNet						= (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END) * LDCL.dblQuantity
	, intWeightUOMId				= L.intWeightUnitMeasureId
	, strWeightUOM					= WTUOM.strUnitMeasure
	, intEntityVendorId				= LD.intVendorEntityId
	, strVendor						= EY.strName
	, strItemNo						= Item.strItemNo
	, strItemDescription			= Item.strDescription
	, strLotTracking				= Item.strLotTracking
	, strType						= CASE WHEN L.intPurchaseSale = 1 THEN 'Inbound' ELSE CASE WHEN L.intPurchaseSale = 2 THEN 'Outbound' ELSE 'Drop Ship' END END
	, strUnitMeasure				= UOM.strUnitMeasure
	, dblItemUOMCF					= ItemUOM.dblUnitQty
	, strBLNumber					= L.strBLNumber
	, strContainerNumber			= LC.strContainerNumber
	, strLotNumber					= LC.strLotNumber
	, strMarks						= LC.strMarks
	, strOtherMarks					= LC.strOtherMarks
	, strSealNumber					= LC.strSealNumber
	, strContainerType				= ContType.strContainerType
	, strMainCurrency				= ISNULL(AD.strSeqCurrency,CY.strCurrency)
	, dblMainCashPrice				= CT.dblCashPrice / CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END
	, dblFranchise					= CASE WHEN WG.dblFranchise > 0 THEN WG.dblFranchise / 100 ELSE 0 END
	, dblContainerWeightPerQty		= (LC.dblNetWt / CASE WHEN ISNULL(LC.dblQuantity,0) = 0 THEN 1 ELSE LC.dblQuantity END)
	, intSubLocationId				= LW.intSubLocationId
	, strSubLocationName			= SubLocation.strSubLocationName
	, intLoadContainerId			= LC.intLoadContainerId
	, intLoadDetailContainerLinkId	= LDCL.intLoadDetailContainerLinkId
	, intPurchaseSale				= L.intPurchaseSale
	, intTransUsedBy 				= L.intTransUsedBy
	, intSourceType					= L.intSourceType
	, ysnPosted						= L.ysnPosted
	, intStorageLocationId			= SL.intStorageLocationId	
	, strStorageLocationName 		= SL.strName
	, ysnSubCurrency				= AD.ysnSeqSubCurrency
	, dblCost						= AD.dblSeqPrice
	, strPCostUOM					= AD.strSeqPriceUOM
	, intPCostUOMId					= AD.intSeqPriceUOMId
	, strCurrency					= AD.strSeqCurrency
	, dblPCostUOMCF					= ISNULL(oPriceStock.dblUnitQty, 0)
	, intWeightItemUOMId			= oWeightStock.intItemUOMId
	, intStockUOM					= ISNULL(oStockUOM.intItemUOMId, 0)
	, strStockUOM					= oStockUOM.strUnitMeasure
	, strStockUOMType				= oStockUOM.strUnitType
	, dblStockUOMCF					= oStockUOM.dblUnitQty
	, intForexRateTypeId			= CT.intRateTypeId
	, strForexRateType				= RT.strCurrencyExchangeRateType
	, dblForexRate					= CT.dblRate
	, L.dtmScheduledDate
	, FreightTerm.intFreightTermId
	, FreightTerm.strFreightTerm
FROM tblLGLoad L
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	INNER JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	--INNER JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	INNER JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId 
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CT.intContractDetailId) AD
	INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
	INNER JOIN tblICItemUOM IU ON IU.intItemUOMId = LDCL.intItemUOMId
	LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = CT.intCurrencyId
	LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId 
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=	CT.intRateTypeId	
	OUTER APPLY (
		SELECT TOP 1 intItemUOMId, strUnitMeasure, strUnitType, dblUnitQty
		FROM tblICItemUOM ItemUOM 
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId
	) oStockUOM
	OUTER APPLY (
		SELECT TOP 1 dblUnitQty
		FROM tblICItemUOM ItemUOM
		WHERE ItemUOM.intItemUOMId = CT.intPriceItemUOMId
	) oPriceStock
	OUTER APPLY (
		SELECT WeightItem.intItemUOMId
		FROM tblICItemUOM WeightItem
		WHERE WeightItem.intItemId=LD.intItemId
			AND WeightItem.intUnitMeasureId=L.intWeightUnitMeasureId
	) oWeightStock
	LEFT JOIN tblSMFreightTerms FreightTerm
		ON	FreightTerm.intFreightTermId = L.intFreightTermId
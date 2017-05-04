CREATE VIEW [dbo].[vyuICLoadContainerPurchaseContracts]
AS	
SELECT LD.intLoadDetailId
	,L.intLoadId
	,L.strLoadNumber
	,LD.intPContractDetailId
	,CH.intContractHeaderId AS intPContractHeaderId
	,CD.intContractSeq AS intPContractSeq
	,CH.strContractNumber AS strPContractNumber
	,CH.intCommodityId AS intPCommodityId
	,LD.intItemId
	,IM.intLifeTime AS intPLifeTime
	,IM.strLifeTimeType AS strPLifeTimeType
	,LD.intItemUOMId
	,LD.intPCompanyLocationId AS intCompanyLocationId
	,CASE WHEN ISNULL(LDCL.dblQuantity,0) = 0 THEN LD.dblQuantity ELSE LDCL.dblQuantity END AS dblQuantity
	,CASE WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0 THEN LD.dblDeliveredQuantity ELSE ISNULL(LDCL.dblReceivedQty, 0) END AS dblDeliveredQuantity
	,COALESCE(LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0), LD.dblQuantity - LD.dblDeliveredQuantity) AS dblBalanceToReceive
	,COALESCE((LC.dblGrossWt / LC.dblQuantity) * LDCL.dblQuantity, LD.dblGross) AS dblGross
	,COALESCE((LC.dblTareWt / LC.dblQuantity) * LDCL.dblQuantity, LD.dblTare) AS dblTare
	,COALESCE((LC.dblNetWt / LC.dblQuantity) * LDCL.dblQuantity, LD.dblNet) AS dblNet
	,AD.dblSeqPrice AS dblCost
	,AD.strSeqPriceUOM AS strPCostUOM
	,AD.intSeqPriceUOMId intPCostUOMId
	,ISNULL((SELECT TOP 1 dblUnitQty
			 FROM tblICItemUOM ItemUOM
			 WHERE ItemUOM.intItemUOMId = CD.intPriceItemUOMId), 0) AS dblPCostUOMCF
	,intWeightItemUOMId AS intWeightUOMId
	,WeightUOM.strUnitMeasure AS strWeightItemUOM
	,LD.intVendorEntityId AS intEntityVendorId
	,VEN.strName AS strVendor
	,IM.strItemNo
	,IM.strDescription AS strItemDescription
	,IM.strLotTracking
	,CASE L.intPurchaseSale
		WHEN 1
			THEN 'Inbound'
		WHEN 2
			THEN 'Outbound'
		ELSE 'Drop Ship'
		END AS strType
	,UOM.strUnitMeasure
	,ItemUOM.dblUnitQty AS dblItemUOMCF
	,ISNULL((SELECT TOP 1 intItemUOMId
			FROM tblICItemUOM ItemUOM
			WHERE ysnStockUnit = 1
				AND ItemUOM.intItemUOMId = CD.intItemUOMId), 0) AS intStockUOM
	,(SELECT TOP 1 strUnitMeasure
		FROM tblICItemUOM ItemUOM
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1
			AND ItemUOM.intItemUOMId = CD.intItemUOMId) AS strStockUOM
	,(SELECT TOP 1 strUnitType
		FROM tblICItemUOM ItemUOM
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1
			AND ItemUOM.intItemUOMId = CD.intItemUOMId) AS strPStockUOMType
	,ISNULL((SELECT TOP 1 dblUnitQty
			FROM tblICItemUOM ItemUOM
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			WHERE ysnStockUnit = 1
				AND ItemUOM.intItemUOMId = CD.intItemUOMId), 0) AS dblPStockUOMCF
	,L.strBLNumber
	,LC.strContainerNumber
	,LC.strLotNumber
	,LC.strMarks
	,LC.strOtherMarks
	,LC.strSealNumber
	,ContType.strContainerType
	,LD.intWeightItemUOMId
	,AD.strSeqCurrency AS strCurrency
	,CY.strCurrency AS strMainCurrency
	,AD.ysnSeqSubCurrency AS ysnSubCurrency
	,CD.dblCashPrice / CASE 
		WHEN ISNULL(CU.intCent, 0) = 0
			THEN 1
		ELSE CU.intCent
		END AS dblMainCashPrice
	,CASE 
		WHEN PWG.dblFranchise > 0
			THEN PWG.dblFranchise / 100
		ELSE 0
		END AS dblFranchise
	,dblContainerWeightPerQty = (LC.dblNetWt / LC.dblQuantity)
	,LW.intSubLocationId
	,SubLocation.strSubLocationName
	,ISNULL(LC.intLoadContainerId,-1) AS intLoadContainerId
	,ISNULL(LDCL.intLoadDetailContainerLinkId,-1) AS intLoadDetailContainerLinkId
	,L.intPurchaseSale
	,L.intTransUsedBy
	,L.intSourceType
	,ISNULL(L.ysnPosted, 0) AS ysnPosted
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem IM ON IM.intItemId = LD.intItemId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = CH.intWeightId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LD.intVendorEntityId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CU.intMainCurrencyId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = LW.intSubLocationId
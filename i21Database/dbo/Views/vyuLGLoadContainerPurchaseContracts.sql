﻿CREATE VIEW vyuLGLoadContainerPurchaseContracts
AS   
SELECT
	 LD.intLoadDetailId
	,LDCL.intLoadId
	,LDCL.intLoadDetailContainerLinkId
	,LC.intLoadContainerId
	,L.intPurchaseSale
	,L.strLoadNumber
	,LD.intPSubLocationId
	,LD.intPContractDetailId
	,CT.intContractHeaderId
	,CT.intContractSeq
	,CT.strContractNumber
	,Item.intCommodityId
	,LD.intItemId
	,CT.intItemUOMId
	,LW.intSubLocationId
	,intLocationId = L.intCompanyLocationId
	,LDCL.dblQuantity
	,ISNULL(LDCL.dblReceivedQty, 0) AS dblReceivedQty
	,dblGrossWt = (LC.dblGrossWt / LC.dblQuantity) * LDCL.dblQuantity
	,dblTareWt = (LC.dblTareWt / LC.dblQuantity) * LDCL.dblQuantity
	,dblNetWt = (LC.dblNetWt / LC.dblQuantity) * LDCL.dblQuantity
	,dblCost = CT.dblCashPrice
	,intWeightUOMId = L.intWeightUnitMeasureId
	,WTUOM.strUnitMeasure AS strWeightUOM
	,intEntityVendorId = LD.intVendorEntityId
	,CT.strEntityName AS strVendor
	,Item.strItemNo
	,strItemDescription = Item.strDescription
	,Item.strLotTracking
    ,Item.strType AS strItemType
    ,strType = CASE WHEN L.intPurchaseSale = 1 THEN 
                        'Inbound' 
                        ELSE 
                            CASE WHEN L.intPurchaseSale = 2 THEN 
                            'Outbound' 
                            ELSE
                            'Drop Ship'
                            END
                        END
    ,Item.intLifeTime
	,Item.strLifeTimeType
	,UOM.strUnitMeasure
	,dblItemUOMCF = ItemUOM.dblUnitQty
	,intStockUOM = ISNULL((
			SELECT TOP 1 intItemUOMId
			FROM tblICItemUOM ItemUOM
			WHERE ysnStockUnit = 1
				AND ItemUOM.intItemUOMId = CT.intItemUOMId
			), 0)
	,strStockUOM = (
		SELECT TOP 1 strUnitMeasure
		FROM tblICItemUOM ItemUOM
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1
			AND ItemUOM.intItemUOMId = CT.intItemUOMId
		)
	,strStockUOMType = (
		SELECT TOP 1 strUnitType
		FROM tblICItemUOM ItemUOM
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1
			AND ItemUOM.intItemUOMId = CT.intItemUOMId
		)
	,dblStockUOMCF = ISNULL((
			SELECT TOP 1 dblUnitQty
			FROM tblICItemUOM ItemUOM
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			WHERE ysnStockUnit = 1
				AND ItemUOM.intItemUOMId = CT.intItemUOMId
			), 0)
	,SubLocation.strSubLocationName
	,L.strBLNumber
	,LC.strContainerNumber
	,LC.strLotNumber
	,LC.strMarks
	,LC.strOtherMarks
	,LC.strSealNumber
	,ContType.strContainerType
	,intCostUOMId = CT.intPriceItemUOMId
	,strCostUOM = CT.strPriceUOM
	,dblCostUOMCF = ISNULL((
			SELECT TOP 1 dblUnitQty
			FROM tblICItemUOM ItemUOM
			WHERE ItemUOM.intItemUOMId = CT.intPriceItemUOMId
			), 0)
	,intWeightItemUOMId = (SELECT WeightItem.intItemUOMId FROM tblICItemUOM WeightItem WHERE WeightItem.intItemId=LD.intItemId AND WeightItem.intUnitMeasureId=L.intWeightUnitMeasureId)
	,CT.strCurrency
	,CT.strMainCurrency
	,CT.ysnSubCurrency
	,CT.dblMainCashPrice
	,dblFranchise = CASE WHEN WG.dblFranchise > 0 THEN WG.dblFranchise / 100 ELSE 0 END
	,dblContainerWeightPerQty = (LC.dblNetWt / LC.dblQuantity)
	,LW.intLoadWarehouseId
	,LW.strDeliveryNoticeNumber
	,LW.dtmDeliveryNoticeDate
	,LW.intHaulerEntityId
	,LW.dtmPickupDate
	,LW.dtmDeliveryDate
	,LW.dtmLastFreeDate
	,LW.dtmStrippingReportReceivedDate
	,LW.dtmSampleAuthorizedDate
	,LWC.intLoadContainerId intWarehouseContainerId
	,L.intSourceType
	,L.intTransUsedBy
	,L.ysnPosted
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = LD.intPContractDetailId
JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LDCL.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CT.intWeightId
LEFT JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId 
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = LW.intSubLocationId
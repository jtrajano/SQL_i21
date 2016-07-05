CREATE VIEW vyuLGLoadPurchaseContracts
AS   
SELECT t1.*
	,dblCashPriceInWeightUOM = ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(t1.intWeightItemUOMId, t1.intPriceItemUOMId, t1.dblCashPrice), 0.0)
FROM (
	SELECT LD.intLoadDetailId
		,LD.intLoadId
		,L.strLoadNumber
		,CASE 
			WHEN L.intPurchaseSale = 3
				THEN 1
			ELSE 0
			END ysnDirectShipment
		,LD.intPContractDetailId
		,CT.intContractHeaderId
		,CT.intContractSeq
		,CH.strContractNumber
		,CH.intEntityId AS intVendorEntityId
		,L.dtmPostedDate
		,L.strBLNumber
		,Item.intCommodityId
		,LD.intItemId
		,CT.intItemUOMId
		,LW.intSubLocationId
		,intLocationId = L.intCompanyLocationId
		,LD.dblQuantity
		,IsNull(LD.dblDeliveredQuantity, 0) AS dblReceivedQty
		,LD.dblGross
		,LD.dblTare
		,LD.dblNet
		,dblCost = CT.dblCashPrice
		,intWeightUOMId = L.intWeightUnitMeasureId
		,WTUOM.strUnitMeasure AS strWeightUOM
		,intEntityVendorId = LD.intVendorEntityId
		,E.strName AS strVendor
		,Item.strItemNo
		,strItemDescription = Item.strDescription
		,Item.strLotTracking
		,Item.strType
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
		,L.intCompanyLocationId
		,CT.dblCashPrice
		,dbo.fnCTConvertQtyToTargetItemUOM(CT.intItemUOMId, CT.intPriceItemUOMId, CT.dblCashPrice) AS dblCashPriceInQtyUOM
		,intWeightItemUOMId = (
			SELECT WeightItem.intItemUOMId
			FROM tblICItemUOM WeightItem
			WHERE WeightItem.intItemId = LD.intItemId
				AND WeightItem.intUnitMeasureId = L.intWeightUnitMeasureId
			)
		,CT.intPriceItemUOMId
		,U2.strUnitMeasure AS strPriceUOM
		,intCostUOMId = CT.intPriceItemUOMId
		,strCostUOM = U2.strUnitMeasure
		,dblCostUOMCF = ISNULL((
				SELECT TOP 1 dblUnitQty
				FROM tblICItemUOM ItemUOM
				WHERE ItemUOM.intItemUOMId = CT.intPriceItemUOMId
				), 0)
		,CU.strCurrency
		,CY.strCurrency AS strMainCurrency
		,CAST(ISNULL(CU.intMainCurrencyId, 0) AS BIT) AS ysnSubCurrency
		,CT.dblCashPrice / CASE 
			WHEN ISNULL(CU.intCent, 0) = 0
				THEN 1
			ELSE CU.intCent
			END AS dblMainCashPrice
		,dblFranchise = CASE 
			WHEN WG.dblFranchise > 0
				THEN WG.dblFranchise / 100
			ELSE 0
			END
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CT.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CT.intCurrencyId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CU.intMainCurrencyId
) t1
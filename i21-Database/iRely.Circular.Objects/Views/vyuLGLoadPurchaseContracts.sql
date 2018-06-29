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
		,intSubLocationId = NULL
		,intLocationId = L.intCompanyLocationId
		,LD.dblQuantity
		,dblReceivedQty = 0.0
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
		,strSubLocationName = ''
		,intCompanyLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
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
		,intSubCurrencyCents = CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,CY.strCurrency AS strMainCurrency
		,CAST(ISNULL(CU.intMainCurrencyId, 0) AS BIT) AS ysnSubCurrency
		,CT.dblCashPrice / CASE 
			WHEN ISNULL(CU.intCent, 0) = 0
				THEN 1
			ELSE CU.intCent
			END AS dblMainCashPrice
		,intContractCurrencyId = CT.intCurrencyId
		,dblFranchise = CASE 
			WHEN WG.dblFranchise > 0
				THEN WG.dblFranchise / 100
			ELSE 0
			END
		,L.ysnPosted
		,L.intCurrencyId
		,strLoadCurrency = LCU.strCurrency
		,receiptItem.intInventoryReceiptItemId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CT.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CT.intCurrencyId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CT.intCurrencyId
--	LEFT JOIN tblSMCurrency LC ON LC.intCurrencyID = L.intCurrencyId
	LEFT JOIN tblSMCurrency LCU ON LCU.intCurrencyID = L.intCurrencyId
	LEFT JOIN (tblICInventoryReceipt receipt INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
	ON LD.intLoadDetailId = receiptItem.intSourceId AND receipt.intSourceType = 2
	WHERE L.ysnPosted = 1 AND L.intPurchaseSale IN (1, 3) AND L.intShipmentStatus IN (1,3)
) t1
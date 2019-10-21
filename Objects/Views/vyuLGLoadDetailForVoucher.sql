CREATE VIEW vyuLGLoadDetailForVoucher
AS
SELECT
	[intLoadId] = L.intLoadId
	,[strLoadNumber] = L.strLoadNumber
	,[intLoadDetailId] = LD.intLoadDetailId
	,[strContractNumber] = CH.strContractNumber
	,[intContractHeaderId] = CH.intContractHeaderId
	,[intContractSeq] = CT.intContractSeq
	,[intContractDetailId] = LD.intPContractDetailId
	,[dblBalance] = CT.dblBalance
	,[intItemId] = LD.intItemId
	,[strItemNo] = item.strItemNo
	,[strItemDescription] = item.strDescription
	,[dblQuantity] = LD.dblQuantity
	,[strQtyUnitMeasure] = UOM.strUnitMeasure
	,[intUnitMeasureId] = LD.intItemUOMId
	,[dblUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
	,[dblGross] = LD.dblGross
	,[dblTare] = LD.dblTare
	,[dblNet] = LD.dblNet
	,[strWeightUnitMeasure] = WUOM.strUnitMeasure
	,[intWeightUnitMeasure] = ItemWeightUOM.intItemUOMId
	,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
	,[strVendor] = D2.strName
	,[intEntityVendorId] = D1.intEntityId
	,[dblCost] = ISNULL(AD.dblSeqPrice, 0)
	,[intCostUOMId] = AD.intSeqPriceUOMId
	,[strCostUOM] = AD.strSeqPriceUOM
	,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
	,[intCurrencyId] = AD.intSeqCurrencyId
	,[ysnSubCurrency] =	AD.ysnSeqSubCurrency
	,[intForexRateTypeId] = CT.intRateTypeId
	,[dblForexRate] = CT.dblRate
	,[strCurrency] = ISNULL(MCY.strCurrency,CY.strCurrency)
	,[strSubCurrency] = CY.strCurrency
	,[intCent] = ISNULL(CY.intCent,1)
	,[intInventoryReceiptItemId] = receipt.intInventoryReceiptItemId
	,[ysnPosted] = receipt.ysnPosted
	,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
	,[intSubLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CT.intContractDetailId) AD
JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = AD.intSeqCurrencyId
LEFT JOIN tblSMCurrency MCY ON MCY.intCurrencyID = CY.intMainCurrencyId
LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = CT.intPriceItemUOMId
OUTER APPLY (SELECT TOP 1 R2.intInventoryReceiptItemId, R1.ysnPosted FROM tblICInventoryReceiptItem R2
			INNER JOIN tblICInventoryReceipt R1  ON R1.intInventoryReceiptId = R2.intInventoryReceiptId
			WHERE R2.intSourceId = LD.intLoadDetailId AND R1.intSourceType = 2) receipt
OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
			WHERE intLoadId = L.intLoadId) LW
WHERE LD.intLoadDetailId NOT IN (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
									WHERE BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge')
UNION ALL
		
SELECT
	[intLoadId] = L.intLoadId
	,[strLoadNumber] = L.strLoadNumber
	,[intLoadDetailId] = LD.intLoadDetailId
	,[strContractNumber] = CH.strContractNumber
	,[intContractHeaderId] = CH.intContractHeaderId
	,[intContractSeq] = CT.intContractSeq
	,[intContractDetailId] = CT.intContractDetailId
	,[dblBalance] = CT.dblBalance
	,[intItemId] = A.intItemId
	,[strItemNo] = A.strItemNo
	,[strItemDescription] = A.strItemDescription
	,[dblQuantity] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
	,[strQtyUnitMeasure] = UOM.strUnitMeasure
	,[intUnitMeasureId] = A.intItemUOMId
	,[dblUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
	,[dblGross] = 0
	,[dblTare] = 0
	,[dblNet] = 0
	,[strWeightUnitMeasure] = NULL
	,[intWeightUnitMeasure] = NULL
	,[dblWeightUnitQty] = 1
	,[strVendor] = A.strCustomerName
	,[intEntityVendorId] = A.intEntityVendorId
	,[dblCost] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN ISNULL(A.dblTotal, A.dblPrice) ELSE ISNULL(A.dblPrice, A.dblTotal) END 
	,[intCostUOMId] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE A.intPriceItemUOMId END
	,[strCostUOM] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE CostUOM.strUnitMeasure END
	,[dblCostUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
	,[intCurrencyId] = A.intCurrencyId
	,[ysnSubCurrency] =	CC.ysnSubCurrency
	,[intForexRateTypeId] = NULL
	,[dblForexRate] = 1
	,[strCurrency] = ISNULL(MCC.strCurrency,CC.strCurrency)
	,[strSubCurrency] = CC.strCurrency
	,[intCent] = ISNULL(CC.intCent,1)
	,[intInventoryReceiptItemId] = NULL
	,[ysnPosted] = NULL
	,[intStorageLocationId] = NULL
	,[intSubLocationId] = NULL
FROM vyuLGLoadCostForVendor A
	JOIN tblLGLoad L ON L.intLoadId = A.intLoadId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
	LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = A.intCurrencyId
	LEFT JOIN tblSMCurrency MCC ON MCC.intCurrencyID = CC.intMainCurrencyId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
	INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
	WHERE A.intLoadDetailId NOT IN 
			(SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
			WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1)
CREATE PROCEDURE [dbo].[uspLGProcessPayables]
	@intLoadId INT = NULL
	,@intLoadCostId INT = NULL
	,@ysnPost BIT
	,@intEntityUserSecurityId INT
AS
BEGIN
	DECLARE @voucherPayable VoucherPayable

	IF (@intLoadId IS NOT NULL)
	BEGIN
		INSERT INTO @voucherPayable(
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intCurrencyId]
			,[dtmDate]
			,[strVendorOrderNumber]
			,[strReference]
			,[strSourceNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
			,[intItemId]
			,[strMiscDescription]
			,[dblOrderQty]
			,[dblOrderUnitQty]
			,[intOrderUOMId]
			,[dblQuantityToBill]
			,[dblQtyToBillUnitQty]
			,[intQtyToBillUOMId]
			,[dblCost]
			,[dblCostUnitQty]
			,[intCostUOMId]
			,[dblNetWeight]
			,[dblWeightUnitQty]
			,[intWeightUOMId]
			,[intCostCurrencyId]
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
			,[intStorageLocationId]
			,[intSubLocationId])
		SELECT
			[intEntityVendorId] = D1.intEntityId
			,[intTransactionType] = 1
			,[intLocationId] = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
			,[intCurrencyId] = L.intCurrencyId
			,[dtmDate] = L.dtmPostedDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(L.strLoadNumber)
			,[intContractHeaderId] = CH.intContractHeaderId
			,[intContractDetailId] = LD.intPContractDetailId
			,[intContractSeqId] = CT.intContractSeq
			,[intInventoryReceiptItemId] = receiptItem.intInventoryReceiptItemId
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[intItemId] = LD.intItemId
			,[strMiscDescription] = item.strDescription
			,[dblOrderQty] = LD.dblQuantity
			,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intOrderUOMId] = LD.intItemUOMId
			,[dblQuantityToBill] = LD.dblQuantity
			,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intQtyToBillUOMId] = LD.intItemUOMId
			,[dblCost] = CAST(ISNULL(CT.dblCashPrice,0) AS DECIMAL(38,20))
			,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
			,[intCostUOMId] = CT.intPriceItemUOMId
			,[dblNetWeight] = ISNULL(LD.dblNet,0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = ItemWeightUOM.intItemUOMId
			,[intCostCurrencyId] = CT.intCurrencyId
			,[dblTax] = ISNULL(receiptItem.dblTax, 0)
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] =	ISNULL(CY.ysnSubCurrency,0)
			,[intSubCurrencyCents] = ISNULL(CY.intCent,0)
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[intStorageLocationId] = ISNULL(LW.intSubLocationId, CT.intSubLocationId)
			,[intSubLocationId] = ISNULL(LW.intStorageLocationId, CT.intStorageLocationId)
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
		JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CH.intEntityId = D1.[intEntityId]  
		LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CT.intCurrencyId
		LEFT JOIN (tblICInventoryReceipt receipt 
					INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
					ON LD.intLoadDetailId = receiptItem.intSourceId AND receipt.intSourceType = 2
		LEFT JOIN tblICItem item ON item.intItemId = LD.intItemId 
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId and ItemLoc.intLocationId = IsNull(L.intCompanyLocationId, CT.intCompanyLocationId)
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemId = LD.intItemId and ItemWeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = CT.intPriceItemUOMId
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(LD.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
					LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
					LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
					WHERE intLoadId = L.intLoadId) LW
		LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
		WHERE L.intLoadId = @intLoadId
			AND LD.intLoadDetailId NOT IN (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
										  WHERE BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge')
		
		UNION ALL
		
		SELECT
			[intEntityVendorId] = A.intEntityVendorId
			,[intTransactionType] = 1
			,[intLocationId] = A.intCompanyLocationId
			,[intCurrencyId] = A.intCurrencyId
			,[dtmDate] = A.dtmProcessDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(A.strLoadNumber)
			,[intContractHeaderId] = A.intContractHeaderId
			,[intContractDetailId] = A.intContractDetailId
			,[intContractSeqId] = A.intContractSeq
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = A.intLoadId
			,[intLoadShipmentDetailId] = A.intLoadDetailId
			,[intItemId] = A.intItemId
			,[strMiscDescription] = A.strItemDescription
			,[dblOrderQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblOrderUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intOrderUOMId] = A.intItemUOMId
			,[dblQuantityToBill] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE LD.dblQuantity END
			,[dblQtyToBillUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intQtyToBillUOMId] = A.intItemUOMId
			,[dblCost] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN ISNULL(A.dblTotal, A.dblPrice) ELSE ISNULL(A.dblPrice, A.dblTotal) END 
			,[dblCostUnitQty] = CASE WHEN A.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
			,[intCostUOMId] = A.intPriceItemUOMId
			,[dblNetWeight] = ISNULL(A.dblNet,0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = A.intWeightItemUOMId
			,[intCostCurrencyId] = A.intCurrencyId
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] =	CASE WHEN ISNULL(CC.intMainCurrencyId, CC.intCurrencyID) > 0 THEN 1 ELSE 0 END
			,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = L.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[intStorageLocationId] = A.intStorageLocationId
			,[intSubLocationId] = A.intSubLocationId
		FROM vyuLGLoadCostForVendor A
			JOIN tblLGLoad L ON L.intLoadId = A.intLoadId
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = A.intCurrencyId
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.[intEntityVendorId] = D1.[intEntityId]
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
			LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
			WHERE A.intLoadId = @intLoadId
				AND A.intLoadCostId = ISNULL(@intLoadCostId, A.intLoadCostId)
				AND A.intLoadDetailId NOT IN 
					(SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE BD.intItemId = A.intItemId AND Item.strType = 'Other Charge' AND ISNULL(A.ysnAccrue,0) = 1)

	END

	IF (@ysnPost = 1)
	BEGIN
		EXEC uspAPUpdateVoucherPayableQty @voucherPayable, DEFAULT
	END
	ELSE
	BEGIN
		EXEC uspAPRemoveVoucherPayable @voucherPayable, 0, DEFAULT
	END


END

GO
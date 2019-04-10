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
			,[ysnReturn])
		SELECT
			[intEntityVendorId] = A.intVendorEntityId
			,[intTransactionType] = 1
			,[intLocationId] = A.intCompanyLocationId
			,[intCurrencyId] = A.intCurrencyId
			,[dtmDate] = A.dtmPostedDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(A.strLoadNumber)
			,[intContractHeaderId] = A.intContractHeaderId
			,[intContractDetailId] = A.intPContractDetailId
			,[intContractSeqId] = A.intContractSeq
			,[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
			,[intLoadShipmentId] = A.intLoadId
			,[intLoadShipmentDetailId] = A.intLoadDetailId
			,[intItemId] = A.intItemId
			,[strMiscDescription] = A.strItemDescription
			,[dblOrderQty] = A.dblQuantity
			,[dblOrderUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intOrderUOMId] = A.intItemUOMId
			,[dblQuantityToBill] = A.dblQuantity
			,[dblQtyToBillUnitQty] = ISNULL(ItemUOM.dblUnitQty,1)
			,[intQtyToBillUOMId] = A.intItemUOMId
			,[dblCost] = CAST(ISNULL(A.dblCashPrice,0) AS DECIMAL(38,20))
			,[dblCostUnitQty] = CAST(ISNULL(ItemCostUOM.dblUnitQty,1) AS DECIMAL(38,20))
			,[intCostUOMId] = A.intPriceItemUOMId
			,[dblNetWeight] = ISNULL(A.dblNet,0)
			,[dblWeightUnitQty] = ISNULL(ItemWeightUOM.dblUnitQty,1)
			,[intWeightUOMId] = A.intWeightItemUOMId
			,[intCostCurrencyId] = A.intContractCurrencyId
			,[dblTax] = ISNULL(IRI.dblTax, 0)
			,[dblDiscount] = 0
			,[dblExchangeRate] = 1
			,[ysnSubCurrency] =	CASE WHEN ISNULL(A.intSubCurrencyCents,0) > 0 THEN 1 ELSE 0 END
			,[intSubCurrencyCents] = ISNULL(A.intSubCurrencyCents,0)
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = A.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
		FROM vyuLGLoadPurchaseContracts A
		INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON A.intVendorEntityId = D1.[intEntityId]  
		LEFT JOIN tblICItem item ON item.intItemId = A.intItemId 
		LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = A.intItemId and ItemLoc.intLocationId = A.intCompanyLocationId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = A.intItemUOMId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = A.intWeightItemUOMId
		LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = A.intCostUOMId
		OUTER APPLY dbo.fnGetItemGLAccountAsTable(A.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
		LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
		LEFT JOIN tblICInventoryReceiptItem IRI ON A.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		WHERE A.intLoadId = @intLoadId
			AND A.intLoadDetailId NOT IN (SELECT IsNull(BD.intLoadDetailId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
										  WHERE BD.intItemId = A.intItemId AND Item.strType <> 'Other Charge')
		
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
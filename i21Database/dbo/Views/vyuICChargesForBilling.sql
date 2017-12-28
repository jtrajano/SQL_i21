CREATE VIEW [dbo].[vyuICChargesForBilling]
AS
SELECT
	 [intInventoryReceiptId]					=	ReceiptCharge.intInventoryReceiptId
	,[intEntityVendorId]						=	Vendor.[intEntityId]
	,[dtmDate]									=	Receipt.dtmReceiptDate
	,[strReference]								=	Receipt.strVendorRefNo
	,[strSourceNumber]							=	Receipt.strReceiptNumber
	,[intItemId]								=	Item.intItemId
	,[strMiscDescription]						=	Item.strDescription
	,[strItemNo]								=	Item.strItemNo
	,[strDescription]							=	Item.strDescription
	,[dblOrderQty]								=	
													CASE 
														WHEN ISNULL(ReceiptCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0))
														ELSE ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)
													END 
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	
													CASE 
														WHEN ISNULL(ReceiptCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ReceiptCharge.dblQuantity- ISNULL(ReceiptCharge.dblQuantityBilled, 0))
														ELSE ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)
													END 
	,[dblQuantityToBill]						=	
													CASE 
														WHEN ISNULL(ReceiptCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)) 
														ELSE ReceiptCharge.dblQuantity - ISNULL(ReceiptCharge.dblQuantityBilled, 0)	
													END 
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryReceiptItemId]				=	ReceiptItem.intInventoryReceiptItemId --add for strSource reference
	,[intInventoryReceiptChargeId]				=	ReceiptCharge.intInventoryReceiptChargeId
	,[dblUnitCost]								=	
													CASE 
														WHEN ReceiptCharge.ysnSubCurrency = 1 AND ReceiptCharge.strCostMethod = 'Per Unit' THEN 
															ABS(ISNULL(ReceiptCharge.dblRate, 0)) * 100
														WHEN ReceiptCharge.strCostMethod = 'Per Unit' THEN 
															ABS(ISNULL(ReceiptCharge.dblRate, 0))
														WHEN ReceiptCharge.ysnSubCurrency = 1 THEN 
															ABS(ISNULL(ReceiptCharge.dblAmount, 0)) * 100
														ELSE 
															ABS(ISNULL(ReceiptCharge.dblAmount, 0))
													END
	,[dblTax]									=	ISNULL(ReceiptCharge.dblTax,0) 
	,[intAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.intAccountId 
															ELSE 																
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.intAccountId
																	FROM	tblICInventoryReceiptItemAllocatedCharge ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 
	,[strAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.strAccountId
															ELSE 
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.strAccountId
																	FROM	tblICInventoryReceiptItemAllocatedCharge ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 

	,[strName]									= Entity.strName
	,[strVendorId]								= Vendor.strVendorId
	,[strContractNumber]						= vReceiptCharge.strContractNumber
	,[intContractHeaderId]						= ReceiptCharge.intContractId
	,[intContractDetailId]						= ReceiptCharge.intContractDetailId 
	,[intCurrencyId]							= vReceiptCharge.intCurrencyId 
	,[ysnSubCurrency]							= ReceiptCharge.ysnSubCurrency
	,[intMainCurrencyId]						= CASE WHEN ReceiptCharge.ysnSubCurrency = 1 THEN MainCurrency.intCurrencyID ELSE TransCurrency.intCurrencyID END 
	,[intSubCurrencyCents]						= TransCurrency.intCent
	,[strCostUnitMeasure]						= CostUOM.strUnitMeasure
	,[intCostUnitMeasureId]                     = ItemCostUOM.intItemUOMId
	,[intScaleTicketId]							= ScaleTicket.intScaleTicketId
	,[strScaleTicketNumber]						= ScaleTicket.strScaleTicketNumber
	,[intLocationId]							= Receipt.intLocationId
	,[intTaxGroupId]							= ReceiptCharge.intTaxGroupId
	,[strReceiptType]							= Receipt.strReceiptType
	,intForexRateTypeId							= ReceiptCharge.intForexRateTypeId
	,dblForexRate								= ReceiptCharge.dblForexRate
	,[ysnPrice]									= ReceiptCharge.ysnPrice
	,[ysnAccrue]								= ReceiptCharge.ysnAccrue
FROM 
	tblICInventoryReceiptCharge ReceiptCharge  INNER JOIN tblICItem Item 
		ON ReceiptCharge.intChargeId = Item.intItemId

	INNER JOIN tblICInventoryReceipt Receipt 
		ON ReceiptCharge.intInventoryReceiptId = Receipt.intInventoryReceiptId

	INNER JOIN (
		tblAPVendor Vendor INNER JOIN tblEMEntity Entity
			ON Vendor.[intEntityId] = Entity.intEntityId
	) 
		ON Vendor.[intEntityId] = ISNULL(ReceiptCharge.intEntityVendorId,  Receipt.intEntityVendorId) 
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId = Receipt.intLocationId	
	
	INNER JOIN vyuICGetInventoryReceiptCharge vReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = vReceiptCharge.intInventoryReceiptChargeId
	
	LEFT JOIN tblGLAccount OtherChargeExpense
		ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'Other Charge Expense') = OtherChargeExpense.intAccountId

	LEFT JOIN dbo.tblSMCurrency TransCurrency 
		ON TransCurrency.intCurrencyID = ReceiptCharge.intCurrencyId

	LEFT JOIN dbo.tblSMCurrency MainCurrency
		ON MainCurrency.intCurrencyID = TransCurrency.intMainCurrencyId
	 
	LEFT JOIN tblICItemUOM ItemCostUOM 
		ON ItemCostUOM.intItemUOMId = ReceiptCharge.intCostUOMId

	LEFT JOIN tblICUnitMeasure CostUOM 
		ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId	

	OUTER APPLY (
		SELECT TOP 1
			A.intInventoryReceiptItemId
		FROM tblICInventoryReceiptItem A
		WHERE A.intInventoryReceiptId = Receipt.intInventoryReceiptId
	) ReceiptItem 

	OUTER APPLY dbo.fnICGetScaleTicketIdForReceiptCharge(Receipt.intInventoryReceiptId, Receipt.strReceiptNumber) ScaleTicket

	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
	--LEFT JOIN tblGLAccount OtherChargeAPClearing
	--	ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId

WHERE	ReceiptCharge.ysnAccrue = 1 
		AND ISNULL(Receipt.ysnPosted, 0) = 1
		AND ISNULL(ReceiptCharge.dblAmountBilled, 0) < ROUND(ReceiptCharge.dblAmount, 6) 

-- Query for 'Price' Other Charges. 
UNION ALL 
SELECT
	 [intInventoryReceiptId]					=	ReceiptCharge.intInventoryReceiptId
	,[intEntityVendorId]						=	Vendor.[intEntityId]
	,[dtmDate]									=	Receipt.dtmReceiptDate
	,[strReference]								=	Receipt.strVendorRefNo
	,[strSourceNumber]							=	Receipt.strReceiptNumber
	,[intItemId]								=	Item.intItemId
	,[strMiscDescription]						=	Item.strDescription
	,[strItemNo]								=	Item.strItemNo
	,[strDescription]							=	Item.strDescription
	,[dblOrderQty]								=		
													CASE 
														WHEN ReceiptCharge.dblAmount > 0 
															--Negate Quantity if amount is positive for Price Down charges; Amount is negated in Voucher for Price Down so no need to negate quantity for negative amount
															THEN -(ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0))															
														ELSE 
															ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0)
													END  
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=		
													CASE 
														WHEN ReceiptCharge.dblAmount > 0 
															--Negate Quantity if amount is positive for Price Down charges; Amount is negated in Voucher for Price Down so no need to negate quantity for negative amount
															THEN -(ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0))
														ELSE 
															ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0)
													END 
	,[dblQuantityToBill]						=	
													CASE 
														WHEN ReceiptCharge.dblAmount > 0 
															--Negate Quantity if amount is positive for Price Down charges; Amount is negated in Voucher for Price Down so no need to negate quantity for negative amount
															THEN -(ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0))
														ELSE 
															ReceiptCharge.dblQuantity - ISNULL(-ReceiptCharge.dblQuantityPriced, 0)
													END 
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryReceiptItemId]				=	ReceiptItem.intInventoryReceiptItemId  --add for strSource reference
	,[intInventoryReceiptChargeId]				=	ReceiptCharge.intInventoryReceiptChargeId
	,[dblUnitCost]								=	
													CASE 
														WHEN ReceiptCharge.ysnSubCurrency = 1 AND ReceiptCharge.strCostMethod = 'Per Unit' THEN 
															ABS(ISNULL(ReceiptCharge.dblRate, 0)) * 100
														WHEN ReceiptCharge.strCostMethod = 'Per Unit' THEN 
															ABS(ISNULL(ReceiptCharge.dblRate, 0))
														WHEN ReceiptCharge.ysnSubCurrency = 1 THEN 
															ABS(ISNULL(ReceiptCharge.dblAmount, 0)) * 100
														ELSE 
															ABS(ISNULL(ReceiptCharge.dblAmount, 0))
													END
	,[dblTax]									=	ISNULL(ReceiptCharge.dblTax,0)
	,[intAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.intAccountId 
															ELSE 																
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.intAccountId
																	FROM	tblICInventoryReceiptItemAllocatedCharge ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 
	,[strAccountId]								=	
													CASE	WHEN ISNULL(ReceiptCharge.ysnInventoryCost, 0) = 0 THEN 
																OtherChargeExpense.strAccountId
															ELSE 
																(
																	-- Pick top 1 item from 'Charges per Item' and use its ap clearing account as data for Voucher (Bill). 
																	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
																	SELECT	TOP 1 
																			OtherChargeAPClearing.strAccountId
																	FROM	tblICInventoryReceiptItemAllocatedCharge ChargePerItem INNER JOIN tblICInventoryReceiptItem ReceiptItem
																				ON ChargePerItem.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
																			LEFT JOIN tblGLAccount OtherChargeAPClearing
																				ON [dbo].[fnGetItemGLAccount](ReceiptItem.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId
																	WHERE	ChargePerItem.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
																			AND ChargePerItem.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
																)

													END 

	,[strName]									= Entity.strName
	,[strVendorId]								= Vendor.strVendorId
	,[strContractNumber]						= vReceiptCharge.strContractNumber
	,[intContractHeaderId]						= ReceiptCharge.intContractId
	,[intContractDetailId]						= ReceiptCharge.intContractDetailId 
	,[intCurrencyId]							= ISNULL(ReceiptCharge.intCurrencyId,Receipt.intCurrencyId)
	,[ysnSubCurrency]							= ReceiptCharge.ysnSubCurrency
	,[intMainCurrencyId]						= CASE WHEN ReceiptCharge.ysnSubCurrency = 1 THEN MainCurrency.intCurrencyID ELSE TransCurrency.intCurrencyID END 
	,[intSubCurrencyCents]						= TransCurrency.intCent
	,[strCostUnitMeasure]						= CostUOM.strUnitMeasure
	,[intCostUnitMeasureId]                     = ItemCostUOM.intItemUOMId
	,[intScaleTicketId]							= ScaleTicket.intScaleTicketId
	,[strScaleTicketNumber]						= ScaleTicket.strScaleTicketNumber
	,[intLocationId]							= Receipt.intLocationId
	,[intTaxGroupId]							= ReceiptCharge.intTaxGroupId
	,[strReceiptType]							= Receipt.strReceiptType
	,intForexRateTypeId							= ReceiptCharge.intForexRateTypeId
	,dblForexRate								= ReceiptCharge.dblForexRate
	,[ysnPrice]									= ReceiptCharge.ysnPrice
	,[ysnAccrue]								= ReceiptCharge.ysnAccrue

FROM tblICInventoryReceiptCharge ReceiptCharge INNER JOIN tblICItem Item 
		ON ReceiptCharge.intChargeId = Item.intItemId
	INNER JOIN tblICInventoryReceipt Receipt
		ON ReceiptCharge.intInventoryReceiptId = Receipt.intInventoryReceiptId
	INNER JOIN (
		tblAPVendor Vendor INNER JOIN tblEMEntity Entity
			ON Vendor.[intEntityId] = Entity.intEntityId
	) 
		ON Vendor.[intEntityId] = Receipt.intEntityVendorId
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId = Receipt.intLocationId

	INNER JOIN vyuICGetInventoryReceiptCharge vReceiptCharge
		ON ReceiptCharge.intInventoryReceiptChargeId = vReceiptCharge.intInventoryReceiptChargeId

	LEFT JOIN tblGLAccount OtherChargeExpense
		ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'Other Charge Expense') = OtherChargeExpense.intAccountId

	LEFT JOIN dbo.tblSMCurrency TransCurrency 
		ON TransCurrency.intCurrencyID = ReceiptCharge.intCurrencyId

	LEFT JOIN dbo.tblSMCurrency MainCurrency
		ON MainCurrency.intCurrencyID = TransCurrency.intMainCurrencyId
	
	LEFT JOIN tblICItemUOM ItemCostUOM 
		ON ItemCostUOM.intItemUOMId = ReceiptCharge.intCostUOMId

	LEFT JOIN tblICUnitMeasure CostUOM 
		ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId	
	OUTER APPLY (
		SELECT TOP 1
			A.intInventoryReceiptItemId
		FROM tblICInventoryReceiptItem A
		WHERE A.intInventoryReceiptId = Receipt.intInventoryReceiptId
	) ReceiptItem

	OUTER APPLY dbo.fnICGetScaleTicketIdForReceiptCharge(Receipt.intInventoryReceiptId, Receipt.strReceiptNumber) ScaleTicket

	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
	--LEFT JOIN tblGLAccount OtherChargeAPClearing
	--	ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId

WHERE	ReceiptCharge.ysnPrice = 1
		AND ISNULL(Receipt.ysnPosted, 0) = 1
		AND ISNULL(-ReceiptCharge.dblAmountPriced, 0) < ROUND(ReceiptCharge.dblAmount, 6) 
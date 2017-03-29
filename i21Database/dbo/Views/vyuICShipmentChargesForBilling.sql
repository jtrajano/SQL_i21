CREATE VIEW [dbo].[vyuICShipmentChargesForBilling]
AS
SELECT
	 [intInventoryShipmentId]					=	ShipmentCharge.intInventoryShipmentId
	,[intEntityVendorId]						=	Vendor.[intEntityId]
	,[dtmDate]									=	Shipment.dtmShipDate
	,[strReference]								=	Shipment.strReferenceNumber
	,[strSourceNumber]							=	Shipment.strShipmentNumber
	,[intItemId]								=	Item.intItemId
	,[strMiscDescription]						=	Item.strDescription
	,[strItemNo]								=	Item.strItemNo
	,[strDescription]							=	Item.strDescription
	,[dblOrderQty]								=	1
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	1
	,[dblQuantityToBill]						=	1
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryShipmentItemId]				=	ShipmentItem.intInventoryShipmentItemId --add for strSource reference
	,[intInventoryShipmentChargeId]				=	ShipmentCharge.intInventoryShipmentChargeId
	,[dblUnitCost]								=	CASE WHEN ShipmentCharge.ysnSubCurrency > 0 THEN (ShipmentCharge.dblAmount * 100) ELSE ShipmentCharge.dblAmount END
	,[dblTax]									=	0
	,[intAccountId]								=	OtherChargeExpense.intAccountId 											 
	,[strAccountId]								=	OtherChargeExpense.strAccountId
	,[strName]									=	Entity.strName
	,[strVendorId]								=	Vendor.strVendorId
	,[strContractNumber]						=	vShipmentCharge.strContractNumber
	,[intContractHeaderId]						=	ShipmentCharge.intContractId
	,[intContractDetailId]						=	ShipmentCharge.intContractDetailId 
	,[intCurrencyId]							=	ShipmentCharge.intCurrencyId
	,[ysnSubCurrency]							=	ShipmentCharge.ysnSubCurrency
	,[intMainCurrencyId]						=	CASE WHEN ShipmentCharge.ysnSubCurrency = 1 THEN MainCurrency.intCurrencyID ELSE TransCurrency.intCurrencyID END 
	,[intSubCurrencyCents]						=	TransCurrency.intCent
	,[strCostUnitMeasure]						=	CostUOM.strUnitMeasure
	,[intCostUnitMeasureId]                     =	ItemCostUOM.intItemUOMId
	,[intScaleTicketId]							=	ScaleTicket.intScaleTicketId
	,[strScaleTicketNumber]						=	ScaleTicket.strScaleTicketNumber
	,[intLocationId]							=	Shipment.intShipFromLocationId
	,intForexRateTypeId							=	ShipmentCharge.intForexRateTypeId
	,dblForexRate								=	ShipmentCharge.dblForexRate

FROM tblICInventoryShipmentCharge ShipmentCharge INNER JOIN tblICItem Item 
		ON ShipmentCharge.intChargeId = Item.intItemId
	INNER JOIN tblICInventoryShipment Shipment
		ON ShipmentCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
	INNER JOIN (
		tblAPVendor Vendor INNER JOIN tblEMEntity Entity
			ON Vendor.[intEntityId] = Entity.intEntityId
	) 
		ON Vendor.[intEntityId] = ShipmentCharge.intEntityVendorId
	INNER JOIN tblICItemLocation ItemLocation 
		ON ItemLocation.intItemId = Item.intItemId
		AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
	
	INNER JOIN vyuICGetInventoryShipmentCharge vShipmentCharge
		ON ShipmentCharge.intInventoryShipmentChargeId = vShipmentCharge.intInventoryShipmentChargeId
	
	LEFT JOIN tblGLAccount OtherChargeExpense
		ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'Other Charge Expense') = OtherChargeExpense.intAccountId

	LEFT JOIN dbo.tblSMCurrency TransCurrency 
		ON TransCurrency.intCurrencyID = ShipmentCharge.intCurrencyId

	LEFT JOIN dbo.tblSMCurrency MainCurrency
		ON MainCurrency.intCurrencyID = TransCurrency.intMainCurrencyId
	 
	LEFT JOIN tblICItemUOM ItemCostUOM 
		ON ItemCostUOM.intItemUOMId = ShipmentCharge.intCostUOMId

	LEFT JOIN tblICUnitMeasure CostUOM 
		ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId	
	OUTER APPLY (
		SELECT
			A.intInventoryShipmentItemId
		FROM tblICInventoryShipmentItem A
		WHERE A.intInventoryShipmentId = Shipment.intInventoryShipmentId
	) ShipmentItem 

	OUTER APPLY dbo.fnICGetScaleTicketIdForShipmentCharge(Shipment.intInventoryShipmentId, Shipment.strShipmentNumber) ScaleTicket

	-- Refactor this part after we put a schedule on the change on AP-1934 and IC-1648
	--LEFT JOIN tblGLAccount OtherChargeAPClearing
	--	ON [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLocation.intItemLocationId, 'AP Clearing') = OtherChargeAPClearing.intAccountId

WHERE	ShipmentCharge.ysnAccrue = 1 
		AND ShipmentCharge.intEntityVendorId IS NOT NULL
		AND ISNULL(Shipment.ysnPosted, 0) = 1
		AND ISNULL(ShipmentCharge.dblAmountBilled, 0) < ROUND(ShipmentCharge.dblAmount, 6) 
CREATE VIEW [dbo].[vyuAPShipmentChargesForBilling]
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
	,[dblOrderQty]								=	
													CASE 
														WHEN ISNULL(ShipmentCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)) 
														ELSE ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)	
													END 
	,[dblPOOpenReceive]							=	0
	,[dblOpenReceive]							=	
													CASE 
														WHEN ISNULL(ShipmentCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)) 
														ELSE ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)	
													END 
	,[dblQuantityToBill]						=	
													CASE 
														WHEN ISNULL(ShipmentCharge.dblAmount,0) < 0 -- Negate the qty if Charge is negative. 
															THEN -(ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)) 
														ELSE ISNULL(ShipmentCharge.dblQuantity, 1) - ISNULL(ShipmentCharge.dblQuantityBilled, 0)	
													END 
	,[dblQuantityBilled]						=	0
	,[intLineNo]								=	1
	,[intInventoryShipmentItemId]				=	ShipmentItem.intInventoryShipmentItemId --add for strSource reference
	,[intInventoryShipmentChargeId]				=	ShipmentCharge.intInventoryShipmentChargeId
	,[dblUnitCost]								=	--CASE WHEN ShipmentCharge.ysnSubCurrency > 0 THEN (ShipmentCharge.dblAmount * 100) ELSE ShipmentCharge.dblAmount END
													CASE 
														WHEN ShipmentCharge.ysnSubCurrency = 1 AND ShipmentCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
															ABS(ISNULL(ShipmentCharge.dblRate, 0)) * 100
														WHEN ShipmentCharge.strCostMethod IN ('Per Unit', 'Gross Unit') THEN 
															ABS(ISNULL(ShipmentCharge.dblRate, 0))
														WHEN ShipmentCharge.ysnSubCurrency = 1 THEN 
															ABS(ISNULL(ShipmentCharge.dblAmount, 0)) * 100
														ELSE 
															ABS(ISNULL(ShipmentCharge.dblAmount, 0))
													END
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
	,[strBillOfLading]							=	Shipment.strBOLNumber
	,[intSourceType]							=	Shipment.intSourceType
	,[dblShipmentChargeLineTotal]				=	ROUND(ShipmentCharge.dblAmount, 2)
	, ShipmentCharge.dblAmount
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
		AND (
			ISNULL(ShipmentCharge.dblAmountBilled, 0) < ROUND(ShipmentCharge.dblAmount, 6) 
			OR (
				ISNULL(ShipmentCharge.dblAmountBilled, 0) = 0 
				AND ROUND(ShipmentCharge.dblAmount, 6) = 0 
			)
		)

UNION ALL

--VOUCHER CHARGES FROM LOAD SHIPMENT COST TAB
	  	SELECT 
		 [intInventoryShipmentId] = V.intLoadId		
		,[intEntityVendorId] = V.intEntityVendorId			
		,[dtmDate] = V.dtmProcessDate					
		,[strReference]	= V.strLoadNumber				
		,[strSourceNumber] = V.strLoadNumber				
		,[intItemId] = 	V.intItemId				
		,[strMiscDescription] = V.strItemDescription			
		,[strItemNo] = V.strItemNo					
		,[strDescription] = V.strItemDescription				
		,[dblOrderQty]	= 1				
		,[dblPOOpenReceive] = 1 				
		,[dblOpenReceive] = 1			
		,[dblQuantityToBill] = 1 			
		,[dblQuantityBilled] = CASE WHEN Bill.dblQtyReceived <> 0 AND Bill.ysnPosted = 1 THEN 1 ELSE 0 END 			
		,[intLineNo] = 1					
		,[intInventoryShipmentItemId]  =  NULL	
		,[intInventoryShipmentChargeId]	=  V.intLoadId		
		,[dblUnitCost]	= dblPrice					
		,[dblTax] = 0						
		,[intAccountId]	 = NULL				
		,[strAccountId]	= NULL				
		,[strName]	= V.strCustomerName				
		,[strVendorId] = ISNULL(Vendor.strVendorId,'') + ' ' + ISNULL(Vendor.strName,'') 					
		,[strContractNumber] = NULL			
		,[intContractHeaderId] = V.intContractHeaderId			
		,[intContractDetailId]	= V.intContractDetailId
		,[intCurrencyId] = V.intCurrencyId				
		,[ysnSubCurrency] = V.intCurrencyId			
		,[intMainCurrencyId] = V.intCurrencyId					
		,[intSubCurrencyCents] = V.intCurrencyId					 			
		,[strCostUnitMeasure]	= V.strPriceUOM		
		,[intCostUnitMeasureId]  = V.intItemUOMId       
		,[intScaleTicketId]	 = 	NULL		
		,[strScaleTicketNumber]	= NULL		
		,[intLocationId]	= 	NULL		
		,intForexRateTypeId	= NULL			
		,dblForexRate	= NULL				
		,[strBillOfLading] = NULL				
		,[intSourceType]	=  NULL		
		,[dblShipmentChargeLineTotal] = V.dblTotal
		, dblAmount = V.dblTotal
	FROM vyuLGLoadCostForVendor V
	JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = V.intLoadDetailId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN ISNULL(LD.intPContractDetailId, 0) = 0
				THEN LD.intSContractDetailId
			ELSE LD.intPContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LD.intItemId
		AND ItemLoc.intLocationId = CD.intCompanyLocationId
	JOIN tblICItem I ON I.intItemId = V.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemUOMId = V.intPriceItemUOMId
	LEFT JOIN vyuAPVendor Vendor
			ON Vendor.intEntityId = V.intEntityVendorId
	LEFT JOIN (
		SELECT DISTINCT 
			  Header.strBillId
			, Header.dtmBillDate
			, Header.dtmDate
			, Header.dtmDueDate
			, Header.intBillId
			, Header.dblAmountDue
			, Header.intTransactionType
			, Header.ysnPaid
			, Header.ysnPosted
			, Header.intEntityVendorId
			, Detail.intLoadId
			, Detail.dblQtyReceived
			, Detail.dblDetailTotal
			, Header.dblTotal
			, Header.intShipFromEntityId
			, T.strTerm
		FROM tblAPBill Header
		LEFT JOIN dbo.tblSMTerm T  ON Header.intTermsId = T.intTermID
		OUTER APPLY (
				SELECT 
					intLoadId,
					SUM(dblQtyReceived) AS dblQtyReceived,
					SUM(A.dblTotal)	+ SUM(A.dblTax) AS dblDetailTotal
				FROM dbo.tblAPBillDetail A
				WHERE Header.intBillId = A.intBillId AND A.intLoadId IS NOT NULL
				GROUP BY intLoadId
			) Detail		
		WHERE ISNULL(intLoadId, '') <> '' 
	) Bill ON Bill.intLoadId = V.intLoadId AND Bill.intEntityVendorId NOT IN (V.intEntityVendorId)
	WHERE  V.intLoadId NOT IN (SELECT DISTINCT intLoadId FROM tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId WHERE intLoadId IS NOT NULL AND B.ysnPosted = 1)
	GROUP BY V.intEntityVendorId
		,Vendor.strVendorId
		,Vendor.strName
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,ItemLoc.intItemLocationId
		,V.intItemId
		,V.intLoadId
		,V.strLoadNumber
		,V.dblNet
		,LD.intLoadId
		,LD.intLoadDetailId
		,V.intLoadCostId
		,I.ysnInventoryCost
		,LD.intItemUOMId
		,V.intPriceItemUOMId
		,ItemUOM.dblUnitQty
		,CostUOM.dblUnitQty
		,LD.dblQuantity
		,V.strCostMethod
		,V.dblPrice
		,V.dblTotal
		,V.dtmProcessDate
		,V.intLoadId
		,Bill.dtmDate
		,Bill.dblQtyReceived
		,Bill.strBillId
		,Bill.ysnPosted
		,Bill.dblDetailTotal
		,V.strCustomerName 
		,Bill.dtmDueDate
		,V.ysnPosted
		,Bill.ysnPaid
		,Bill.strTerm
		,Bill.intShipFromEntityId
		,V.strItemDescription
		,V.strItemNo
		,V.intContractDetailId
		,V.intContractHeaderId
		,V.intCurrencyId
		,V.strPriceUOM
		,V.intItemUOMId
GO



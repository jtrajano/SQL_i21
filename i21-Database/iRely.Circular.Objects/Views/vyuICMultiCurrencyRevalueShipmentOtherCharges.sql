CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueShipmentOtherCharges]
AS
SELECT
	 strTransactionType			= CASE s.intOrderType WHEN 1 THEN 'Sales Contract' WHEN 2 THEN 'Sales Order' WHEN 3 THEN 'Transfer Order' WHEN 4 THEN 'Direct' END
	,strTransactionId			= s.strShipmentNumber
	,strTransactionDate			= s.dtmShipDate
	,strTransactionDueDate		= s.dtmRequestedArrivalDate
	,strVendorName				= e.strName
	,strCommodity				= c.strCommodityCode
	,strLineOfBusiness			= lob.strLineOfBusiness
	,strLocation				= loc.strLocationName
	,strTicket					= CAST(NULL AS NVARCHAR(50))
	,strContractNumber			= sc.strContractNumber
	,strItemId					= sc.strItemNo
	,dblQuantity				= CAST(1 AS NUMERIC(18, 6))
	,dblUnitPrice				= sc.dblAmount
	,dblAmount					= sc.dblAmount -- + sc.dblTax  -- Note: There is no tax in Shipment Charges. 
	,intCurrencyId				= sc.intCurrencyId
	,intForexRateType			= sc.intForexRateTypeId
	,strForexRateType			= ex.strCurrencyExchangeRateType
	,dblForexRate				= sc.dblForexRate
	,dblHistoricAmount			= sc.dblAmount * sc.dblForexRate
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
	,ysnPayable					= CASE WHEN sc.ysnAccrue = 1 AND sc.intEntityVendorId IS NOT NULL AND b.intBillId IS NULL THEN 1 ELSE 0 END 
	,ysnReceivable				= CASE WHEN sc.ysnPrice = 1 AND id.intInvoiceId IS NULL THEN 1 ELSE 0 END 
FROM 
	vyuICGetInventoryShipmentCharge sc
	LEFT OUTER JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = sc.intInventoryShipmentId
	LEFT JOIN tblICItem i ON i.intItemId = sc.intItemId
	LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityCustomerId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = s.intShipFromLocationId
	LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
	LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = sc.intForexRateTypeId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	LEFT JOIN (
		tblARInvoiceDetail id INNER JOIN tblARInvoice iv 
			ON iv.intInvoiceId = id.intInvoiceId
			AND iv.ysnPosted = 1
	)
		ON id.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
		AND id.intItemId = sc.intItemId

	LEFT JOIN ( 
		tblAPBillDetail bd INNER JOIN tblAPBill b 
		ON b.intBillId = bd.intBillId		
		AND b.ysnPosted = 1
	)
		ON bd.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
		AND bd.intItemId = sc.intItemId

WHERE	s.ysnPosted = 1
		AND (id.intInvoiceId IS NULL OR b.intBillId IS NULL)
		AND sc.ysnAccrue = 1 
		-- Note: 
		-- Only include the following: 
		-- 1. Shipment charges that is payable to the vendor, ysnAccrue = 1. It is the only amount that will have impact to GL. 
	
		-- Do not include the following: 
		-- 1. Charges where both ysnPrice and ysnAccrue are zero. It has impact on Revenue and Expense account. But the GL entries basically cancelled out each other.
		-- 2. The ysnPrice = 1 has no impact to Shipment GL entries. Do not include it in the revalue. 
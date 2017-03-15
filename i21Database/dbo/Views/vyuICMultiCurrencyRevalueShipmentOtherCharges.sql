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
	,dblQuantity				= CAST(NULL AS NUMERIC(18, 6))
	,dblUnitPrice				= CAST(NULL AS NUMERIC(18, 6))
	,dblAmount					= sc.dblAmount
	,intCurrencyId				= sc.intCurrencyId
	,intForexRateType			= ssc.intForexRateTypeId
	,strForexRateType			= ex.strCurrencyExchangeRateType
	,dblForexRate				= ssc.dblForexRate
	,dblHistoricAmount			= CAST(NULL AS NUMERIC(18, 6))
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
	,ysnPayable					= CASE WHEN ssc.ysnAccrue = 1 AND ssc.intEntityVendorId IS NOT NULL AND b.intBillId IS NULL THEN 1 ELSE 0 END 
	,ysnReceivable				= CASE WHEN ssc.ysnPrice = 1 AND id.intInvoiceId IS NULL THEN 1 ELSE 0 END 
FROM 
	vyuICGetInventoryShipmentCharge sc
	INNER JOIN tblICInventoryShipmentCharge ssc ON ssc.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
	LEFT OUTER JOIN tblICInventoryShipment s ON s.intInventoryShipmentId = sc.intInventoryShipmentId
	LEFT JOIN tblICItem i ON i.intItemId = ssc.intChargeId
	LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityCustomerId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = s.intShipFromLocationId
	LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
	LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = ssc.intForexRateTypeId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	LEFT JOIN (
		tblARInvoiceDetail id INNER JOIN tblARInvoice iv 
			ON iv.intInvoiceId = id.intInvoiceId
			AND iv.ysnPosted = 1
	)
		ON id.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
		AND id.intItemId = ssc.intChargeId

	LEFT JOIN ( 
		tblAPBillDetail bd INNER JOIN tblAPBill b 
		ON b.intBillId = bd.intBillId		
		AND b.ysnPosted = 1
	)
		ON bd.intInventoryShipmentChargeId = sc.intInventoryShipmentChargeId
		AND bd.intItemId = ssc.intChargeId

WHERE	s.ysnPosted = 1
		AND (id.intInvoiceId IS NULL OR b.intBillId IS NULL)
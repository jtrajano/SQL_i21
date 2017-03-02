CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueReceiptOtherCharges]
AS
SELECT
	 strTransactionType			= r.strReceiptType
	,strTransactionId			= r.strReceiptNumber
	,strTransactionDate			= r.dtmReceiptDate
	,strTransactionDueDate		= CAST(NULL AS NVARCHAR(50))
	,strVendorName				= e.strName
	,strCommodity				= c.strCommodityCode
	,strLineOfBusiness			= lob.strLineOfBusiness
	,strLocation				= loc.strLocationName
	,strTicket					= rc.strScaleTicketNumber
	,strContractNumber			= oc.strContractNumber
	,strItemId					= oc.strItemNo
	,dblQuantity				= rc.dblQuantityBilled
	,dblUnitPrice				= rc.dblUnitCost
	,dblAmount					= oc.dblAmount
	,intCurrencyId				= rc.intCurrencyId
	,intForexRateType			= rc.intForexRateTypeId
	,strForexRateType			= ex.strCurrencyExchangeRateType
	,dblForexRate				= rc.dblForexRate
	,dblHistoricAmount			= CAST(NULL AS NUMERIC(18, 6))
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
FROM vyuICChargesForBilling rc
	LEFT OUTER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	LEFT JOIN tblEMEntity e ON e.intEntityId = r.intEntityVendorId
	LEFT JOIN tblICItem i ON i.intItemId = rc.intItemId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = r.intLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = rc.intForexRateTypeId
	LEFT JOIN vyuICGetInventoryReceiptCharge oc ON oc.intInventoryReceiptId = r.intInventoryReceiptId
		AND oc.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
WHERE r.ysnPosted = 1
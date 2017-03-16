CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueShipment]
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
	,strTicket					= st.strTicketNumber
	,strContractNumber			= hd.strContractNumber
	,strItemId					= i.strItemNo
	,dblQuantity				= si.dblQuantity
	,dblUnitPrice				= si.dblUnitPrice
	,dblAmount					= ISNULL(si.dblQuantity, 0) * ISNULL(si.dblUnitPrice, 0)
	,intCurrencyId				= s.intCurrencyId
	,intForexRateType			= si.intForexRateTypeId
	,strForexRateType			= ex.strCurrencyExchangeRateType
	,dblForexRate				= si.dblForexRate
	,dblHistoricAmount			= CAST(NULL AS NUMERIC(18, 6))
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
FROM tblICInventoryShipment s
	LEFT JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentId = s.intInventoryShipmentId
	LEFT JOIN tblICItem i ON i.intItemId = si.intItemId
	LEFT JOIN tblEMEntity e ON e.intEntityId = s.intEntityCustomerId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = s.intShipFromLocationId
	LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
	LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = si.intForexRateTypeId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	LEFT JOIN vyuCTContractHeaderView hd ON si.intSourceId = hd.intContractHeaderId
	LEFT JOIN vyuSCTicketInventoryShipmentView st ON st.intInventoryShipmentId = si.intInventoryShipmentId
	LEFT JOIN tblARInvoiceDetail id ON id.intInventoryShipmentItemId = si.intInventoryShipmentItemId
		AND id.intItemId = si.intItemId
	LEFT JOIN tblARInvoice iv ON iv.intInvoiceId = id.intInvoiceId
WHERE s.ysnPosted = 1
	AND id.intInvoiceId IS NULL
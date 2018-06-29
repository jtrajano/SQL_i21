CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueReceiptOtherCharges]
AS
SELECT
	 strTransactionType			= rc.strReceiptType
	,strTransactionId			= rc.strSourceNumber
	,strTransactionDate			= rc.dtmDate
	,strTransactionDueDate		= CAST(NULL AS NVARCHAR(50))
	,strVendorName				= rc.strName
	,strCommodity				= c.strCommodityCode
	,strLineOfBusiness			= lob.strLineOfBusiness
	,strLocation				= loc.strLocationName
	,strTicket					= rc.strScaleTicketNumber
	,strContractNumber			= rc.strContractNumber
	,strItemId					= rc.strItemNo
	,dblQuantity				= rc.dblOrderQty
	,dblUnitPrice				= rc.dblUnitCost
	,dblAmount					= rc.dblUnitCost + rc.dblTax
	,intCurrencyId				= rc.intCurrencyId
	,intForexRateType			= rc.intForexRateTypeId
	,strForexRateType			= ex.strCurrencyExchangeRateType
	,dblForexRate				= rc.dblForexRate
	,dblHistoricAmount			= (rc.dblUnitCost + rc.dblTax) * rc.dblForexRate
	,dblNewForexRate			= 0 --Calcuate By GL
	,dblNewAmount				= 0 --Calcuate By GL
	,dblUnrealizedDebitGain		= 0 --Calcuate By GL
	,dblUnrealizedCreditGain	= 0 --Calcuate By GL
	,dblDebit					= 0 --Calcuate By GL
	,dblCredit					= 0 --Calcuate By GL
FROM 
	vyuICChargesForBilling rc
	LEFT JOIN tblICItem i ON i.intItemId = rc.intItemId
	LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = rc.intLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType ex ON ex.intCurrencyExchangeRateTypeId = rc.intForexRateTypeId
	LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
	LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
WHERE 
	rc.intCurrencyId <> dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
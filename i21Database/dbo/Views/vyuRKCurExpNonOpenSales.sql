CREATE VIEW [dbo].[vyuRKCurExpNonOpenSales]

AS

SELECT NOS.intCurExpNonOpenSalesId
	, NOS.intCurrencyExposureId
	, NOS.intCustomerId
	, Customer.strCustomerNumber
	, strCustomerName = Customer.strName
	, NOS.dblQuantity
	, NOS.intQuantityUOMId
	, strQuantityUOM = QtyUOM.strUnitMeasure
	, NOS.dblOrigPrice
	, NOS.intOrigPriceUOMId
	, strPriceUOM = PriceUOM.strUnitMeasure
	, NOS.intOrigPriceCurrencyId
	, Currency.strCurrency
	, NOS.dblPrice
	, NOS.strPeriod
	, NOS.strContractType
	, NOS.dblValueUSD
	, NOS.intCompanyId
	, NOS.intConcurrencyId
FROM tblRKCurExpNonOpenSales NOS
LEFT JOIN vyuARCustomer Customer ON Customer.intEntityId = NOS.intCustomerId
LEFT JOIN tblICUnitMeasure QtyUOM ON QtyUOM.intUnitMeasureId = NOS.intQuantityUOMId
LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = NOS.intOrigPriceUOMId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = NOS.intOrigPriceCurrencyId
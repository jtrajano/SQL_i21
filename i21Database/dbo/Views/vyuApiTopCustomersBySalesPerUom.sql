CREATE VIEW [dbo].[vyuApiTopCustomersBySalesPerUom]
AS
SELECT 
	  r.intEntityCustomerId
	, r.strCustomerName
	, r.strCustomerNumber
	, c.Email strCustomerEmail
	, c.Phone strCustomerPhone
	, r.intUnitMeasureId
	, r.strUOM
	, SUM(dbo.fnCMGetForexRateFromCurrency(r.intCurrencyId, dbo.fnSMGetDefaultCurrency('REPORTING'), ad.intCurrencyExchangeRateTypeId, r.dtmDate) * r.dblLineTotal) dblTotalSales
	, SUM(ad.dblQtyOrdered) dblTotalOrdered
	, MIN(r.dtmDate) dtmLastOrderDate
	, MIN(ad.dblQtyOrdered) dblLastOrderQty
    , MIN(r.intEntitySalespersonId) intSalespersonId
FROM tblARSalesAnalysisStagingReport r
JOIN tblARInvoiceDetail ad ON ad.intInvoiceDetailId = r.intInvoiceDetailId
JOIN tblICItemUOM iu ON iu.intItemUOMId = ad.intItemUOMId
JOIN vyuApiCustomer c ON c.EntityId = r.intEntityCustomerId
WHERE r.strTransactionType != 'Order'
    AND YEAR(r.dtmDate) = YEAR(GETDATE())
GROUP BY r.intEntityCustomerId, r.strCustomerName, r.strCustomerNumber, r.intUnitMeasureId, r.strUOM, c.Email, c.Phone
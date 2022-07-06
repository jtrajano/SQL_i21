CREATE VIEW [dbo].[vyuARSalesTaxReportDashBoard]
AS
SELECT  
  strInvoiceNumber
, strItemNo
, strTaxGroup
, dtmDate
, SUM(dblTaxable) dblTaxable
, SUM(dblNonTaxable) dblNonTaxable
, SUM(dblTotalSales) dblTotalSales  
, SUM(dblTax) dblTax
FROM vyuARSalesTaxReport
GROUP BY strInvoiceNumber, strItemNo, strTaxGroup, dtmDate

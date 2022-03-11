CREATE VIEW [dbo].[vyuARSalesTaxReportDashBoard]
AS
SELECT  
  strInvoiceNumber
, COUNT(strInvoiceNumber) intInvoiceCount
, strItemNo
, strTaxGroup
, dtmDate
, SUM(dblTaxable) dblTaxable
, SUM(dblNonTaxable) dblNonTaxable
, SUM(dblTotalSales) dblTotalSales  
, SUM(dblTotalTax) dblTotalTax
, SUM(dblTotalAdjustedTax) dblTotalAdjustedTax
, dblTotalAdjustment = SUM(dblTotalTax) - SUM(dblTotalAdjustedTax) 
FROM vyuARSalesTaxReport
GROUP BY strInvoiceNumber, strItemNo, strTaxGroup, dtmDate

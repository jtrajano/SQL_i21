CREATE VIEW [dbo].[vyuARInvoiceSubFormulaReport]
AS 
SELECT strItemName		= strSubFormula
	 --, strUnitMeasure	= strUnitMeasure
	 , intEntityUserId	= intEntityUserId
	 , strRequestId		= strRequestId
	 , intInvoiceId		= intInvoiceId
	 , dblQtyOrdered	= 0.00
	 , dblQtyShipped	= SUM(dblQtyShipped)
	 , dblDiscount		= 0.00
	 , dblTaxDetail		= 0.00
	 , dblPrice			= CASE WHEN SUM(dblQtyShipped) <> 0 THEN SUM(dblItemPrice) / SUM(dblQtyShipped) ELSE 0.00 END
	 , dblTotal			= SUM(dblItemPrice)
FROM tblARInvoiceReportStagingTable
WHERE ISNULL(LTRIM(RTRIM(strSubFormula)), '') <> ''
GROUP BY intEntityUserId, intInvoiceId, strRequestId, strSubFormula--, strUnitMeasure
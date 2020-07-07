CREATE VIEW vyuARInvoiceGrossMargin
AS
SELECT  
ARI.intInvoiceId,
ARI.strInvoiceNumber, 
ARI.dblPayment dblRevenue,
SUM( dblTotalCost)dblExpense,
ARI.dblPayment- sum( dblTotalCost) dblNet, 
(ARI.dblPayment- sum( dblTotalCost)) /  ARI.dblPayment dblGrossMargin
FROM tblARInvoiceDetail ARID 
JOIN 
[vyuARSalesAnalysisReport] SA
ON ARID.intInvoiceDetailId = SA.intInvoiceDetailId
JOIN tblARInvoice ARI ON ARI.intInvoiceId = ARID.intInvoiceId
WHERE ARI.ysnPosted =1 and ysnPaid = 1
and ARI.dblInvoiceTotal <> 0
GROUP by ARI.intInvoiceId, ARI.strInvoiceNumber, ARI.dblPayment, ARI.dtmDate
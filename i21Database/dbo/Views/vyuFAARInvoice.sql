CREATE VIEW [dbo].[vyuFAARInvoice]
AS 
SELECT
	AR.intInvoiceId,
	AR.strInvoiceNumber,
	AR.dtmDate,
	AR.dtmShipDate,
	AR.intEntityCustomerId,
	CE.strName strCustomerName,
	dblInvoiceTotal = CASE WHEN (AR.strTransactionType  IN ('Invoice','Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(AR.dblInvoiceTotal, 0)
						WHEN (AR.strTransactionType  IN ('Customer Prepayment')) THEN CASE WHEN AR.ysnRefundProcessed = 1 THEN ISNULL(AR.dblInvoiceTotal, 0) * -1 ELSE 0 END
						ELSE ISNULL(AR.dblInvoiceTotal, 0) * -1 END,
	AR.intConcurrencyId
FROM tblARInvoice AR
INNER JOIN (
	SELECT intEntityId
		 , strCustomerNumber 
	FROM dbo.tblARCustomer WITH (NOLOCK)
) C ON AR.intEntityCustomerId = C.intEntityId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) CE ON C.intEntityId = CE.intEntityId

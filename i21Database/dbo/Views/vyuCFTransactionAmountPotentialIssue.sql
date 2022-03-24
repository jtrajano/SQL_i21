CREATE VIEW vyuCFTransactionAmountPotentialIssue
AS

SELECT * FROM 
(
	SELECT 
	tblCFTransaction.intTransactionId,
	tblCFTransaction.strTransactionId,
	tblCFTransaction.dblQuantity,
	dblNetPrice = ISNULL(tblCFTransaction.dblCalculatedNetPrice,0),
	dblTotalTax = SUM(ISNULL(tblCFTransactionTax.dblTaxCalculatedAmount,0)),
	dblExtendedNetPrice = ROUND(ISNULL(tblCFTransaction.dblCalculatedNetPrice,0) * ISNULL(tblCFTransaction.dblQuantity,0),2), --AR ROUNDS SUB TOTAL TO 2 DECIMAL PLACES
	dblInvoicePrice = ROUND((ISNULL(tblCFTransaction.dblCalculatedNetPrice,0) * ISNULL(tblCFTransaction.dblQuantity,0)),2) + SUM(ISNULL(tblCFTransactionTax.dblTaxCalculatedAmount,0)),
	dblTotalPrice = ROUND(ISNULL(tblCFTransaction.dblCalculatedTotalPrice,0),2)
	FROM tblCFTransaction 
	LEFT JOIN tblCFTransactionTax ON tblCFTransaction.intTransactionId = tblCFTransactionTax.intTransactionId
	WHERE ISNULL(ysnPosted,0) = 0
	GROUP BY 
	tblCFTransaction.intTransactionId,
	tblCFTransaction.dblQuantity,
	tblCFTransaction.dblCalculatedNetPrice,
	tblCFTransaction.dblCalculatedTotalPrice,
	tblCFTransaction.strTransactionId
) as tblCFTransaction
WHERE dblTotalPrice != dblInvoicePrice

go
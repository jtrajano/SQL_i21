CREATE VIEW [dbo].[vyuARCustomerStatementReport]
AS
SELECT I.strInvoiceNumber AS strReferenceNumber
	 , I.strTransactionType
	 , I.dtmDueDate
	 , intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], GETDATE())
	 , dblTotalAmount = CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid = CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , C.strCustomerNumber
	 , C.strName
	 , strFullAddress = ISNULL(RTRIM(C.strBillToLocationName) + CHAR(13) + char(10), '')
						+ ISNULL(RTRIM(C.strBillToAddress) + CHAR(13) + char(10), '')
						+ ISNULL(RTRIM(C.strBillToCity), '')
						+ ISNULL(', ' + RTRIM(C.strBillToState), '')
						+ ISNULL(', ' + RTRIM(C.strZipCode), '')
						+ ISNULL(', ' + RTRIM(C.strBillToCountry), '')
FROM tblARInvoice I
	INNER JOIN vyuARCustomer C ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE I.ysnPosted = 1
  AND I.ysnPaid = 0

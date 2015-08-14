CREATE VIEW [dbo].[vyuARCustomerStatementReport]
AS
SELECT I.strInvoiceNumber AS strReferenceNumber
	 , I.strTransactionType
	 , I.dtmDueDate
	 , I.dtmDate
	 , intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], GETDATE())
	 , dblTotalAmount = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
	 , C.strCustomerNumber
	 , C.strName
	 , strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry)
FROM tblARInvoice I
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
WHERE I.ysnPosted = 1
  AND I.ysnPaid = 0
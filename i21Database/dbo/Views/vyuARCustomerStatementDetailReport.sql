CREATE VIEW [dbo].[vyuARCustomerStatementDetailReport]
AS
SELECT I.strInvoiceNumber AS strReferenceNumber
	 , I.strTransactionType
	 , I.dtmDate
	 , I.dtmDueDate
	 , intDaysDue = DATEDIFF(DAY, I.[dtmDueDate], GETDATE())
	 , dblTotalAmount = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblInvoiceTotal, 0) * -1 ELSE ISNULL(I.dblInvoiceTotal, 0) END
	 , dblAmountPaid = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblPayment, 0) * -1 ELSE ISNULL(I.dblPayment, 0) END
	 , dblAmountDue = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END	 
	 , IC.strDescription
	 , IC.strItemNo
	 , ID.dblQtyOrdered
	 , ID.dblQtyShipped
	 , ID.dblTotal
	 , ID.dblPrice
	 , C.strCustomerNumber
	 , C.strName
	 , I.strBOLNumber
	 , CA.dblCreditLimit
	 , dblCreditAvailable = CA.dblCreditLimit - CA.dblTotalAR
	 , CA.dbl10Days
	 , CA.dbl30Days
	 , CA.dbl60Days
	 , CA.dbl90Days
	 , CA.dbl91Days
	 , I.intInvoiceId
	 , I.intEntityCustomerId
	 , strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL)
FROM tblARInvoice I
	INNER JOIN (tblARInvoiceDetail ID 
		LEFT JOIN tblICItem IC ON ID.intItemId = IC.intItemId) ON I.intInvoiceId = ID.intInvoiceId	
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId
	LEFT JOIN vyuARCustomerAgingReport CA ON I.intEntityCustomerId = CA.intEntityCustomerId
WHERE I.ysnPosted = 1
  AND I.ysnPaid = 0
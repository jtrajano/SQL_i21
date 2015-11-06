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
	 , dblPastDue = CASE WHEN DATEDIFF(DAY, I.[dtmDueDate], GETDATE()) > ISNULL(T.intBalanceDue, 0) 
						THEN CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(I.dblAmountDue, 0) * -1 ELSE ISNULL(I.dblAmountDue, 0) END
						ELSE 0
					END
	 , dblMonthlyBudget = ISNULL([dbo].[fnARGetCustomerBudget](I.intEntityCustomerId, I.dtmDate), 0)
	 , C.strCustomerNumber
	 , C.strName
	 , strFullAddress = [dbo].fnARFormatCustomerAddress(CC.strPhone, CC.strEmail, C.strBillToLocationName, C.strBillToAddress, C.strBillToCity, C.strBillToState, C.strBillToZipCode, C.strBillToCountry, NULL)
	 , strStatementFooterComment = [dbo].fnARGetFooterComment(I.intCompanyLocationId, I.intEntityCustomerId, 'Statement Footer')
	 , blbCompanyLogo = [dbo].fnSMGetCompanyLogo('Header')
	 , strCompanyName = (SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
	 , strCompanyAddress = (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup)
FROM tblARInvoice I
	INNER JOIN (vyuARCustomer C INNER JOIN vyuARCustomerContacts CC ON C.intEntityCustomerId = CC.intEntityCustomerId AND ysnDefaultContact = 1) ON I.intEntityCustomerId = C.intEntityCustomerId	
	LEFT JOIN tblSMTerm T ON I.intTermId = T.intTermID
WHERE I.ysnPosted = 1
  AND I.ysnPaid = 0
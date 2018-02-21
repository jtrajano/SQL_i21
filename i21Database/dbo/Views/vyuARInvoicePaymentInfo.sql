﻿CREATE VIEW [dbo].[vyuARInvoicePaymentInfo]
AS
SELECT I.intInvoiceId
	   , I.strInvoiceNumber
	   , I.intEntityCustomerId 
	   , strCustomerName = C.strName
	   , strCustomerNumber = C.strCustomerNumber
	   , I.intEntityContactId
	   , strContactName = EC.strName
	   , I.strType
	   , I.strTransactionType
	   , I.intTermId
	   , T.strTerm
	   , I.strBOLNumber
	   , strTicketNumbers = SCALETICKETS.strTicketNumbers
	   , strCustomerReferences = CUSTOMERREFERENCES.strCustomerReferences
	   , I.dtmDate
	   , I.dblInvoiceTotal
	   , I.dtmDueDate
	   , P.intPaymentId
	   , P.intPaymentMethodId
	   , strPaymentMethod = CASE WHEN LEN(RTRIM(LTRIM(P.strPaymentMethod))) = 0 THEN PAYMENTMETHOD.strPaymentMethod  ELSE ISNULL(P.strPaymentMethod, PAYMENTMETHOD.strPaymentMethod) END
	   , dblDiscount = CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscount,0)  ELSE  ISNULL(I.dblDiscount,0) * -1 END
	   , dblDiscountAvailable = CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblDiscountAvailable,0)  ELSE  ISNULL(I.dblDiscountAvailable,0) * -1 END
	   , dblInterest = CASE WHEN (I.strTransactionType  IN ('Invoice','Debit Memo', 'Cash')) THEN ISNULL(I.dblInterest,0)  ELSE  ISNULL(I.dblInterest,0) * -1 END
	   , PD.dblPayment
	   , I.ysnPosted
	   , I.dtmPostDate
	   , I.ysnPaid
	   , I.ysnProcessed
	   , I.ysnRecurring
	   , I.strComments
	   , strBatchId = CASE WHEN I.strTransactionType = 'Customer Prepayment' THEN P.strBatchId ELSE I.strBatchId END
	   , I.intCompanyLocationId
	   , strLocationName = L.strLocationName
	   , strEnteredBy = EB.strName
	   ,strUserEntered = USERENTERED.strName
	   , I.intCurrencyId
	   , strCurrency = CUR.strCurrency
FROM tblARInvoice I 
	RIGHT OUTER JOIN(
		SELECT intInvoiceId
		, dblPayment 
		, MAX(intPaymentId) intPaymentId
		FROM tblARPaymentDetail
		GROUP BY intInvoiceId, dblPayment
	) PD ON I.intInvoiceId = PD.intInvoiceId
	RIGHT OUTER JOIN (
		SELECT intPaymentId, intPaymentMethodId, strPaymentMethod, strBatchId FROM tblARPayment
	) P ON PD.intPaymentId = P.intPaymentId
	LEFT JOIN (
		SELECT intPaymentMethodID, strPaymentMethod FROM tblSMPaymentMethod
	) PAYMENTMETHOD ON P.intPaymentMethodId = PAYMENTMETHOD.intPaymentMethodID
	INNER JOIN (SELECT EME.intEntityId
			, EME.strName
			, ARC.strCustomerNumber
	FROM dbo.tblEMEntity EME WITH (NOLOCK)  
	LEFT JOIN (SELECT intEntityId
					, strCustomerNumber
					FROM 
					tblARCustomer WITH (NOLOCK)) ARC ON EME.intEntityId = ARC.intEntityId
	) C ON I.intEntityCustomerId = C.intEntityId
	OUTER APPLY (
		SELECT TOP 1 strName , strEmail, intEntityContactId 
		FROM dbo.vyuEMEntityContact WITH (NOLOCK) 
		WHERE I.intEntityContactId = intEntityContactId
	) EC
	LEFT OUTER JOIN (
		SELECT intTermID, strTerm
		FROM dbo.tblSMTerm WITH (NOLOCK)
	) T ON I.intTermId = T.intTermID
	INNER JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
			 , dblWithholdPercent
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) L ON I.intCompanyLocationId  = L.intCompanyLocationId  
	OUTER APPLY (
		SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1)
		FROM (
			SELECT CAST(T.strTicketNumber AS VARCHAR(200))  + ', '
			FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
			INNER JOIN (
				SELECT intTicketId, strTicketNumber 
				FROM dbo.tblSCTicket WITH(NOLOCK)
			) T ON ID.intTicketId = T.intTicketId
			WHERE ID.intInvoiceId = I.intInvoiceId
			GROUP BY ID.intInvoiceId, ID.intTicketId, T.strTicketNumber
			FOR XML PATH ('')
		) INV (strTicketNumber)
	) SCALETICKETS
	OUTER APPLY (
		SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1)
		FROM (
			SELECT CAST(T.strCustomerReference AS VARCHAR(200))  + ', '
			FROM dbo.tblARInvoiceDetail ID WITH(NOLOCK)		
			INNER JOIN (
				SELECT intTicketId, strCustomerReference 
				FROM dbo.tblSCTicket WITH(NOLOCK)
				WHERE ISNULL(strCustomerReference, '') <> ''
			) T ON ID.intTicketId = T.intTicketId
			WHERE ID.intInvoiceId = I.intInvoiceId
			GROUP BY ID.intInvoiceId, ID.intTicketId, T.strCustomerReference
			FOR XML PATH ('')
		) INV (strCustomerReference)
	) CUSTOMERREFERENCES
	LEFT OUTER JOIN (
		SELECT intEntityId, strName 
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) EB ON I.intEntityId = EB.intEntityId
	LEFT OUTER JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription
		FROM dbo.tblSMCurrency WITH (NOLOCK)
	) CUR ON I.intCurrencyId = CUR.intCurrencyID
	LEFT OUTER JOIN (
		SELECT intEntityId
			 , strName 
		FROM dbo.tblEMEntity WITH (NOLOCK)
	) USERENTERED ON USERENTERED.intEntityId = I.intPostedById
WHERE I.intInvoiceId IS NOT NULL
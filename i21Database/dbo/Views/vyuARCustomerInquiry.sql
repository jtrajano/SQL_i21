CREATE VIEW [dbo].[vyuARCustomerInquiry]
AS 
SELECT intEntityCustomerId			= C.intEntityId
	 , strCustomerName				= E.strName
	 , CI.strTerm
	 , C.strCustomerNumber
	 , strAddress					= LOCATION.strAddress
	 , strZipCode					= LOCATION.strZipCode
	 , strCity						= LOCATION.strCity
	 , strState						= LOCATION.strState
	 , strCountry					= LOCATION.strCountry
	 , strPhone1					= CONTACT2.strPhone
	 , strPhone2					= CONTACT.strPhone2
	 , strBusinessLocation			= LOCATION.strLocationName
	 , CI.strBudgetStatus
	 , dblYTDSales					= ISNULL(CI.dblYTDSales, CONVERT(NUMERIC(18,6), 0))
	 , dblLastPayment				= ISNULL(CI.dblLastPayment, CONVERT(NUMERIC(18,6), 0))
	 , dblLastYearSales				= ISNULL(CI.dblLastYearSales, CONVERT(NUMERIC(18,6), 0))
	 , dblLastStatement				= ISNULL(CI.dblLastStatement, CONVERT(NUMERIC(18,6), 0))
	 , dblPendingInvoice			= ISNULL(CI.dblPendingInvoice, CONVERT(NUMERIC(18,6), 0))
	 , dblPendingPayment			= ISNULL(CI.dblPendingPayment, CONVERT(NUMERIC(18,6), 0))
	 , dblCreditLimit				= ISNULL(CI.dblCreditLimit, CONVERT(NUMERIC(18,6), 0))
	 , dblFuture					= ISNULL(CI.dblFuture, CONVERT(NUMERIC(18,6), 0))
	 , dbl0Days						= ISNULL(CI.dbl0Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl10Days					= ISNULL(CI.dbl10Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl30Days					= ISNULL(CI.dbl30Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl60Days					= ISNULL(CI.dbl60Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl90Days					= ISNULL(CI.dbl90Days, CONVERT(NUMERIC(18,6), 0))
	 , dbl91Days					= ISNULL(CI.dbl91Days, CONVERT(NUMERIC(18,6), 0))
	 , dblUnappliedCredits			= ISNULL(CI.dblUnappliedCredits, CONVERT(NUMERIC(18,6), 0))
	 , dblPrepaids					= ISNULL(CI.dblPrepaids, CONVERT(NUMERIC(18,6), 0))
	 , dblTotalDue					= ISNULL(CI.dblTotalDue, CONVERT(NUMERIC(18,6), 0))
	 , dblBudgetAmount				= ISNULL(CI.dblBudgetAmount, CONVERT(NUMERIC(18,6), 0))	 
	 , dblThru						= ISNULL(CI.dblThru, CONVERT(NUMERIC(18,6), 0))
	 , dblNextPaymentAmount			= ISNULL(CI.dblNextPaymentAmount, CONVERT(NUMERIC(18,6), 0))
	 , dblAmountPastDue				= ISNULL(CI.dblAmountPastDue, CONVERT(NUMERIC(18,6), 0))
	 , intRemainingBudgetPeriods	= ISNULL(CI.intRemainingBudgetPeriods, CONVERT(NUMERIC(18,6), 0))
	 , dtmNextPaymentDate			= CI.dtmNextPaymentDate
	 , dtmLastPaymentDate			= CI.dtmLastPaymentDate
	 , dtmLastStatementDate			= CI.dtmLastStatementDate
	 , dtmBudgetMonth				= CI.dtmBudgetMonth
FROM dbo.tblARCustomer C WITH (NOLOCK)
LEFT JOIN (SELECT intEntityId
				, strName 
		   FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON C.intEntityId = E.intEntityId
LEFT JOIN (SELECT intEntityId
				, strAddress
				, strLocationName
				, strZipCode
				, strCity
				, strState
				, strCountry
		   FROM dbo.tblEMEntityLocation WITH (NOLOCK)
		   WHERE ysnDefaultLocation = 1
) LOCATION ON C.intEntityId = LOCATION.intEntityId
LEFT JOIN (SELECT intEntityId
				, intEntityContactId
		   FROM dbo.tblEMEntityToContact WITH (NOLOCK)
		   WHERE ysnDefaultContact = 1
) ETC ON C.intEntityId = ETC.intEntityId
LEFT JOIN (SELECT intEntityId
				, strPhone2
		   FROM dbo.tblEMEntity WITH (NOLOCK)
) CONTACT ON ETC.intEntityContactId = CONTACT.intEntityId
LEFT JOIN (SELECT intEntityId
				, strPhone
		   FROM dbo.tblEMEntityPhoneNumber WITH (NOLOCK)
) CONTACT2 ON ETC.intEntityContactId = CONTACT2.intEntityId
LEFT JOIN dbo.vyuARCustomerInquiryReport CI WITH (NOLOCK)
	ON C.intEntityId = CI.intEntityCustomerId
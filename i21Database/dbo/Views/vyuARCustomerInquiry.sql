CREATE VIEW [dbo].[vyuARCustomerInquiry]
AS 
SELECT C.[intEntityId]
	 , strCustomerName				= C.strName
	 , CI.strTerm
	 , C.strCustomerNumber
	 , C.strAddress
	 , C.strZipCode
	 , C.strCity
	 , C.strState
	 , strCountry					= C.strCountry
	 , strPhone1					= C.strPhone1
	 , strPhone2					= C.strPhone2
	 , strBusinessLocation			= C.strLocationName
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
FROM vyuARCustomer C
LEFT JOIN vyuARCustomerInquiryReport CI
	ON C.[intEntityId] = CI.intEntityCustomerId
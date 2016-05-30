CREATE VIEW [dbo].[vyuARCustomerBalancesForET]
AS 
SELECT
	 blpatr				= ARCI.[strCustomerNumber]
	,bldept				= ARCI.[strBusinessLocation]
	,blterm				= SMT.[strTermCode]  
	,blov30				= ISNULL(ARCI.[dbl30Days], 0.000000)
	,blov60				= ISNULL(ARCI.[dbl60Days], 0.000000)
	,blov90				= ISNULL(ARCI.[dbl90Days], 0.000000)
	,blcchr				= ISNULL(ARCI.[dbl0Days], 0.000000)
	,blcpay				= ISNULL(ARCI.[dblUnappliedCredits], 0.000000) + ISNULL(ARCI.[dblPrepaids], 0.000000)
	,decLastPaymentAmt	= ISNULL(ARCI.[dblLastPayment], 0.000000)
	,dtLastPaymentDate	= ARCI.[dtmLastPaymentDate]
FROM
	vyuARCustomerInquiry ARCI
INNER JOIN
	vyuARCustomer ARC
		ON ARCI.[intEntityCustomerId] = ARC.[intEntityCustomerId]
LEFT OUTER JOIN
	tblSMTerm SMT
		ON ARC.[intTermsId]	 = SMT.[intTermID]
CREATE VIEW [dbo].[vyuARPOSEndOfDayReport]
AS 
SELECT intPOSLogId			= POSLOG.intPOSLogId
	 , intEntityUserId		= POSLOG.intEntityUserId
	 , intCompanyLocationId	= POSLOG.intCompanyLocationId
	 , dtmLogin				= POSLOG.dtmLogin
	 , dtmLogout			= POSLOG.dtmLogout
	 , strStatus			= (CASE WHEN POSLOG.dtmLogout IS NULL THEN 'Open' ELSE 'Closed' END)
	 , strLocation			= CL.strLocationName
	 , strUserName			= EC.strUserName
	 , strStore				= ISNULL(STORE.strDescription, '')
	 , SubTotal				= ISNULL(POS.dblSubTotal, 0)
	 , Shipping				= ISNULL(POS.dblShipping, 0)
	 , Discount				= ISNULL(POS.dblDiscount, 0)
	 , Tax					= ISNULL(POS.dblTax, 0)
	 , Total				= ISNULL(POS.dblTotal, 0)
	 , NumberOfSales		= ISNULL(POS.intTotalSales, 0)
	 , dblEndingBalance		= ISNULL(POSLOG.dblEndingBalance, 0)
	 , dblOpeningBalance	= ISNULL(POSLOG.dblOpeningBalance, 0)
	 , Cash					= ISNULL(PAYMENT.dblCashAmount, 0)
	 , CashCount			= ISNULL(PAYMENT.intCashCount, 0)
	 , [Check]				= ISNULL(PAYMENT.dblCheckAmount, 0)
	 , CheckCount			= ISNULL(PAYMENT.intCheckCount, 0)
	 , CreditCard			= ISNULL(PAYMENT.dblCreditCardAmount, 0)
	 , CrediCardCount		= ISNULL(PAYMENT.intCreditCardCount, 0)
	 , DebitCard			= ISNULL(PAYMENT.dblDebitCardAmount, 0)
	 , DebitCardCount		= ISNULL(PAYMENT.intDebitCardCount, 0)
	 , OnAccount			= ISNULL(PAYMENT.dblOnAccountAmount, 0)
	 , OnAccountCount		= ISNULL(PAYMENT.intOnAccountCount, 0)
FROM dbo.tblARPOSLog POSLOG WITH (NOLOCK)
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON POSLOG.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN (
	SELECT intEntityId
		 , strUserName 
	FROM dbo.tblEMEntityCredential WITH (NOLOCK)
) EC ON POSLOG.intEntityUserId = EC.intEntityId
LEFT JOIN (
	SELECT intStoreId
		 , strDescription 
	FROM dbo.tblSTStore WITH (NOLOCK)
) STORE ON POSLOG.intStoreId = STORE.intStoreId
OUTER APPLY (
	SELECT dblSubTotal		= SUM(ISNULL(dblSubTotal, 0))
		 , dblShipping		= SUM(ISNULL(dblShipping, 0))
		 , dblDiscount		= SUM(ISNULL(dblDiscount, 0))
		 , dblTax			= SUM(ISNULL(dblTax, 0))
		 , dblTotal			= SUM(ISNULL(dblTotal, 0))
		 , intTotalSales	= COUNT(intPOSId)
	FROM dbo.tblARPOS WITH (NOLOCK)
	WHERE intInvoiceId IS NOT NULL
	  AND intPOSLogId = POSLOG.intPOSLogId 
) POS
OUTER APPLY (
	SELECT dblCashAmount		= SUM(CASE WHEN POSP.strPaymentMethod = 'Cash' THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
	     , intCashCount			= COUNT(CASE WHEN POSP.strPaymentMethod = 'Cash' THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblCheckAmount		= SUM(CASE WHEN POSP.strPaymentMethod = 'Check' THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intCheckCount		= COUNT(CASE WHEN POSP.strPaymentMethod = 'Check' THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblCreditCardAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'Credit Card' THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intCreditCardCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'Credit Card' THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblDebitCardAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'Debit Card' THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intDebitCardCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'Debit Card' THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblOnAccountAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'On Account' THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intOnAccountCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'On Account' THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
	FROM dbo.tblARPOSPayment POSP WITH (NOLOCK) 
	INNER JOIN (
		SELECT intPOSId
		     , intPOSLogId 
		FROM dbo.tblARPOS WITH (NOLOCK)
		WHERE intInvoiceId IS NOT NULL
		  AND intPOSLogId = POSLOG.intPOSLogId 
	) ARPOS ON POSP.intPOSId = ARPOS.intPOSId		  
) PAYMENT

CREATE VIEW [dbo].[vyuARPOSEndOfDayReport]
AS 
SELECT DISTINCT intPOSEndOfDayId		= EOD.intPOSEndOfDayId
	 , intEntityUserId		= EOD.intEntityId
	 , intCompanyLocationId	= CL.intCompanyLocationId
	 , dtmLogin				= EOD.dtmOpen
	 , dtmLogout			= EOD.dtmClose
	 , ysnClosed			= EOD.ysnClosed
	 , strStatus			= (CASE WHEN EOD.ysnClosed = 0 THEN 'Open' ELSE 'Closed' END) COLLATE Latin1_General_CI_AS
	 , strLocation			= CL.strLocationName
	 , strUserName			= EC.strUserName
	 , strStore				= ISNULL(STORE.strDescription, '')
	 , SubTotal				= ISNULL(POS.dblSubTotal, 0)
	 , Shipping				= ISNULL(POS.dblShipping, 0)
	 , Discount				= ISNULL(POS.dblDiscount, 0)
	 , Tax					= ISNULL(POS.dblTax, 0)
	 , Total				= ISNULL(POS.dblTotal, 0)
	 , NumberOfSales		= ISNULL(POS.intTotalSales, 0)
	 , dblEndingBalance		= ISNULL(EOD.dblFinalEndingBalance, 0)--ISNULL(EOD.dblOpeningBalance, 0) + ISNULL(PAYMENT.dblCashAmount, 0) + ISNULL(PAYMENT.dblCheckAmount, 0)
	 , dblOpeningBalance	= ISNULL(EOD.dblOpeningBalance, 0)
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
	 , dblCashReturn		= ISNULL(EOD.dblCashReturn,0)
	 , dblCashSales			= ISNULL(EOD.dblExpectedEndingBalance,0)
	 , intReturnCount		= ISNULL(CASHRETURN.intReturnCount,0)
FROM tblARPOSEndOfDay EOD WITH (NOLOCK)
INNER JOIN (
	SELECT 
		intPOSLogId
		,intEntityId
		,ysnLoggedIn
		,intPOSEndOfDayId
	FROM tblARPOSLog WITH (NOLOCK)
)POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
INNER JOIN(
	SELECT
		intCompanyLocationPOSDrawerId
		,intCompanyLocationId
		,strPOSDrawerName
		,ysnAllowMultipleUser
	FROM tblSMCompanyLocationPOSDrawer
) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) CL ON DRAWER.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN (
	SELECT intEntityId
		 , strUserName 
	FROM dbo.tblEMEntityCredential WITH (NOLOCK)
) EC ON EOD.intEntityId = EC.intEntityId
LEFT JOIN (
	SELECT intStoreId
		 , strDescription 
	FROM dbo.tblSTStore WITH (NOLOCK)
) STORE ON EOD.intStoreId = STORE.intStoreId
OUTER APPLY (
	SELECT dblSubTotal		= SUM(ISNULL(dblSubTotal, 0))
		 , dblShipping		= SUM(ISNULL(dblShipping, 0))
		 , dblDiscount		= SUM(ISNULL(dblDiscount, 0))
		 , dblTax			= SUM(ISNULL(dblTax, 0))
		 , dblTotal			= SUM(ISNULL(dblTotal, 0))
		 , intTotalSales	= COUNT(intPOSId)
	FROM dbo.tblARPOS IPOS WITH (NOLOCK)
	INNER JOIN (
		SELECT intPOSLogId, intPOSEndOfDayId
		FROM tblARPOSLog
	)IPOSLOG ON IPOS.intPOSLogId = IPOSLOG.intPOSLogId
	INNER JOIN(
		SELECT intPOSEndOfDayId
		FROM tblARPOSEndOfDay
	)IEOD ON IPOSLOG.intPOSEndOfDayId = IEOD.intPOSEndOfDayId
	WHERE intInvoiceId IS NOT NULL
	  AND dblTotal > 0
	  AND IEOD.intPOSEndOfDayId = EOD.intPOSEndOfDayId
) POS
OUTER APPLY (
	SELECT dblCashAmount		= SUM(CASE WHEN POSP.strPaymentMethod = 'Cash' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
	     , intCashCount			= COUNT(CASE WHEN POSP.strPaymentMethod = 'Cash' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblCheckAmount		= SUM(CASE WHEN POSP.strPaymentMethod = 'Check' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intCheckCount		= COUNT(CASE WHEN POSP.strPaymentMethod = 'Check' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblCreditCardAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'Credit Card' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intCreditCardCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'Credit Card' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblDebitCardAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'Debit Card' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intDebitCardCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'Debit Card' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
		 , dblOnAccountAmount	= SUM(CASE WHEN POSP.strPaymentMethod = 'On Account' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.dblAmount, 0) ELSE 0 END)
		 , intOnAccountCount	= COUNT(CASE WHEN POSP.strPaymentMethod = 'On Account' AND ARPOS.dblTotal > 0 THEN ISNULL(POSP.intPOSPaymentId, 0) ELSE NULL END)
	FROM dbo.tblARPOSPayment POSP WITH (NOLOCK) 
	INNER JOIN (
		SELECT PPOS.intPOSId
		     , PPOS.intPOSLogId 
			 , dblTotal 
		FROM dbo.tblARPOS PPOS WITH (NOLOCK)
		INNER JOIN (
			SELECT intPOSLogId, intPOSEndOfDayId
			FROM tblARPOSLog
		)PPOSLOG ON PPOS.intPOSLogId = PPOSLOG.intPOSLogId
		INNER JOIN(
			SELECT intPOSEndOfDayId
			FROM tblARPOSEndOfDay
		)PEOD ON PPOSLOG.intPOSEndOfDayId = PEOD.intPOSEndOfDayId
		WHERE PPOS.intInvoiceId IS NOT NULL
			AND PEOD.intPOSEndOfDayId = EOD.intPOSEndOfDayId
	) ARPOS ON POSP.intPOSId = ARPOS.intPOSId		  
) PAYMENT
OUTER APPLY (
	SELECT intReturnCount = COUNT(DISTINCT RPOS.intPOSId)	
	FROM dbo.tblARPOS RPOS WITH (NOLOCK)
	INNER JOIN  tblARPOSPayment RPOSPAYMENT ON RPOS.intPOSId = RPOSPAYMENT.intPOSId
	INNER JOIN (
		SELECT intPOSLogId, intPOSEndOfDayId
		FROM tblARPOSLog
	)RPOSLOG ON RPOS.intPOSLogId = RPOSLOG.intPOSLogId
	INNER JOIN(
		SELECT intPOSEndOfDayId
		FROM tblARPOSEndOfDay
	)REOD ON RPOSLOG.intPOSEndOfDayId = REOD.intPOSEndOfDayId
	WHERE ysnReturn = 1
	  AND dblTotal < 0
	  AND REOD.intPOSEndOfDayId = EOD.intPOSEndOfDayId
) CASHRETURN
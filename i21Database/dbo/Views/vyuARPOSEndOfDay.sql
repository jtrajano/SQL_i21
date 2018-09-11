CREATE VIEW [dbo].[vyuARPOSEndOfDay]
AS 
SELECT intPOSEndOfDayId				= EOD.intPOSEndOfDayId
	 , intPOSLogId					= POSLOG.intPOSLogId
	 , strEODNo						= EOD.strEODNo
	 , dblOpeningBalance			= EOD.dblOpeningBalance
	 , dblExpectedEndingBalance		= (EOD.dblOpeningBalance + EOD.dblExpectedEndingBalance)
	 , dblFinalEndingBalance		= EOD.dblFinalEndingBalance
	 , dblCashReturn				= ISNULL(CASHRETURN.dblCashReturn, 0)
	 , intCompanyLocationPOSDrawerId= EOD.intCompanyLocationPOSDrawerId
	 , intCompanyLocationId			= DRAWER.intCompanyLocationId
	 , intStoreId					= EOD.intStoreId
	 , intEntityId					= POSLOG.intEntityId
	 , strUsername					= CRED.strUserName
	 , strName						= EM.strName
	 , strEmail						= EM.strEmail
	 , strPOSDrawerName				= DRAWER.strPOSDrawerName
	 , strLocationName				= LOC.strLocationName
	 , strStoreName					= ST.strDescription
	 , ysnClosed					= EOD.ysnClosed
	 , ysnAllowMultipleUser			= DRAWER.ysnAllowMultipleUser
	 , dblTotalCashReceipt          = CASHRECEIPT.dblTotalCashReceipt	
FROM tblARPOSEndOfDay EOD
INNER JOIN tblSMCompanyLocationPOSDrawer DRAWER ON  EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
INNER JOIN (
	SELECT
		intCompanyLocationId
		,strLocationName
		,strAddress
		,strZipPostalCode
		,strCity
		,strStateProvince
		,strCountry
	FROM tblSMCompanyLocation
) LOC ON DRAWER.intCompanyLocationId = LOC.intCompanyLocationId
INNER JOIN (
	SELECT 
		intPOSLogId
		, intEntityId
		, intPOSEndOfDayId
	FROM tblARPOSLog
) POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
INNER JOIN (
	SELECT 
		intEntityId
		,strName
		,strEmail
		FROM tblEMEntity
) EM ON POSLOG.intEntityId = EM.intEntityId
INNER JOIN (
	SELECT
		intEntityCredentialId
		,intEntityId
		,strUserName
	FROM tblEMEntityCredential
) CRED ON EM.intEntityId = CRED.intEntityId
LEFT JOIN (
	SELECT
		intStoreId,
		strDescription
	FROM tblSTStore
) ST ON EOD.intStoreId = ST.intStoreId
OUTER APPLY (
	SELECT dblCashReturn = SUM(dblTotal)
	FROM dbo.tblARPOS WITH (NOLOCK)
	WHERE ysnReturn = 1
	  AND intPOSLogId = POSLOG.intPOSLogId
) CASHRETURN
OUTER APPLY(
	SELECT CR.intPOSLogId, dblTotalCashReceipt = SUM(ISNULL(CR.dblAmount,0))  FROM
	(
		SELECT intPOSId			= POS.intPOSId
			, dblTotal			= POS.dblTotal
			, strPaymentMethod	= PAYMENT.strPaymentMethod
			, dblAmount		= PAYMENT.dblAmountTendered
			, dblTotalAmount	= TOTAL.dblTotalAmount
			, ysnReturn        = POS.ysnReturn
			, intPOSLogId      = POS.intPOSLogId
			, ysnPaid			= CASE WHEN POS.intInvoiceId IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblARPOS POS 
	INNER JOIN tblARPOSPayment PAYMENT ON POS.intPOSId = PAYMENT.intPOSId
	CROSS APPLY (
		SELECT dblTotalAmount = SUM(POSP.dblAmountTendered) 
		FROM tblARPOSPayment POSP
		WHERE POSP.intPOSId = POS.intPOSId
	) TOTAL
	WHERE intPOSLogId = POSLOG.intPOSLogId AND POS.intInvoiceId IS NOT NULL AND POS.ysnReturn = 0 AND(PAYMENT.strPaymentMethod = 'Cash' OR PAYMENT.strPaymentMethod = 'Check')
	) CR
	GROUP BY CR.intPOSLogId
)CASHRECEIPT
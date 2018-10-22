CREATE VIEW [dbo].[vyuARPOSEndOfDay]
AS 
SELECT intPOSEndOfDayId				= EOD.intPOSEndOfDayId
	 , intPOSLogId					= POSLOG.intPOSLogId
	 , strEODNo						= EOD.strEODNo
	 , dblOpeningBalance			= EOD.dblOpeningBalance
	 , dblExpectedEndingBalance		= (EOD.dblOpeningBalance + CASHSALES.dblTotalCashReceipt) - ISNULL(ABS(CASHRETURN.dblCashReturn), 0)
	 , dblFinalEndingBalance		= EOD.dblFinalEndingBalance
	 , dblCashReturn				= ISNULL(ABS(CASHRETURN.dblCashReturn), 0)
	 , intCompanyLocationPOSDrawerId= EOD.intCompanyLocationPOSDrawerId
	 , intCompanyLocationId			= DRAWER.intCompanyLocationId
	 , intFreightTermId				= LOC.intFreightTermId
	 , intStoreId					= EOD.intStoreId
	 , intEntityId					= POSLOG.intEntityId
	 , strUsername					= CRED.strUserName
	 , strName						= EM.strName
	 , strEmail						= EM.strEmail
	 , strPOSDrawerName				= DRAWER.strPOSDrawerName
	 , strLocationName				= LOC.strLocationName
	 , strStoreName					= ST.strDescription
	 , dtmOpen						= EOD.dtmOpen
	 , dtmClose						= EOD.dtmClose
	 , ysnClosed					= EOD.ysnClosed
	 , ysnAllowMultipleUser			= DRAWER.ysnAllowMultipleUser
	 , dblTotalCashReceipt          = CASHSALES.dblTotalCashReceipt
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
		,intFreightTermId
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
	SELECT dblCashReturn = SUM(dblAmount)
	FROM dbo.tblARPOS POS WITH (NOLOCK)
	INNER JOIN  tblARPOSPayment PAY ON POS.intPOSId = PAY.intPOSId
	WHERE ysnReturn = 1
	  AND strPaymentMethod IN ('Check','Cash')
	  AND intPOSLogId = POSLOG.intPOSLogId
	  AND dblTotal < 0
) CASHRETURN
OUTER APPLY (
	SELECT dblTotalCashReceipt = SUM(dblAmount)
	FROM dbo.tblARPOS P WITH (NOLOCK)
	INNER JOIN tblARPOSPayment POSP ON P.intPOSId = POSP.intPOSId
	WHERE POSP.strPaymentMethod IN ('Cash','Check')
	AND P.intPOSLogId = POSLOG.intPOSLogId
	AND P.dblTotal > 0
) CASHSALES
GO
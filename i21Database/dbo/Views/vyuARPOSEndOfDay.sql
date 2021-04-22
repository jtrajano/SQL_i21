﻿CREATE VIEW [dbo].[vyuARPOSEndOfDay]
AS 
SELECT intPOSEndOfDayId				= EOD.intPOSEndOfDayId
	 , intPOSLogId					= POSLOG.intPOSLogId
	 , strEODNo						= EOD.strEODNo
	 , dblOpeningBalance			= EOD.dblOpeningBalance
	 , dblExpectedEndingBalance		= (EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0)) - ISNULL(ABS(EOD.dblCashReturn), 0)
	 , dblFinalEndingBalance		= EOD.dblFinalEndingBalance
	 , dblCashReturn				= ISNULL(ABS(EOD.dblCashReturn), 0)
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
	 , dblTotalCashReceipt          = EOD.dblExpectedEndingBalance
	 , dblCashReceived				= ISNULL(EOD.dblCashPaymentReceived,0.000000)
	 , dblUnprocessTransaction		= ISNULL(UnprocessTransaction.dblTotal, 0)
FROM tblARPOSEndOfDay EOD WITH (NOLOCK)
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
	FROM tblARPOSLog WITH (NOLOCK)
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
LEFT JOIN (
	SELECT SUM(dblTotal) [dblTotal],POSLOG.intPOSLogId
	FROM dbo.tblARPOS POS
		INNER JOIN dbo.tblARPOSLog POSLOG
			ON POS.intPOSLogId = POSLOG.intPOSLogId
		INNER JOIN dbo.tblARPOSEndOfDay EOD
			ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
	WHERE  POS.intInvoiceId IS  NULL	 AND POS.intCreditMemoId IS  NULL	 AND EOD.ysnClosed = 0
	GROUP BY  POSLOG.intPOSLogId
)UnprocessTransaction ON  UnprocessTransaction.intPOSLogId = POSLOG.intPOSLogId

GO 
CREATE VIEW [dbo].[vyuSTBatchPostingRetailPriceAdjustment]
	AS 
SELECT 
	'Retail Price Adjustment'				COLLATE Latin1_General_CI_AS 			AS 	strTransactionType,
	rpa.intRetailPriceAdjustmentId													AS	intTransactionId,
	rpa.strRetailPriceAdjustmentNumber		COLLATE Latin1_General_CI_AS			AS 	strTransactionId , 
	CASE 
		WHEN rpa.intEntityId IS NULL 
			THEN auditLog.intEntityId --(SELECT TOP 1 intEntityId FROM tblSMUserSecurity) 
		ELSE rpa.intEntityId 
	END AS intEntityId, 
	SUM(rpad.dblPrice)																AS	dblAmount,
	''										COLLATE Latin1_General_CI_AS			AS	strVendorInvoiceNumber,
	NULL																			AS  intEntityVendorId,
	''										COLLATE Latin1_General_CI_AS			AS	strVendorName,
	ISNULL(userSec.strUserName, '')													AS	strUserName,
	ISNULL(rpa.strDescription, '')			COLLATE Latin1_General_CI_AS			AS	strDescription,

	--rpa.dtmPostedDate																AS	dtmDate,
	--MAX(auditLog.dtmDate)															AS	dtmDate,
	rpa.dtmEffectiveDate															AS	dtmDate,

	''										COLLATE Latin1_General_CI_AS			AS  strFiscalUniqueId,
	ISNULL(companyLoc.strLocationName, '')	COLLATE Latin1_General_CI_AS			AS	strLocation,
	ISNULL(rpa.ysnPosted, 0)														AS  ysnPosted,
	companyLoc.intCompanyLocationId													AS  intCompanyLocationId
FROM tblSTRetailPriceAdjustment		rpa
INNER JOIN tblSTRetailPriceAdjustmentDetail		rpad
	ON rpa.intRetailPriceAdjustmentId	=	rpad.intRetailPriceAdjustmentId
INNER JOIN tblSMTransaction		trans
	ON rpa.intRetailPriceAdjustmentId = trans.intRecordId
INNER JOIN tblSMLog		auditLog
	ON trans.intTransactionId	=	auditLog.intTransactionId
INNER JOIN tblSMScreen	screen	
	ON trans.intScreenId	=	screen.intScreenId
LEFT JOIN tblEMEntity	em
	ON rpa.intEntityId	=	em.intEntityId
LEFT JOIN tblSMUserSecurity		userSec
	ON em.intEntityId	=	userSec.intEntityId
LEFT JOIN tblSMCompanyLocation	companyLoc
	ON userSec.intCompanyLocationId		=	companyLoc.intCompanyLocationId
WHERE rpa.strRetailPriceAdjustmentNumber IS NOT NULL
	AND screen.strModule = N'Store'
	AND screen.strScreenName = N'Retail Price Adjustment'
GROUP BY rpa.intRetailPriceAdjustmentId,
		 rpa.strRetailPriceAdjustmentNumber,
		 rpa.intEntityId,
		 userSec.strUserName,
		 rpa.strDescription,
		 rpa.dtmEffectiveDate,
		 rpa.dtmPostedDate,
		 companyLoc.strLocationName,
		 rpa.ysnPosted,
		 companyLoc.intCompanyLocationId,
		 auditLog.intEntityId
CREATE VIEW [dbo].[vyuSTBatchPostingRetailPriceAdjustment]
	AS 
SELECT 
	'Retail Price Adjustment'			AS	strTransactionType,
	rpa.intRetailPriceAdjustmentId		AS	intTransactionId,
	rpa.strRetailPriceAdjustmentNumber	AS	strTransactionId, 
	rpa.intEntityId						AS	intEntityId, 
	SUM(rpad.dblPrice)					AS	dblAmount,
	NULL								AS	strVendorInvoiceNumber,
	NULL								AS  intEntityVendorId,
	NULL								AS	strVendorName,
	ISNULL(userSec.strUserName, '')		AS	strUserName,
	rpa.strDescription					AS	strDescription,
	rpa.dtmPostedDate					AS	dtmDate,
	NULL								AS  strFiscalUniqueId,
	companyLoc.strLocationName			AS	strLocation,
	ISNULL(rpa.ysnPosted, 0)			AS  ysnPosted					
FROM tblSTRetailPriceAdjustment rpa
INNER JOIN tblSTRetailPriceAdjustmentDetail rpad
	ON rpa.intRetailPriceAdjustmentId = rpad.intRetailPriceAdjustmentId
LEFT JOIN tblEMEntity em
	ON rpa.intEntityId = em.intEntityId
LEFT JOIN tblSMUserSecurity userSec
	ON em.intEntityId = userSec.intEntityId
LEFT JOIN tblSMCompanyLocation companyLoc
	ON userSec.intCompanyLocationId = companyLoc.intCompanyLocationId
WHERE rpa.strRetailPriceAdjustmentNumber IS NOT NULL
GROUP BY rpa.intRetailPriceAdjustmentId,
		 rpa.strRetailPriceAdjustmentNumber,
		 rpa.intEntityId,
		 userSec.strUserName,
		 rpa.strDescription,
		 rpa.dtmPostedDate,
		 companyLoc.strLocationName,
		 rpa.ysnPosted
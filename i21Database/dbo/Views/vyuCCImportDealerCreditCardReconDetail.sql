CREATE VIEW [dbo].[vyuCCImportDealerCreditCardReconDetail]
AS 
SELECT D.intImportDealerCreditCardReconDetailId,
	D.intImportDealerCreditCardReconId,
	D.intVendorDefaultId,
    strVendorNo = CASE WHEN Vendor.strVendorId IS NULL THEN D.strVendor ELSE Vendor.strVendorId END,
	intBankAccountId = CASE WHEN Vendor.strVendorId IS NULL THEN NULL ELSE V.intBankAccountId END,
	strApType = CASE WHEN Vendor.strVendorId IS NULL THEN NULL ELSE V.strApType END,
	intCompanyLocationId = CASE WHEN Vendor.strVendorId IS NULL THEN NULL ELSE V.intCompanyLocationId END,
	D.intSiteId,
	D.strSiteNumber,
    strSiteDescription = S.strSiteDescription,
	D.dblGross,
	D.dblNet,
	D.dblFee,
	D.strBatchNumber,
	D.dblBatchGross,
	D.dblBatchNet,
	D.dblBatchFee,
	D.dtmTransactionDate,
	strSiteType = S.strSiteType,
    strCustomerName = S.strCustomerName,
	D.ysnValid,
	D.strMessage,
	D.ysnGeneric
 FROM tblCCImportDealerCreditCardReconDetail D 
 LEFT JOIN vyuCCSite S ON S.intSiteId = D.intSiteId
 LEFT JOIN tblCCVendorDefault V ON V.intVendorDefaultId = D.intVendorDefaultId
 LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityId = V.intVendorId

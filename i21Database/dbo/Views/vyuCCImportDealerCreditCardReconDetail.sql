CREATE VIEW [dbo].[vyuCCImportDealerCreditCardReconDetail]
AS 
SELECT D.intImportDealerCreditCardReconDetailId,
	D.intImportDealerCreditCardReconId,
	D.intVendorDefaultId,
    strVendorNo = Vendor.strVendorId,
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
	D.strMessage
 FROM tblCCImportDealerCreditCardReconDetail D 
 LEFT JOIN vyuCCSite S ON S.intSiteId = D.intSiteId
 LEFT JOIN tblCCVendorDefault V ON V.intVendorDefaultId = D.intVendorDefaultId
 LEFT JOIN tblAPVendor Vendor ON Vendor.intEntityId = V.intVendorId

CREATE VIEW [dbo].[vyuFAAssetVoucher]
AS
SELECT
	AV.intAssetVoucherId,
	AV.intAssetId,
	FA.strAssetId,
	AV.intBillId,
	AP.strBillId,
	AP.intEntityVendorId,	-- Vendor Id
	AP.strVendorName,		-- Vendor Name	
	AP.strVendorOrderNumber,-- Invoice No
	AP.dtmBillDate,			-- Invoice Date
	AP.dblTotal,			-- Invoice Amount
	AP.strTransactionType,
	AV.intConcurrencyId
FROM tblFAAssetVoucher AV
INNER JOIN tblFAFixedAsset FA 
	ON FA.intAssetId = AV.intAssetId
LEFT JOIN vyuFAAPBill AP
	ON AP.intBillId = AV.intBillId
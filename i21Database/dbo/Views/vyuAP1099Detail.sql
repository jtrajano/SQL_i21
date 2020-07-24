CREATE VIEW [dbo].[vyuAP1099Detail]
AS 

SELECT 
	CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS INT) AS intId
	,voucher.dtmDateCreated
	,voucher.dtmDate
	,voucher.dtmDatePaid
	,commodity.strCommodityCode
	,voucher.intBillId
	,voucher.strBillId
	,entity.strName
	,patron.strStockStatus
	,voucher.strVendorOrderNumber
	,(voucherDetail.dblTotal / ISNULL(NULLIF(voucher.dblTotal, 0),1)) * ISNULL(voucher.dblPayment,0) AS dblPayment
	--1099 in voucher details should be positive is line item is positive
	,voucherDetail.dbl1099 * (CASE WHEN voucher.intTransactionType = 3 THEN -1 ELSE 1 END) AS dbl1099Amount
	,voucher.strComment
	,item.strItemNo
	,item.strDescription AS strItemDescription
	,paymentInfo.strCheckNumbers COLLATE Latin1_General_CI_AS AS strCheckNumbers
	,CASE voucherDetail.int1099Form WHEN 0 THEN 'NONE'
		WHEN 1 THEN '1099 MISC'
		WHEN 2 THEN '1099 INT'
		WHEN 3 THEN '1099 B'
		WHEN 4 THEN '1099 PATR'
		WHEN 5 THEN '1099 DIV'
		ELSE 'NONE' END COLLATE Latin1_General_CI_AS AS str1099Form
	,CASE voucherDetail.int1099Form 
			WHEN 1
			THEN category.strCategory
			WHEN 4
			THEN categoryPATR.strCategory
			WHEN 5
			THEN categoryDIV.strCategory
			ELSE 'NONE'
	END AS strCategory
	,voucher.intEntityVendorId
	,voucher.intShipToId
FROM tblAPBill voucher
INNER JOIN tblAPBillDetail voucherDetail
	ON voucher.intBillId = voucherDetail.intBillId
INNER JOIN tblEMEntity entity ON voucher.intEntityVendorId = entity.intEntityId
LEFT JOIN vyuPATEntityPatron patron
	ON voucher.intEntityVendorId = patron.intEntityId
LEFT JOIN dbo.tblICItem item ON voucherDetail.intItemId = item.intItemId
LEFT JOIN dbo.tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
LEFT JOIN tblAP1099Category category ON category.int1099CategoryId = voucherDetail.int1099Category
LEFT JOIN tblAP1099PATRCategory categoryPATR ON categoryPATR.int1099CategoryId = voucherDetail.int1099Category
LEFT JOIN tblAP1099DIVCategory categoryDIV ON categoryDIV.int1099CategoryId = voucherDetail.int1099Category
OUTER APPLY (
		SELECT STUFF(
			(SELECT 
				',' + H.strReferenceNo
			FROM dbo.tblAPPayment B 
			INNER JOIN dbo.tblAPPaymentDetail C ON B.intPaymentId = C.intPaymentId
			INNER JOIN dbo.tblCMBankTransaction H ON B.strPaymentRecordNum = H.strTransactionId
			WHERE B.ysnPosted = 1 AND H.ysnCheckVoid = 0 AND C.intBillId = voucher.intBillId
			ORDER BY B.intPaymentId FOR XML PATH('')),1,1,'') AS strCheckNumbers
) paymentInfo
WHERE voucherDetail.int1099Form > 0
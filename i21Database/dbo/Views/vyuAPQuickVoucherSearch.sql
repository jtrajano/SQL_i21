CREATE VIEW [dbo].[vyuAPQuickVoucherSearch]
AS
SELECT
	A.strBillId,
	A.intBillId,
	CASE A.intTransactionType
		 WHEN 1 THEN 'Voucher'
		 WHEN 2 THEN 'Vendor Prepayment'
		 WHEN 3 THEN 'Debit Memo'
		 WHEN 7 THEN 'Invalid Type'
		 WHEN 9 THEN '1099 Adjustment'
		 WHEN 11 THEN 'Claim'
		 WHEN 12 THEN 'Prepayment Reversal'
		 WHEN 13 THEN 'Basis Advance'
		 WHEN 14 THEN 'Deferred Interest'
		 ELSE 'Invalid Type'
	END COLLATE Latin1_General_CI_AS AS strTransactionType,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	CASE WHEN (A.intTransactionType IN (3,8,11)) OR (A.intTransactionType IN (2,13) AND A.ysnPrepayHasPayment = 1) THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblPayment,
	A.dtmDate,
	A.dtmBillDate,
	A.dtmDueDate,
	A.strVendorOrderNumber,
	A.intTransactionType,
	A.intEntityVendorId,
	A.dblWithheld,
	A.strReference,
	A.strComment,
	CASE WHEN A.dtmDateCreated IS NULL THEN A.dtmDate ELSE A.dtmDateCreated END AS dtmDateCreated,
	A.dblTax,
	B1.strName,
	F.strUserName AS strUserId,
	G.strLocationName AS strUserLocation,
	A.ysnPosted,
	EL.strCheckPayeeName AS strPayeeName,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	A.ysnPrepayHasPayment,
	A.intShipToId
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	OUTER APPLY (
		SELECT TOP 1
			COUNT(commodity.intCommodityId) intCount, 
			commodity.intCommodityId,
			commodity.strCommodityCode
		FROM tblAPBillDetail detail
		LEFT JOIN tblICItem item ON detail.intItemId = item.intItemId
		LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
		WHERE detail.intBillId = A.intBillId
		GROUP BY commodity.intCommodityId, commodity.strCommodityCode
		ORDER BY COUNT(commodity.intCommodityId) DESC
	) commodity
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	LEFT JOIN dbo.tblSMCompanyLocation G
		ON A.intStoreLocationId = G.intCompanyLocationId
	LEFT JOIN dbo.tblEMEntityLocation EL 
		ON EL.intEntityLocationId = A.intPayToAddressId
	

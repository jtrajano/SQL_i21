CREATE VIEW [dbo].[vyuAPRestApiVoucher]
AS
SELECT
	bill.strBillId strVoucherNo,
	bill.intBillId intVoucherId,
	CASE bill.intTransactionType
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
	CASE WHEN (bill.intTransactionType IN (3,8,11)) OR (bill.intTransactionType IN (2,13) AND bill.ysnPrepayHasPayment = 1) THEN bill.dblTotal * -1 ELSE bill.dblTotal END AS dblTotal,
	CASE WHEN (bill.intTransactionType IN (3,8,11)) OR (bill.intTransactionType IN (2,13) AND bill.ysnPrepayHasPayment = 1) THEN bill.dblAmountDue * -1 ELSE bill.dblAmountDue END AS dblAmountDue,
	CASE WHEN (bill.intTransactionType IN (3,8,11)) OR (bill.intTransactionType IN (2,13) AND bill.ysnPrepayHasPayment = 1) THEN bill.dblPayment * -1 ELSE bill.dblPayment END AS dblPayment,
	bill.dtmDate,
	fiscalPeriod.strPeriod,
	bill.dtmBillDate,
	bill.dtmDueDate,
	bill.strVendorOrderNumber strInvoiceNo,
	bill.intTransactionType,
	entity.intEntityId,
	bill.dblWithheld,
	bill.strReference,
	bill.strComment,
	CASE WHEN bill.dtmDateCreated IS NULL THEN bill.dtmDate ELSE DATEADD(dd, DATEDIFF(dd, 0,bill.dtmDateCreated), 0) END AS dtmDateCreated,
	bill.dblTax,
	entity.strName,
	entityCredential.strUserName AS strUserId,
	companyLocation.strLocationName AS strUserLocation,
	companyLocation.intCompanyLocationId AS intLocationId,
	bill.ysnPosted,
	entityLocation.strCheckPayeeName AS strPayeeName,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	bill.ysnPrepayHasPayment,
	bill.intShipToId,
	shipTo.strLocationName strShipToLocation,
	COALESCE(updated.dtmDate, created.dtmDate, CASE WHEN bill.dtmDateCreated IS NULL THEN bill.dtmDate ELSE DATEADD(dd, DATEDIFF(dd, 0,bill.dtmDateCreated), 0) END) dtmDateLastUpdated
FROM
	dbo.tblAPBill bill
	INNER JOIN (dbo.tblAPVendor vendor INNER JOIN dbo.tblEMEntity entity ON vendor.[intEntityId] = entity.intEntityId)
		ON bill.[intEntityVendorId] = vendor.[intEntityId]
	LEFT JOIN tblSMCompanyLocation shipTo ON shipTo.intCompanyLocationId = bill.intShipToId
	OUTER APPLY (
		SELECT TOP 1 commodity.strCommodityCode
		FROM dbo.tblAPBillDetail detail
		LEFT JOIN dbo.tblICItem item ON detail.intItemId = item.intItemId
		LEFT JOIN dbo.tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
		WHERE detail.intBillId = bill.intBillId
	) commodity
	LEFT JOIN dbo.[tblEMEntityCredential] entityCredential ON bill.intEntityId = entityCredential.intEntityId
	LEFT JOIN dbo.tblSMCompanyLocation companyLocation
		ON bill.intStoreLocationId = companyLocation.intCompanyLocationId
	LEFT JOIN dbo.tblEMEntityLocation entityLocation 
		ON entityLocation.intEntityLocationId = bill.intPayToAddressId
	LEFT JOIN dbo.tblGLFiscalYearPeriod fiscalPeriod
		ON bill.dtmDate BETWEEN fiscalPeriod.dtmStartDate AND fiscalPeriod.dtmEndDate OR bill.dtmDate = fiscalPeriod.dtmStartDate OR bill.dtmDate = fiscalPeriod.dtmEndDate
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = bill.intBillId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'AccountsPayable.view.Voucher'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = bill.intBillId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'AccountsPayable.view.Voucher'
) updated

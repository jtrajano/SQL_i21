CREATE VIEW vyuSMTransactionRaw
AS

SELECT 	
	ROW_NUMBER() OVER(ORDER BY B.intScreenId DESC) AS intRowId,
	A.intId,
	A.strRecordNo, 
	B.strNamespace,
	B.strScreenName,
	B.intScreenId,
	intEntityId
FROM (
	SELECT 
		intJournalId as intId,
		strJournalId as strRecordNo, 
		NULL as intEntityId,
		'GeneralLedger.view.GeneralJournal' as strNamespace
	FROM tblGLJournal
	UNION ALL
	SELECT
		intAccountId as intId,
		strAccountId as strRecordNo,
		NULL as intEntityId,
		'GeneralLedger.view.EditAccount' as strNamespace
	FROM tblGLAccount
	UNION ALL
	SELECT
		intLoadId as intId,
		strLoadNumber as strRecordNo,
		NULL as intEntityId,
		'Logistics.view.LoadSchedule' as strNamespace
	FROM tblLGLoad
	UNION ALL
	SELECT
		intEntityId as intId,
		strEntityNo as strRecordNo,
		NULL as intEntityId,
		'EntityManagement.view.Entity' as strNamespace
	FROM tblEMEntity
	UNION ALL
	SELECT
		intBillBatchId as intId,
		strBillId as strRecordNo,
		intEntityVendorId as intEntityId,
		'AccountsPayable.view.Voucher' as strNamespace
	FROM tblAPBill
	UNION ALL
	Select
		intPurchaseId as intId,
		strPurchaseOrderNumber as strRecordNo,
		intEntityVendorId as intEntityId,
		'AccountsPayable.view.PurchaseOrder' as strNamespace
	FROM tblPOPurchase
	UNION ALL
	SELECT
		intSalesOrderId as intId,
		strSalesOrderNumber as strRecordNo,
		intEntityCustomerId as intEntityId,
		'AccountsReceivable.view.SalesOrder' as strNamespace
	FROM tblSOSalesOrder
	UNION ALL
	SELECT
		intContractHeaderId as intId,
		strContractNumber as strRecordNo,
		intEntityId as intEntityId,
		'ContractManagement.view.Contract' as strNamespace
	FROM tblCTContractHeader
	UNION ALL
	SELECT
		intFutOptTransactionId as intId,
		NULL as strRecordNo,
		intEntityId as intEntityId,
		'RiskManagement.view.FuturesOptionsTransactions' as strNamespace
	FROM tblRKFutOptTransaction
	UNION ALL
	SELECT
		intTimeOffRequestId as intId,
		strRequestId as strRecordNo,
		intEntityEmployeeId as intEntityId,
		'Payroll.view.TimeOffRequest' as strNamespace
	FROM tblPRTimeOffRequest) A 
	INNER JOIN tblSMScreen B ON A.strNamespace COLLATE SQL_Latin1_General_CP1_CS_AS = B.strNamespace

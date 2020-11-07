IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblGRSettleStorageBillDetail')
BEGIN
	PRINT '--Start inserting missing bill ids and settle storage ids in tblGRSettleStorageBillDetail--'

	INSERT INTO tblGRSettleStorageBillDetail
	SELECT 1, SS.intSettleStorageId,AP.intBillId,1
	FROM tblAPBill AP
	INNER JOIN tblGRSettleStorage SS
		ON SS.strStorageTicket = AP.strVendorOrderNumber
	WHERE AP.intTransactionType = 1
		AND AP.strVendorOrderNumber LIKE 'STR-%'
		AND NOT EXISTS (select intBillId, intSettleStorageId from tblGRSettleStorageBillDetail where intBillId = AP.intBillId AND intSettleStorageId = SS.intSettleStorageId)

	PRINT '--End inserting missing bill ids and settle storage ids in tblGRSettleStorageBillDetail--'
END
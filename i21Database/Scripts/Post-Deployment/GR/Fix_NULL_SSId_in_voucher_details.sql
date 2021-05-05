PRINT 'BEGIN UPDATING NULL intSettleStorageId in tblAPBillDetail'
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblGRSettleStorageBillDetail')
BEGIN
--DECLARE @tbl AS TABLE
--(
--	strBillId NVARCHAR(40) COLLATE Latin1_General_CI_AS
--	,intBillId INT
--	,intBillDetailId INT
--	,strMiscDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
--	,intSettleStorageId INT NULL
--	,strVendorOrderNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS
--)

--INSERT INTO @tbl
--SELECT A.strBillId,A.intBillId,B.intBillDetailId,B.strMiscDescription,B.intSettleStorageId,A.strVendorOrderNumber
--FROM tblAPBill A
--INNER JOIN tblAPBillDetail B
--	ON B.intBillId = A.intBillId
--WHERE A.strVendorOrderNumber LIKE 'STR-%' AND A.intTransactionType = 1 AND B.intSettleStorageId IS NULL AND B.intCustomerStorageId IS NOT NULL
--ORDER BY A.strVendorOrderNumber

--SELECT '--no settle storage id--', * FROM @tbl

	INSERT INTO tblGRSettleStorageBillDetail
	--SELECT SS.strStorageTicket,AP.strBillId 
	SELECT 1, SS.intSettleStorageId,AP.intBillId,1
	FROM tblAPBill AP
	INNER JOIN tblGRSettleStorage SS
		ON SS.strStorageTicket = AP.strVendorOrderNumber
	WHERE AP.intTransactionType = 1
		AND AP.strVendorOrderNumber LIKE 'STR-%'
		AND NOT EXISTS (select intBillId, intSettleStorageId from tblGRSettleStorageBillDetail where intBillId = AP.intBillId AND intSettleStorageId = SS.intSettleStorageId)
	ORDER BY SS.intSettleStorageId

	UPDATE BD
	SET intSettleStorageId = SS.intSettleStorageId
	FROM tblAPBillDetail BD
	INNER JOIN tblAPBill AP
		ON AP.intBillId = BD.intBillId
	INNER JOIN tblGRSettleStorageBillDetail SS
		ON SS.intBillId = BD.intBillId
	WHERE BD.intSettleStorageId IS NULL
		AND BD.intCustomerStorageId IS NOT NULL
	
END

PRINT 'END UPDATING NULL intSettleStorageId in tblAPBillDetail'
GO
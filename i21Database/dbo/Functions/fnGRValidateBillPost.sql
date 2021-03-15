CREATE FUNCTION [dbo].[fnGRValidateBillPost]
(
	@billIds NVARCHAR(MAX),
	@post BIT,
	@transaction NVARCHAR(100)
)
RETURNS @returntable TABLE
(
	strError NVARCHAR(1000),
	strTransactionType NVARCHAR(50),
	strTransactionNo NVARCHAR(50),
	intTransactionId INT
)
AS
BEGIN
	
	DECLARE @tmpBills TABLE(
		[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
	);
	INSERT INTO @tmpBills SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@billIds)

	--USER IS POSTING/UNPOSTING ON VOUCHER SCREEN
	IF @transaction = 'Voucher'
	BEGIN
		IF @post = 0
		BEGIN
			INSERT INTO @returntable
			SELECT	'Please unpost the voucher on settle storage screen.',
					'Settle Storage',
					SS.strStorageTicket,
					SS.intSettleStorageId
			FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN 
			(
				tblGRCustomerStorage CS
				INNER JOIN tblGRSettleStorageTicket SST
					ON SST.intCustomerStorageId = CS.intCustomerStorageId
				INNER JOIN tblGRSettleStorage SS
					ON SST.intSettleStorageId = SS.intSettleStorageId
			) ON B.intCustomerStorageId = CS.intCustomerStorageId
			WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		END
		ELSE
		BEGIN
			--ALLOW POSTING ON VOUCHER SCREEN ONLY FOR DP
			INSERT INTO @returntable
			SELECT	'Please post the voucher on settle storage screen for non-DP.',
					'Settle Storage',
					SS.strStorageTicket,
					SS.intSettleStorageId
			FROM tblAPBill A
			INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
			INNER JOIN 
			(
				tblGRCustomerStorage CS
				INNER JOIN tblGRSettleStorageTicket SST
					ON SST.intCustomerStorageId = CS.intCustomerStorageId
				INNER JOIN tblGRSettleStorage SS
					ON SST.intSettleStorageId = SS.intSettleStorageId
				INNER JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType != 1
			) ON B.intCustomerStorageId = CS.intCustomerStorageId
			WHERE A.intBillId IN (SELECT [intBillId] FROM @tmpBills)
		END
	END
	--PUT VALIDATION HERE FOR SETTLE STORAGE WHEN POSTING/UNPOSTING DONE ON SETTLE STORAGE SCREEN
	--ELSE
	--BEGIN
	--END

	RETURN;
END

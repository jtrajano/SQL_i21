CREATE FUNCTION [dbo].[fnGRCheckBillPaymentOfSettleStorage]
(
  @intSettleStorageId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnBillIsPaid BIT
	DECLARE @isParent BIT

	--CHECK FIRST IF SELECTED SETTLE STORAGE IS A PARENT
	SELECT @isParent = CAST(CASE WHEN intParentSettleStorageId IS NULL THEN 1 ELSE 0 END AS BIT)
	FROM tblGRSettleStorage
	WHERE intSettleStorageId = @intSettleStorageId

	--1: GET THE BILL IDS OF CHILDREN; 0: OK
	IF @isParent = 1
	BEGIN
		SELECT @ysnBillIsPaid = CAST(CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS BIT)
		FROM tblGRSettleStorage SS
		INNER JOIN tblAPBill AP
			ON AP.intBillId = SS.intBillId
		WHERE intParentSettleStorageId = @intSettleStorageId AND AP.dblPayment > 0
	END
	ELSE
	BEGIN
		SELECT @ysnBillIsPaid = CAST(CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS BIT)
		FROM tblGRSettleStorage SS
		INNER JOIN tblAPBill AP
			ON AP.intBillId = SS.intBillId
		WHERE SS.intSettleStorageId = @intSettleStorageId AND AP.dblPayment > 0
	END

	RETURN @ysnBillIsPaid
END
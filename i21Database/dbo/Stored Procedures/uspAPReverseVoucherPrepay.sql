﻿CREATE PROCEDURE [dbo].[uspAPReverseVoucherPrepay]
	@billId INT,
	@userId INT,
	@createdReversal INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @postSuccess BIT = 0;
DECLARE @postParam NVARCHAR(50);
DECLARE @batchId NVARCHAR(50);
DECLARE @error NVARCHAR(200);
DECLARE @recordNum NVARCHAR(50);
DECLARE @GLEntries AS RecapTableType;
DECLARE @transCount INT;
DECLARE @ids AS Id;
DECLARE @oldPrepay BIT;
DECLARE @oldBillId NVARCHAR(50);

BEGIN TRY

SET @transCount = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

EXEC uspAPDuplicateBill @billId = @billId, @userId = @userId, @type = 12, @billCreatedId = @createdReversal OUT
--EXEC uspSMGetStartingNumber 122, @recordNum OUTPUT

SELECT
	@oldPrepay = CASE WHEN ysnOldPrepayment = 1 OR ysnOrigin = 1 THEN 1 ELSE 0 END,
	@oldBillId = strBillId
FROM tblAPBill WHERE intBillId = @billId

UPDATE A
	SET A.intTransactionType = 12
	,A.dtmDate = GETDATE()
	,A.strBillId = @oldBillId + '-R'
FROM tblAPBill A
WHERE A.intBillId = @createdReversal

--IF OLD PREPAYMENT, DO NOT REVERSE GL ENTRIES AS THERE ARE NO GL ENTRIES
IF @oldPrepay = 0
BEGIN
	INSERT INTO @ids
	SELECT @billId

	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@ids, 'Bill', DEFAULT, @userId, @batchId)

	EXEC uspGLBookEntries @GLEntries, 1
END

UPDATE A
	SET A.intTransactionReversed = @createdReversal
FROM tblAPBill A
WHERE A.intBillId = @billId

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	SET @error = ERROR_MESSAGE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@error, 16, 1);
END CATCH
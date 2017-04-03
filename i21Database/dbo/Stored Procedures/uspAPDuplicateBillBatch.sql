CREATE PROCEDURE [dbo].[uspAPDuplicateBillBatch]
	@billBatchId INT,
	@userId INT,
	@billBatchCreatedId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @generatedBillBatchRecordId NVARCHAR(50);
DECLARE @createdBillId INT;
DECLARE @billId INT, @vendorId INT;
DECLARE @shipFromId INT, @shipToId INT;
DECLARE @tmpBillData TABLE(
	[intBillId] [int] PRIMARY KEY,
	[intEntityVendorId] INT,
	UNIQUE ([intBillId])
);

BEGIN TRANSACTION

IF (@userId IS NULL)
BEGIN
	RAISERROR('User is required.', 16, 1);
	GOTO UNDO;
END

EXEC uspSMGetStartingNumber 7, @generatedBillBatchRecordId OUT

SET @shipToId = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE [intEntityId] = @userId)
IF (@shipToId IS NULL)
BEGIN
	SET @shipToId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation)
END

--EXEC uspSMGetStartingNumber 7, @generatedBillBatchRecordId OUT

INSERT INTO tblAPBillBatch(
	[intAccountId],
    [ysnPosted],
	[dtmBatchDate],
    [strReference],
	[strBillBatchNumber],
    [dblTotal],
    [intConcurrencyId], 
    [intEntityId], 
    [dtmDateCreated]
)
SELECT
	[intAccountId]			=	A.intAccountId,
    [ysnPosted]				=	0,
	[dtmBatchDate]			=	GETDATE(),
    [strReference]			=	A.strReference + ' Duplicate of ' + A.strBillBatchNumber,
	[strBillBatchNumber]	=	@generatedBillBatchRecordId,
    [dblTotal]				=	A.dblTotal,
    [intConcurrencyId]		=	0, 
    [intEntityId]			=	@userId, 
    [dtmDateCreated]		=	GETDATE()
FROM tblAPBillBatch A
WHERE A.intBillBatchId = @billBatchId

SET @billBatchCreatedId = SCOPE_IDENTITY()

INSERT INTO @tmpBillData 
SELECT intBillId, intEntityVendorId FROM tblAPBill WHERE intBillBatchId = @billBatchId;

WHILE EXISTS(SELECT 1 FROM @tmpBillData)
BEGIN
	SELECT TOP 1 @billId = intBillId, @vendorId = intEntityVendorId FROM @tmpBillData
	EXEC uspAPDuplicateBill @billId, @userId, @createdBillId OUT;
	--GET DEFAULT SHIP FROM PER VENDOR
	SET @shipFromId = (SELECT intEntityLocationId FROM [tblEMEntityLocation] WHERE intEntityId = @vendorId AND ysnDefaultLocation = 1)
	UPDATE A
		SET intBillBatchId = @billBatchCreatedId
		,intShipFromId = CASE WHEN intShipFromId IS NULL OR intShipFromId <= 0 THEN @shipFromId ELSE A.intShipFromId END --SET DEFAULT SHIP FROM
		,intShipToId = CASE WHEN intShipToId IS NULL OR intShipToId <= 0 THEN @shipToId ELSE A.intShipToId END --SET DEFAULT SHIP TO
	FROM tblAPBill A
	WHERE A.intBillId = @createdBillId
	DELETE FROM @tmpBillData WHERE intBillId = @billId
END

GOTO DONE;

DONE:
COMMIT TRANSACTION;
RETURN;

UNDO:
ROLLBACK TRANSACTION;
RETURN;
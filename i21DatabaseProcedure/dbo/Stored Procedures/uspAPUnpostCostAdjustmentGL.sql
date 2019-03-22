CREATE PROCEDURE [dbo].[uspAPUnpostCostAdjustmentGL]
	@billIds AS Id READONLY,
	@batchId AS NVARCHAR(100),
	@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @billId INT;
DECLARE @strBatchId NVARCHAR(100) = @batchId;
DECLARE @billRecordNumber NVARCHAR(100);
DECLARE @billsCursor AS CURSOR;

SET @billsCursor = CURSOR FORWARD_ONLY FOR

SELECT 
	A.intBillId
	,A.strBillId
FROM tblAPBill A
	INNER JOIN @billIds B
	ON A.intBillId = B.intId

OPEN @billsCursor;

FETCH NEXT FROM @billsCursor INTO @billId, @billRecordNumber

WHILE @@FETCH_STATUS = 0
BEGIN

	EXEC uspICUnpostCostAdjustment @billId, @billRecordNumber, @strBatchId, @userId, DEFAULT
	FETCH NEXT FROM @billsCursor INTO @billId, @billRecordNumber
END

CLOSE @billsCursor;
DEALLOCATE @billsCursor;

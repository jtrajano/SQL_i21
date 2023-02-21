CREATE PROCEDURE [dbo].[uspGRUnpostAdjustSettlements]
(
	@intAdjustSettlementId INT
)
AS
BEGIN
DECLARE @ErrMsg AS NVARCHAR(MAX)
DECLARE @intTypeId INT
DECLARE @intUserId INT
DECLARE @success BIT
DECLARE @strBillId NVARCHAR(40)
DECLARE @ysnBillPosted BIT
DECLARE @BillIds AS Id
DECLARE @intBillId INT
DECLARE @intAdjustmentTypeId INT
DECLARE @batchIdUsed NVARCHAR(50)

BEGIN TRANSACTION
BEGIN TRY

SELECT @intTypeId = intTypeId
	,@strBillId = strBillNumbers
	,@intUserId = intCreatedUserId
	,@ysnBillPosted = ysnBillPosted
	,@intAdjustmentTypeId = intAdjustmentTypeId
FROM vyuGRSearchAdjustSettlements
WHERE intAdjustSettlementId = @intAdjustSettlementId

INSERT INTO @BillIds
SELECT COALESCE(A.intBillId,B.intBillId)
FROM tblGRAdjustSettlements A
LEFT JOIN tblGRAdjustSettlementsSplit B
	ON B.intAdjustSettlementId = A.intAdjustSettlementId

IF @intTypeId = 1
BEGIN
	IF @ysnBillPosted = 1
	BEGIN
		IF @intAdjustmentTypeId <> 1 --NOT ADVANCE
		BEGIN
			EXEC [dbo].[uspAPPostBill] 
					@post = 0
					,@recap = 0
					,@isBatch = 0
					,@param = @strBillId
					,@userId = @intUserId
					,@transactionType = NULL
					,@success = @success OUTPUT
		END
		ELSE
		BEGIN
			EXEC [dbo].[uspAPPostVoucherPrepay]
				@post = 0
				,@recap = 0
				,@param = @strBillId
				,@batchId = DEFAULT
				,@userId = @intUserId
				,@success = @success OUTPUT
				,@batchIdUsed = @batchIdUsed OUTPUT
		END
	END
	
	IF EXISTS(SELECT 1 FROM @BillIds)
	BEGIN
		SELECT TOP 1 @intBillId = intId FROM @BillIds

		EXEC uspAPDeleteVoucher 
			@intBillId
			,@intUserId
			,@callerModule = 1

		DELETE FROM @BillIds WHERE intId = @intBillId
	END	
END
ELSE
BEGIN
	IF @ysnBillPosted = 1
	BEGIN
		SET @strBillId = CAST(@strBillId AS NVARCHAR(40))
		EXEC dbo.uspARPostInvoice @param = @strBillId, @post = 0, @recap = 0, @userId = @intUserId, @raiseError = 1
	END
	
	IF EXISTS(SELECT 1 FROM @BillIds)
	BEGIN
		SELECT TOP 1 @intBillId = intId FROM @BillIds

		EXEC dbo.uspARDeleteInvoice @intBillId, @intUserId

		DELETE FROM @BillIds WHERE intId = @intBillId
	END
END

DELETE FROM tblGRAdjustSettlements WHERE intAdjustSettlementId = @intAdjustSettlementId

SELECT SCOPE_IDENTITY()

Post_Transaction:
COMMIT TRANSACTION

END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
SET @ErrMsg = ERROR_MESSAGE()
RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

END
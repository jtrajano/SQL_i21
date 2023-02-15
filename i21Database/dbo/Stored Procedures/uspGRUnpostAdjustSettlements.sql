CREATE PROCEDURE [dbo].[uspGRUnpostAdjustSettlements]
(
	@intAdjustSettlementId INT
)
AS
BEGIN
DECLARE @ErrMsg AS NVARCHAR(MAX)
DECLARE @intTypeId INT
DECLARE @intBillId INT
DECLARE @intUserId INT
DECLARE @success BIT
DECLARE @strBillId NVARCHAR(40)
DECLARE @ysnBillPosted BIT

BEGIN TRANSACTION
BEGIN TRY

SELECT @intTypeId = intTypeId
	,@intBillId = strBillNumbers
	,@intUserId = intCreatedUserId
	,@ysnBillPosted = ysnBillPosted
FROM vyuGRSearchAdjustSettlements
WHERE intAdjustSettlementId = @intAdjustSettlementId

IF @intTypeId = 1
BEGIN
	IF @ysnBillPosted = 1
	BEGIN
		EXEC [dbo].[uspAPPostBill] 
				@post = 0
				,@recap = 0
				,@isBatch = 0
				,@param = @intBillId
				,@userId = @intUserId
				,@transactionType = NULL
				,@success = @success OUTPUT
	END

	IF @intBillId IS NOT NULL
	BEGIN
		EXEC uspAPDeleteVoucher 
			@intBillId
			,@intUserId
			,@callerModule = 1
	END	
END
ELSE
BEGIN
	IF @ysnBillPosted = 1
	BEGIN
		SET @strBillId = CAST(@intBillId AS NVARCHAR(40))
		EXEC dbo.uspARPostInvoice @param = @strBillId, @post = 0, @recap = 0, @userId = @intUserId, @raiseError = 1
	END
	
	IF @intBillId IS NOT NULL
	BEGIN
		EXEC dbo.uspARDeleteInvoice @intBillId, @intUserId
	END
END

INSERT INTO tblGRDeletedAdjustSettlements
(
	[intAdjustSettlementId]
	,[strAdjustSettlementNumber]
	,[intTypeId]
	,[intEntityId]
	,[intCompanyLocationId]
	,[intItemId]
	,[intTicketId]
	,[strTicketNumber]
	,[intAdjustmentTypeId]
	,[intSplitId]
	,[dtmAdjustmentDate]
	,[dblAdjustmentAmount]
	,[dblWithholdAmount]
	,[dblTotalAdjustment]
	,[dblCkoffAdjustment]
	,[strRailReferenceNumber]
	,[strCustomerReference]
	,[strComments]
	,[intGLAccountId]
	,[ysnTransferSettlement]
	,[intTransferEntityId]
	,[strTransferComments]
	,[intBillId]
	,[strBillId]
	--FREIGHT
	,[dblFreightUnits]
	,[dblFreightRate]
	,[dblFreightSettlement]
	--CONTRACT
	,[intContractLocationId]
	,[intContractDetailId]
	,[intContractHeaderId]
	,[dtmDateCreated]
	,[intConcurrencyId]
	,[intParentAdjustSettlementId]
	,[intCreatedUserId]
)
SELECT [intAdjustSettlementId]
	,[strAdjustSettlementNumber]
	,[intTypeId]
	,[intEntityId]
	,[intCompanyLocationId]
	,[intItemId]
	,[intTicketId]
	,[strTicketNumber]
	,[intAdjustmentTypeId]
	,[intSplitId]
	,[dtmAdjustmentDate]
	,[dblAdjustmentAmount]
	,[dblWithholdAmount]
	,[dblTotalAdjustment]
	,[dblCkoffAdjustment]
	,[strRailReferenceNumber]
	,[strCustomerReference]
	,[strComments]
	,[intGLAccountId]
	,[ysnTransferSettlement]
	,[intTransferEntityId]
	,[strTransferComments]
	,[strBillId]
	,[strBillNumbers]
	--FREIGHT
	,[dblFreightUnits]
	,[dblFreightRate]
	,[dblFreightSettlement]
	--CONTRACT
	,[intContractLocationId]
	,[intContractDetailId]
	,[intContractHeaderId]
	,[dtmDateCreated]
	,[intConcurrencyId]
	,[intParentAdjustSettlementId]
	,[intCreatedUserId]
FROM vyuGRSearchAdjustSettlements
WHERE intAdjustSettlementId = @intAdjustSettlementId

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
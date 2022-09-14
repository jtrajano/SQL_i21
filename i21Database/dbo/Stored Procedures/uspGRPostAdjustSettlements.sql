CREATE PROCEDURE [dbo].[uspGRPostAdjustSettlements]
(
	@intAdjustSettlementId INT
)
AS
BEGIN
DECLARE @ErrMsg AS NVARCHAR(MAX)
DECLARE @AdjustSettlementsStagingTable AS AdjustSettlementsStagingTable
DECLARE @ysnTransferSettlement BIT
DECLARE @ysnPosted BIT
DECLARE @strAdjustSettlementNumber NVARCHAR(40)
DECLARE @intTransferAdjustSettlementId INT
DECLARE @intAdjustmentTypeId INT
DECLARE @intTypeId INT
DECLARE @intUserId INT
DECLARE @intEntityId INT
DECLARE @intContractDetailId INT
DECLARE @intBillId INT
DECLARE @BillIds NVARCHAR(MAX)
DECLARE @success AS BIT
DECLARE @intItemId INT

BEGIN TRANSACTION
BEGIN TRY


INSERT INTO @AdjustSettlementsStagingTable
SELECT *
FROM tblGRAdjustSettlements
WHERE intAdjustSettlementId = @intAdjustSettlementId
	
SELECT @ysnTransferSettlement = ysnTransferSettlement
	,@ysnPosted = ysnPosted
	,@intAdjustmentTypeId = intAdjustmentTypeId
	,@intTypeId = intTypeId
	,@intUserId = intCreatedUserId
	,@intEntityId = intEntityId
	,@intContractDetailId = intContractDetailId
	,@intItemId = intItemId
FROM @AdjustSettlementsStagingTable

SELECT @intTransferAdjustSettlementId = CASE WHEN ISNULL(intAdjustSettlementId,0) = 0 THEN 0 ELSE 1 END
FROM tblGRAdjustSettlements
WHERE intParentAdjustSettlementId = @intAdjustSettlementId

IF @ysnTransferSettlement = 1
BEGIN
	EXEC uspSMGetStartingNumber 177, @strAdjustSettlementNumber OUT

	INSERT INTO tblGRAdjustSettlements
	(
		[strAdjustSettlementNumber]
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
		,[ysnPosted]
		--FREIGHT
		,[dblFreightUnits]
		,[dblFreightRate]
		,[dblFreightSettlement]
		--CONTRACT
		,[intContractLocationId]
		,[intContractDetailId]
		,[dtmDateCreated]
		,[intConcurrencyId]
		,[intParentAdjustSettlementId]
		,[intCreatedUserId]
	)
	SELECT 
		[strAdjustSettlementNumber]	= @strAdjustSettlementNumber
		,[intTypeId]
		,[intEntityId] = intTransferEntityId
		,[intCompanyLocationId]
		,[intItemId]
		,[intTicketId]
		,[strTicketNumber]
		,[intAdjustmentTypeId]
		,[intSplitId]
		,[dtmAdjustmentDate]
		,[dblAdjustmentAmount] = dblAdjustmentAmount * -1
		,[dblWithholdAmount] = dblWithholdAmount * -1
		,[dblTotalAdjustment] = dblTotalAdjustment * -1
		,[dblCkoffAdjustment] = dblCkoffAdjustment * -1
		,[strRailReferenceNumber]
		,[strCustomerReference]
		,[strComments] = strTransferComments
		,[intGLAccountId]
		,[ysnTransferSettlement] = 0
		,[intTransferEntityId] = NULL
		,[strTransferComments] = NULL
		,[ysnPosted]
		--FREIGHT
		,[dblFreightUnits]
		,[dblFreightRate]
		,[dblFreightSettlement]
		--CONTRACT
		,[intContractLocationId]
		,[intContractDetailId]
		,[dtmDateCreated] = GETDATE()
		,[intConcurrencyId] = 1
		,[intParentAdjustSettlementId] = @intAdjustSettlementId
		,[intCreatedUserId]
	FROM @AdjustSettlementsStagingTable
END
ELSE
BEGIN
	IF (@intAdjustmentTypeId = 3 AND ISNULL(@intTransferAdjustSettlementId,0) > 0)
	BEGIN
		UPDATE A
		SET intEntityId = B.intEntityId
			,dblAdjustmentAmount = B.dblAdjustmentAmount
			,dblWithholdAmount = B.dblWithholdAmount
			,dblTotalAdjustment = B.dblTotalAdjustment
			,dblCkoffAdjustment = B.dblCkoffAdjustment
			,strComments = B.strComments
			,intParentAdjustSettlementId = @intAdjustSettlementId
		FROM tblGRAdjustSettlements A
		OUTER APPLY (
		SELECT [intEntityId] = intTransferEntityId
			,[dblAdjustmentAmount] = dblAdjustmentAmount * -1
			,[dblWithholdAmount] = dblWithholdAmount * -1
			,[dblTotalAdjustment] = dblTotalAdjustment * -1
			,[dblCkoffAdjustment] = dblCkoffAdjustment * -1
			,[strComments] = strTransferComments
		FROM @AdjustSettlementsStagingTable
		) B
		WHERE A.intParentAdjustSettlementId = @intAdjustSettlementId
	END	
END

IF @intTypeId = 1 --PURCHASE
/*************CREATE VOUCHER/VENDOR PREPAY/DEBIT MEMO****************/
BEGIN
	EXEC [dbo].[uspGRAdjustSettlementsForPurchase]
		@intUserId = @intUserId
		,@intItemId = @intItemId
		,@intContractDetailId = @intContractDetailId
		,@intAdjustmentTypeId = @intAdjustmentTypeId
		,@AdjustSettlementsStagingTable = @AdjustSettlementsStagingTable
		,@intBillId = @intBillId OUTPUT
		,@BillIds = @BillIds OUTPUT

	UPDATE tblGRAdjustSettlements SET intBillId = @intBillId WHERE intAdjustSettlementId = @intAdjustSettlementId

	DECLARE @param NVARCHAR(MAX)
	SET @param = CASE WHEN @intBillId IS NULL THEN @BillIds ELSE CAST(@intBillId AS NVARCHAR) END

	EXEC [dbo].[uspAPPostBill] 
		@post = 1
		,@recap = 0
		,@isBatch = 0
		,@param = @param
		,@userId = @intUserId
		,@transactionType = NULL
		,@success = @success OUTPUT

	UPDATE tblGRAdjustSettlements SET ysnPosted = 1 WHERE intAdjustSettlementId = @intAdjustSettlementId

	IF @ysnTransferSettlement = 1
	BEGIN
		SELECT @intTransferAdjustSettlementId = intAdjustSettlementId FROM tblGRAdjustSettlements WHERE intParentAdjustSettlementId = @intAdjustSettlementId
		--CALL THIS SP AGAIN
		EXEC [dbo].[uspGRPostAdjustSettlements] @intTransferAdjustSettlementId		
	END
END
ELSE --SALES
BEGIN
	DECLARE @strBillId NVARCHAR(40)
	EXEC [dbo].[uspGRAdjustSettlementsForSales]
		@intUserId = @intUserId
		,@intItemId = @intItemId
		,@AdjustSettlementsStagingTable = @AdjustSettlementsStagingTable
		,@intInvoiceId = @intBillId OUTPUT
		,@InvoiceIds = @BillIds OUTPUT

	UPDATE tblGRAdjustSettlements SET intBillId = @intBillId WHERE intAdjustSettlementId = @intAdjustSettlementId
	
	IF ISNULL(@intBillId,0) > 0 OR @BillIds IS NOT NULL
	BEGIN
		SET @strBillId = CASE WHEN @intBillId IS NOT NULL THEN CAST(@intBillId AS NVARCHAR(40)) ELSE @BillIds END
		EXEC dbo.uspARPostInvoice @param = @strBillId, @post = 1, @recap = 0, @userId = @intUserId, @raiseError = 1		
	END

	UPDATE tblGRAdjustSettlements SET ysnPosted = 1 WHERE intAdjustSettlementId = @intAdjustSettlementId

	IF @ysnTransferSettlement = 1
	BEGIN
		SELECT @intTransferAdjustSettlementId = intAdjustSettlementId FROM tblGRAdjustSettlements WHERE intParentAdjustSettlementId = @intAdjustSettlementId
		--CALL THIS SP AGAIN
		EXEC [dbo].[uspGRPostAdjustSettlements] @intTransferAdjustSettlementId		
	END
END



Post_Transaction:
COMMIT TRANSACTION

END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
SET @ErrMsg = ERROR_MESSAGE()
RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

END
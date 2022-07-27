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

BEGIN TRANSACTION
BEGIN TRY


INSERT INTO @AdjustSettlementsStagingTable
SELECT *
FROM tblGRAdjustSettlements
WHERE intAdjustSettlementId = @intAdjustSettlementId
	
SELECT @ysnTransferSettlement = ysnTransferSettlement
	,@ysnPosted = ysnPosted
	,@intAdjustmentTypeId = intAdjustmentTypeId
FROM @AdjustSettlementsStagingTable

SELECT @intTransferAdjustSettlementId = CASE WHEN ISNULL(intAdjustSettlementId,0) = 0 THEN 0 ELSE 1 END
FROM tblGRAdjustSettlements
WHERE intParentAdjustSettlementId = @intAdjustSettlementId

IF(@ysnTransferSettlement = 1 AND ISNULL(@intTransferAdjustSettlementId,0) = 0)
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
	--UNPOST TRANSACTION FIRST THEN UPDATE THE DETAILS
	EXEC uspGRUnpostAdjustSettlements @intAdjustSettlementId
	
	IF(@intAdjustmentTypeId <> 3 AND ISNULL(@intTransferAdjustSettlementId,0) > 0)
	BEGIN
		INSERT INTO tblGRDeletedAdjustSettlements
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
			,[dtmDateDeleted]
		)
		SELECT 
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
			,[dtmDateDeleted] = GETDATE()
		FROM tblGRAdjustSettlements
		WHERE intParentAdjustSettlementId = @intAdjustSettlementId

		DELETE FROM tblGRAdjustSettlements WHERE intParentAdjustSettlementId = @intAdjustSettlementId
	END
	ELSE IF (@intAdjustmentTypeId = 3 AND ISNULL(@intTransferAdjustSettlementId,0) > 0)
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
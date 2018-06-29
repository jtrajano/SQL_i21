CREATE PROCEDURE [dbo].[uspCTInventoryReceiptDelete]

	@intTransactionId	INT,
	@intUserId			INT

AS
	DECLARE @intOrderType				INT,
			@intSourceType				INT,
			@intSourceNumberId			INT,
			@intTransactionDetailLogId	INT,
			@intContractDetailId		INT,
			@dblQuantityToUpdate		NUMERIC(18,6),
			@intSourceItemUOMId			INT

	SELECT	@intOrderType	= intOrderType, 
			@intSourceType	= intSourceType 
	FROM	tblICTransactionDetailLog 
	WHERE	intTransactionId = @intTransactionId

	SELECT @intTransactionDetailLogId = MIN(intTransactionDetailLogId) FROM tblICTransactionDetailLog WHERE intTransactionId = @intTransactionId

	WHILE ISNULL(@intTransactionDetailLogId,0) > 0
	BEGIN
		SELECT @intSourceNumberId = intSourceNumberId FROM tblICTransactionDetailLog WHERE intTransactionDetailLogId = @intTransactionDetailLogId
		
		IF	@intOrderType = 1 AND @intSourceType = 1
		BEGIN
				SELECT @intContractDetailId = intContractId,@dblQuantityToUpdate = dblNetUnits,@intSourceItemUOMId = intItemUOMIdTo FROM tblSCTicket WHERE intTicketId = @intSourceNumberId
				EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId, @dblQuantityToUpdate, @intUserId, @intSourceNumberId, 'Scale', @intSourceItemUOMId
		END

		SELECT @intTransactionDetailLogId = MIN(intTransactionDetailLogId) FROM tblICTransactionDetailLog WHERE intTransactionId = @intTransactionId AND intTransactionDetailLogId > @intTransactionDetailLogId
	END
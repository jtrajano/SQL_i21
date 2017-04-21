CREATE PROCEDURE uspLGUpdateContractShippingInstructionQty 
	 @intContractDetailId INT
	,@dblQuantityToUpdate NUMERIC(18, 6)
	,@intUserId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@dblShippingInstructionQty NUMERIC(18, 6)
		,@dblNewShippingInstructionQty NUMERIC(18, 6)
		,@dblQuantityToIncrease NUMERIC(18, 6)

	IF NOT EXISTS (SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR ('Sequence is deleted by other user.',16,1)
	END

	SELECT @dblShippingInstructionQty = ISNULL(dblShippingInstructionQty, 0)
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intContractDetailId

	SELECT @dblNewShippingInstructionQty = @dblShippingInstructionQty + @dblQuantityToUpdate

	UPDATE tblCTContractDetail
	SET dblShippingInstructionQty = @dblNewShippingInstructionQty
		,intConcurrencyId = intConcurrencyId + 1
	WHERE intContractDetailId = @intContractDetailId
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
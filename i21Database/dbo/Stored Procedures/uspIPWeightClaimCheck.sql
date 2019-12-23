Create PROCEDURE uspIPWeightClaimCheck
AS
BEGIN
	DECLARE @intInventoryReceiptId INT
		,@intLoadDetailId INT
		,@intLoadId INT
		,@intNewWeightClaimId int

	SELECT @intInventoryReceiptId = Max(intInventoryReceiptId)
	FROM tblIPInventoryReceiptWeightClaim

	IF @intInventoryReceiptId IS NULL
		SELECT @intInventoryReceiptId = 0

	DECLARE @tblIPInventoryReceipt TABLE (intInventoryReceiptId INT)

	INSERT INTO @tblIPInventoryReceipt (intInventoryReceiptId)
	SELECT intInventoryReceiptId
	FROM tblICInventoryReceipt
	WHERE intInventoryReceiptId > @intInventoryReceiptId

	SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
	FROM @tblIPInventoryReceipt

	WHILE @intInventoryReceiptId IS NOT NULL
	BEGIN
		SELECT @intLoadDetailId = NULL

		SELECT @intLoadId = NULL

		SELECT @intLoadDetailId = intSourceId
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		SELECT @intLoadId = intLoadId
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		IF EXISTS (
				SELECT *
				FROM vyuIPGetOpenWeightClaim
				WHERE intLoadId = @intLoadId
					AND intContainerCount = intIRCount
					AND IsNULL(dblClaimableWt, 0) < 0
				)
		BEGIN
			--INSERT INTO tblLGWeightClaimStage (intLoadId)
			--SELECT @intLoadId

			EXEC dbo.uspIPCreateWeightClaims @intLoadId = @intLoadId,@intNewWeightClaimId=@intNewWeightClaimId output
			
			EXEC [dbo].[uspIPWeightClaimPopulateStgXML] @intWeightClaimId =@intNewWeightClaimId,@strRowState ='Added'
		END

		INSERT INTO tblIPInventoryReceiptWeightClaim (intInventoryReceiptId)
		SELECT @intInventoryReceiptId

		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
		FROM @tblIPInventoryReceipt
		WHERE intInventoryReceiptId > @intInventoryReceiptId
	END
END

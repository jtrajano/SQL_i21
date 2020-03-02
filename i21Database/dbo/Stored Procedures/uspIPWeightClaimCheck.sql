CREATE PROCEDURE uspIPWeightClaimCheck
AS
BEGIN
	DECLARE @intInventoryReceiptId INT
		,@intLoadDetailId INT
		,@intLoadId INT
		,@intNewWeightClaimId INT
	DECLARE @tblIPInventoryReceipt TABLE (intInventoryReceiptId INT)

	INSERT INTO @tblIPInventoryReceipt (intInventoryReceiptId)
	SELECT intInventoryReceiptId
	FROM tblICInventoryReceipt IR
	WHERE ysnPosted = 1
		AND NOT EXISTS (
			SELECT *
			FROM tblIPInventoryReceiptWeightClaim IRWC
			WHERE IRWC.intInventoryReceiptId = IR.intInventoryReceiptId
			)

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
			EXEC dbo.uspIPCreateWeightClaims @intLoadId = @intLoadId
				,@intNewWeightClaimId = @intNewWeightClaimId OUTPUT

			EXEC [dbo].[uspIPWeightClaimPopulateStgXML] @intWeightClaimId = @intNewWeightClaimId
				,@strRowState = 'Added'
		END

		INSERT INTO tblIPInventoryReceiptWeightClaim (intInventoryReceiptId,intLoadId)
		SELECT @intInventoryReceiptId,@intLoadId

		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
		FROM @tblIPInventoryReceipt
		WHERE intInventoryReceiptId > @intInventoryReceiptId
	END
END

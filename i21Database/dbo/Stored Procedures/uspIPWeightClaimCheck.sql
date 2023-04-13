CREATE PROCEDURE uspIPWeightClaimCheck
AS
BEGIN
	IF EXISTS (
			SELECT *
			FROM dbo.tblIPInventoryReceiptWeightClaim
			WHERE IsNULL(ysnInProgress, 0) = 1
			)
	BEGIN
		RETURN
	END

	DECLARE @intInventoryReceiptId INT
		,@intLoadDetailId INT
		,@intLoadId INT
		,@intNewWeightClaimId INT
	DECLARE @tblIPInventoryReceipt TABLE (intInventoryReceiptId INT)

	DELETE
	FROM @tblIPInventoryReceipt

	INSERT INTO @tblIPInventoryReceipt (intInventoryReceiptId)
	SELECT intInventoryReceiptId
	FROM dbo.tblICInventoryReceipt IR
	WHERE ysnPosted = 1
		AND NOT EXISTS (
			SELECT *
			FROM dbo.tblIPInventoryReceiptWeightClaim IRWC
			WHERE IRWC.intInventoryReceiptId = IR.intInventoryReceiptId
			)

	INSERT INTO dbo.tblIPInventoryReceiptWeightClaim (
		intInventoryReceiptId
		,ysnInProgress
		)
	SELECT intInventoryReceiptId
		,1
	FROM @tblIPInventoryReceipt

	SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
	FROM @tblIPInventoryReceipt

	WHILE @intInventoryReceiptId IS NOT NULL
	BEGIN
		SELECT @intLoadDetailId = NULL

		SELECT @intLoadId = NULL

		SELECT @intNewWeightClaimId = NULL

		SELECT @intLoadDetailId = intSourceId
		FROM dbo.tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		SELECT @intLoadId = intLoadId
		FROM dbo.tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		IF EXISTS (
				/*SELECT *
				FROM dbo.vyuIPGetOpenWeightClaim
				WHERE intLoadId = @intLoadId
					AND intContainerCount = intIRCount
					AND IsNULL(dblClaimableWt, 0) + IsNULL(dblFranchiseWt, 0) < 0*/
				SELECT *
				FROM tblLGPendingClaim
				WHERE intLoadId = @intLoadId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblLGWeightClaim
				WHERE intLoadId = @intLoadId
				)
			AND NOT EXISTS (
				SELECT 1
				FROM tblLGLoadContainer LC
				JOIN tblLGLoadDetailContainerLink LCL ON LCL.intLoadContainerId = LC.intLoadContainerId
				WHERE LC.intLoadId = @intLoadId
					AND IsNULL(LCL.dblReceivedQty,0)=0
				)
		BEGIN
			EXEC dbo.uspIPCreateWeightClaims @intLoadId = @intLoadId
				,@intNewWeightClaimId = @intNewWeightClaimId OUTPUT
		END

		UPDATE dbo.tblIPInventoryReceiptWeightClaim
		SET intWeightClaimId = @intNewWeightClaimId
			,intLoadId = @intLoadId
			,ysnInProgress = 0
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		SELECT @intInventoryReceiptId = MIN(intInventoryReceiptId)
		FROM @tblIPInventoryReceipt
		WHERE intInventoryReceiptId > @intInventoryReceiptId
	END
END

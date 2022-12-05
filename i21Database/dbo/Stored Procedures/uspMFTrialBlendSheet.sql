CREATE PROCEDURE [dbo].[uspMFTrialBlendSheet] (
	@intWorkOrderId INT
	,@intWorkOrderInputLotId INT
	,@ysnKeep NVARCHAR(10) = NULL
	,@type NVARCHAR(50) = NULL
	,@UserId INT = NULL
	,@dblTBSQuantity NUMERIC(18, 6) = NULL
	)
AS
BEGIN
	IF @type = 'Confirm'
	BEGIN
		IF EXISTS (
				SELECT *
				FROM tblMFWorkOrderInputLot
				WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId
					AND IsNULL(ysnTBSReserved, 0) = 0
				)
		BEGIN
			EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId
				,@intWorkOrderInputLotId
		END

		UPDATE tblMFWorkOrderInputLot
		SET ysnKeep = CASE 
				WHEN @ysnKeep = 'true'
					THEN 1
				ELSE 0
				END
			,dblTBSQuantity = @dblTBSQuantity
			,ysnTBSReserved = 1
		WHERE intWorkOrderId = @intWorkOrderId
			AND intWorkOrderInputLotId = @intWorkOrderInputLotId

		UPDATE tblMFWorkOrder
		SET intTrialBlendSheetStatusId = 15
			,intConfirmedBy = @UserId
			,dtmConfirmedDate = GETDATE()
		WHERE intWorkOrderId = @intWorkOrderId
	END

	IF @type = 'Delete'
	BEGIN
		UPDATE tblMFWorkOrderInputLot
		SET ysnKeep = 0
			,ysnTBSReserved = 0
		WHERE intWorkOrderInputLotId = @intWorkOrderInputLotId

		EXEC [dbo].[uspMFDeleteTrialBlendSheetReservation] @intWorkOrderId
			,@intWorkOrderInputLotId
	END

	IF @type = 'Approve'
	BEGIN
		UPDATE tblMFWorkOrder
		SET intTrialBlendSheetStatusId = 17
			,intApprovedBy = @UserId
			,dtmApprovedDate = GETDATE()
		WHERE intWorkOrderId = @intWorkOrderId
	END
END

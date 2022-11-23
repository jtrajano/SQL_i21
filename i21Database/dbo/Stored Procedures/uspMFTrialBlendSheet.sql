CREATE PROCEDURE [dbo].[uspMFTrialBlendSheet] 
(
	@intWorkOrderId INT,
	@intWorkOrderInputLotId INT,
	@ysnKeep nvarchar(10) = NULL,
	@type nvarchar(50) = NULL,
	@UserId int = NULL	
)
AS
BEGIN

	IF @type = 'Confirm' 
	BEGIN

	IF ISNULL(@ysnKeep, '') <> ''
		BEGIN

		UPDATE tblMFWorkOrderInputLot SET ysnKeep = CASE WHEN @ysnKeep = 'true'  THEN 1 ELSE 0 END
		WHERE intWorkOrderId = @intWorkOrderId 
		AND intWorkOrderInputLotId = @intWorkOrderInputLotId  
			
		END
	
		UPDATE tblMFWorkOrder 
		SET  
		intTrialBlendSheetStatusId  = 15,
		intConfirmedBy = @UserId,
		dtmConfirmedDate = GETDATE()
		WHERE intWorkOrderId = @intWorkOrderId 
		EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId

	END


	IF @type = 'Delete' 
	BEGIN

		DELETE FROM  tblMFWorkOrderInputLot
		WHERE intWorkOrderId = @intWorkOrderId 
		AND intWorkOrderInputLotId = @intWorkOrderInputLotId 
		AND ysnKeep = 0

		EXEC [dbo].[uspMFDeleteTrialBlendSheetReservation] @intWorkOrderId

	END

	IF @type = 'Approve' 
	BEGIN

		UPDATE tblMFWorkOrder 
		SET  
		intTrialBlendSheetStatusId  = 17,
		intApprovedBy = @UserId,
		dtmApprovedDate = GETDATE()
		WHERE intWorkOrderId = @intWorkOrderId 
		EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId

	END

END


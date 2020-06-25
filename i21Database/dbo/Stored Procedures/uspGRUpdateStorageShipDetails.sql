CREATE PROCEDURE [dbo].[uspGRUpdateStorageShipDetails]
	@intDeliverySheetId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intShipFromEntityId INT
		,@intShipFromLocationId INT

	SELECT 
		@intShipFromEntityId = intEntityId
		,@intShipFromLocationId = intFarmFieldId
	FROM tblSCDeliverySheet 
	WHERE intDeliverySheetId = @intDeliverySheetId

	IF @intShipFromEntityId IS NOT NULL
	BEGIN
		UPDATE tblGRCustomerStorage
		SET intShipFromEntityId = @intShipFromEntityId
			,intShipFromLocationId = @intShipFromLocationId
		WHERE intDeliverySheetId = @intDeliverySheetId
	END
	ELSE
	BEGIN
		RAISERROR('Please select an entity.',16,1)
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
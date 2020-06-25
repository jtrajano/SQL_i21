CREATE PROCEDURE [dbo].[uspGRUpdateStorageShipDetails]
	@intDeliverySheetId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intShipFromEntityId INT
		,@intShipFromLocationId INT

	SELECT 
		@intShipFromEntityId = SCD.intEntityId
		,@intShipFromLocationId = COALESCE(SCD.intFarmFieldId, VND.intShipFromId, VNDL.intEntityLocationId)
	FROM tblSCDeliverySheetSplit SDS
	INNER JOIN tblSCDeliverySheet SCD ON SCD.intDeliverySheetId = SDS.intDeliverySheetId
	LEFT JOIN tblEMEntityLocation FRM
		ON SCD.intFarmFieldId = FRM.intEntityLocationId
	LEFT JOIN tblAPVendor VND
		ON SCD.intEntityId = VND.intEntityId
	LEFT JOIN tblEMEntityLocation VNDL
		ON VND.intEntityId = VNDL.intEntityId
			AND VNDL.ysnDefaultLocation = 1
	WHERE SDS.intDeliverySheetId = @intDeliverySheetId

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
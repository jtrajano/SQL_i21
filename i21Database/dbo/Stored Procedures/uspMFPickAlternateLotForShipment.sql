CREATE PROCEDURE uspMFPickAlternateLotForShipment
	 @intLotId INT
	,@strAlternateLotNo NVARCHAR(50)
	,@strLotSourceLocation NVARCHAR(50)
	,@strShipmentNo NVARCHAR(100)
AS
BEGIN TRY
	DECLARE @strOrderLotNo NVARCHAR(50)
	DECLARE @intAlternateLotId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intPickListId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @dblAlternateLotQty NUMERIC(38, 20)
	DECLARE @dblReservedLotQtyForPickList NUMERIC(38, 20)
	DECLARE @dblAlternateLotReservedQty NUMERIC(38, 20)
	DECLARE @dblAlternateLotAvailableQty NUMERIC(38, 20)
	DECLARE @intTransactionCount INT
	DECLARE @strBlendProductionStagingLocation NVARCHAR(100)
	DECLARE @strKitStagingArea NVARCHAR(100)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intLotStatusId INT
	DECLARE @intTaskId INT

	SELECT @intStorageLocationId = intStorageLocationId
	FROM tblICStorageLocation
	WHERE strName = @strLotSourceLocation

	SELECT @intAlternateLotId = intLotId
		  ,@dblAlternateLotQty = Case When intWeightUOMId is not null then dblWeight else dblQty End
	FROM tblICLot
	WHERE strLotNumber = @strAlternateLotNo
		AND intStorageLocationId = @intStorageLocationId

	SELECT @strBlendProductionStagingLocation = sl.strName
	FROM tblSMCompanyLocation cl
	JOIN tblICStorageLocation sl ON cl.intBlendProductionStagingUnitId = sl.intStorageLocationId
	WHERE intCompanyLocationId = 1

	SELECT @strKitStagingArea = sl.strName
	FROM tblMFAttribute a
	JOIN tblMFManufacturingProcessAttribute mpa ON mpa.intAttributeId = a.intAttributeId
	JOIN tblICStorageLocation sl ON sl.intStorageLocationId = mpa.strAttributeValue
	WHERE a.strAttributeName = 'Kit Staging Location'
		AND intManufacturingProcessId = 1
	
	IF (@intLotId <> @intAlternateLotId)
	BEGIN
		SELECT @intTaskId = intTaskId FROM tblMFTask T
		JOIN tblMFOrderHeader O ON O.intOrderHeaderId = T.intOrderHeaderId
		WHERE intLotId = @intLotId
	END

	BEGIN TRANSACTION

		IF EXISTS (SELECT 1 FROM tblMFTask WHERE intLotId = @intLotId AND intTaskId = @intTaskId)
		BEGIN
				UPDATE tblMFTask
				SET intLotId = @intAlternateLotId,
					intFromStorageLocationId = @intStorageLocationId
				WHERE intLotId = @intLotId
					AND intTaskId = @intTaskId
		END

	COMMIT TRANSACTION

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @intTransactionCount = 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')

END CATCH
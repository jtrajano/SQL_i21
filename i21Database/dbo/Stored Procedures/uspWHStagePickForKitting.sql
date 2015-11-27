CREATE PROCEDURE uspWHStagePickForKitting 
				@intPickListDetailId INT, 
				@intPickedLotId INT, 
				@dblPickedQty NUMERIC(18, 6), 
				@intUserId INT, 
				@intLocationId INT
AS
BEGIN TRY
	DECLARE @strPickListNo NVARCHAR(100)
	DECLARE @intPickListId INT
	DECLARE @intPickListLotId INT
	DECLARE @dblPickListQty NUMERIC(18, 6)
	DECLARE @intKitStagingLocationId INT
	DECLARE @intManufacturingProcessId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @TransactionCount INT
	DECLARE @intItemId INT
	DECLARE @strLotNumber NVARCHAR(100)
	DECLARE @intNewLotId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	

	SELECT @intPickListId = pl.intPickListId, @strPickListNo = pl.strPickListNo, @intPickListLotId = pld.intStageLotId, @dblPickListQty = pld.dblPickQuantity, @intPickListDetailId = pld.intPickListDetailId
	FROM tblMFPickList pl
	JOIN tblMFPickListDetail pld ON pl.intPickListId = pld.intPickListId
	WHERE intPickListDetailId = @intPickListDetailId

	BEGIN TRANSACTION

	INSERT INTO tblWHPickForKitting (intPickListId, strPickListNo, intPickListDetailId, intPickListLotId, intPickedLotId, dblPickListQty, dblPickedQty, intUserId)
	VALUES (@intPickListId, @strPickListNo, @intPickListDetailId, @intPickListLotId, @intPickedLotId, @dblPickListQty, @dblPickedQty, @intUserId)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFManufacturingProcess
	WHERE intAttributeTypeId = 2

	SELECT @intKitStagingLocationId = pa.strAttributeValue
	FROM tblMFManufacturingProcessAttribute pa
	JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND at.strAttributeName = 'Kit Staging Location'

	SELECT @intStorageLocationId = intStorageLocationId, 
		   @intSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intKitStagingLocationId
	
	SELECT @strLotNumber = strLotNumber,
		   @intItemId = intItemId
	FROM tblICLot 
	WHERE intLotId = @intPickedLotId
	
	--SELECT @intPickedLotId intPickedLotId, @intSubLocationId intSubLocationId, @intStorageLocationId intStorageLocationId, @dblPickedQty dblPickedQty, @intUserId intUserId

	
	EXEC uspMFLotMove @intLotId = @intPickedLotId, 
					  @intNewSubLocationId = @intSubLocationId,
					  @intNewStorageLocationId = @intStorageLocationId, 
					  @dblMoveQty = @dblPickedQty, 
					  @intUserId = @intUserId
					  
	SELECT TOP 1 @intNewLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intItemId = @intItemId
		AND intStorageLocationId = @intKitStagingLocationId
		
	UPDATE tblMFPickListDetail
	SET intStageLotId = @intNewLotId
	WHERE intPickListDetailId = @intPickListDetailId

	IF NOT EXISTS(SELECT *
				  FROM tblMFPickListDetail
				  WHERE intPickListDetailId NOT IN (
						SELECT intPickListDetailId
						FROM tblWHPickForKitting
						WHERE strPickListNo = @strPickListNo
						)
				  AND intPickListId = @intPickListId)
				  BEGIN
					UPDATE tblMFPickList SET intKitStatusId = 12 WHERE intPickListId = @intPickListId
					UPDATE tblMFWorkOrder SET intKitStatusId = 12 WHERE intPickListId = @intPickListId
				  END
	
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @TransactionCount = 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
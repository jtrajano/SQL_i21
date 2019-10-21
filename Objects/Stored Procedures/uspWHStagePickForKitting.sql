CREATE PROCEDURE uspWHStagePickForKitting 
				@intPickListDetailId INT, 
				@intPickedLotId INT, 
				@dblPickedQty NUMERIC(38,20), 
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
	DECLARE @intLotStorageLocationId INT

	DECLARE @dblQtyToProduce NUMERIC(18,6)
	DECLARE @intBlendItemId INT
	DECLARE @dblTotalRequiredQtyToStage NUMERIC(18,6)
	DECLARE @dblTotalPickedQty NUMERIC(18,6)	
	DECLARE @intItemUOMId INT
	DECLARE @intItemIssuedUOMId INT
	DECLARE @dblPickedLotWeightPerUnit NUMERIC(38,20)
			,@intPickUOMId int
	DECLARE @strBulkItemXml nvarchar(max)

	SELECT @intPickListId = pl.intPickListId, @strPickListNo = pl.strPickListNo, @intPickListLotId = pld.intStageLotId, @dblPickListQty = pld.dblPickQuantity, @intPickListDetailId = pld.intPickListDetailId
	FROM tblMFPickList pl
	JOIN tblMFPickListDetail pld ON pl.intPickListId = pld.intPickListId
	WHERE intPickListDetailId = @intPickListDetailId

	BEGIN TRANSACTION

	SELECT @intItemUOMId = intItemUOMId
		  ,@intItemIssuedUOMId = intItemIssuedUOMId
		  ,@intPickUOMId=intPickUOMId
	FROM tblMFPickListDetail
	WHERE intPickListDetailId = @intPickListDetailId

	SELECT @dblPickedLotWeightPerUnit = CASE 
			WHEN ISNULL(dblWeightPerQty, 0) = 0
				THEN 1
			ELSE dblWeightPerQty
			END
	FROM tblICLot
	WHERE intLotId = @intPickedLotId

	--IF @intItemUOMId = @intItemIssuedUOMId
	--BEGIN
	--	SET @dblPickedQty = dbo.fnDivide(@dblPickedQty,@dblPickedLotWeightPerUnit)
	--END

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
		   @intItemId = intItemId,
		   @intLotStorageLocationId = intStorageLocationId
	FROM tblICLot 
	WHERE intLotId = @intPickedLotId

	SET @strBulkItemXml='<root>'

--Bulk Item
	SELECT @strBulkItemXml=COALESCE(@strBulkItemXml, '') + '<lot>' + 
						'<intItemId>' + convert(varchar,sr.intItemId) + '</intItemId>' +
						'<intItemUOMId>' + convert(varchar,sr.intItemUOMId) + '</intItemUOMId>' + 
						'<dblQuantity>' + convert(varchar,sr.dblQty) + '</dblQuantity>' + '</lot>'
	FROM tblICStockReservation sr Join tblICItem i on sr.intItemId=i.intItemId
	WHERE sr.intTransactionId=@intPickListId AND sr.intInventoryTransactionType=34 AND ISNULL(sr.intLotId,0)=0 AND i.strLotTracking <> 'No'

	SET @strBulkItemXml=@strBulkItemXml+'</root>'

	IF LTRIM(RTRIM(@strBulkItemXml))='<root></root>' 
		SET @strBulkItemXml=''

	EXEC [uspMFDeleteLotReservationByPickList] @intPickListId

	--SELECT @intPickedLotId intPickedLotId, @intSubLocationId intSubLocationId, @intStorageLocationId intStorageLocationId, @dblPickedQty dblPickedQty, @intUserId intUserId

	IF @intLotStorageLocationId <> @intStorageLocationId
	BEGIN
		EXEC uspWHLotMove @intLotId = @intPickedLotId, 
						  @intNewSubLocationId = @intSubLocationId,
						  @intNewStorageLocationId = @intStorageLocationId, 
						  @dblMoveQty = @dblPickedQty, 
						  @intUserId = @intUserId
						  ,@intItemUOMId=@intPickUOMId
	END
					  
	SELECT TOP 1 @intNewLotId = intLotId
	FROM tblICLot
	WHERE strLotNumber = @strLotNumber
		AND intItemId = @intItemId
		AND intStorageLocationId = @intKitStagingLocationId
		
	UPDATE tblMFPickListDetail
	SET intStageLotId = @intNewLotId
	WHERE intPickListDetailId = @intPickListDetailId

	SELECT @dblQtyToProduce = SUM(dblQuantity), 
		   @intBlendItemId = MAX(intItemId), 
		   @intLocationId = MAX(intLocationId)  
	FROM tblMFWorkOrder 
	WHERE intPickListId = @intPickListId
	
	SELECT @dblTotalPickedQty = SUM(dblQuantity) 
	FROM tblMFPickListDetail 
	WHERE intPickListId = @intPickListId

	SELECT @dblTotalRequiredQtyToStage = SUM((ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)))
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE ri.intRecipeItemTypeId = 1
		AND r.intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1
		AND ri.intConsumptionMethodId = 1

	--UPDATE tblICStockReservation
	--SET intLotId = @intNewLotId,
	--	intStorageLocationId = @intKitStagingLocationId
	--WHERE intLotId = @intPickedLotId
	--	AND strTransactionId = @strPickListNo

	IF NOT EXISTS(SELECT *
				  FROM tblMFPickListDetail
				  WHERE intPickListDetailId NOT IN (
						SELECT intPickListDetailId
						FROM tblWHPickForKitting
						WHERE strPickListNo = @strPickListNo
						)
				  AND intPickListId = @intPickListId)
					BEGIN
				  		IF ROUND(@dblTotalPickedQty,0) > = ROUND(@dblTotalRequiredQtyToStage,0)
						BEGIN
							UPDATE tblMFPickList SET intKitStatusId = 12 WHERE intPickListId = @intPickListId
							UPDATE tblMFWorkOrder SET intKitStatusId = 12 WHERE intPickListId = @intPickListId
						END
					END
	
	EXEC [uspMFCreateLotReservationByPickList] @intPickListId,@strBulkItemXml
	
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
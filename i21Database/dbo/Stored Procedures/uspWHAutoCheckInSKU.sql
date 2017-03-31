CREATE PROCEDURE [dbo].[uspWHAutoCheckInSKU]
			@intOrderHeaderId INT,
			@strUnitName NVARCHAR(100),
			@strUserName NVARCHAR(100),
			@intAddressId INT = NULL
			
AS
BEGIN TRY

	DECLARE @intItemId INT
	DECLARE @intItemUOMId INT
	DECLARE @dblOrderedQty NUMERIC(18,6)
	DECLARE @dblLotQty NUMERIC(18,6)
	DECLARE @intUnitsPerPallet INT
	DECLARE @intOrderLineItemId INT
	DECLARE @intItemRecordId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intUserId INT
	DECLARE @intStorageLocationId INT
	DECLARE @strBOLNo NVARCHAR(100)
	DECLARE @STARTING_NUMBER_BATCH AS INT = 24
	DECLARE @strLotNumber NVARCHAR(50) 
	DECLARE @strLotAlias NVARCHAR(100)
	DECLARE @strItemType NVARCHAR(100)
	DECLARE @dblWeightPerQty NUMERIC(18,6)
	DECLARE @dblLotWeight NUMERIC(18,6)
	DECLARE @intLotId INT
	DECLARE @intWeightPerUnitUOMId INT
	DECLARE @intPhysicalCountUOMId INT
	DECLARE @intLotQtyUOMId INT
		
	DECLARE @tblLineItem TABLE 
			(intItemRecordId INT Identity(1, 1), 
			 intOrderHeaderId INT, 
			 intItemId INT, 
			 dblOrderedQty NUMERIC(18, 6), 
			 dblLotQty NUMERIC(18, 6), 
			 intUnitsPerPallet INT,
			 intOrderLineItemId INT)

BEGIN TRANSACTION
	INSERT INTO @tblLineItem (
		intOrderHeaderId,
		intItemId,
		dblOrderedQty,
		dblLotQty,
		intUnitsPerPallet,
		intOrderLineItemId
		)
	SELECT li.intOrderHeaderId,
		   li.intItemId, 
		   li.dblQty AS dblQty, 
		   li.dblQty AS dblLotQty, 
		   ISNULL((m.intUnitPerLayer * m.intLayerPerPallet), 1) intUnitsPerPallet, 
		   li.intOrderLineItemId
	FROM tblWHOrderLineItem li
	INNER JOIN tblICItem m ON m.intItemId = li.intItemId
	WHERE li.intOrderHeaderId = @intOrderHeaderId
	
	SELECT @intUserId = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strUserName
	SELECT @intStorageLocationId = intStorageLocationId FROM tblICStorageLocation WHERE strName = @strUnitName
	SELECT @strBOLNo = strBOLNo FROM tblWHOrderHeader WHERE intOrderHeaderId = @intOrderHeaderId
	
	SELECT @intItemRecordId = MIN(intItemRecordId)
	FROM @tblLineItem
	
	WHILE (@intItemRecordId IS NOT NULL)
		BEGIN
			SET @intItemId = NULL 
			SET @dblOrderedQty = NULL
			SET @dblLotQty = NULL
			SET @intUnitsPerPallet = NULL
			SET @intOrderLineItemId = NULL

			SELECT @intOrderLineItemId = intOrderLineItemId,
				   @intItemId = intItemId,
				   @dblOrderedQty = dblOrderedQty,
				   @dblLotQty = dblLotQty,
				   @intUnitsPerPallet = intUnitsPerPallet
			FROM @tblLineItem
			WHERE intItemRecordId = @intItemRecordId
			
			WHILE @dblOrderedQty > 0
			BEGIN
			
				IF (@dblOrderedQty > @intUnitsPerPallet)
				BEGIN
					IF @dblOrderedQty <= 0
					BEGIN
						BREAK;
					END
					
					SELECT 1,@dblOrderedQty
					EXEC uspWHCheckInSKU @intOrderHeaderId = @intOrderHeaderId,
										 @strUserName = @strUserName,
										 @intAddressId = @intAddressId,
										 @strContainerNo = '',
										 @intContainerTypeId = 0,
										 @strStorageLocationName = @strUnitName,
										 @strSKUNo = '',
										 @dblQty = @intUnitsPerPallet,
										 @strLotCode = '',
										 @dtmProductionDate = '1/1/1990',
										 @intItemId = @intItemId,
										 @intContainerId = 0,
										 @intOrderLineItemId = @intOrderLineItemId,
										 @intSKUId = 0
										 
					SET @dblOrderedQty = @dblOrderedQty - @intUnitsPerPallet
				END
				ELSE 
				BEGIN
					IF @dblOrderedQty <= 0
					BEGIN
						BREAK;
					END				
					SELECT 2,@dblOrderedQty
					EXEC uspWHCheckInSKU @intOrderHeaderId = @intOrderHeaderId,
										 @strUserName = @strUserName,
										 @intAddressId = @intAddressId,
										 @strContainerNo = '',
										 @intContainerTypeId = 0,
										 @strStorageLocationName = @strUnitName,
										 @strSKUNo = '',
										 @dblQty = @dblOrderedQty,
										 @strLotCode = '',
										 @dtmProductionDate = '1/1/1990',
										 @intItemId = @intItemId,
										 @intContainerId = 0,
										 @intOrderLineItemId = @intOrderLineItemId,
										 @intSKUId = 0
					SET @dblOrderedQty = 0
				END
					IF @dblOrderedQty <= 0
					BEGIN
						BREAK;
					END
			END			 
			
			SELECT @strItemType = strType FROM tblICItem WHERE intItemId = @intItemId
			
			IF (@strItemType <> 'Finished Good')
			BEGIN
				SELECT @strLotAlias = strLotAlias
				FROM tblWHOrderLineItem
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intItemId = @intItemId
				
				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND ysnStockUnit = 1

				SELECT @dblWeightPerQty = dblWeightPerUnit, 
					   @intWeightPerUnitUOMId = intWeightPerUnitUOMId,
					   @intPhysicalCountUOMId = intPhysicalCountUOMId 
				FROM tblWHOrderLineItem 
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intItemId = @intItemId 

								SELECT @intLotQtyUOMId = intItemUOMId
				FROM tblICItemUOM u
				JOIN tblICItem i ON i.intItemId = u.intItemId
				WHERE i.intItemId = @intItemId
					AND ysnStockUnit <> 1
					AND u.intUnitMeasureId = @intPhysicalCountUOMId

				IF ISNULL(@intLotQtyUOMId,0) = 0 
				BEGIN
					SELECT TOP 1 @intLotQtyUOMId = intItemUOMId
					FROM tblICItemUOM u
					JOIN tblICItem i ON i.intItemId = u.intItemId
					WHERE i.intItemId = @intItemId
				END

				SET @dblLotWeight = @dblLotQty * @dblWeightPerQty
					

				EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strLotNumber OUTPUT 
				
				EXEC uspWHCreateLot 
							@ysnPost = 1
							,@ysnRecap=0
							,@intOrderHeaderId=@intOrderHeaderId
							,@intItemId =@intItemId
							,@intUserId=@intUserId
							,@intEntityId =NULL
							,@intStorageLocationId = @intStorageLocationId
							,@dblWeight = @dblLotWeight
							,@intWeightUOMId = @intItemUOMId
							,@dblUnitQty = 1
							,@dblProduceQty= @dblLotQty
							,@intProduceUOMKey =@intLotQtyUOMId
							,@strBatchId = @strBOLNo
							,@strLotNumber = @strLotNumber
							,@intBatchId = NULL
							,@intLotId =@intLotId OUT
							,@strLotAlias=@strLotAlias
							,@strVendorLotNo = NULL
							,@strParentLotNumber= NULL
								
				UPDATE tblWHSKU
				SET intLotId = @intLotId
				WHERE intSKUId IN (
						SELECT intSKUId
						FROM tblWHOrderManifest om
						JOIN tblWHOrderLineItem oli ON oli.intOrderLineItemId = om.intOrderLineItemId
						WHERE oli.intOrderHeaderId = @intOrderHeaderId
							AND oli.intItemId = @intItemId)
							
				UPDATE om
				SET om.intLotId = @intLotId
				FROM tblWHOrderManifest om
				JOIN tblWHOrderLineItem oli ON oli.intOrderLineItemId = om.intOrderLineItemId
				WHERE oli.intOrderHeaderId = @intOrderHeaderId
					AND oli.intItemId = @intItemId
					
			END
			
			SELECT @intItemRecordId = MIN(intItemRecordId)
			FROM @tblLineItem WHERE intItemRecordId > @intItemRecordId
		END
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF xact_State() <> 0
		ROLLBACK TRANSACTION

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCheckInSKU: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
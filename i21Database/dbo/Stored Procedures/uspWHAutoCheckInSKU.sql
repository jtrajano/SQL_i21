CREATE PROCEDURE [dbo].[uspWHAutoCheckInSKU]
			@intOrderHeaderId INT,
			@strUnitName NVARCHAR(100),
			@strUserName NVARCHAR(100),
			@intAddressId INT = NULL
			
AS
BEGIN TRY

	DECLARE @intItemId INT
	DECLARE @dblOrderedQty NUMERIC(18,6)
	DECLARE @intUnitsPerPallet INT
	DECLARE @intOrderLineItemId INT
	DECLARE @intItemRecordId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	
	DECLARE @tblLineItem TABLE 
			(intItemRecordId INT Identity(1, 1), 
			 intOrderHeaderId INT, 
			 intItemId INT, 
			 dblOrderedQty NUMERIC(18, 6), 
			 intUnitsPerPallet INT,
			 intOrderLineItemId INT)

BEGIN TRANSACTION
	INSERT INTO @tblLineItem (
		intOrderHeaderId,
		intItemId,
		dblOrderedQty,
		intUnitsPerPallet,
		intOrderLineItemId
		)
	SELECT li.intOrderHeaderId,
		   li.intItemId, 
		   li.dblQty AS dblQty, 
		   ISNULL((m.intUnitPerLayer * m.intLayerPerPallet), 1) intUnitsPerPallet, 
		   li.intOrderLineItemId
	FROM tblWHOrderLineItem li
	INNER JOIN tblICItem m ON m.intItemId = li.intItemId
	WHERE li.intOrderHeaderId = @intOrderHeaderId
	
	
	SELECT * FROM  @tblLineItem
	
	SELECT @intItemRecordId = MIN(intItemRecordId)
	FROM @tblLineItem
	
	WHILE (@intItemRecordId IS NOT NULL)
		BEGIN
			SET @intItemId = NULL 
			SET @dblOrderedQty = NULL
			SET @intUnitsPerPallet = NULL
			SET @intOrderLineItemId = NULL

			SELECT @intOrderLineItemId = intOrderLineItemId,
				   @intItemId = intItemId,
				   @dblOrderedQty = dblOrderedQty,
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
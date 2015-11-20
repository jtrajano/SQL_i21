CREATE PROCEDURE [dbo].[uspWHCreateOrderLineItem] 
		@strXML NVARCHAR(MAX),
		@intOrderLineItemId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX), 
		    @idoc INT, 
		    @intPhysicalCountUOMId INT, 
		    @intItemId INT, 
		    @intOrderHeaderId INT, 
		    @intNetWeightUOMId INT, 
		    @dblReceivedQty NUMERIC(18, 6), 
		    @intWeightPerUnitUOMId INT, 
		    @intPallets INT, 
		    @intLayers INT, 
		    @strLineItemNote NVARCHAR(128), 
		    @intReceiptQtyUOMId INT, 
		    @strLastUpdateBy NVARCHAR(32), 
		    @strLotControl NVARCHAR(30), 
		    @dblTareWeight NUMERIC(18, 6), 
		    @intOriginId INT, 
		    @dtmLastUpdateOn DATETIME, 
		    @strContainerNo NVARCHAR(50), 
		    @dblNetWeight NUMERIC(18, 6), 
		    @strLotAlias NVARCHAR(30), 
		    @strQtyOpenToReceiveUOM NVARCHAR(50), 
		    @strSupplierLotNo NVARCHAR(30), 
		    @dblWeightPerUnit NUMERIC(18, 6), 
		    @dblWeightPerUnit1 NUMERIC(18, 6), 
		    @strGrade NVARCHAR(265), 
		    @ysnIsPhysicalCountVerified BIT, 
		    @strGarden NVARCHAR(265), 
		    @intNoOfBags INT, 
		    @dblQty NUMERIC(18, 6), 
		    @intPickPreferenceId INT, 
		    @intUnitPerLayer NUMERIC(24, 10), 
		    @intLayersPerPallet NUMERIC(24, 10), 
		    @dtmProductionDate DATETIME, 
		    @intLineNumber INT, 
		    @intLotId INT, 
		    @strBOLNo NVARCHAR(50), 
		    @intOldLotId INT, 
		    @dblNewQty NUMERIC(18, 6), 
		    @dblOldQty NUMERIC(18, 6), 
		    @dblSKUAdjustmentToleranceLimit NUMERIC(18, 6),
		    @dblOrderedQrtAvailableQtyDifference NUMERIC(18, 6), 
		    @dblAvailableQty NUMERIC(18, 6), 
		    @dblReservedQty NUMERIC(18, 6), 
		    @strSubstituteValueList NVARCHAR(MAX), 
		    @dblPhysicalCount NUMERIC(18, 6), 
		    @strUOM NVARCHAR(50), 
		    @dblUnitCount NUMERIC(18, 6), 
		    @intOrderTypeId INT, 
		    @strInternalCode NVARCHAR(50), 
		    @strLotNumber NVARCHAR(50), 
		    @strOldLotAlias NVARCHAR(100)

	SET @intLineNumber = 0

	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML

	SELECT @intPhysicalCountUOMId = intPhysicalCountUOMId, 
		   @intItemId = intItemId, 
		   @intOrderHeaderId = intOrderHeaderId, 
		   @dblReceivedQty = dblPhysicalCount, 
		   @intWeightPerUnitUOMId = intWeightPerUnitUOMId, 
		   @intOrderLineItemId = intOrderLineItemId, 
		   @intPallets = intPallets, 
		   @intLayers = intLayers, 
		   @strLineItemNote = strLineItemNote, 
		   @strLastUpdateBy = strLastUpdateBy, 
		   @strLotControl = strLotControl, 
		   @intOriginId = intOriginId, 
		   @dtmLastUpdateOn = dtmLastUpdateOn, 
		   @strContainerNo = strContainerNo, 
		   @strLotAlias = strLotAlias, 
		   @strQtyOpenToReceiveUOM = strQtyOpenToReceiveUOM, 
		   @strSupplierLotNo = strSupplierLotNo, 
		   @dblWeightPerUnit = dblWeightPerUnit, 
		   @strGrade = strGrade, 
		   @ysnIsPhysicalCountVerified = ysnIsPhysicalCountVerified, 
		   @strGarden = strGarden, 
		   @intReceiptQtyUOMId = intReceiptQtyUOMId, 
		   @intNoOfBags = intNoOfBags, 
		   @dblQty = dblQty, 
		   @intPickPreferenceId = intPickPreferenceId, 
		   @intUnitPerLayer = intUnitsPerLayer, 
		   @intLayersPerPallet = intLayersPerPallet, 
		   @dtmProductionDate = dtmProductionDate, 
		   @intLotId = intLotId
	FROM OpenXML(@idoc, 'root', 2) 
	WITH   (intPhysicalCountUOMId INT, 
			intItemId INT, 
			intOrderHeaderId INT, 
			dblPhysicalCount NUMERIC(18, 6), 
			intWeightPerUnitUOMId INT, 
			intOrderLineItemId INT, 
			intPallets NUMERIC(24, 10),
			intLayers NUMERIC(24, 10), 
			strLineItemNote NVARCHAR(128), 
			strLastUpdateBy NVARCHAR(32), 
			strLotControl NVARCHAR(30), 
			intOriginId INT, 
			dtmLastUpdateOn DATETIME, 
			strContainerNo NVARCHAR(50),
			strLotAlias NVARCHAR(30), 
			strQtyOpenToReceiveUOM NVARCHAR(50), 
			strSupplierLotNo NVARCHAR(30), 
			dblWeightPerUnit NUMERIC(18, 6), 
			strGrade NVARCHAR(265),
			ysnIsPhysicalCountVerified BIT, 
			strGarden NVARCHAR(265), 
			intReceiptQtyUOMId INT, 
			intNoOfBags INT, 
			dblQty NUMERIC(18, 6), 
			intPickPreferenceId INT, 
			intUnitsPerLayer NUMERIC(24, 10), 
			intLayersPerPallet NUMERIC(24, 10), 
			dtmProductionDate DATETIME, 
			intLotId INT)

	IF @dblWeightPerUnit IS NULL
	BEGIN
		SELECT @dblWeightPerUnit1 = dblWeightPerUnit
		FROM OpenXML(@idoc, 'root', 2) 
		WITH (dblWeightPerUnit NUMERIC(18, 6))
		
		SET @dblWeightPerUnit = @dblWeightPerUnit1
	END

	IF @intPickPreferenceId IS NULL
	BEGIN
		SELECT @intPickPreferenceId = intPickPreferenceId
		FROM tblWHPickPreference
		WHERE ysnIsDefault = 1
	END

	IF @intPickPreferenceId = 0
	BEGIN
		SELECT @intPickPreferenceId = NULL
	END

	SELECT @intOrderTypeId = intOrderTypeId, @strBOLNo = strBOLNo
	FROM tblWHOrderHeader
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @strInternalCode = strInternalCode
	FROM dbo.tblWHOrderType
	WHERE intOrderTypeId = @intOrderTypeId

	--  SELECT @dblSKUAdjustmentToleranceLimit=apsv.SettingValue 
	--FROM iMake_AppSetting aps   
	--JOIN iMake_AppSettingValue apsv ON aps.SettingKey = apsv.SettingKey  
	--WHERE aps.SettingName = 'SKUAdjustmentToleranceLimit'  
	IF @intLotId IS NOT NULL
		AND @strInternalCode = 'WT'
	BEGIN
		SELECT @strUOM = ISNULL(UM.strUnitMeasure, ''), @dblUnitCount = l.dblWeightPerQty
		FROM tblICLot l
		JOIN tblICItemUOM IU ON IU.intItemUOMId = l.intWeightUOMId
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE intLotId = @intLotId

		IF @dblWeightPerUnit = 0
			SELECT @dblWeightPerUnit = 1

		SELECT @dblAvailableQty = dblQty
		FROM tblICLot
		WHERE intLotId = @intLotId

		--SELECT  @dblReservedQty=ISNULL(sum(ReservedQty),0)        
		--FROM  LotReservation   
		--WHERE intLotId=@intLotId          
		IF ISNULL(@intOrderLineItemId, 0) = 0
		BEGIN
			SET @dblAvailableQty = @dblAvailableQty - @dblReservedQty
		END
		ELSE
		BEGIN
			SELECT @dblPhysicalCount = CASE 
					WHEN intPhysicalCountUOMId = intWeightPerUnitUOMId
						THEN dblPhysicalCount
					ELSE dblPhysicalCount * dblWeightPerUnit
					END, @intOldLotId = intLotId
			FROM tblWHOrderLineItem
			WHERE intOrderLineItemId = @intOrderLineItemId

			IF @intLotId = @intOldLotId
			BEGIN
				SET @dblAvailableQty = @dblAvailableQty + @dblPhysicalCount - @dblReservedQty
			END
			ELSE
			BEGIN
				SET @dblAvailableQty = @dblAvailableQty - @dblReservedQty
			END
		END

		SET @dblOrderedQrtAvailableQtyDifference = (
				CASE 
					WHEN @intPhysicalCountUOMId = @intWeightPerUnitUOMId
						THEN CONVERT(DECIMAL(18, 4), @dblReceivedQty)
					ELSE CONVERT(DECIMAL(18, 4), (@dblReceivedQty * @dblWeightPerUnit))
					END
				) - @dblAvailableQty

		IF @dblOrderedQrtAvailableQtyDifference > @dblSKUAdjustmentToleranceLimit
		BEGIN
			IF (
					CASE 
						WHEN @intPhysicalCountUOMId = @intWeightPerUnitUOMId
							THEN CONVERT(DECIMAL(18, 4), @dblReceivedQty)
						ELSE CONVERT(DECIMAL(18, 4), (@dblReceivedQty * @dblWeightPerUnit))
						END
					) > @dblAvailableQty
			BEGIN
				SELECT @strLotNumber = strLotNumber
				FROM tblICLot
				WHERE intLotId = @intLotId

				RAISERROR ('The system has detected that the lot is scheduled for a quantity greater than the physicalQty.', 16, 1)
			END
		END
	END

	BEGIN TRANSACTION

	IF ISNULL(@intOrderLineItemId, 0) = 0
	BEGIN
		IF @intOrderTypeId = 3
			AND (
				EXISTS (
					SELECT 1
					FROM tblWHOrderLineItem
					WHERE strLotAlias = @strLotAlias
						AND ISNULL(@strLotAlias, '') <> ''
					)
				) --  OR EXISTS(SELECT 1 FROM iMake_Archive.dbo.ARC_OrderDetail WHERE strLotAlias=@strLotAlias AND ISNULL(@strLotAlias,'')<>''))
		BEGIN
			RAISERROR ('The Lot Alias exist. Please generate a new Lot Alias.', 16, 1)
		END
	END
	ELSE
	BEGIN
		SELECT @strOldLotAlias = strLotAlias, @intOldLotId = intLotId, @dblOldQty = CASE 
				WHEN intPhysicalCountUOMId = intWeightPerUnitUOMId
					THEN dblPhysicalCount
				ELSE dblPhysicalCount * dblWeightPerUnit
				END
		FROM tblWHOrderLineItem
		WHERE intOrderLineItemId = @intOrderLineItemId

		IF @strOldLotAlias <> ISNULL(@strLotAlias, '')
		BEGIN
			IF @intOrderTypeId = 3
				AND (
					EXISTS (
						SELECT 1
						FROM tblWHOrderLineItem
						WHERE strLotAlias = @strLotAlias
							AND ISNULL(@strLotAlias, '') <> ''
						)
					)
			BEGIN
				RAISERROR ('The Lot Alias exist. Please generate a new Lot Alias.', 16, 1)
			END
		END
	END

	IF EXISTS (
			SELECT 1
			FROM tblWHOrderHeader
			WHERE intOrderHeaderId = @intOrderHeaderId
			) -- or @strInternalCode='PS'
	BEGIN
		IF ISNULL(@intOrderLineItemId, 0) = 0
		BEGIN
			IF @strInternalCode = 'PS'
			BEGIN
				IF EXISTS (
						SELECT *
						FROM tblWHOrderLineItem
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intItemId = @intItemId
							AND intLotId = @intLotId
						)
				BEGIN
					RAISERROR ('The Item with the same lot code is already added. Please adjust the quantity of the existing lot if required and continue.', 16, 1)
				END
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT *
						FROM tblWHOrderLineItem
						WHERE intOrderHeaderId = @intOrderHeaderId
							AND intItemId = @intItemId
							AND strLotAlias = @strLotAlias
						)
				BEGIN
					RAISERROR ('The Item with the same lot code is already available in this order. Please adjust the quantity of the existing line if required and continue.', 16, 1)
				END
			END

			SELECT @intLineNumber = ISNULL(MAX(intLineNo), 0) + 1
			FROM tblWHOrderLineItem
			WHERE intOrderHeaderId = @intOrderHeaderId

			INSERT INTO tblWHOrderLineItem (
						intPhysicalCountUOMId, 
						intItemId, 
						intOrderHeaderId, 
						dblQty, 
						intWeightPerUnitUOMId, 
						strLineItemNote, 
						intLastUpdateId, 
						intOriginId, 
						dtmLastUpdateOn, 
						strContainerNo, 
						strLotAlias, 
						strSupplierLotNo, 
						dblWeightPerUnit, 
						ysnIsPhysicalCountVerified, 
						intReceiptQtyUOMId, 
						dblPhysicalCount, 
						intNoOfBags, 
						intPreferenceId, 
						intLayersPerPallet, 
						intUnitsPerLayer, 
						dblRequiredQty, 
						dtmProductionDate, 
						intLineNo, 
						intLotId)
				VALUES (@intPhysicalCountUOMId, 
						@intItemId, 
						@intOrderHeaderId, 
						@dblReceivedQty, 
						ISNULL(@intWeightPerUnitUOMId, - 1), 
						@strLineItemNote, 
						@strLastUpdateBy, 
						@intOriginId, 
						ISNULL(@dtmLastUpdateOn, GETDATE()), 
						@strContainerNo, 
						@strLotAlias, 
						@strSupplierLotNo, 
						@dblWeightPerUnit, 
						@ysnIsPhysicalCountVerified, 
						ISNULL(@intPhysicalCountUOMId, - 1), 
						@dblReceivedQty, 
						@intNoOfBags, 
						@intPickPreferenceId, 
						@intLayersPerPallet, 
						@intUnitPerLayer, 
						@dblReceivedQty, 
						@dtmProductionDate, 
						@intLineNumber, 
						@intLotId)

			SELECT @intOrderLineItemId = Scope_Identity()
		END
		ELSE
		BEGIN
				UPDATE tblWHOrderLineItem
				SET intPhysicalCountUOMId = @intPhysicalCountUOMId, 
					dblQty = @dblReceivedQty, 
					strLineItemNote = @strLineItemNote, 
					intReceiptQtyUOMId = ISNULL(@intPhysicalCountUOMId, - 1), 
					dblPhysicalCount = @dblReceivedQty, 
					intLastUpdateId = @strLastUpdateBy, 
					intOriginId = @intOriginId, 
					dtmLastUpdateOn = ISNULL(@dtmLastUpdateOn, GETDATE()), 
					strLotAlias = @strLotAlias, 
					strSupplierLotNo = @strSupplierLotNo, 
					dblWeightPerUnit = @dblWeightPerUnit, 
					ysnIsPhysicalCountVerified = @ysnIsPhysicalCountVerified, 
					intNoOfBags = @intNoOfBags, 
					intPreferenceId = @intPickPreferenceId, 
					intLayersPerPallet = @intLayersPerPallet, 
					intUnitsPerLayer = @intUnitPerLayer, 
					dtmProductionDate = @dtmProductionDate, 
					intLotId = @intLotId
				WHERE intOrderLineItemId = @intOrderLineItemId
		END
	END

	IF ISNULL(@intOldLotId, 0) > 0
		AND @strInternalCode = 'WT'
	BEGIN
		--EXEC Lot_UnReserve @intOldLotId,@strBOLNo,@dblOldQty,4
		PRINT 'Lot_UnReserve SP'
	END

	IF ISNULL(@intLotId, 0) > 0
		AND @strInternalCode = 'WT'
	BEGIN
		--SET @dblNewQty = CAse When @intPhysicalCountUOMId=@intWeightPerUnitUOMId Then @dblReceivedQty Else @dblReceivedQty*@dblWeightPerUnit End
		--EXEC Lot_Reserve @intLotId,@strBOLNo,@dblNewQty,4
		PRINT 'Lot_UnReserve SP'
	END

	COMMIT TRANSACTION

	SELECT @intOrderLineItemId
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = 'uspWHCreateOrderLineItem:' + Error_Message()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
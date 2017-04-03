CREATE PROCEDURE [dbo].[uspMFProduceSanitizedOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@dblInputWeight NUMERIC(38, 20)
		,@strOutputLotNumber NVARCHAR(50)
		,@intItemId INT
		,@dblQty NUMERIC(38, 20)
		,@intItemUOMId INT
		,@dblWeightPerQty NUMERIC(38, 20)
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intStorageLocationId INT
		,@intUserId INT
		,@intUnitPerLayer INT
		,@intLayerPerPallet INT
		,@intNoOfPallet INT
		,@intTransactionCount INT
		,@intLocationId INT
		,@intOutputLotId INT
		,@dtmCreated DATETIME
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@intBatchId INT
		,@intSubLocationId INT
		,@intInputLotId INT
		,@intInputStorageLocationId INT
		,@dblInputWeightPerQty NUMERIC(38, 20)
		,@strDefaultStatusForSanitizedLot NVARCHAR(50)
		,@intLotStatusId INT
		,@intCasesPerPallet INT
		,@SKUQuantity NUMERIC(38, 20)
		,@intUnitMeasureId INT
		,@ysnGeneratePickTask INT
		,@intOwnerId INT
		,@intOrderTermsId INT
		,@strUserName NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@intEntityId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@strLotAlias NVARCHAR(50)
		,@intWorkOrderProducedLotId INT
		,@intOrderLineItemId INT
		,@intInventoryAdjustmentId INT
		,@strLotTracking NVARCHAR(50)
		,@dblOutputWeightPerQty numeric(18,6)
		,@intCategoryId int

	SELECT @strDefaultStatusForSanitizedLot = strDefaultStatusForSanitizedLot
	FROM dbo.tblMFCompanyPreference

	--EXEC dbo.uspSMGetStartingNumber 33
	--	,@intBatchId OUTPUT

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intInputLotId = intInputLotId
		,@intOutputLotId = intOutputLotId
		,@strOutputLotNumber = strOutputLotNumber
		,@intItemId = intItemId
		,@dblQty = dblQty
		,@intItemUOMId = intItemUOMId
		,@dblWeightPerQty = dblWeightPerQty
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@intStorageLocationId = intStorageLocationId
		,@intSubLocationId = intSubLocationId
		,@intUserId = intUserId
		,@intUnitPerLayer = intUnitPerLayer
		,@intLayerPerPallet = intLayerPerPallet
		,@intNoOfPallet = intNoOfPallet
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intInputLotId INT
			,intOutputLotId INT
			,strOutputLotNumber NVARCHAR(50)
			,intItemId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,dblWeightPerQty NUMERIC(38, 20)
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,intStorageLocationId INT
			,intSubLocationId INT
			,intUserId INT
			,intUnitPerLayer INT
			,intLayerPerPallet INT
			,intNoOfPallet INT
			,intLocationId INT
			)

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
		,@intItemId = NULL
		,@intManufacturingId = NULL
		,@intSubLocationId = NULL
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 33
		,@ysnProposed = 0
		,@strPatternString = @intBatchId OUTPUT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	SELECT @dblInputWeight = dblWeight
		,@dblInputWeightPerQty = dblWeightPerQty
		,@intInputStorageLocationId = intStorageLocationId
	FROM tblICLot
	WHERE intLotId = @intInputLotId

	SELECT @strLotTracking = strLotTracking
			,@intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @dblWeight > @dblInputWeight
	BEGIN
		EXEC uspMFLotAdjustQty @intLotId = @intInputLotId
			,@dblNewLotQty = @dblWeight
			,@intUserId = @intUserId
			,@strReasonCode = 'Production'
			,@strNotes = 'Production - Adjust'
	END

	UPDATE tblICStockReservation
	SET dblQty =dblQty-@dblWeight
	WHERE intLotId=@intInputLotId and intTransactionId=@intWorkOrderId

	UPDATE tblICStockReservation
	SET dblQty =CASE WHEN dblQty <0 THEN 0 ELSE dblQty END
	WHERE intLotId=@intInputLotId AND intTransactionId=@intWorkOrderId

	SELECT @dtmCreated = Getdate()

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intBusinessShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intOutputLotId IS NULL
		OR @intOutputLotId = 0
	BEGIN
		IF (
				@strOutputLotNumber = ''
				OR @strOutputLotNumber IS NULL
				)
			--AND @strLotTracking <> 'Yes - Serial Number'
		BEGIN
			--EXEC dbo.uspSMGetStartingNumber 24
			--	,@strOutputLotNumber OUTPUT
			Declare @intManufacturingCellId int
			Select @intManufacturingCellId=intManufacturingCellId from tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
						,@intItemId = @intItemId
						,@intManufacturingId = @intManufacturingCellId
						,@intSubLocationId = @intSubLocationId
						,@intLocationId = @intLocationId
						,@intOrderTypeId = NULL
						,@intBlendRequirementId = NULL
						,@intPatternCode = 24
						,@ysnProposed = 0
						,@strPatternString = @strOutputLotNumber OUTPUT
						,@intShiftId=@intBusinessShiftId
		END

		EXEC dbo.uspMFLotSplit @intLotId = @intInputLotId
			,@strNewLotNumber = @strOutputLotNumber
			,@intSplitSubLocationId = @intSubLocationId
			,@intSplitStorageLocationId = @intStorageLocationId
			,@dblSplitQty = @dblQty
			,@intUserId = @intUserId
			,@strNote = 'Sanitized'
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		IF @strLotTracking = 'Yes - Serial Number'
		BEGIN
			SELECT @intOutputLotId = intNewLotId
			FROM tblICInventoryAdjustmentDetail
			WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

			SELECT @intLotStatusId = intLotStatusId
				,@strLotAlias = strLotAlias
			FROM tblICLot
			WHERE intLotId = @intOutputLotId
		END
		ELSE
		BEGIN
			SELECT @intOutputLotId = intLotId
				,@intLotStatusId = intLotStatusId
				,@strLotAlias = strLotAlias
			FROM tblICLot
			WHERE strLotNumber = @strOutputLotNumber
				AND intStorageLocationId = @intStorageLocationId
		END

		IF (
				SELECT intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strDefaultStatusForSanitizedLot
				) <> @intLotStatusId
			AND EXISTS (
				SELECT intLotStatusId
				FROM tblICLotStatus
				WHERE strSecondaryStatus = @strDefaultStatusForSanitizedLot
				)
		BEGIN
			SELECT @intLotStatusId = intLotStatusId
			FROM tblICLotStatus
			WHERE strSecondaryStatus = @strDefaultStatusForSanitizedLot

			--UPDATE tblICLot
			--SET intLotStatusId = @intLotStatusId
			--WHERE intLotId = @intOutputLotId
			
			EXEC uspMFSetLotStatus intOutputLotId,@intLotStatusId,@intUserId

		END
	END
	ELSE
	BEGIN
		Select @dblOutputWeightPerQty =dblWeightPerQty from tblICLot Where intLotId=@intOutputLotId
		IF @dblOutputWeightPerQty <> @dblWeightPerQty
		BEGIN
			RAISERROR (
					90003
					,14
					,1
					)
		END

		EXEC dbo.uspMFLotMerge @intLotId = @intInputLotId
			,@intNewLotId = @intOutputLotId
			,@dblMergeQty = @dblQty
			,@intUserId = @intUserId

		SELECT @strLotAlias = strLotAlias
		FROM tblICLot
		WHERE intLotId = @intOutputLotId
	END

	INSERT INTO dbo.tblMFWorkOrderProducedLot (
		intWorkOrderId
		,intItemId
		,intLotId
		,dblQuantity
		,intItemUOMId
		,dblWeightPerUnit
		,dblPhysicalCount
		,intPhysicalItemUOMId
		,intStorageLocationId
		,dtmBusinessDate
		,intBusinessShiftId
		,dtmProductionDate
		,intShiftId
		,intBatchId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		,intInputLotId
		,intInputStorageLocationId
		,intUnitPerLayer
		,intLayerPerPallet
		)
	SELECT @intWorkOrderId
		,@intItemId
		,@intOutputLotId
		,@dblWeight
		,@intWeightUOMId
		,@dblWeightPerQty
		,@dblQty
		,@intItemUOMId
		,@intStorageLocationId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@dtmBusinessDate
		,@intBusinessShiftId
		,@intBatchId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
		,@intUserId
		,@intInputLotId
		,@intInputStorageLocationId
		,@intUnitPerLayer
		,@intLayerPerPallet

	SELECT @intWorkOrderProducedLotId = SCOPE_IDENTITY()

	DECLARE @intOrderHeaderId INT
		,@strSanitizationStagingLocation NVARCHAR(50)
		,@intStagingLocationId INT
		,@dblRequiredWeight NUMERIC(38, 20)
		,@intSKUId INT
		,@intRecordId INT
		,@strSourceContainerNo NVARCHAR(50)
		,@intContainerId INT
		,@intDestinationContainerId INT
		,@dblSplitQty NUMERIC(38, 20)
		,@strDestinationContainerNo NVARCHAR(50)
		,@intNewSKUId INT
		,@ysnSanitizationInboundPutaway BIT
		,@intItemUnitMeasureId INT
		,@intWeightUnitMeasureId INT
		,@intUOMId INT
		,@dblWeightperUnit NUMERIC(38, 20)
		,@strSKUNo NVARCHAR(50)
		,@intSanitizationStagingUnitId int

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @ysnSanitizationInboundPutaway = ysnSanitizationInboundPutaway
	FROM dbo.tblMFCompanyPreference

	SELECT @strUserName = strUserName
	FROM dbo.tblSMUserSecurity
	WHERE [intEntityId] = @intUserId

	IF @intOrderHeaderId > 0
	BEGIN
		--SELECT @intStagingLocationId = intStorageLocationId
		--FROM dbo.tblICStorageLocation
		--WHERE strName = @strSanitizationStagingLocation
		--	AND intLocationId = @intLocationId

		SELECT @intStagingLocationId=intSanitizationStagingUnitId
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId=@intLocationId

		DECLARE @tblWHSKU TABLE (
			intRecordId INT IDENTITY(1, 1)
			,intItemId INT
			,intLotId INT
			,intSKUId INT
			,strSKUNo NVARCHAR(50)
			,intContainerId INT
			,intUOMId INT
			,dblQuantity NUMERIC(16, 8)
			,intItemUOMId INT
			,intItemUnitMeasureId INT
			,dblWeightperUnit NUMERIC(16, 8)
			,dblWeight NUMERIC(16, 8)
			,intWeightUOMId INT
			,intWeightUnitMeasureId INT
			)

		INSERT INTO @tblWHSKU (
			intItemId
			,intLotId
			,intSKUId
			,strSKUNo
			,intContainerId
			,intUOMId
			,dblQuantity
			,intItemUOMId
			,intItemUnitMeasureId
			,dblWeightperUnit
			,dblWeight
			,intWeightUOMId
			,intWeightUnitMeasureId
			)
		SELECT S.intItemId
			,S.intLotId
			,S.intSKUId
			,S.strSKUNo
			,C.intContainerId
			,S.intUOMId
			,S.dblQty
			,L.intItemUOMId
			,I.intUnitMeasureId
			,S.dblWeightPerUnit
			,S.dblQty * S.dblWeightPerUnit
			,L.intWeightUOMId
			,W.intUnitMeasureId
		FROM dbo.tblWHSKU S
		JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
		JOIN dbo.tblICLot L ON L.intLotId = S.intLotId
		JOIN dbo.tblICItemUOM I ON I.intItemUOMId = L.intItemUOMId
		LEFT JOIN dbo.tblICItemUOM W ON W.intItemUOMId = L.intWeightUOMId
		WHERE C.intStorageLocationId = @intStagingLocationId
			AND S.dblQty > 0
			AND S.intLotId = @intInputLotId
			AND S.intSKUStatusId in (1,2)
		ORDER BY S.intSKUId

		SELECT @dblRequiredWeight = @dblWeight

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblWHSKU

		WHILE @intRecordId IS NOT NULL
			AND @dblRequiredWeight > 0
		BEGIN
			SELECT @intSKUId = NULL
				,@dblWeight = NULL
				,@intUOMId = NULL
				,@intItemUnitMeasureId = NULL
				,@intWeightUnitMeasureId = NULL
				,@dblWeightperUnit = NULL
				,@intContainerId = NULL
				,@strSKUNo = NULL

			SELECT @intSKUId = intSKUId
				,@strSKUNo = strSKUNo
				,@intUOMId = intUOMId
				,@dblWeight = dblWeight
				,@intItemUnitMeasureId = intItemUnitMeasureId
				,@intWeightUnitMeasureId = intWeightUnitMeasureId
				,@dblWeightperUnit = dblWeightperUnit
				,@intContainerId = intContainerId
			FROM @tblWHSKU
			WHERE intRecordId = @intRecordId

			IF @dblRequiredWeight >= @dblWeight
			BEGIN
				UPDATE tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intSKUId

				PRINT 'Call Delete SKU'
				EXEC dbo.uspWHDeleteSKUForWarehouse 
						@intSKUId=@intSKUId, 
						@strUserName=@strUserName

				INSERT INTO dbo.tblMFWorkOrderConsumedSKU (
					intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intBatchId
					,intShiftId
					,dtmCreated
					,intCreatedUserId
					)
				SELECT @intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblWeight
					,intWeightUOMId
					,dblQuantity
					,intItemUOMId
					,@intBatchId
					,@intBusinessShiftId
					,@dtmCreated
					,@intUserId
				FROM @tblWHSKU
				WHERE intRecordId = @intRecordId

				SELECT @dblRequiredWeight = @dblRequiredWeight - @dblWeight
			END
			ELSE
			BEGIN
				SELECT @strSourceContainerNo = NULL

				SELECT @strSourceContainerNo = strContainerNo
				FROM dbo.tblWHContainer
				WHERE intContainerId = @intContainerId

				DELETE
				FROM dbo.tblWHTask
				WHERE intFromContainerId = @intContainerId

				SELECT @intDestinationContainerId = NULL
					,@dblSplitQty = NULL

				IF ISNULL(@intWeightUnitMeasureId, @intItemUnitMeasureId) = @intUOMId
				BEGIN
					SELECT @dblSplitQty = @dblRequiredWeight
				END
				ELSE
				BEGIN
					SELECT @dblSplitQty = @dblRequiredWeight / @dblWeightperUnit
				END

				EXEC [dbo].uspWHSplitSKUForOrder @strUserName = @strUserName
					,@intAddressId = @intLocationId
					,@strSourceContainerNo = @strSourceContainerNo
					,@dblSplitQty = @dblSplitQty
					,@strSKUNo = @strSKUNo
					,@intOrderHeaderId = 0
					,@ysnGeneratePickTask = @ysnGeneratePickTask OUT
					,@strDestContainerNo = @strDestinationContainerNo OUT

				PRINT 'Call Split SKU proc'

				SELECT @intDestinationContainerId = NULL

				SELECT @intDestinationContainerId = intContainerId
				FROM dbo.tblWHContainer
				WHERE strContainerNo = @strDestinationContainerNo

				SELECT @intNewSKUId = NULL

				SELECT @intNewSKUId = intSKUId
				FROM dbo.tblWHSKU
				WHERE intContainerId = @intDestinationContainerId

				UPDATE dbo.tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intNewSKUId

				INSERT INTO dbo.tblMFWorkOrderConsumedSKU (
					intWorkOrderId
					,intItemId
					,intLotId
					,intSKUId
					,intContainerId
					,dblQuantity
					,intItemUOMId
					,dblIssuedQuantity
					,intItemIssuedUOMId
					,intBatchId
					,intShiftId
					,dtmCreated
					,intCreatedUserId
					)
				SELECT @intWorkOrderId
					,S.intItemId
					,S.intLotId
					,S.intSKUId
					,S.intContainerId
					,S.dblQty*S.dblWeightPerUnit 
					,L.intWeightUOMId
					,S.dblQty
					,L.intItemUOMId
					,@intBatchId
					,@intBusinessShiftId
					,@dtmCreated
					,@intUserId
				FROM tblWHSKU S
				JOIN tblICLot L on L.intLotId=S.intLotId
				WHERE intSKUId = @intSKUId

				UPDATE dbo.tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intNewSKUId

				PRINT 'Call Delete SKU proc'
				EXEC dbo.uspWHDeleteSKUForWarehouse 
						@intSKUId=@intNewSKUId, 
						@strUserName=@strUserName

				SELECT @dblRequiredWeight = 0
			END

			SELECT @intRecordId = MIN(intRecordId)
			FROM @tblWHSKU
			WHERE intRecordId > @intRecordId
		END
	END

	SELECT @intOwnerId = IO.intOwnerId
	FROM dbo.tblICItemOwner IO
	WHERE intItemId = @intItemId

	IF @ysnSanitizationInboundPutaway = 1
	BEGIN
		IF EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder
				WHERE intInboundOrderHeaderId IS NULL
				)
		BEGIN
			SELECT @intEntityId = E.intEntityId
			FROM dbo.tblEMEntity E
			JOIN dbo.[tblEMEntityType] ET ON E.intEntityId = ET.intEntityId
			WHERE ET.strType = 'Warehouse'
				AND E.strName = 'Production'

			SELECT @intOrderTermsId = intOrderTermsId
			FROM dbo.tblWHOrderTerms
			WHERE ysnDefault = 1

			SELECT @strWorkOrderNo = strWorkOrderNo
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId

			--EXEC dbo.uspSMGetStartingNumber 75
			--	,@strBOLNo OUTPUT
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
							,@intItemId = @intItemId
							,@intManufacturingId = @intManufacturingCellId
							,@intSubLocationId = @intSubLocationId
							,@intLocationId = @intLocationId
							,@intOrderTypeId = 9
							,@intBlendRequirementId = NULL
							,@intPatternCode = 75
							,@ysnProposed = 0
							,@strPatternString = @strBOLNo OUTPUT

			DECLARE @tblWHOrderHeader TABLE (intOrderHeaderId INT)

			SELECT @strXML = '<root>'

			SELECT @strXML += '<intOrderStatusId>8</intOrderStatusId>'

			SELECT @strXML += '<intOrderTypeId>9</intOrderTypeId>'

			SELECT @strXML += '<intOrderDirectionId>1</intOrderDirectionId>'

			SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

			SELECT @strXML += '<strReferenceNo>' + @strWorkOrderNo + '</strReferenceNo>'

			SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCreated) + '</dtmRAD>'

			SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

			SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intStagingLocationId) + '</intStagingLocationId>'

			SELECT @strXML += '<intFreightTermId>' + LTRIM(@intOrderTermsId) + '</intFreightTermId>'

			SELECT @strXML += '<intShipFromAddressId>' + LTRIM(@intEntityId) + '</intShipFromAddressId>'

			SELECT @strXML += '<intShipToAddressId>' + LTRIM(@intLocationId) + '</intShipToAddressId>'

			SELECT @strXML += '<strLastUpdateBy>' + LTRIM(@strUserName) + ' </strLastUpdateBy>'

			SELECT @strXML += '</root>'

			INSERT INTO @tblWHOrderHeader
			EXEC dbo.uspWHCreateOutboundOrder @strXML = @strXML

			SELECT @intOrderHeaderId = intOrderHeaderId
			FROM @tblWHOrderHeader

			UPDATE dbo.tblMFWorkOrder
			SET intInboundOrderHeaderId = @intOrderHeaderId
				,strInboundBOLNo = @strBOLNo
			WHERE intWorkOrderId = @intWorkOrderId

			PRINT 'Call line item insert procedure'
		END
		ELSE
		BEGIN
			PRINT 'Call line item Update procedure'
		END

		IF NOT EXISTS (
				SELECT *
				FROM dbo.tblWHOrderLineItem
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intItemId = @intItemId
					AND strLotAlias = @strLotAlias
				)
		BEGIN
			INSERT INTO tblWHOrderLineItem (
				intOrderHeaderId
				,intItemId
				,dblQty
				,intReceiptQtyUOMId
				,intLastUpdateId
				,dtmLastUpdateOn
				--,intPreferenceId
				,dblRequiredQty
				,intUnitsPerLayer
				,intLayersPerPallet
				,intNoOfBags
				,intLineNo
				,dblPhysicalCount
				,intPhysicalCountUOMId
				,dblWeightPerUnit
				,intWeightPerUnitUOMId
				,dtmProductionDate
				,strLotAlias
				,intConcurrencyId
				)
			SELECT @intOrderHeaderId
				,@intItemId
				,PL.dblPhysicalCount
				,PL.intPhysicalItemUOMId
				,PL.intCreatedUserId
				,PL.dtmCreated
				--,(
				--	SELECT TOP 1 intPickPreferenceId
				--	FROM dbo.tblWHPickPreference
				--	WHERE ysnDefault = 1
				--	)
				,PL.dblPhysicalCount
				,PL.intUnitPerLayer
				,PL.intLayerPerPallet
				,@intNoOfPallet
				,(
					SELECT ISNULL(MAX(LI.intLineNo), 0) + 1
					FROM dbo.tblWHOrderLineItem LI
					WHERE LI.intOrderHeaderId = @intOrderHeaderId
					)
				,PL.dblPhysicalCount
				,PL.intPhysicalItemUOMId
				,PL.dblWeightPerUnit
				,IU.intUnitMeasureId
				,@dtmCreated
				,@strLotAlias
				,1
			FROM dbo.tblMFWorkOrderProducedLot PL
			JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = PL.intItemUOMId
			WHERE PL.intWorkOrderProducedLotId = @intWorkOrderProducedLotId

			SELECT @intOrderLineItemId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE tblWHOrderLineItem
			SET dblQty = dblQty + @dblQty
				,intLastUpdateId = @intUserId
				,dtmLastUpdateOn = @dtmCreated
				,dblRequiredQty = dblRequiredQty + @dblQty
				,intUnitsPerLayer = @intUnitPerLayer
				,intLayersPerPallet = @intLayerPerPallet
				,intNoOfBags = @intNoOfPallet
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intItemId = @intItemId
				AND strLotAlias = @strLotAlias
		END
	END

	SELECT @intCasesPerPallet = @intUnitPerLayer * @intLayerPerPallet

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @intUserId

	WHILE @intNoOfPallet > 0
	BEGIN
		IF @dblQty - @intCasesPerPallet > 0
		BEGIN
			SELECT @SKUQuantity = @intCasesPerPallet
		END
		ELSE
		BEGIN
			SELECT @SKUQuantity = @dblQty
		END

		SELECT @dblQty = @dblQty - @SKUQuantity

		SELECT @intSKUId = NULL

		SELECT @intUnitMeasureId = intUnitMeasureId
		FROM dbo.tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId

		EXEC dbo.uspWHCreateSKUByLot @strUserName = @strUserName
			,@intCompanyLocationSubLocationId = @intLocationId
			,@intDefaultStagingLocationId = @intStagingLocationId
			,@intItemId = @intItemId
			,@dblQty = @SKUQuantity
			,@intLotId = @intOutputLotId
			,@dtmProductionDate = @dtmCreated
			,@intOwnerAddressId = @intOwnerId
			,@ysnStatus = 0
			,@strPalletLotCode = @strOutputLotNumber
			,@ysnUseContainerPattern = 1
			,@intUOMId = @intUnitMeasureId
			,@intUnitPerLayer = @intUnitPerLayer
			,@intLayersPerPallet = @intLayerPerPallet
			,@ysnForced = 1
			,@ysnSanitized = 0
			,@strBatchNo = @intBatchId
			,@intSKUId = @intSKUId OUTPUT

		INSERT INTO dbo.tblMFWorkOrderProducedSKU (
			intWorkOrderId
			,intItemId
			,intLotId
			,intSKUId
			,intContainerId
			,dblQuantity
			,intItemUOMId
			,dblIssuedQuantity
			,intItemIssuedUOMId
			,intBatchId
			,intShiftId
			,dtmCreated
			,intCreatedUserId
			)
		SELECT @intWorkOrderId
			,intItemId
			,intLotId
			,intSKUId
			,intContainerId
			,dblQty * dblWeightPerUnit
			,@intWeightUOMId
			,dblQty
			,@intItemUOMId
			,@intBatchId
			,@intBusinessShiftId
			,@dtmCreated
			,@intUserId
		FROM dbo.tblWHSKU
		WHERE intSKUId = @intSKUId

		IF @ysnSanitizationInboundPutaway = 1
		BEGIN
			INSERT INTO dbo.tblWHOrderManifest (
				intOrderLineItemId
				,intSKUId
				,strManifestItemNote
				,intLastUpdateId
				,dtmLastUpdateOn
				,intConcurrencyId
				,intOrderHeaderId
				)
			SELECT (
					SELECT intOrderLineItemId
					FROM dbo.tblWHOrderLineItem
					WHERE intOrderHeaderId = @intOrderHeaderId
						AND intItemId = @intItemId
						AND strLotAlias = @strLotAlias
					)
				,@intSKUId
				,NULL
				,@intUserId
				,@dtmCreated
				,1
				,@intOrderHeaderId
		END

		SELECT @intNoOfPallet = @intNoOfPallet - 1
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

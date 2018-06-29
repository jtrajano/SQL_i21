CREATE PROCEDURE uspMFConsumeSKU (@intWorkOrderId INT)
AS
BEGIN
	DECLARE @intOrderHeaderId INT
		--,@strBlendProductionStagingLocation NVARCHAR(50)
		--,@intStagingLocationId INT
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
		,@strUserName NVARCHAR(50)
		,@intUserId INT
		,@intLocationId INT
		,@dblWeight NUMERIC(38, 20)
		,@intBusinessShiftId INT
		,@dtmCreated DATETIME
		,@ysnGeneratePickTask BIT
		,@intLotRecordId INT
		,@intLotId INT
		,@dblQuantity NUMERIC(38, 20)
		,@strSKUNo NVARCHAR(50)
		,@intBlendProductionStagingUnitId int

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intBlendProductionStagingUnitId=intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId=@intLocationId

	--SELECT @strBlendProductionStagingLocation = strBlendProductionStagingLocation
	--FROM dbo.tblMFCompanyPreference

	SELECT @strUserName = strUserName
	FROM dbo.tblSMUserSecurity
	WHERE [intEntityId] = @intUserId

	--SELECT @intStagingLocationId = intStorageLocationId
	--FROM dbo.tblICStorageLocation
	--WHERE strName = @strBlendProductionStagingLocation
	--	AND intLocationId = @intLocationId

	DECLARE @tblICLot TABLE (
		intLotRecordId INT IDENTITY(1, 1)
		,intLotId INT
		,dblWeight NUMERIC(38, 20)
		)
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

	INSERT INTO @tblICLot (
		intLotId
		,dblWeight
		)
	SELECT WC.intLotId
		,WC.dblQuantity
	FROM tblMFWorkOrderConsumedLot WC
	JOIN tblICItem I ON I.intItemId = WC.intItemId
	JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
	WHERE intWorkOrderId = @intWorkOrderId
		AND C.ysnWarehouseTracked = 1

	SELECT @intLotRecordId = Min(intLotRecordId)
	FROM @tblICLot

	WHILE @intLotRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL
			,@dblWeight = NULL

		SELECT @intLotId = intLotId
			,@dblWeight = dblWeight
		FROM @tblICLot
		WHERE intLotRecordId = @intLotRecordId

		DELETE
		FROM @tblWHSKU

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
			,S.intUOMId
			,C.intContainerId
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
		WHERE C.intStorageLocationId = @intBlendProductionStagingUnitId
			AND S.dblQty > 0
			AND S.intLotId = @intLotId
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

			SELECT @intSKUId = intSKUId
				,@strSKUNo = strSKUNo
				,@intUOMId = intUOMId
				,@dblWeight = dblWeight
				,@intItemUnitMeasureId = intItemUnitMeasureId
				,@intWeightUnitMeasureId = intWeightUnitMeasureId
				,@dblWeightperUnit = dblWeightperUnit
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
					,NULL
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
					,@dblSplitQty = dblSplitQty
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
					,NULL
					,@intBusinessShiftId
					,@dtmCreated
					,@intUserId
				FROM tblWHSKU S
				JOIN tblICLot L on L.intLotId=S.intLotId
				WHERE intSKUId = @intSKUId

				UPDATE dbo.tblWHSKU
				SET intSKUStatusId = 5
				WHERE intSKUId = @intNewSKUId

				EXEC dbo.uspWHDeleteSKUForWarehouse 
						@intSKUId=@intNewSKUId, 
						@strUserName=@strUserName

				PRINT 'Call Delete SKU proc'

				SELECT @dblRequiredWeight = 0
			END

			SELECT @intRecordId = MIN(intRecordId)
			FROM @tblWHSKU
			WHERE intRecordId > @intRecordId
		END

		SELECT @intLotRecordId = Min(intLotRecordId)
		FROM @tblICLot
		WHERE intLotRecordId > @intLotRecordId
	END
END

CREATE PROCEDURE [dbo].uspMFCreatePickOrder (
	@strXML NVARCHAR(MAX)
	,@intOrderHeaderId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intLocationId INT
		,@intStorageLocationId INT
		,@dtmCurrentDate DATETIME
		,@intOwnerId INT
		,@strBlendProductionStagingLocation NVARCHAR(50)
		,@intOrderTermsId INT
		,@strUserName NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@intEntityId INT
		,@strItemNo NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intLocationId = x.intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intUserId INT
			) x

	SELECT @intOwnerId = IO.intOwnerId
	FROM dbo.tblMFWorkOrderConsumedLot WC
	JOIN dbo.tblICItemOwner IO ON WC.intItemId = IO.intItemId
	WHERE WC.intWorkOrderId IN (
			SELECT x.intWorkOrderId
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
			)

	SELECT @strBlendProductionStagingLocation = strBlendProductionStagingLocation
	FROM dbo.tblMFCompanyPreference

	SELECT @intStorageLocationId = intStorageLocationId
	FROM dbo.tblICStorageLocation
	WHERE strName = @strBlendProductionStagingLocation
		AND intLocationId = @intLocationId

	SELECT @intEntityId = E.intEntityId
	FROM dbo.tblEntity E
	JOIN dbo.tblEntityType ET ON E.intEntityId = ET.intEntityId
	WHERE ET.strType = 'Warehouse'
		AND E.strName = 'Production'

	SELECT @intOrderTermsId = intOrderTermsId
	FROM tblWHOrderTerms
	WHERE ysnDefault = 1

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @intUserId

	EXEC dbo.uspSMGetStartingNumber 75
		,@strBOLNo OUTPUT

	DECLARE @tblWHOrderHeader TABLE (intOrderHeaderId INT)

	IF @intOwnerId IS NULL
	BEGIN
		SELECT @strItemNo = I.strItemNo
		FROM dbo.tblMFWorkOrderConsumedLot WC
		JOIN dbo.tblICItem I ON I.intItemId = WC.intItemId
		WHERE WC.intWorkOrderId IN (
				SELECT x.intWorkOrderId
				FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
				)

		RAISERROR (
				90005
				,14
				,1
				,@strItemNo
				)
	END

	SELECT @strXML = '<root>'

	SELECT @strXML += '<intOrderStatusId>1</intOrderStatusId>'

	SELECT @strXML += '<intOrderTypeId>8</intOrderTypeId>'

	SELECT @strXML += '<intOrderDirectionId>2</intOrderDirectionId>'

	SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

	SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCurrentDate) + '</dtmRAD>'

	SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

	SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intStorageLocationId) + '</intStagingLocationId>'

	SELECT @strXML += '<intFreightTermId>' + LTRIM(@intOrderTermsId) + '</intFreightTermId>'

	SELECT @strXML += '<intShipFromAddressId>' + LTRIM(@intLocationId) + '</intShipFromAddressId>'

	SELECT @strXML += '<intShipToAddressId>' + LTRIM(@intEntityId) + '</intShipToAddressId>'

	SELECT @strXML += '<strLastUpdateBy>' + LTRIM(@strUserName) + ' </strLastUpdateBy>'

	SELECT @strXML += '</root>'

	BEGIN TRANSACTION

	INSERT INTO @tblWHOrderHeader
	EXEC dbo.uspWHCreateOutboundOrder @strXML = @strXML

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblWHOrderHeader

	UPDATE dbo.tblMFWorkOrder
	SET intOrderHeaderId = @intOrderHeaderId
		,strBOLNo = @strBOLNo
	WHERE intWorkOrderId IN (
			SELECT x.intWorkOrderId
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
			)

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
		,intLineNo
		,dblPhysicalCount
		,intPhysicalCountUOMId
		,dblWeightPerUnit
		,intWeightPerUnitUOMId
		,dtmProductionDate
		,strLotAlias
		--,intSanitizationOrderDetailsId
		,intLotId
		,intConcurrencyId
		,ysnIsWeightCertified
		)
	SELECT @intOrderHeaderId
		,CL.intItemId
		,SUM(CL.dblIssuedQuantity)
		,IU1.intUnitMeasureId
		,CL.intCreatedUserId
		,CL.dtmCreated
		--,(
		--	SELECT TOP 1 intPickPreferenceId
		--	FROM dbo.tblWHPickPreference
		--	WHERE ysnDefault = 1
		--	)
		,SUM(CL.dblIssuedQuantity)
		,ISNULL((
				--SELECT MAX(intUnitPerLayer)
				--FROM tblWHSKU S
				--WHERE S.intLotId = CL.intLotId
				NULL
				), I.intUnitPerLayer)
		,ISNULL((
				--SELECT MAX(intLayerPerPallet)
				--FROM tblWHSKU S1
				--WHERE S1.intLotId = CL.intLotId
				NULL
				), I.intLayerPerPallet)
		,intSequenceNo
		,SUM(CL.dblIssuedQuantity)
		,IU1.intUnitMeasureId
		,L.dblWeightPerQty
		,IU.intUnitMeasureId
		,@dtmCurrentDate
		,L.strLotAlias
		--,CL.intWorkOrderInputLotId
		,L.intLotId
		,1
		,1
	FROM dbo.tblMFWorkOrderConsumedLot CL
	JOIN dbo.tblICLot L ON L.intLotId = CL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = CL.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = CL.intItemUOMId
	JOIN dbo.tblICItemUOM IU1 ON IU1.intItemUOMId = CL.intItemIssuedUOMId
	WHERE CL.intWorkOrderId IN (
			SELECT x.intWorkOrderId
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
			)
	GROUP BY CL.intItemId
		,IU1.intUnitMeasureId
		,CL.intCreatedUserId
		,CL.dtmCreated
		--,(
		--	SELECT TOP 1 intPickPreferenceId
		--	FROM dbo.tblWHPickPreference
		--	WHERE ysnDefault = 1
		--	)
		,ISNULL((
				--SELECT MAX(intUnitPerLayer)
				--FROM tblWHSKU S
				--WHERE S.intLotId = CL.intLotId
				NULL
				), I.intUnitPerLayer)
		,ISNULL((
				--SELECT MAX(intLayerPerPallet)
				--FROM tblWHSKU S1
				--WHERE S1.intLotId = CL.intLotId
				NULL
				), I.intLayerPerPallet)
		,intSequenceNo
		,IU1.intUnitMeasureId
		,L.dblWeightPerQty
		,IU.intUnitMeasureId
		,L.strLotAlias
		--,CL.intWorkOrderInputLotId
		,L.intLotId
		

	COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO



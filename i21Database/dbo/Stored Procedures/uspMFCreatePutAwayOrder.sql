CREATE PROCEDURE [dbo].uspMFCreatePutAwayOrder (
	@strXML NVARCHAR(MAX)
	,@intOrderHeaderId INT OUTPUT
	)
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@intLocationId INT
		--,@intStorageLocationId INT
		,@dtmCurrentDate DATETIME
		,@intOwnerId INT
		--,@strBlendProductionStagingLocation NVARCHAR(50)
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

	SELECT @intOwnerId = S.intOwnerId
	FROM dbo.tblWHSKU S
	JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
	WHERE C.intContainerId IN (
			SELECT x.intContainerId
			FROM OPENXML(@idoc, 'root/Containers/Container', 2) WITH (intContainerId INT) x
			)

	--SELECT @strBlendProductionStagingLocation = strBlendProductionStagingLocation
	--FROM dbo.tblMFCompanyPreference

	--SELECT @intStorageLocationId = intStorageLocationId
	--FROM dbo.tblICStorageLocation
	--WHERE strName = @strBlendProductionStagingLocation
	--	AND intLocationId = @intLocationId

	DECLARE @intBlendProductionStagingUnitId INT

	SELECT @intBlendProductionStagingUnitId=intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId=@intLocationId

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
		FROM dbo.tblWHSKU S
		JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
		JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
		WHERE C.intContainerId IN (
				SELECT x.intContainerId
				FROM OPENXML(@idoc, 'root/Containers/Container', 2) WITH (intContainerId INT) x
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

	SELECT @strXML += '<intOrderTypeId>7</intOrderTypeId>'

	SELECT @strXML += '<intOrderDirectionId>1</intOrderDirectionId>'

	SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

	SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCurrentDate) + '</dtmRAD>'

	SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

	SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intBlendProductionStagingUnitId) + '</intStagingLocationId>'

	SELECT @strXML += '<intFreightTermId>' + LTRIM(@intOrderTermsId) + '</intFreightTermId>'

	SELECT @strXML += '<intShipFromAddressId>' + LTRIM(@intEntityId) + '</intShipFromAddressId>'

	SELECT @strXML += '<intShipToAddressId>' + LTRIM(@intLocationId) + '</intShipToAddressId>'

	SELECT @strXML += '<strLastUpdateBy>' + LTRIM(@strUserName) + ' </strLastUpdateBy>'

	SELECT @strXML += '</root>'

	BEGIN TRANSACTION

	INSERT INTO @tblWHOrderHeader
	EXEC dbo.uspWHCreateOutboundOrder @strXML = @strXML

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblWHOrderHeader

	INSERT INTO dbo.tblWHContainerInboundOrder (
		intContainerId
		,intOrderHeaderId
		)
	SELECT x.intContainerId
		,@intOrderHeaderId
	FROM OPENXML(@idoc, 'root/Containers/Container', 2) WITH (intContainerId INT) x

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
		,I.intItemId
		,SUM(S.dblQty)
		,S.intUOMId
		,@intUserId
		,@dtmCurrentDate
		,SUM(S.dblQty)
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
		,0
		,SUM(S.dblQty)
		,S.intUOMId
		,S.dblWeightPerUnit
		,IU.intUnitMeasureId
		,@dtmCurrentDate
		,S.strLotCode
		--,CL.intWorkOrderInputLotId
		,S.intLotId
		,1
		,1
	FROM dbo.tblWHSKU S
	JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	WHERE S.intContainerId IN (
			SELECT x.intContainerId
			FROM OPENXML(@idoc, 'root/Containers/Container', 2) WITH (intContainerId INT) x
			)
	GROUP BY I.intItemId
		,S.intUOMId
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
		,IU.intUnitMeasureId
		,S.dblWeightPerUnit
		,IU.intUnitMeasureId
		,S.strLotCode
		--,CL.intWorkOrderInputLotId
		,S.intLotId

	INSERT INTO dbo.tblWHOrderManifest (
		intConcurrencyId
		,intOrderLineItemId
		,intOrderHeaderId
		,strManifestItemNote
		,intSKUId
		,intLotId
		,strSSCCNo
		,intLastUpdateId
		,dtmLastUpdateOn
		)
	SELECT 1
		,(
			SELECT TOP 1 LI.intOrderLineItemId
			FROM dbo.tblWHOrderLineItem LI
			WHERE LI.intLotId = S.intLotId
				AND LI.intOrderHeaderId = @intOrderHeaderId
			)
		,@intOrderHeaderId
		,''
		,S.intSKUId
		,S.intLotId
		,''
		,@intUserId
		,@dtmCurrentDate
	FROM dbo.tblWHSKU S
	WHERE S.intContainerId IN (
			SELECT x.intContainerId
			FROM OPENXML(@idoc, 'root/Containers/Container', 2) WITH (intContainerId INT) x
			)


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




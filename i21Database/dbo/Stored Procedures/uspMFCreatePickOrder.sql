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
		,@dtmCurrentDate DATETIME
		,@intOwnerId INT
		,@strBlendProductionStagingLocation NVARCHAR(50)
		,@intOrderTermsId INT
		,@strUserName NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@intEntityId INT
		,@strItemNo NVARCHAR(50)
		,@intBlendProductionStagingUnitId INT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intManufacturingProcessId INT
		,@intDayOfYear INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDate)

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = x.intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingProcessId INT
			,intLocationId INT
			,intUserId INT
			) x

	DECLARE @tblMFWorkOrder TABLE (
		intWorkOrderId INT
		,intItemId INT
		,dblPlannedQty NUMERIC(18, 6)
		,dtmPlannedDate DATETIME
		,intPlannedShift INT
		)

	INSERT INTO @tblMFWorkOrder (
		intWorkOrderId
		,intItemId
		,dblPlannedQty
		,dtmPlannedDate
		,intPlannedShift
		)
	SELECT x.intWorkOrderId
		,x.intItemId
		,x.dblPlannedQty
		,x.dtmPlannedDate
		,x.intPlannedShift
	FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (
			intWorkOrderId INT
			,intItemId INT
			,dblPlannedQty NUMERIC(18, 6)
			,dtmPlannedDate DATETIME
			,intPlannedShift INT
			) x

	DECLARE @tblMFWorkOrderFinal TABLE (
		intItemId INT
		,dblPlannedQty NUMERIC(18, 6)
		)

	INSERT INTO @tblMFWorkOrderFinal (
		intItemId
		,dblPlannedQty
		)
	SELECT intItemId
		,SUM(dblPlannedQty)
	FROM @tblMFWorkOrder
	GROUP BY intItemId

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intPackagingCategoryId

	SELECT @intOwnerId = IO.intOwnerId
	FROM dbo.tblMFWorkOrderConsumedLot WC
	JOIN dbo.tblICItemOwner IO ON WC.intItemId = IO.intItemId
	WHERE WC.intWorkOrderId IN (
			SELECT x.intWorkOrderId
			FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
			)

	IF @intOwnerId IS NULL
	BEGIN
		SELECT @intOwnerId = IO.intOwnerId
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFRecipe I ON I.intItemId = W.intItemId
			AND I.intLocationId = @intLocationId
		JOIN dbo.tblMFRecipeItem RI ON RI.intRecipeId = I.intRecipeId
		JOIN dbo.tblICItemOwner IO ON RI.intItemId = IO.intItemId
		WHERE W.intWorkOrderId IN (
				SELECT x.intWorkOrderId
				FROM OPENXML(@idoc, 'root/WorkOrders/WorkOrder', 2) WITH (intWorkOrderId INT) x
				)
	END

	SELECT @intBlendProductionStagingUnitId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

	SELECT @intEntityId = E.intEntityId
	FROM dbo.tblEMEntity E
	JOIN dbo.[tblEMEntityType] ET ON E.intEntityId = ET.intEntityId
	WHERE ET.strType = 'Customer'
		AND E.strName = 'Production'

	SELECT @intOrderTermsId = intOrderTermsId
	FROM tblWHOrderTerms
	WHERE ysnDefault = 1

	SELECT @strUserName = strUserName
	FROM tblSMUserSecurity
	WHERE intEntityUserSecurityId = @intUserId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
		,@intItemId = NULL
		,@intManufacturingId = NULL
		,@intSubLocationId = NULL
		,@intLocationId = @intLocationId
		,@intOrderTypeId = 6
		,@intBlendRequirementId = NULL
		,@intPatternCode = 75
		,@ysnProposed = 0
		,@strPatternString = @strBOLNo OUTPUT

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

	SELECT @strXML += '<intOrderTypeId>6</intOrderTypeId>'

	SELECT @strXML += '<intOrderDirectionId>2</intOrderDirectionId>'

	SELECT @strXML += '<strBOLNo>' + @strBOLNo + '</strBOLNo>'

	SELECT @strXML += '<dtmRAD>' + LTRIM(@dtmCurrentDate) + '</dtmRAD>'

	SELECT @strXML += '<intOwnerAddressId>' + LTRIM(@intOwnerId) + '</intOwnerAddressId>'

	SELECT @strXML += '<intStagingLocationId>' + LTRIM(@intBlendProductionStagingUnitId) + '</intStagingLocationId>'

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

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrder W
			JOIN @tblMFWorkOrder W1 ON W.intWorkOrderId = W1.intWorkOrderId
			WHERE intTransactionFrom = 1
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
			,@dtmCurrentDate
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
			--,CL.dtmCreated
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
	END
	ELSE
	BEGIN
		INSERT INTO tblWHOrderLineItem (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intReceiptQtyUOMId
			,intLastUpdateId
			,dtmLastUpdateOn
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
			,intLotId
			,intConcurrencyId
			,ysnIsWeightCertified
			)
		SELECT @intOrderHeaderId
			,ri.intItemId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,IU.intUnitMeasureId
			,@intUserId
			,@dtmCurrentDate
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,ISNULL(NULL, I.intUnitPerLayer)
			,ISNULL(NULL, I.intLayerPerPallet)
			,ROW_NUMBER() OVER (
				ORDER BY ri.intItemId
				)
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,IU.intUnitMeasureId
			,1
			,IU.intUnitMeasureId
			,@dtmCurrentDate
			,NULL
			,NULL
			,1
			,1
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem I ON I.intItemId = ri.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ri.intItemUOMId
		JOIN dbo.tblICCategory C ON I.intCategoryId = C.intCategoryId
		JOIN dbo.tblICItem P ON r.intItemId = P.intItemId
		JOIN @tblMFWorkOrderFinal W ON W.intItemId = r.intItemId
		WHERE ri.intRecipeItemTypeId = 1
			AND (
				(
					ri.ysnYearValidationRequired = 1
					AND @dtmCurrentDate BETWEEN ri.dtmValidFrom
						AND ri.dtmValidTo
					)
				OR (
					ri.ysnYearValidationRequired = 0
					AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom)
						AND DATEPART(dy, ri.dtmValidTo)
					)
				)
	END

	INSERT INTO tblMFStageWorkOrder (
		intWorkOrderId
		,dtmPlannedDate
		,intPlannnedShiftId
		,intOrderHeaderId
		,intConcurrencyId
		,dtmCreated
		,intCreatedUserId
		,dtmLastModified
		,intLastModifiedUserId
		)
	SELECT intWorkOrderId
		,dtmPlannedDate
		,intPlannedShift
		,@intOrderHeaderId
		,0
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
	FROM @tblMFWorkOrder

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



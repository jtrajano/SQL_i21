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
		,@intStageLocationTypeId int
		,@strStageLocationType nvarchar(50)
		,@intProductionStagingId int
		,@intProductionStageLocationId int
		,@intStagingId int
		,@intStageLocationId int


	SELECT @dtmCurrentDate = GetDate()

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDate)
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML
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

	SELECT @intBlendProductionStagingUnitId = intBlendProductionStagingUnitId
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intLocationId

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

	DECLARE @tblMFOrderHeader TABLE (intOrderHeaderId INT)

	SELECT @intStageLocationTypeId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Staging Location Type'

	SELECT @strStageLocationType = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intStageLocationTypeId

	SELECT @intProductionStagingId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Production Staging Location'

	SELECT @intProductionStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intProductionStagingId

	SELECT @intStagingId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Production Staging Location'

	SELECT @intStageLocationId = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = @intStagingId

	BEGIN TRANSACTION

	DECLARE @OrderHeaderInformation AS OrderHeaderInformation

	INSERT INTO @OrderHeaderInformation (
		intOrderStatusId
		,intOrderTypeId
		,intOrderDirectionId
		,strOrderNo
		,strReferenceNo
		,intStagingLocationId
		,strComment
		,dtmOrderDate
		,strLastUpdateBy
		)
	SELECT 1
		,1
		,2
		,@strBOLNo
		,''
		,Case When @strStageLocationType='Alternate Staging Location' Then NULL
				When @strStageLocationType='Production Staging Location' Then @intProductionStageLocationId
				Else @intStageLocationId End
		,''
		,@dtmCurrentDate
		,@strUserName
		
	INSERT INTO @tblMFOrderHeader
	EXEC dbo.uspMFCreateStagingOrder @OrderHeaderInformation = @OrderHeaderInformation

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblMFOrderHeader

	DECLARE @OrderDetailInformation AS OrderDetailInformation

	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrder W
			JOIN @tblMFWorkOrder W1 ON W.intWorkOrderId = W1.intWorkOrderId
			WHERE intTransactionFrom = 1
			)
	BEGIN
		INSERT INTO @OrderDetailInformation (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,intLotId
			,strLotAlias
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,dtmProductionDate
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
		SELECT @intOrderHeaderId
			,CL.intItemId
			,SUm(L.dblQty)
			,L.intItemUOMId
			,SUm(L.dblWeight)
			,L.intWeightUOMId
			,L.dblWeightPerQty
			,L.intLotId
			,L.strLotAlias
			,I.intUnitPerLayer
			,intLayerPerPallet
			,(
				SELECT TOP 1 intPickListPreferenceId
				FROM tblMFPickListPreference
				)
			,L.dtmDateCreated
			,Row_Number() OVER (
				ORDER BY CL.intItemId
				)
			,NULL
			,''
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
			,L.intItemUOMId
			,L.intWeightUOMId
			,L.dblWeightPerQty
			,L.intLotId
			,L.strLotAlias
			,I.intUnitPerLayer
			,intLayerPerPallet
			,L.dtmDateCreated
	END
	ELSE
	BEGIN
		INSERT INTO @OrderDetailInformation (
			intOrderHeaderId
			,intItemId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dblWeightPerUnit
			,intUnitsPerLayer
			,intLayersPerPallet
			,intPreferenceId
			,intLineNo
			,intSanitizationOrderDetailsId
			,strLineItemNote
			)
		SELECT @intOrderHeaderId
			,ri.intItemId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,ri.intItemUOMId
			,CASE 
				WHEN C.strCategoryCode = @strPackagingCategory
					THEN CAST(CEILING((ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))) AS NUMERIC(38, 20))
				ELSE (ri.dblCalculatedQuantity * (W.dblPlannedQty / r.dblQuantity))
				END
			,ri.intItemUOMId
			,IU.dblUnitQty
			,ISNULL(NULL, I.intUnitPerLayer)
			,ISNULL(NULL, I.intLayerPerPallet)
			,(
				SELECT TOP 1 intPickListPreferenceId
				FROM tblMFPickListPreference
				)
			,Row_Number() OVER (
				ORDER BY ri.intRecipeItemId
				)
			,NULL
			,''
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

	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation =@OrderDetailInformation

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



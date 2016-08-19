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
		,@dtmCurrentDate DATETIME
		,@strUserName NVARCHAR(50)
		,@strOrderNo nvarchar(50) 

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @dtmCurrentDate = GetDate()

	SELECT @intLocationId = x.intLocationId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intUserId INT
			) x

	DECLARE @intBlendProductionStagingUnitId INT

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
		,@intOrderTypeId = 7
		,@intBlendRequirementId = NULL
		,@intPatternCode = 75
		,@ysnProposed = 0
		,@strPatternString = @strOrderNo OUTPUT

	BEGIN TRANSACTION

	DECLARE @OrderHeaderInformation AS OrderHeaderInformation
	DECLARE @tblMFOrderHeader TABLE (intOrderHeaderId INT)

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
		,2
		,1
		,@strOrderNo
		,''
		,@intBlendProductionStagingUnitId
		,''
		,@dtmCurrentDate
		,@strUserName

	INSERT INTO @tblMFOrderHeader
	EXEC dbo.uspMFCreateStagingOrder @OrderHeaderInformation = @OrderHeaderInformation

	SELECT @intOrderHeaderId = intOrderHeaderId
	FROM @tblMFOrderHeader

	DECLARE @OrderDetailInformation AS OrderDetailInformation

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
		,strLastUpdateBy
		)
	SELECT @intOrderHeaderId
		,L.intItemId
		,SUm(L.dblQty)
		,L.intItemUOMId
		,SUm(L.dblWeight)
		,L.intWeightUOMId
		,L.dblWeightPerQty
		,L.intLotId
		,L.strLotAlias
		,I.intUnitPerLayer
		,I.intLayerPerPallet
		,(
			SELECT TOP 1 intPickListPreferenceId
			FROM tblMFPickListPreference
			)
		,L.dtmDateCreated
		,Row_Number() OVER (
			ORDER BY L.intItemId
			)
		,NULL
		,''
		,@strUserName
	FROM dbo.tblICLot L
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	WHERE L.intLotId IN (
			SELECT x.intLotId
			FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (intLotId INT) x
			)
	GROUP BY L.intItemId
		,L.intItemUOMId
		,L.intWeightUOMId
		,L.dblWeightPerQty
		,L.intLotId
		,L.strLotAlias
		,I.intUnitPerLayer
		,I.intLayerPerPallet
		,L.dtmDateCreated

	EXEC dbo.uspMFCreateStagingOrderDetail @OrderDetailInformation =@OrderDetailInformation

	INSERT INTO dbo.tblMFOrderManifest (
		intConcurrencyId
		,intOrderDetailId
		,intOrderHeaderId
		,intLotId
		,strManifestItemNote
		,intLastUpdateId
		,dtmLastUpdateOn
		)
	SELECT 1
		,(
			SELECT TOP 1 OD.intOrderDetailId
			FROM dbo.tblMFOrderDetail OD
			WHERE OD.intLotId = L.intLotId
				AND OD.intOrderHeaderId = @intOrderHeaderId
			)
		,@intOrderHeaderId
		,L.intLotId
		,''
		,@intUserId
		,@dtmCurrentDate
	FROM dbo.tblICLot L
	WHERE L.intLotId IN (
			SELECT x.intLotId
			FROM OPENXML(@idoc, 'root/Lots/Lot', 2) WITH (intLotId INT) x
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



CREATE PROCEDURE [dbo].[uspMFCreateRequirement] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@dblQuantity NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intUserId INT
		,@intLocationId INT
		,@intSubLocationId INT
		,@dtmExpectedDate DATETIME
		,@intCategoryId INT
		,@strDemandNo NVARCHAR(50)
		,@intUnitMeasureId INT
		,@dtmCurrentDate DATETIME
		,@intWorkOrderId INT
		,@intBlendRequirementId INT

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intItemId = intItemId
		,@dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dtmExpectedDate = dtmExpectedDate
		,@intUserId = intUserId
		,@intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intWorkOrderId = intWorkOrderId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intItemId INT
			,dblQuantity NUMERIC(18, 6)
			,intItemUOMId INT
			,dtmExpectedDate DATETIME
			,intUserId INT
			,intLocationId INT
			,intSubLocationId INT
			,intWorkOrderId INT
			)

	SELECT @intCategoryId = intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @intUnitMeasureId = intUnitMeasureId
	FROM tblICItemUOM
	WHERE intItemUOMId = @intItemUOMId

	EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = NULL
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 46
		,@ysnProposed = 0
		,@strPatternString = @strDemandNo OUTPUT

	INSERT INTO tblMFBlendRequirement (
		strDemandNo
		,intItemId
		,dblQuantity
		,intUOMId
		,dtmDueDate
		,intLocationId
		,intStatusId
		,dblIssuedQty
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	VALUES (
		@strDemandNo
		,@intItemId
		,@dblQuantity
		,@intUnitMeasureId
		,@dtmExpectedDate
		,@intLocationId
		,2
		,@dblQuantity
		,@intUserId
		,@dtmCurrentDate
		,@intUserId
		,@dtmCurrentDate
		)

	SELECT @intBlendRequirementId = SCOPE_IDENTITY()

	UPDATE tblMFWorkOrder
	SET intBlendRequirementId = @intBlendRequirementId
	WHERE intWorkOrderId = @intWorkOrderId

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH


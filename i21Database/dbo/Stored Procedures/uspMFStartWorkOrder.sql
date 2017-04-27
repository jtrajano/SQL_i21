CREATE PROCEDURE [dbo].[uspMFStartWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intUserId INT
		,@dtmCurrentDate DATETIME
		,@intItemId INT
		,@intLocationId INT
		,@strItemNo NVARCHAR(MAX)
		,@intScheduleId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@intSampleStatusId INT
		,@strCellName NVARCHAR(50)
		,@dtmSampleCreated DATETIME
		,@strWIPSampleMandatory NVARCHAR(50)
		,@intDurationBetweenLineSample INT
		,@dtmStartedDate DATETIME
		,@intControlPointId INT
		,@intSampleTypeId INT
		,@intManufacturingCellId INT
		,@intManufacturingProcessId INT
		,@strSampleTypeName NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	SELECT @dtmCurrentDate = GETDATE()

	SELECT @intItemId = intItemId
		,@intLocationId = intLocationId
		,@strWorkOrderNo = strWorkOrderNo
		,@intManufacturingCellId = intManufacturingCellId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF NOT EXISTS (
			SELECT *
			FROM tblICItem
			WHERE intItemId = @intItemId
				AND strStatus = 'Active'
			)
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				'The target item %s is Phased out or Discontinued, cannot start the work order.'
				,11
				,1
				,@strItemNo
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblMFRecipe
			WHERE intItemId = @intItemId
				AND intLocationId = @intLocationId
				AND ysnActive = 1
			)
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				'There is no active recipe found for item  %s Cannot proceed'
				,11
				,1
				,@strItemNo
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE W.intWorkOrderId = @intWorkOrderId
				AND EXISTS (
					SELECT *
					FROM dbo.tblICItemUOM IU
					WHERE IU.intItemUOMId = W.intItemUOMId
					)
			)
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				'The UOM used in the work order %s is not added for the item %s in item maintenance.'
				,11
				,1
				,@strWorkOrderNo
				,@strItemNo
				)
	END

	SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
		,@dtmSampleCreated = S.dtmCreated
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	WHERE S.intProductTypeId = 12
		AND S.intProductValueId = @intWorkOrderId
		AND ST.intControlPointId = 11 --Line Sample
	ORDER BY S.dtmLastModified DESC

	IF @intSampleStatusId = 4
	BEGIN
		SELECT @strCellName = strCellName
		FROM tblMFManufacturingCell
		WHERE intManufacturingCellId = @intManufacturingCellId

		RAISERROR (
				'%s has failed the quality test. Cannot proceed further.'
				,11
				,1
				,@strCellName
				)
	END

	SELECT @intSampleStatusId = NULL
		,@dtmSampleCreated = NULL

	SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
		,@dtmSampleCreated = S.dtmCreated
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	WHERE S.intProductTypeId = 12
		AND S.intProductValueId = @intWorkOrderId
		AND ST.intControlPointId = 12 --WIP Sample
	ORDER BY S.dtmLastModified DESC

	IF @intSampleStatusId = 4
	BEGIN
		SELECT @strCellName = strCellName
		FROM tblMFManufacturingCell
		WHERE intManufacturingCellId = @intManufacturingCellId

		RAISERROR (
				'%s has failed the quality test. Cannot proceed further.'
				,11
				,1
				,@strCellName
				)
	END

	SELECT @strWIPSampleMandatory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 84

	IF @strWIPSampleMandatory = 'True'
	BEGIN
		SELECT @intSampleStatusId = NULL
			,@dtmSampleCreated = NULL

		DECLARE @strSampleTypeId NVARCHAR(MAX)

		SELECT @strSampleTypeId = strAttributeValue
		FROM tblMFManufacturingProcessAttribute
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND intAttributeId = 96

		SELECT @intSampleTypeId = Item Collate Latin1_General_CI_AS
		FROM [dbo].[fnSplitString](@strSampleTypeId, ',') ST1
		WHERE NOT EXISTS (
				SELECT 1
				FROM tblQMSample S
				JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.intProductTypeId = 12
					AND S.intProductValueId = @intWorkOrderId
					AND ST.intControlPointId = 11 --Line Sample
					AND ST.intSampleTypeId = ST1.Item Collate Latin1_General_CI_AS
				)

		IF @intSampleTypeId IS NOT NULL
		BEGIN
			SELECT @strSampleTypeName = strSampleTypeName
			FROM tblQMSampleType
			WHERE intSampleTypeId = @intSampleTypeId

			SELECT @strCellName = strCellName
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

			RAISERROR (
					'%s is not taken for the line %s. Please take the sample and then start the work order'
					,11
					,1
					,@strSampleTypeName
					,@strCellName
					)
		END

		SELECT @intSampleStatusId = NULL
			,@dtmSampleCreated = NULL

		SELECT TOP 1 @intSampleStatusId = S.intSampleStatusId
			,@dtmSampleCreated = S.dtmCreated
		FROM tblQMSample S
		JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		WHERE S.intProductTypeId = 12
			AND S.intProductValueId = @intWorkOrderId
			AND ST.intControlPointId = 12 --WIP Sample
		ORDER BY S.dtmLastModified DESC

		IF @intSampleStatusId IS NULL
		BEGIN
			SELECT @strSampleTypeName = strSampleTypeName
			FROM tblQMSampleType
			WHERE intControlPointId = 12 --WIP Sample

			SELECT @strCellName = strCellName
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intManufacturingCellId

			RAISERROR (
					'%s is not taken for the line %s. Please take the sample and then start the work order'
					,11
					,1
					,@strSampleTypeName
					,@strCellName
					)
		END
	END

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 10
		,dtmStartedDate = @dtmCurrentDate
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFScheduleWorkOrder
	SET intStatusId = 10
		,intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intScheduleId = W.intScheduleId
	FROM dbo.tblMFScheduleWorkOrder W
	JOIN dbo.tblMFSchedule S ON S.intScheduleId = W.intScheduleId
		AND ysnStandard = 1
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFSchedule
	SET intConcurrencyId = intConcurrencyId + 1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intScheduleId = @intScheduleId

	EXEC dbo.uspMFCopyRecipe @intItemId = @intItemId
		,@intLocationId = @intLocationId
		,@intUserId = @intUserId
		,@intWorkOrderId = @intWorkOrderId

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
GO



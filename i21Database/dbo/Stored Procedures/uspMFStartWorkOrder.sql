﻿CREATE PROCEDURE [dbo].[uspMFStartWorkOrder] (@strXML NVARCHAR(MAX))
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
		,@intScheduleId int
		,@strWorkOrderNo nvarchar(50)

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
		,@strWorkOrderNo=strWorkOrderNo 
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF NOT EXISTS (
			SELECT *
			FROM tblICItem
			WHERE intItemId = @intItemId
				AND strStatus  = 'Active'
			)
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				51152
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
				51147
				,11
				,1
				,@strItemNo
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			WHERE W.intWorkOrderId = @intWorkOrderId
				AND EXISTS(SELECT *FROM dbo.tblICItemUOM IU WHERE IU.intItemUOMId =W.intItemUOMId)
			)
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		RAISERROR (
				90006
				,11
				,1
				,@strWorkOrderNo
				,@strItemNo
				)
	END

	UPDATE dbo.tblMFWorkOrder
	SET intStatusId = 10
		,dtmStartedDate = @dtmCurrentDate
		,intConcurrencyId=intConcurrencyId+1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFScheduleWorkOrder
	SET intStatusId = 10
		,intConcurrencyId=intConcurrencyId+1
		,dtmLastModified = @dtmCurrentDate
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intScheduleId=W.intScheduleId 
	FROM dbo.tblMFScheduleWorkOrder W 
	JOIN dbo.tblMFSchedule S ON S.intScheduleId =W.intScheduleId  AND ysnStandard =1
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFSchedule 
	SET intConcurrencyId=intConcurrencyId+1
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



CREATE PROCEDURE [dbo].uspMFStartCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLocationId INT
		,@intSubLocationId INT
		,@intWorkOrderId INT
		,@intManufacturingProcessId INT
		,@dtmPlannedDate DATETIME
		,@intItemId INT
		,@intUserId INT
		,@intCycleCountSessionId INT
		,@ysnIncludeOutputItem bit
		,@strExcludeItemType nvarchar(MAX)
		,@strWorkOrderNo nvarchar(MAX)
		,@dtmCurrentDate datetime
		,@dtmCurrentDateTime datetime
		,@intDayOfYear int
		,@TRANCOUNT int

	Select @TRANCOUNT			=@@TRANCOUNT
	
	Select @dtmCurrentDateTime	=GETDATE()
	Select @dtmCurrentDate		=CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	Select @intDayOfYear		=DATEPART(dy,@dtmCurrentDateTime)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intUserId = intUserId
		,@intWorkOrderId = intWorkOrderId
		,@ysnIncludeOutputItem=ysnIncludeOutputItem
		,@strExcludeItemType=strExcludeItemType
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intLocationId INT
			,intSubLocationId INT
			,intUserId INT
			,intWorkOrderId INT
			,ysnIncludeOutputItem bit
			,strExcludeItemType nvarchar(MAX)
			)

	DECLARE @intUserSecurityID INT
		,@dtmSessionStartDateTime DATETIME
		,@strSessionStartDateTime NVARCHAR(50)
		,@dtmShiftStartTime DATETIME
		,@dtmPlannedDateTime DATETIME
		,@intPlannedShiftId INT
		,@intStartOffset INT
		,@strUserName NVARCHAR(50)
		,@intPriorWorkOrderId INT
		,@strProductItem NVARCHAR(50)
		,@strInputItem NVARCHAR(50)
		,@strPlannedDate NVARCHAR(50)

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder
			WHERE intWorkOrderId = @intWorkOrderId
				AND intCountStatusId = 13
			)
	BEGIN
		RAISERROR (
				51108
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intWorkOrderId
			)
	BEGIN
		SELECT @intUserSecurityID = intUserId
			,@strSessionStartDateTime = dtmSessionStartDateTime
		FROM dbo.tblMFProcessCycleCountSession
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strUserName = strUserName
		FROM dbo.tblSMUserSecurity
		WHERE intUserSecurityID = @intUserSecurityID

		RAISERROR (
				51109
				,11
				,1
				,@strSessionStartDateTime
				,@strUserName
				)
	END

	SELECT @dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@dtmPlannedDateTime = (
			CASE 
				WHEN intPlannedShiftId IS NOT NULL
					THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
				ELSE dtmPlannedDate
				END
			)
		,@intItemId = intItemId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intWorkOrderId = @intWorkOrderId

	IF @dtmPlannedDateTime > @dtmCurrentDateTime
	BEGIN
		RAISERROR (
				51102
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFManufacturingProcessMachine PM
			JOIN dbo.tblMFMachine M ON M.intMachineId = PM.intMachineId
			WHERE PM.intManufacturingProcessId = @intManufacturingProcessId
				AND M.ysnCycleCounted = 1
			)
	BEGIN
		RAISERROR (
				51103
				,11
				,1
				)
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFRecipeItem ri
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			WHERE r.ysnActive = 1
				AND r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND ri.intRecipeItemTypeId = 1
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
			)
	BEGIN
		RAISERROR (
				51104
				,11
				,1
				)
	END

	SELECT TOP 1 @intPriorWorkOrderId = intWorkOrderId
	FROM dbo.tblMFWorkOrder W
	LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
	WHERE intItemId = @intItemId
		AND intManufacturingProcessId = @intManufacturingProcessId
		AND intStatusId<>13
		AND (
			CASE 
				WHEN intPlannedShiftId IS NOT NULL
					THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
				ELSE dtmPlannedDate
				END
			) < @dtmPlannedDateTime
		AND intWorkOrderId <> @intWorkOrderId
	ORDER BY CASE 
			WHEN intPlannedShiftId IS NOT NULL
				THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
			ELSE dtmPlannedDate
			END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFProcessCycleCountSession
			WHERE intWorkOrderId = @intPriorWorkOrderId
			)
		AND @intPriorWorkOrderId IS NOT NULL
	BEGIN
		RAISERROR (
				51105
				,11
				,1
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
			JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
			JOIN dbo.tblMFRecipeItem ri ON ri.intItemId = CC.intItemId
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			WHERE r.ysnActive = 1
				AND r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND ri.intRecipeItemTypeId = 1
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
				AND intCountStatusId <> 13
				AND intStatusId<>13
			)
	BEGIN
		SELECT TOP 1 @strWorkOrderNo=strWorkOrderNo
			,@strProductItem = Product.strItemNo + ' - ' + Product.strDescription
			,@strInputItem = Input.strItemNo + ' - ' + Input.strDescription
			,@strPlannedDate = ltrim(W.dtmPlannedDate) + (
				CASE 
					WHEN W.intPlannedShiftId IS NULL
						THEN ''
					ELSE ' - ' + S.strShiftName
					END
				)
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
		JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
		JOIN dbo.tblMFRecipeItem ri ON ri.intItemId = CC.intItemId
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem Product ON Product.intItemId = W.intItemId
		JOIN dbo.tblICItem Input ON Input.intItemId = ri.intItemId
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
		WHERE r.ysnActive = 1
			AND r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND ri.intRecipeItemTypeId = 1
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
			AND intCountStatusId <> 13
			AND intStatusId<>13
		ORDER BY W.dtmPlannedDate DESC
			,W.intPlannedShiftId DESC

		RAISERROR (
				51106
				,11
				,1
				,@strInputItem
				,@strWorkOrderNo
				,@strPlannedDate
				,@strProductItem
				)
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblMFWorkOrder W
			LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
			JOIN dbo.tblMFRecipe Product ON Product.intItemId = W.intItemId
			JOIN dbo.tblMFRecipeItem ProductItem ON ProductItem.intRecipeId = Product.intRecipeId
			JOIN dbo.tblMFRecipeItem ri ON ri.intItemId = ProductItem.intItemId
			JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
			WHERE r.ysnActive = 1
				AND r.intItemId = @intItemId
				AND r.intLocationId = @intLocationId
				AND ri.intRecipeItemTypeId = 1
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
				AND intCountStatusId <> 13
				AND intStatusId<>13
				AND (
					CASE 
						WHEN intPlannedShiftId IS NOT NULL
							THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
						ELSE dtmPlannedDate
						END
					) < @dtmPlannedDateTime
				AND W.intWorkOrderId <> @intWorkOrderId
			)
	BEGIN
		SELECT TOP 1 @strProductItem = Product.strItemNo + ' - ' + Product.strDescription
			,@strInputItem = Input.strItemNo + ' - ' + Input.strDescription
			,@strPlannedDate = ltrim(W.dtmPlannedDate) + (
				CASE 
					WHEN W.intPlannedShiftId IS NULL
						THEN ''
					ELSE ' - ' + S.strShiftName
					END
				)
		FROM dbo.tblMFWorkOrder W
		LEFT JOIN dbo.tblMFShift S ON S.intShiftId = W.intPlannedShiftId
		JOIN dbo.tblMFRecipe P ON P.intItemId = W.intItemId
		JOIN dbo.tblMFRecipeItem PI ON PI.intRecipeId = P.intRecipeId
		JOIN dbo.tblMFRecipeItem ri ON ri.intItemId = PI.intItemId
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		JOIN dbo.tblICItem Product ON Product.intItemId = W.intItemId
		JOIN dbo.tblICItem Input ON Input.intItemId = PI.intItemId
		WHERE r.ysnActive = 1
			AND r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND ri.intRecipeItemTypeId = 1
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
			AND intCountStatusId <> 13
			AND intStatusId<>13
			AND (
				CASE 
					WHEN intPlannedShiftId IS NOT NULL
						THEN dtmPlannedDate + dtmShiftStartTime + intStartOffset
					ELSE dtmPlannedDate
					END
				) < @dtmPlannedDateTime
			AND W.intWorkOrderId <> @intWorkOrderId

		RAISERROR (
				51107
				,11
				,1
				,@strProductItem
				,@strPlannedDate
				,@strInputItem
				)
	END

	DECLARE @tblICItem TABLE (intItemId INT)

	INSERT INTO @tblICItem (intItemId)
	SELECT ri.intItemId
	FROM dbo.tblMFRecipeItem ri
	JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.ysnActive = 1
		AND r.intItemId = @intItemId
		AND r.intLocationId = @intLocationId
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
		AND ri.intRecipeItemTypeId = 1
	
	UNION
	
	SELECT RSI.intSubstituteItemId
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblMFRecipeItem RI ON R.intRecipeId = RI.intRecipeId
	JOIN dbo.tblMFRecipeSubstituteItem RSI ON RSI.intRecipeItemId = RI.intRecipeItemId
	WHERE R.intItemId = @intItemId
		AND R.ysnActive = 1
		AND RI.intRecipeItemTypeId = 1
		AND R.intLocationId = @intLocationId

	if @ysnIncludeOutputItem=1
	Begin
		INSERT INTO @tblICItem (intItemId)
		SELECT ri.intItemId
		FROM dbo.tblMFRecipeItem ri
		JOIN dbo.tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
		WHERE r.ysnActive = 1
			AND r.intItemId = @intItemId
			AND r.intLocationId = @intLocationId
			AND ri.intRecipeItemTypeId = 2

	End

	DELETE tempItem 
	FROM @tblICItem tempItem 
	JOIN tblICItem I on I.intItemId=tempItem.intItemId
	Where I.strType in (Select Item COLLATE Latin1_General_CI_AS from dbo.fnSplitString(@strExcludeItemType,','))
	
	--BEGIN TRANSACTION

	INSERT INTO dbo.tblMFProcessCycleCountSession (
		intSubLocationId
		,intUserId
		,dtmSessionStartDateTime
		,dtmSessionEndDateTime
		,ysnCycleCountCompleted
		,intWorkOrderId
		)
	SELECT @intSubLocationId
		,@intUserId
		,@dtmCurrentDateTime
		,NULL
		,0
		,@intWorkOrderId

	SELECT @intCycleCountSessionId = SCOPE_IDENTITY()

	INSERT INTO dbo.tblMFProcessCycleCount (
		intCycleCountSessionId
		,intMachineId
		,intLotId
		,intItemId
		,dblQuantity
		,dblSystemQty
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,intConcurrencyId
		)
	SELECT @intCycleCountSessionId
		,MP.intMachineId
		,NULL
		,I.intItemId
		,NULL
		,(
			SELECT TOP 1 CC.dblQuantity
			FROM dbo.tblMFProcessCycleCount AS CC
			JOIN dbo.tblMFProcessCycleCountSession AS CS ON CS.intCycleCountSessionId = CC.intCycleCountSessionId
			JOIN dbo.tblMFWorkOrder W ON W.intWorkOrderId = CS.intWorkOrderId
			WHERE CC.intItemId = I.intItemId
				AND CC.intMachineId = MP.intMachineId
				AND W.dtmPlannedDate <= @dtmPlannedDate
			ORDER BY W.dtmPlannedDate DESC
				,CC.dtmLastModified DESC
			)
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,1
	FROM dbo.tblMFManufacturingProcessMachine MP
	CROSS JOIN @tblICItem I
	WHERE MP.intManufacturingProcessId = @intManufacturingProcessId

	UPDATE dbo.tblMFWorkOrder
	SET intCountStatusId  = 10
		,dtmLastModified = @dtmCurrentDateTime
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId
	
	--COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	--IF XACT_STATE() != 0 
		--ROLLBACK TRANSACTION

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



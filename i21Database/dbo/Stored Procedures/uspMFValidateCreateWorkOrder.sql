CREATE PROCEDURE [dbo].[uspMFValidateCreateWorkOrder] (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intItemId INT
		,@intManufacturingCellId INT
		,@dtmPlannedDate DATETIME
		,@intPlannedShiftId INT
		,@intManufacturingProcessId INT
		,@strExcludeItemType NVARCHAR(MAX)
		,@ysnCycleCountRequired BIT
		,@dtmLastPlannedDate DATETIME
		,@intCountStatusId INT
		,@dtmLastPlannedDateTime DATETIME
		,@strLastPlannedDate NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strDescription NVARCHAR(100)
		,@strCountStatus NVARCHAR(50)
		,@strManufacturingProcessRunDurationName NVARCHAR(50)
		,@intIngredientItemId INT
		,@strIngredientItemNo NVARCHAR(50)
		,@strIngredientDescription NVARCHAR(50)
		,@intShiftId INT
		,@strShiftName NVARCHAR(50)
		,@strPlannedDate NVARCHAR(50)
		,@intAttributeId int
		,@strTimebasedProduction nvarchar(50)
		,@intLocationId int

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intManufacturingCellId = intManufacturingCellId
		,@dtmPlannedDate = dtmPlannedDate
		,@intPlannedShiftId = intPlannedShiftId
		,@intItemId = intItemId
		,@strExcludeItemType = strExcludeItemType
		,@ysnCycleCountRequired = ysnCycleCountRequired
		,@strManufacturingProcessRunDurationName = strManufacturingProcessRunDurationName
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingProcessId INT
			,intManufacturingCellId INT
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			,intItemId INT
			,strExcludeItemType NVARCHAR(MAX)
			,ysnCycleCountRequired BIT
			,strManufacturingProcessRunDurationName NVARCHAR(50)
			)
	Select @intAttributeId=intAttributeId from tblMFAttribute Where strAttributeName='Time based Production'
	Select @intLocationId=intLocationId from tblMFManufacturingCell Where intManufacturingCellId = @intManufacturingCellId

	Select @strTimebasedProduction=strAttributeValue
	From tblMFManufacturingProcessAttribute
	Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId and intAttributeId=@intAttributeId

	IF @strTimebasedProduction='True'
	BEGIN
		SELECT TOP 1 @dtmLastPlannedDateTime = CASE 
				WHEN W.intPlannedShiftId IS NOT NULL
					THEN W.dtmPlannedDate + SH.dtmShiftStartTime
				ELSE W.dtmPlannedDate
				END
			,@strLastPlannedDate = CASE 
				WHEN W.intPlannedShiftId IS NOT NULL
					THEN CONVERT(CHAR,W.dtmPlannedDate,101) + ' ' + SH.strShiftName
				ELSE CONVERT(CHAR,W.dtmPlannedDate,101)
				END
			,@dtmLastPlannedDate = W.dtmPlannedDate
			,@intCountStatusId = intCountStatusId
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
			AND W.intItemId = @intItemId
		JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
		LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
		ORDER BY W.dtmPlannedDate DESC
			,SH.dtmShiftStartTime DESC

		SELECT @strItemNo = strItemNo
			,@strDescription = strDescription
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @dtmLastPlannedDateTime IS NOT NULL
			AND @dtmPlannedDate < @dtmLastPlannedDateTime
		BEGIN
			IF @intCountStatusId = 13
			BEGIN
				SELECT @strCountStatus = 'trued up'
			END
			ELSE
			BEGIN
				SELECT @strCountStatus = 'started - cycle count'
			END

			RAISERROR (
					'A run for ''%s'' - ''%s'' is %s on ''%s''. Please create a run later than the ''%s''.'
					,11
					,1
					,@strItemNo
					,@strDescription
					,@strCountStatus
					,@strLastPlannedDate
					,@strLastPlannedDate
					)
		END

		SELECT TOP 1 @dtmLastPlannedDateTime = CASE 
				WHEN W.intPlannedShiftId IS NOT NULL
					THEN W.dtmPlannedDate + SH.dtmShiftStartTime
				ELSE W.dtmPlannedDate
				END
			,@strLastPlannedDate = CASE 
				WHEN W.intPlannedShiftId IS NOT NULL
					THEN CONVERT(CHAR,W.dtmPlannedDate,101) + ' ' + SH.strShiftName
				ELSE CONVERT(CHAR,W.dtmPlannedDate,101)
				END
			,@dtmLastPlannedDate = W.dtmPlannedDate
			,@intCountStatusId = intCountStatusId
			,@intIngredientItemId = CC.intItemId
		FROM dbo.tblMFWorkOrder W
		JOIN dbo.tblMFProcessCycleCountSession CS ON W.intWorkOrderId = CS.intWorkOrderId
			AND W.intCountStatusId = 13
			AND W.intManufacturingProcessId = @intManufacturingProcessId
		JOIN dbo.tblMFProcessCycleCount CC ON CC.intCycleCountSessionId = CS.intCycleCountSessionId
		JOIN dbo.tblMFRecipeItem RI ON RI.intItemId = CC.intItemId
			AND RI.intRecipeItemTypeId = 1
		JOIN dbo.tblMFRecipe R ON R.intRecipeId = RI.intRecipeId
			AND R.intItemId = @intItemId
		JOIN dbo.tblICItem I ON I.intItemId = CC.intItemId
		JOIN dbo.tblMFManufacturingProcessMachine PM ON PM.intManufacturingProcessId = W.intManufacturingProcessId
			AND PM.intMachineId = CC.intMachineId
		LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
		WHERE I.strType IN (
				SELECT Item COLLATE Latin1_General_CI_AS
				FROM dbo.fnSplitString(@strExcludeItemType, ',')
				)
		ORDER BY W.dtmPlannedDate DESC
			,SH.dtmShiftStartTime DESC

		SELECT @strIngredientItemNo = strItemNo
			,@strIngredientDescription = strDescription
		FROM tblICItem
		WHERE intItemId = @intIngredientItemId

		IF @dtmLastPlannedDateTime IS NOT NULL
			AND @dtmPlannedDate < @dtmLastPlannedDateTime
		BEGIN
			RAISERROR (
					'A run for ''%s'' - ''%s'' is %s on ''%s''. Please create a run later than the ''%s''.'
					,11
					,1
					,@strItemNo
					,@strDescription
					,@strLastPlannedDate
					,@strIngredientItemNo
					,@strIngredientDescription
					,@strLastPlannedDate
					)
		END
	

		IF @strManufacturingProcessRunDurationName = 'By Shift'
			AND EXISTS (
				SELECT *
				FROM tblMFWorkOrder
				WHERE dtmPlannedDate = @dtmPlannedDate
					AND intPlannedShiftId = @intPlannedShiftId
					AND intManufacturingProcessId = @intManufacturingProcessId
					AND intItemId = @intItemId
				)
		BEGIN
			SELECT @strShiftName = strShiftName
			FROM dbo.tblMFShift
			WHERE intShiftId = @intPlannedShiftId

			SELECT @strItemNo = strItemNo + ' ' + strDescription
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			SELECT @strPlannedDate = CONVERT(CHAR,@dtmPlannedDate,101) + ' ' + @strShiftName

			RAISERROR (
					'There is already a run/work order for the date %s and %s, cannot create one more in the same shift and date.'
					,11
					,1
					,@strPlannedDate
					,@strItemNo
					)
		END

		IF @strManufacturingProcessRunDurationName = 'By Day'
			AND EXISTS (
				SELECT *
				FROM dbo.tblMFWorkOrder
				WHERE dtmPlannedDate = @dtmPlannedDate
					AND intManufacturingProcessId = @intManufacturingProcessId
					AND intItemId = @intItemId
				)
		BEGIN
			SELECT @strItemNo = strItemNo + ' ' + strDescription
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			SELECT @strPlannedDate = CONVERT(CHAR,@dtmPlannedDate,101)

			RAISERROR (
					'There is already a run/work order for the date %s and %s, cannot create one more in the same date.'
					,11
					,1
					,@strPlannedDate
					,@strItemNo
					)
		END
	END
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



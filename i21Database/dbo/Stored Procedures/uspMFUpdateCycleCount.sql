CREATE PROCEDURE [dbo].uspMFUpdateCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intCycleCountId INT
		,@intCycleCountSessionId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT TOP 1 @intCycleCountId = intCycleCountId
	FROM OPENXML(@idoc, 'root/CycleCounts/CycleCount', 2) WITH (intCycleCountId INT)

	SELECT @intWorkOrderId = CS.intWorkOrderId
		,@intCycleCountSessionId = CS.intCycleCountSessionId
	FROM tblMFProcessCycleCount CC
	JOIN tblMFProcessCycleCountSession CS ON CS.intCycleCountSessionId = CC.intCycleCountSessionId
	WHERE CC.intCycleCountId = @intCycleCountId

	UPDATE dbo.tblMFProcessCycleCount
	SET dblQuantity = x.dblQuantity
		,dtmLastModified = GetDate()
		,intLastModifiedUserId = x.intUserId
	FROM OPENXML(@idoc, 'root/CycleCounts/CycleCount', 2) WITH (
			intCycleCountId INT
			,dblQuantity NUMERIC(38, 20)
			,intUserId INT
			) x
	WHERE tblMFProcessCycleCount.intCycleCountId = x.intCycleCountId

	DECLARE @tblMFProcessCycleCount TABLE (
		intItemId INT
		,intMachineId INT
		,dblQuantity NUMERIC(38, 20)
		)

	INSERT INTO @tblMFProcessCycleCount
	SELECT intItemId
		,PCCM.intMachineId
		,SUM(dblQuantity)
	FROM tblMFProcessCycleCount PCC
	LEFT JOIN tblMFProcessCycleCountMachine PCCM ON PCCM.intCycleCountId = PCC.intCycleCountId
	WHERE intCycleCountSessionId = @intCycleCountSessionId
	GROUP BY PCC.intItemId
		,PCCM.intMachineId

	UPDATE tblMFProductionSummary
	SET dblCountQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 1
				OR RSI.intRecipeItemTypeId = 1
				THEN ISNULL(CC.dblQuantity, 0)
			ELSE 0
			END
		,dblCountOutputQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 2
				THEN ISNULL(CC.dblQuantity, 0)
			ELSE 0
			END
	FROM @tblMFProcessCycleCount CC
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = CC.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId = CC.intItemId
		AND RSI.intWorkOrderId = @intWorkOrderId
	JOIN dbo.tblMFProductionSummary PS ON PS.intItemId = CC.intItemId
		AND IsNULL(PS.intMachineId, 0) = IsNULL(CC.intMachineId, 0)
		AND PS.intWorkOrderId = @intWorkOrderId
		AND PS.intItemTypeId IN (
			1
			,3
			)
		AND PS.intMachineId IS NOT NULL

	UPDATE tblMFProductionSummary
	SET dblCountQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 1
				OR RSI.intRecipeItemTypeId = 1
				THEN ISNULL(CC.dblQuantity, 0)
			ELSE 0
			END
		,dblCountOutputQuantity = CASE 
			WHEN RI.intRecipeItemTypeId = 2
				THEN ISNULL(CC.dblQuantity, 0)
			ELSE 0
			END
	FROM @tblMFProcessCycleCount CC
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = CC.intItemId
		AND RI.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId = CC.intItemId
		AND RSI.intWorkOrderId = @intWorkOrderId
	JOIN dbo.tblMFProductionSummary PS ON PS.intItemId = CC.intItemId
		AND PS.intWorkOrderId = @intWorkOrderId
		AND PS.intItemTypeId IN (
			1
			,3
			)
		AND PS.intMachineId IS NULL

	--INSERT INTO dbo.tblMFProductionSummary (
	--	intWorkOrderId
	--	,intItemId
	--	,dblOpeningQuantity
	--	,dblOpeningOutputQuantity
	--	,dblOpeningConversionQuantity
	--	,dblInputQuantity
	--	,dblConsumedQuantity
	--	,dblOutputQuantity
	--	,dblOutputConversionQuantity
	--	,dblCountQuantity
	--	,dblCountOutputQuantity
	--	,dblCountConversionQuantity
	--	,dblCalculatedQuantity
	--	)
	--SELECT DISTINCT @intWorkOrderId
	--	,CC.intItemId
	--	,0
	--	,0
	--	,0
	--	,0
	--	,0
	--	,0
	--	,0
	--	,CASE 
	--		WHEN RI.intRecipeItemTypeId = 1
	--			OR RI.intRecipeItemTypeId IS NULL
	--			THEN ISNULL(CC.dblQuantity, 0)
	--		ELSE 0
	--		END
	--	,CASE 
	--		WHEN RI.intRecipeItemTypeId = 2
	--			THEN ISNULL(CC.dblQuantity, 0)
	--		ELSE 0
	--		END
	--	,0
	--	,0
	--FROM @tblMFProcessCycleCount CC
	--LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId = CC.intItemId
	--	AND RI.intWorkOrderId = @intWorkOrderId
	--WHERE NOT EXISTS (
	--		SELECT *
	--		FROM dbo.tblMFProductionSummary PS
	--		WHERE PS.intWorkOrderId = @intWorkOrderId
	--			AND PS.intItemId = CC.intItemId
	--			and IsNULL(PS.intMachineId,0) =IsNULL(CC.intMachineId ,0)
	--			AND PS.intItemTypeId IN (
	--				1
	--				,3
	--				)
	--		)
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



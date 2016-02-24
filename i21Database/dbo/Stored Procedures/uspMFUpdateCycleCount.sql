﻿CREATE PROCEDURE [dbo].uspMFUpdateCycleCount (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId int
		,@intCycleCountId int

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT Top 1 @intCycleCountId = intCycleCountId
	FROM OPENXML(@idoc, 'root/CycleCounts/CycleCount', 2) WITH (
			intCycleCountId INT
			)

	Select @intWorkOrderId =CS.intWorkOrderId 
	from tblMFProcessCycleCount CC 
	JOIN tblMFProcessCycleCountSession CS on CS.intCycleCountSessionId =CC.intCycleCountSessionId
	Where CC.intCycleCountId=@intCycleCountId

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

	UPDATE tblMFProductionSummary 
	SET 	dblCountQuantity=CASE 
			WHEN RI.intRecipeItemTypeId =1 OR RSI.intRecipeItemTypeId =1
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
			,dblCountOutputQuantity=CASE 
			WHEN RI.intRecipeItemTypeId =2
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
	FROM dbo.tblMFProcessCycleCount CC 
	JOIN dbo.tblMFProcessCycleCountSession CCS ON CCS.intCycleCountSessionId=CC.intCycleCountSessionId AND CCS.intWorkOrderId =@intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId =CC.intItemId AND RI.intWorkOrderId=@intWorkOrderId 
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem RSI ON RSI.intSubstituteItemId =CC.intItemId AND RSI.intWorkOrderId=@intWorkOrderId 
	JOIN dbo.tblMFProductionSummary PS ON PS.intItemId=CC.intItemId AND PS.intWorkOrderId=@intWorkOrderId 

	INSERT INTO dbo.tblMFProductionSummary (
		intWorkOrderId
		,intItemId
		,dblOpeningQuantity
		,dblOpeningOutputQuantity
		,dblOpeningConversionQuantity
		,dblInputQuantity
		,dblConsumedQuantity
		,dblOutputQuantity
		,dblOutputConversionQuantity
		,dblCountQuantity
		,dblCountOutputQuantity
		,dblCountConversionQuantity
		,dblCalculatedQuantity
		)
	SELECT DISTINCT @intWorkOrderId
		,CC.intItemId
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,CASE 
			WHEN RI.intRecipeItemTypeId =1 OR RI.intRecipeItemTypeId IS NULL
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
		,CASE 
			WHEN RI.intRecipeItemTypeId =2
				THEN ISNULL(CC.dblQuantity,0)
			ELSE 0
			END
		,0
		,0
	FROM dbo.tblMFProcessCycleCount CC 
	JOIN dbo.tblMFProcessCycleCountSession S ON S.intCycleCountSessionId = CC.intCycleCountSessionId AND S.intWorkOrderId = @intWorkOrderId
	LEFT JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId =CC.intItemId AND RI.intWorkOrderId=@intWorkOrderId 
	WHERE NOT EXISTS (SELECT *FROM dbo.tblMFProductionSummary PS WHERE PS.intWorkOrderId=@intWorkOrderId AND PS.intItemId=CC.intItemId)

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



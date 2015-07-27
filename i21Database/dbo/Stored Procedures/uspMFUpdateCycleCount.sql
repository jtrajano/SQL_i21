CREATE PROCEDURE [dbo].uspMFUpdateCycleCount (@strXML NVARCHAR(MAX))
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
			,dblQuantity NUMERIC(18, 6)
			,intUserId INT
			) x
	WHERE tblMFProcessCycleCount.intCycleCountId = x.intCycleCountId

	UPDATE tblMFProductionSummary 
	SET 	dblOpeningQuantity=CASE 
			WHEN RI.intRecipeItemTypeId =1
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
			,dblOpeningOutputQuantity=CASE 
			WHEN RI.intRecipeItemTypeId =2
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
	FROM tblMFProcessCycleCount CC 
	JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId =CC.intItemId AND RI.intWorkOrderId=@intWorkOrderId 
	WHERE EXISTS (SELECT *FROM tblMFProductionSummary PS WHERE PS.intWorkOrderId=@intWorkOrderId AND PS.intItemId=CC.intItemId)

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
		,CASE 
			WHEN RI.intRecipeItemTypeId =1
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
		,CASE 
			WHEN RI.intRecipeItemTypeId =2
				THEN ISNULL(CC.dblSystemQty,0)
			ELSE 0
			END
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,0
	FROM dbo.tblMFProcessCycleCount CC 
	JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intItemId =CC.intItemId AND RI.intWorkOrderId=@intWorkOrderId 
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



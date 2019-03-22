CREATE PROCEDURE uspMFStageWorkOrder (
	@strXML NVARCHAR(MAX)
	,@intWorkOrderInputLotId INT = NULL OUTPUT
	)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intManufacturingProcessId INT
		,@idoc INT
		,@intLocationId INT
		,@strAttributeValue NVARCHAR(50)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intManufacturingProcessId INT
			,intLocationId INT
			)

	SELECT @strAttributeValue = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 116

	IF @strAttributeValue IS NULL
		OR @strAttributeValue = ''
	BEGIN
		SELECT @strAttributeValue = 'False'
	END

	IF @strAttributeValue = 'True'
	BEGIN
		EXEC [dbo].[uspMFStageWorkOrderByStorageLocation] @strXML = @strXML
			,@intWorkOrderInputLotId = @intWorkOrderInputLotId OUTPUT
	END
	ELSE
	BEGIN
		EXEC [dbo].[uspMFStageWorkOrderByLot] @strXML = @strXML
			,@intWorkOrderInputLotId = @intWorkOrderInputLotId OUTPUT
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

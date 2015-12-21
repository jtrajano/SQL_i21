CREATE PROCEDURE uspMFWarehouseReleaseByParentLot (@strXML NVARCHAR(MAX))
AS
BEGIN
	DECLARE @intRecordId INT
		,@intParentLotId INT
		,@intLotId INT
		,@strInputXML NVARCHAR(MAX)
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intParentLotId = intParentLotId
	FROM OPENXML(@idoc, 'root', 2) WITH (intParentLotId INT)

	DECLARE @tblMFParentLot TABLE (
		intRecordId INT identity(1, 1)
		,intLotId INT
		)

	INSERT INTO @tblMFParentLot (intLotId)
	SELECT L.intLotId
	FROM dbo.tblICLot L
	WHERE L.intParentLotId = @intParentLotId
		AND L.intLotStatusId = 3

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFParentLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL

		SELECT @intLotId = intLotId
		FROM @tblMFParentLot
		WHERE intRecordId = @intRecordId

		SELECT @strInputXML = Replace(@strXML, '</root>', '<intLotId>' + ltrim(@intLotId) + '</intLotId></root>')

		EXEC uspMFWarehouseReleaseLot @strXML = @strInputXML

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFParentLot
		WHERE intRecordId > @intRecordId
	END
END

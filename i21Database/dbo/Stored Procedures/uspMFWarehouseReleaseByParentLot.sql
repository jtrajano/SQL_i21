CREATE PROCEDURE uspMFWarehouseReleaseByParentLot (@strXML NVARCHAR(MAX),@strFGReleaseMailTOAddress NVARCHAR(MAX)=NULL OUTPUT
	,@strFGReleaseMailCCAddress NVARCHAR(MAX)=NULL OUTPUT
	,@strSubject VARCHAR(MAX)=NULL OUTPUT
	,@strBody NVARCHAR(MAX)=NULL OUTPUT)
AS
BEGIN
	DECLARE @intRecordId INT
		,@intParentLotId INT
		,@intLotId INT
		,@strInputXML NVARCHAR(MAX)
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intReleaseStatusId int
		,@intLocationId int
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intParentLotId = intParentLotId
			,@intReleaseStatusId=intReleaseStatusId
			,@intLocationId=intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (intParentLotId INT,intReleaseStatusId int,intLocationId int)

	DECLARE @tblMFParentLot TABLE (
		intRecordId INT identity(1, 1)
		,intLotId INT
		)

	INSERT INTO @tblMFParentLot (intLotId)
	SELECT L.intLotId
	FROM dbo.tblICLot L
	WHERE L.intParentLotId = @intParentLotId
		AND L.intLotStatusId = 3
		AND L.dblQty>0

	SELECT @intRecordId = MIN(intRecordId)
	FROM @tblMFParentLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL

		SELECT @intLotId = intLotId
		FROM @tblMFParentLot
		WHERE intRecordId = @intRecordId

		SELECT @strInputXML = Replace(@strXML, '</root>', '<intLotId>' + ltrim(@intLotId) + '</intLotId></root>')

		EXEC uspMFWarehouseReleaseLot @strXML = @strInputXML,@ysnBuildEMailContent=0

		SELECT @intRecordId = MIN(intRecordId)
		FROM @tblMFParentLot
		WHERE intRecordId > @intRecordId
	END
	IF @intReleaseStatusId=2 
	BEGIN
		SELECT @strFGReleaseMailTOAddress = strFGReleaseMailTOAddress
			,@strFGReleaseMailCCAddress = strFGReleaseMailCCAddress
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		SELECT @strSubject = 'FG Release List: ' + CONVERT(NVARCHAR, @dtmCurrentDate, 100)

		SET @strBody = N'<H2>FG Release List</H2>' + N'<table border="1" bgcolor ="rgb(192, 255, 255)">' + N'<tr><th width="175">Lot No</th><th width="175">Item Name</th>' + N'<th width="850">Status</th></tr>' + CAST((
		SELECT td = strLotNumber
			,''
			,td = strItemNo
			,''
			,td = 'Hold'
		FROM dbo.tblICLot L
		JOIN dbo.tblICItem I on I.intItemId=L.intItemId
		WHERE L.intParentLotId = @intParentLotId
		AND L.intLotStatusId = 3
		AND L.dblQty>0
		FOR XML PATH('tr')
			,TYPE
		) AS NVARCHAR(MAX)) + N'</table>';
	END
END

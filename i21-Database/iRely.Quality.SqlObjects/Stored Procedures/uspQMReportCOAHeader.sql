--EXEC uspQMReportCOAHeader '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intInventoryShipmentItemLotId</fieldname><condition>EQUAL TO</condition><from>1231</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportCOAHeader
     @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intInventoryShipmentItemLotId INT
		,@xmlDocumentId INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	IF (@xmlParam IS NULL)
	BEGIN
		SELECT NULL intLotId
			,NULL intInventoryShipmentId
			,NULL intInventoryShipmentItemLotId
			,NULL intItemId

		RETURN
	END

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @intInventoryShipmentItemLotId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInventoryShipmentItemLotId'

	SELECT L.intLotId
		,S.intInventoryShipmentId
		,SIL.intInventoryShipmentItemLotId
		,I.intItemId
	FROM dbo.tblICInventoryShipmentItemLot SIL
	JOIN dbo.tblICInventoryShipmentItem SI ON SI.intInventoryShipmentItemId = SIL.intInventoryShipmentItemId
		AND SIL.intInventoryShipmentItemLotId = @intInventoryShipmentItemLotId
	JOIN dbo.tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
	JOIN dbo.tblICLot L ON L.intLotId = SIL.intLotId
	JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCOAHeader - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH

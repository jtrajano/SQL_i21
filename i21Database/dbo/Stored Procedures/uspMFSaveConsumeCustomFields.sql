CREATE PROCEDURE uspMFSaveConsumeCustomFields @strXML NVARCHAR(MAX)
	,@intWorkOrderInputLotId INT
	,@ysnProducedLot BIT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc INT
	,@ErrMsg NVARCHAR(MAX)

EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXML

IF @ysnProducedLot = 1
BEGIN
	INSERT INTO tblMFCustomFieldValue (
		intConcurrencyId
		,intCustomTabDetailId
		,intWorkOrderInputLotId
		,intWorkOrderProducedLotId
		,strValue
		)
	SELECT 1
		,x.intCustomTabDetailId
		,NULL
		,@intWorkOrderInputLotId
		,x.strValue
	FROM OPENXML(@idoc, 'root/fields', 2) WITH (
			intCustomTabDetailId INT
			,strValue NVARCHAR(MAX)
			) x
END
ELSE
BEGIN
	INSERT INTO tblMFCustomFieldValue (
		intConcurrencyId
		,intCustomTabDetailId
		,intWorkOrderInputLotId
		,intWorkOrderProducedLotId
		,strValue
		)
	SELECT 1
		,x.intCustomTabDetailId
		,@intWorkOrderInputLotId
		,NULL
		,x.strValue
	FROM OPENXML(@idoc, 'root/fields', 2) WITH (
			intCustomTabDetailId INT
			,strValue NVARCHAR(MAX)
			) x
END

EXEC sp_xml_removedocument @idoc

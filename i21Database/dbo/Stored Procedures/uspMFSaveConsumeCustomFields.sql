CREATE PROCEDURE uspMFSaveConsumeCustomFields @strXML NVARCHAR(MAX)
	,@intWorkOrderInputLotId INT
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

INSERT INTO tblMFCustomFieldValue (
	intConcurrencyId
	,intCustomTabDetailId
	,intWorkOrderInputLotId
	,strValue
	)
SELECT 1
	,x.intCustomTabDetailId
	,@intWorkOrderInputLotId
	,x.strValue
FROM OPENXML(@idoc, 'root/fields', 2) WITH (
		intCustomTabDetailId INT
		,strValue NVARCHAR(MAX)
		) x

EXEC sp_xml_removedocument @idoc

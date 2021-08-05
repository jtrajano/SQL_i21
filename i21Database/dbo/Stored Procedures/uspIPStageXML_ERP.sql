CREATE PROCEDURE uspIPStageXML_ERP @strXml NVARCHAR(MAX) = ''
	,@strType NVARCHAR(100) = ''
	,@strCompany NVARCHAR(50) = ''
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX) = ''

	BEGIN
		INSERT INTO tblIPIDOCXMLStage (
			strXml
			,strType
			,strCompany
			,dtmCreatedDate
			)
		SELECT @strXml
			,@strType
			,@strCompany
			,GETDATE()
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

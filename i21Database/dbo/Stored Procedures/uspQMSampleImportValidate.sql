CREATE PROCEDURE uspQMSampleImportValidate
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(Max)

	SELECT intSampleImportErrorId
		,intSampleImportId
		,intConcurrencyId
		,dtmSampleReceivedDate
		,strSampleNumber
		,strItemShortName
		,strSampleTypeName
		,strVendorName
		,strContractNumber
		,strContainerNumber
		,strMarks
		,dblSequenceQuantity
		,strSampleStatus
		,strPropertyName
		,strPropertyValue
		,strErrorMsg
		,intCreatedUserId
		,dtmCreated
	FROM tblQMSampleImportError
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

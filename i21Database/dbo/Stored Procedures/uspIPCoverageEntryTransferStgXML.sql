CREATE PROCEDURE uspIPCoverageEntryTransferStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblRKCoverageEntryStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblRKCoverageEntryStage
	SET strFeedStatus = 'Awt Ack'
	WHERE ISNULL(strFeedStatus, '') = ''
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

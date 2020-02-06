CREATE PROCEDURE uspIPPropertyTransferStgXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblQMPropertyStage
	WHERE intMultiCompanyId = @intToCompanyId
		AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblQMPropertyStage
	SET strFeedStatus = 'Processed'
		,strMessage = 'Success'
	WHERE intMultiCompanyId = @intToCompanyId
		AND ISNULL(strFeedStatus, '') = ''
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

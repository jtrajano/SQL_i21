CREATE PROCEDURE uspIPAttributeTransferStgXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblQMAttributeStage
	WHERE intMultiCompanyId = @intToCompanyId
		AND ISNULL(strFeedStatus, '') = ''

	UPDATE tblQMAttributeStage
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

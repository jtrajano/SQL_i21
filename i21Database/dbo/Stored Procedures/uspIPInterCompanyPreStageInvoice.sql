CREATE PROCEDURE uspIPInterCompanyPreStageInvoice( @intInvoiceId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblARInvoicePreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intInvoiceId = @intInvoiceId
		AND strRowState ='Modified'

	INSERT INTO tblARInvoicePreStage (
		intInvoiceId
		,strRowState
		,intUserId
		)
	SELECT @intInvoiceId
		,@strRowState
		,@intUserId
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

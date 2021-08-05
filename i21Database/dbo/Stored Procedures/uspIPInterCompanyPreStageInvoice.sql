CREATE PROCEDURE [dbo].[uspIPInterCompanyPreStageInvoice]
	  @PreStageInvoice	InvoiceId READONLY
	, @intUserId		INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE PS
	FROM tblARInvoicePreStage PS
	INNER JOIN @PreStageInvoice II ON PS.intInvoiceId = II.intHeaderId
	WHERE ISNULL(strFeedStatus, '') = ''
	  AND strRowState ='Modified'

	INSERT INTO tblARInvoicePreStage (
		  intInvoiceId
		, strRowState
		, intUserId
	)
	SELECT intInvoiceId		= II.intHeaderId
		, strRowState		= II.strTransactionType
		, intUserId			= @intUserId
	FROM @PreStageInvoice II
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH

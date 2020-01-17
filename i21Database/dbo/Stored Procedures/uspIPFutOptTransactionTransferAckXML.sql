﻿CREATE PROCEDURE uspIPFutOptTransactionTransferAckXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT *
	FROM tblRKFutOptTransactionHeaderAckStage
	WHERE ISNULL(strFeedStatus, '') = ''

	UPDATE tblRKFutOptTransactionHeaderAckStage
	SET strFeedStatus = 'Ack Sent'
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

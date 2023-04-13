CREATE PROCEDURE dbo.uspIPDeleteStageLog_EK (@intNoOfDay INT = 30)
AS
BEGIN
	DECLARE @dtmDate DATETIME

	SELECT @dtmDate = CONVERT(VARCHAR(10), GETDATE() - @intNoOfDay, 126) + ' 00:00:00'

	DELETE
	FROM tblIPIDOCXMLError
	WHERE dtmCreatedDate < @dtmDate

	DELETE
	FROM tblIPIDOCXMLArchive
	WHERE dtmCreatedDate < @dtmDate

	--DELETE
	--FROM tblIPContractHeaderArchive
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPContractHeaderError
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPInvReceiptArchive
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPInvReceiptError
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPEntityArchive
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPEntityTermArchive
	--WHERE intStageEntityId NOT IN (
	--		SELECT intStageEntityId
	--		FROM tblIPEntityArchive
	--		)

	--DELETE
	--FROM tblIPEntityError
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPEntityTermError
	--WHERE intStageEntityId NOT IN (
	--		SELECT intStageEntityId
	--		FROM tblIPEntityError
	--		)

	--DELETE
	--FROM tblIPLotArchive
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPLotError
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPPBBSArchive
	--WHERE dtmTransactionDate < @dtmDate

	--DELETE
	--FROM tblIPPBBSError
	--WHERE dtmTransactionDate < @dtmDate

END

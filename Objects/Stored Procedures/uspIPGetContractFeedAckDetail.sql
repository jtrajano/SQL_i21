CREATE PROCEDURE uspIPGetContractFeedAckDetail
AS
BEGIN
	SELECT intContractFeedHeaderRefId
		,intContractFeedHeaderId
	FROM tblIPContractFeedHeader
	WHERE strFeedStatus = 'Processed'

	UPDATE tblIPContractFeedHeader
	SET strFeedStatus = 'Ack Sent'
	WHERE strFeedStatus = 'Processed'
END

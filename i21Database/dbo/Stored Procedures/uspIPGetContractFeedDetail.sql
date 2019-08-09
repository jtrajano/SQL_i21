CREATE PROCEDURE uspIPGetContractFeedDetail
AS
BEGIN
	SELECT intContractHeaderId
		,strApproverXML
		,intContractFeedHeaderId AS intContractFeedHeaderRefId
	FROM tblIPContractFeedHeader
	WHERE strFeedStatus IS NULL

	UPDATE tblIPContractFeedHeader
	SET strFeedStatus = 'Awt Ack'
	WHERE strFeedStatus IS NULL
END

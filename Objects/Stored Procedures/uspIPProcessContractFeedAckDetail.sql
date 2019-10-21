CREATE PROCEDURE uspIPProcessContractFeedAckDetail (
	@intContractFeedHeaderRefId INT
	,@intContractFeedHeaderId INT
	)
AS
BEGIN
	UPDATE tblIPContractFeedHeader
	SET strFeedStatus = 'Ack Rcvd'
		,strMessage = 'Success'
		,intContractFeedHeaderRefId = @intContractFeedHeaderId
	WHERE strFeedStatus = 'Awt Ack'
		AND intContractFeedHeaderId = @intContractFeedHeaderRefId
END

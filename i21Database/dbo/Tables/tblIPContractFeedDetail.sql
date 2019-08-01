CREATE TABLE tblIPContractFeedDetail (
	intContractFeedDetailId INT identity(1, 1)
	,intContractFeedHeaderId INT
	,intContractFeedId INT
	,CONSTRAINT [FK_tblIPContractFeedDetail_tblIPContractFeedHeader_intContractFeedHeaderId] FOREIGN KEY (intContractFeedHeaderId) REFERENCES tblIPContractFeedHeader(intContractFeedHeaderId) ON DELETE CASCADE
	)

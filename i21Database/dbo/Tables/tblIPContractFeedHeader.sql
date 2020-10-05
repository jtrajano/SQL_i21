CREATE TABLE tblIPContractFeedHeader (
	intContractFeedHeaderId INT identity(1, 1)
	,intContractHeaderId INT
	,strContractNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) Collate Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblIPContractFeedDetail_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) Collate Latin1_General_CI_AS
	,strApproverXML NVARCHAR(MAX) Collate Latin1_General_CI_AS
	,strSubmittedByXML NVARCHAR(MAX) Collate Latin1_General_CI_AS
	,ysnMailSent	bit
	,intStatusId	int
	,intContractFeedHeaderRefId INT CONSTRAINT [PK_tblIPContractFeedHeader_intContractFeedHeaderId] PRIMARY KEY (intContractFeedHeaderId)
	)

CREATE TABLE tblCTPriceContractStage
(
	intPriceContractStageId     INT IDENTITY(1,1) PRIMARY KEY, 
	intPriceContractId	      INT,
	strPriceContractNo	      NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strPriceContractXML	      NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strPriceFixationXML	      NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strPriceFixationDetailXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	
	strReference		      NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState			      NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus		      NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate			      DATETIME,
	strMessage			      NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId	      INT,	
	intEntityId			      INT,
	strTransactionType        NVARCHAR(100) COLLATE Latin1_General_CI_AS
)
CREATE TABLE tblCTPriceContractPreStage
(
	intPriceContractPreStageId     INT IDENTITY(1,1) PRIMARY KEY, 
	intPriceContractId	      INT,
	strFeedStatus		      NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate			      DATETIME Constraint DF_tblCTPriceContractPreStage_dtmFeedDate Default GETDATE(),
	strRowState				  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

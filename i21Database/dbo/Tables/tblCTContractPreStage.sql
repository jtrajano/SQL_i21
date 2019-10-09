CREATE TABLE tblCTContractPreStage
(
	intContractPreStageId     INT IDENTITY(1,1) CONSTRAINT [PK_tblCTContractPreStage_intContractPreStageId] PRIMARY KEY, 
	intContractHeaderId	      INT,
	strFeedStatus		      NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate			      DATETIME Constraint DF_tblCTContractPreStage_dtmFeedDate Default GETDATE(),
	strRowState				  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

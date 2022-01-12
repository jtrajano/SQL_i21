CREATE TABLE tblLGIntrCompLogisticsPreStg (
	intLoadPreStageId INT IDENTITY(1, 1) CONSTRAINT [PK_tblLGIntrCompLogisticsPreStg_intLoadPreStageId] PRIMARY KEY
	,intLoadId INT
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblLGIntrCompLogisticsPreStg_dtmFeedDate DEFAULT GETDATE()
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strToTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intToCompanyId INT
	,intToCompanyLocationId INT
	,intToBookId INT
	,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS 
	,intStatusId int
	,strMessage  NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	)



CREATE TABLE tblMFDemandPreStage (
	intDemandPreStageId INT IDENTITY(1, 1) CONSTRAINT PK_tblMFDemandPreStage_intDemandPreStageId PRIMARY KEY
	,intInvPlngReportMasterID INT
	,strRowState NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFDemandPreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)

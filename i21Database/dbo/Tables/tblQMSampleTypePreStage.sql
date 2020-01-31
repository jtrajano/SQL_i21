CREATE TABLE tblQMSampleTypePreStage
(
	intSampleTypePreStageId			INT IDENTITY(1,1) PRIMARY KEY, 
	intSampleTypeId					INT,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intUserId						INT,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblQMSampleTypePreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
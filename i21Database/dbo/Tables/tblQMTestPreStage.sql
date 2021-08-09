CREATE TABLE tblQMTestPreStage
(
	intTestPreStageId				INT IDENTITY(1,1) PRIMARY KEY, 
	intTestId						INT,
	strTestName						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intUserId						INT,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblQMTestPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnMailSent						BIT CONSTRAINT DF_tblQMTestPreStage_ysnMailSent DEFAULT 0,
	intStatusId						INT
)
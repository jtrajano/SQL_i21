CREATE TABLE tblICItemPreStage
(
	intItemPreStageId	INT IDENTITY(1,1) CONSTRAINT PK_tblICItemPreStage_intItemPreStageId PRIMARY KEY, 
	intItemId			INT NOT NULL,
	strRowState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblICItemPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intUserId int
)

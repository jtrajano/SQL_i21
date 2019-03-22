CREATE TABLE dbo.tblMFPatternSequence (
	intPatternSequenceId int IDENTITY(1, 1) NOT NULL
	,intPatternId INT NOT NULL
	,strPatternSequence NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intSequenceNo INT NULL
	,intMaximumSequence INT NULL
	,ysnNotified BIT NOT NULL CONSTRAINT DF_tblMFPatternSequence_ysnNotified DEFAULT((0))
	,CONSTRAINT PK_tblMFPatternSequence_intPatternSequenceId PRIMARY KEY (intPatternSequenceId)
	,CONSTRAINT FK_tblMFPatternSequence_tblMFPattern_intPatternId FOREIGN KEY (intPatternId) REFERENCES dbo.tblMFPattern(intPatternId)
	)
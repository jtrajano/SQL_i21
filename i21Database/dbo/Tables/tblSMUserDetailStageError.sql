CREATE TABLE tblSMUserDetailStageError
(
	intUserStageDetailErrorId		INT IDENTITY(1,1),
	intUserStageErrorId				INT,
	strLocation					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strRole						NVARCHAR(100) COLLATE Latin1_General_CI_AS

	CONSTRAINT [PK_tblSMUserDetailStageError_intUserStageDetailErrorId] PRIMARY KEY ([intUserStageDetailErrorId]),
	CONSTRAINT [FK_tblSMUserDetailStageError_tblSMUserStageError] FOREIGN KEY ([intUserStageErrorId]) REFERENCES [tblSMUserStageError]([intUserStageErrorId]) ON DELETE CASCADE
)

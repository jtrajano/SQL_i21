CREATE TABLE tblSMUserDetailStage
(
	intUserStageDetailId		INT IDENTITY(1,1),
	intUserStageId				INT,
	strLocation					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strRole						NVARCHAR(100) COLLATE Latin1_General_CI_AS

	CONSTRAINT [PK_tblSMUserDetailStage_intUserStageDetailId] PRIMARY KEY ([intUserStageDetailId]),
	CONSTRAINT [FK_tblSMUserDetailStage_tblSMUserStage] FOREIGN KEY ([intUserStageId]) REFERENCES [tblSMUserStage]([intUserStageId]) ON DELETE CASCADE
)
CREATE TABLE tblSMUserDetailStageArchive
(
	intUserStageDetailArchiveId		INT IDENTITY(1,1),
	intUserStageArchiveId				INT,
	strLocation					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strRole						NVARCHAR(100) COLLATE Latin1_General_CI_AS

	CONSTRAINT [PK_tblSMUserDetailStageArchive_intUserStageDetailArchiveId] PRIMARY KEY ([intUserStageDetailArchiveId]),
	CONSTRAINT [FK_tblSMUserDetailStageArchive_tblSMUserStageArchive] FOREIGN KEY ([intUserStageArchiveId]) REFERENCES [tblSMUserStageArchive]([intUserStageArchiveId]) ON DELETE CASCADE
)

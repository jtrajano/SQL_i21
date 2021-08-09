CREATE TABLE tblIPLoadDocumentsArchive
(
	intStageLoadDocumentsId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTypeCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strName						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intOriginal					INT,
	intCopies					INT,

	CONSTRAINT [PK_tblIPLoadDocumentsArchive_intStageLoadDocumentsId] PRIMARY KEY (intStageLoadDocumentsId),
	CONSTRAINT [FK_tblIPLoadDocumentsArchive_tblIPLoadArchive_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadArchive]([intStageLoadId]) ON DELETE CASCADE
)

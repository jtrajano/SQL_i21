CREATE TABLE tblIPLoadDocumentsStage
(
	intStageLoadDocumentsId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTypeCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strName						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intOriginal					INT,
	intCopies					INT,

	CONSTRAINT [PK_tblIPLoadDocumentsStage_intStageLoadDocumentsId] PRIMARY KEY (intStageLoadDocumentsId),
	CONSTRAINT [FK_tblIPLoadDocumentsStage_tblIPLoadStage_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadStage]([intStageLoadId]) ON DELETE CASCADE
)

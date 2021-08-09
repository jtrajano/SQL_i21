CREATE TABLE tblIPLoadDocumentsError
(
	intStageLoadDocumentsId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTypeCode					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strName						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intOriginal					INT,
	intCopies					INT,

	CONSTRAINT [PK_tblIPLoadDocumentsError_intStageLoadDocumentsId] PRIMARY KEY (intStageLoadDocumentsId),
	CONSTRAINT [FK_tblIPLoadDocumentsError_tblIPLoadError_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadError]([intStageLoadId]) ON DELETE CASCADE
)

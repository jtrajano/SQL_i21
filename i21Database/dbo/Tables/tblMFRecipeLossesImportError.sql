CREATE TABLE [dbo].[tblMFRecipeLossesImportError]
(
	intRecipeLossesImportErrorId INT IDENTITY(1,1) NOT NULL,
	intRecipeLossesImportId INT,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFRecipeLossesImportError_intConcurrencyId DEFAULT 0, 

	strRecipeName NVARCHAR(250) COLLATE Latin1_General_CI_AS,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strComponent NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblLoss1 NUMERIC(18, 6),
	dblLoss2 NUMERIC(18, 6),

	strErrorMsg NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intCreatedUserId INT,
	dtmCreated DATETIME NULL CONSTRAINT DF_tblMFRecipeLossesImportError_dtmCreated DEFAULT GETDATE()
)

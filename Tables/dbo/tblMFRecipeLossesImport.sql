CREATE TABLE [dbo].[tblMFRecipeLossesImport]
(
	intRecipeLossesImportId INT IDENTITY(1,1) NOT NULL,
	intConcurrencyId INT NULL CONSTRAINT DF_tblMFRecipeLossesImport_intConcurrencyId DEFAULT 0, 

	strRecipeName NVARCHAR(250) COLLATE Latin1_General_CI_AS,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strComponent NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblLoss1 NUMERIC(18, 6),
	dblLoss2 NUMERIC(18, 6),

	intCreatedUserId INT,
	dtmCreated DATETIME NULL CONSTRAINT DF_tblMFRecipeLossesImport_dtmCreated DEFAULT GETDATE()
)

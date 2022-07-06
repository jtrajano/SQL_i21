CREATE TABLE [dbo].[tblQMLotSampleImport]
(
	intLotSampleImportId	INT IDENTITY(1,1) NOT NULL,
	intConcurrencyId		INT NULL CONSTRAINT DF_tblQMLotSampleImport_intConcurrencyId DEFAULT 0, 
	strSampleNumber			NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	dtmSampleReceivedDate	NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLotNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStorageUnit			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblRepresentingQty		NUMERIC(18, 6),
	strComment				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	
	strProperty1			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty2			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty3			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty4			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty5			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty6			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty7			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty8			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty9			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty10			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty11			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty12			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty13			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty14			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty15			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty16			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty17			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty18			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty19			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strProperty20			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

	dtmCreated				DATETIME NULL CONSTRAINT DF_tblQMLotSampleImport_dtmCreated DEFAULT GETDATE()
)
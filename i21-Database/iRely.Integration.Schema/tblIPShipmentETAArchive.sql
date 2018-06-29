CREATE TABLE [dbo].[tblIPShipmentETAArchive]
(
	[intStageShipmentETAId] INT IDENTITY(1,1),
	strDeliveryNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmETA DATETIME,
	[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrorMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	strPartnerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPShipmentETAArchive_intStageShipmentETAId] PRIMARY KEY ([intStageShipmentETAId]) 
)

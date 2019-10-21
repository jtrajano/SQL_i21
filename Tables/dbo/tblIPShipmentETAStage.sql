CREATE TABLE [dbo].[tblIPShipmentETAStage]
(
	[intStageShipmentETAId] INT IDENTITY(1,1),
	strDeliveryNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmETA DATETIME,
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	strPartnerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPShipmentETAStage_intStageShipmentETAId] PRIMARY KEY ([intStageShipmentETAId]) 
)

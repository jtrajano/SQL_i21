CREATE TABLE tblIPShipmentStatusStage
(
	intStageShipmentStatusId	INT IDENTITY(1,1),
	strContractNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intContractSeq				INT,
	strBLNumber					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strStatus					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmArrivedInPort			DATETIME,
	dtmCustomsReleased			DATETIME,
	dtmETA						DATETIME,

	strLoadNumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPShipmentStatusStage_intStageShipmentStatusId] PRIMARY KEY ([intStageShipmentStatusId])
)

CREATE TABLE tblIPLoadError
(
	intStageLoadId				INT IDENTITY(1,1),
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strERPPONumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strOriginPort				NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strDestinationPort			NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	dtmETAPOD					DATETIME, -- Act. ETA
	dtmETAPOL					DATETIME, -- Act. ETD
	dtmDeadlineCargo			DATETIME, -- LS. Instr ETA
	dtmETSPOL					DATETIME, -- LS. Instr ETD
	strBookingReference			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBLNumber					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dtmBLDate					DATETIME, -- LS
	strShippingLine				NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- LS
	strMVessel					NVARCHAR(200) COLLATE Latin1_General_CI_AS,
	strMVoyageNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strShippingMode				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	
	intNumberOfContainers		INT,
	strContainerType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	strLoadNumber				NVARCHAR(100),
	strAction					NVARCHAR(100),
	strFileName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strCancelStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmCancelDate				DATETIME,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strAckStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,
	strInternalErrorMessage		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnInternalMailSent			BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPLoadError_intStageLoadId] PRIMARY KEY ([intStageLoadId])
)

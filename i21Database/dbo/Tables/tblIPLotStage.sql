CREATE TABLE tblIPLotStage
(
	intStageLotId				INT IDENTITY(1,1),
	strItemNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLocationName				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSubLocationName			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStorageLocationName		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblQuantity					NUMERIC(38,20),
	strQuantityUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblNetWeight				NUMERIC(38,20),
	strNetWeightUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLotNumber				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblCost						NUMERIC(38,20),
	strCostUOM					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCostCurrency				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strBook						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSubBook					NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intTrxSequenceNo BIGINT,
	strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS,
	dtmCreatedDate DATETIME,
	strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,
	intStatusId					INT,

	CONSTRAINT [PK_tblIPLotStage_intStageLotId] PRIMARY KEY ([intStageLotId])
)

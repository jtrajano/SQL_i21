CREATE TABLE tblIPInvReceiptItemError
(
	intStageReceiptItemId		INT IDENTITY(1,1),
	intStageReceiptId			INT NOT NULL,
	strReceiptNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strERPPONumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strERPItemNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intContractSeq				INT,
	strItemNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLocationName				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSubLocationName			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strStorageLocationName		NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblQuantity					NUMERIC(18, 6),
	strQuantityUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblGrossWeight				NUMERIC(18, 6),
	dblTareWeight				NUMERIC(18, 6),
	dblNetWeight				NUMERIC(18, 6),
	strNetWeightUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblCost						NUMERIC(18, 6),
	strCostUOM					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCostCurrency				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strContainerNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strTrackingNo				INT,
	dblCleanGrossWeight			NUMERIC(18, 6),
	dblCleanTareWeight			NUMERIC(18, 6),
	dblCleanNetWeight			NUMERIC(18, 6),
	strCleanNetWeightUOM		NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	intTrxSequenceNo			BIGINT,
	intParentTrxSequenceNo		BIGINT,

	CONSTRAINT [PK_tblIPInvReceiptItemError_intStageReceiptItemId] PRIMARY KEY (intStageReceiptItemId),
	CONSTRAINT [FK_tblIPInvReceiptItemError_tblIPInvReceiptError_intStageReceiptId] FOREIGN KEY (intStageReceiptId) REFERENCES [tblIPInvReceiptError](intStageReceiptId) ON DELETE CASCADE
)

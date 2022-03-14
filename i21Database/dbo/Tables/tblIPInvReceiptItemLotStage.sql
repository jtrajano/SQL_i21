﻿CREATE TABLE tblIPInvReceiptItemLotStage
(
	intStageReceiptItemLotId	INT IDENTITY(1,1),
	intStageReceiptId			INT NOT NULL,
	intTrxSequenceNo			BIGINT,
	intParentTrxSequenceNo		BIGINT,

	strMotherLotNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLotNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblQuantity					NUMERIC(18, 6),
	strQuantityUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblGrossWeight				NUMERIC(18, 6),
	dblTareWeight				NUMERIC(18, 6),
	dblNetWeight				NUMERIC(18, 6),
	strWeightUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strLotPrimaryStatus			NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPInvReceiptItemLotStage_intStageReceiptItemLotId] PRIMARY KEY (intStageReceiptItemLotId),
	CONSTRAINT [FK_tblIPInvReceiptItemLotStage_tblIPInvReceiptStage_intStageReceiptId] FOREIGN KEY (intStageReceiptId) REFERENCES [tblIPInvReceiptStage](intStageReceiptId) ON DELETE CASCADE
)

﻿CREATE TABLE tblIPLoadDetailStage
(
	intStageLoadDetailId		INT IDENTITY(1,1),
	intStageLoadId				INT NOT NULL,
	strCustomerReference		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCommodityCode			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strItemNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strContractItemName			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	dblQuantity					NUMERIC(18, 6),
	dblGrossWeight				NUMERIC(18, 6),
	strPackageType				NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPLoadDetailStage_intStageLoadDetailId] PRIMARY KEY ([intStageLoadDetailId]),
	CONSTRAINT [FK_tblIPLoadDetailStage_tblIPLoadStage_intStageLoadId] FOREIGN KEY ([intStageLoadId]) REFERENCES [tblIPLoadStage]([intStageLoadId]) ON DELETE CASCADE
)

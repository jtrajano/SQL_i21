﻿CREATE TABLE tblIPInventoryAdjustmentStage (
	intInventoryAdjustmentStageId INT identity(1, 1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionTypeId INT
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMotherLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strReasonCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNotes NVARCHAR(2048) COLLATE Latin1_General_CI_AS
	,strNewStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strNewStorageUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intStatusId int
	,strOrderNo nvarchar(50)
	,intOrderCompleted integer
	,CONSTRAINT PK_tblIPInventoryAdjustmentStage PRIMARY KEY (intInventoryAdjustmentStageId)
	)

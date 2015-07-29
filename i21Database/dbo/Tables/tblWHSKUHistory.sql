﻿CREATE TABLE [dbo].[tblWHSKUHistory]
(
	[intSKUHistoryId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strSKUNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strSKUStatus] NVARCHAR(16) COLLATE Latin1_General_CI_AS NULL, 
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strItemDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intShelfLifeDays] INT NULL,
	[strLotCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL, 
	[strSerialNo] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
	[dblQty] NUMERIC(18,6),
	[dblSplitQty] NUMERIC(18,6),
	[dblCountQty] NUMERIC(18,6),
	[dtmReceiveDate] DATETIME,
	[dtmProductionDate] DATETIME,
	[strContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strAddressTitle] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
	[strStorageLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strOwnerTitle] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
	[strTaskType] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL, 
	[strNote] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL, 
	[strBOLNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intUOMId] INT NULL,
	[strReasonCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intChildSKUId] INT,
	[strOldUnitName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intParentSKUId] INT,
	[dblOldQty] NUMERIC(18,6),
	[strComment] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL, 
	[intLastUpdateId] INT,
	[dtmLastUpdateOn] DATETIME,

	CONSTRAINT [PK_tblWHSKUHistory_intSKUHistoryId]  PRIMARY KEY ([intSKUHistoryId]),	
	CONSTRAINT [FK_tblWHSKUHistory_tblICUnitMeasure_intUOMId] FOREIGN KEY ([intUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
)

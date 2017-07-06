﻿CREATE TABLE [dbo].[tblLGLoadDetailStg]
(
	[intLGLoadDetailStgId] INT IDENTITY(1,1) PRIMARY KEY,
	[intLoadStgId] INT,
	[intLoadId] INT,
	[intSIDetailId] INT,
	[intLoadDetailId] INT,
	[intRowNumber] INT,
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strSubLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strStorageLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strBatchNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblDeliveredQty] NUMERIC(18,6), 
	[strUnitOfMeasure] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblNetWt] NUMERIC(18,6), 
	[dblGrossWt] NUMERIC(18,6), 
	[strWeightUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[intHigherPositionRef] INT, 
	[strDocumentCategory] NVARCHAR(10) COLLATE Latin1_General_CI_AS, 
	[strReferenceDataInfo] NVARCHAR(10) COLLATE Latin1_General_CI_AS, 
	[strSeq] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strExternalPONumber] NVARCHAR (100)  COLLATE Latin1_General_CI_AS, 
	[strExternalPOItemNumber]	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[strExternalPOBatchNumber]	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[strExternalShipmentItemNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strExternalBatchNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCommodityCode] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strChangeType] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[dtmFeedCreated] DATETIME,

	CONSTRAINT [FK_tblLGLoadDetailStg_tblLGLoadStg_intLoadStgId] FOREIGN KEY ([intLoadStgId]) REFERENCES [dbo].[tblLGLoadStg] ([intLoadStgId]) ON DELETE CASCADE,
)
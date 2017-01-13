﻿CREATE TABLE [dbo].[tblLGLoadDetailStg]
(
	[intLGLoadDetailStgId] INT IDENTITY(1,1) PRIMARY KEY,
	[intLoadStgId] INT,
	[intLoadId] INT,
	[intRowNumber] INT,
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strSubLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strStorageLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strBatchNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblDeliveredQty] NUMERIC(18,6), 
	[strUnitOfMeasure] NVARCHAR(100), 
	[intHigherPositionRef] INT, 
	[strDocumentCategory] NVARCHAR(10) COLLATE Latin1_General_CI_AS, 
	[strReferenceDataInfo] NVARCHAR(10) COLLATE Latin1_General_CI_AS, 
	[strExternalPONumber] NVARCHAR (100)  COLLATE Latin1_General_CI_AS, 
	[strSeq] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strChangeType] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 

	CONSTRAINT [FK_tblLGLoadDetailStg_tblLGLoadStg_intLoadStgId] FOREIGN KEY ([intLoadStgId]) REFERENCES [dbo].[tblLGLoadStg] ([intLoadStgId]) ON DELETE CASCADE,
)
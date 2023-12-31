﻿CREATE TABLE [dbo].[tblWHCycleCountDetail]
(
	[intCycleCountDetailId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[intCycleCountHeaderId] INT NOT NULL,
	[intStorageLocationId] INT,
	[intContainerId] INT,
	[intSKUId] INT,
	[strUnknownContainerNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dblSKUQty] NUMERIC(18,6),
	[dblC1] NUMERIC(18,6),
	[strC1Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intC1UOMId] INT,
	[dblC2] NUMERIC(18,6),
	[strC2Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intC2UOMId] INT,
	[dblC3] NUMERIC(18,6),
	[strC3Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intC3UOMId] INT,
	[dblC4] NUMERIC(18,6),
	[strC4Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intC4UOMId] INT,
	[dblC5] NUMERIC(18,6),
	[strC5Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intC5UOMId] INT,
	[ysnRecount] BIT,
	[strNote] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL, 
	[intLotId] INT,
	[intLastUpdateId] INT,
	[dtmLastUpdateOn] DATETIME,

	CONSTRAINT [PK_tblWHCycleCountDetail_intCycleCountDetailId]  PRIMARY KEY ([intCycleCountDetailId]),
	CONSTRAINT [FK_tblWHCycleCountDetail_tblWHCycleCountHeader_intCycleCountHeaderId] FOREIGN KEY ([intCycleCountHeaderId]) REFERENCES [tblWHCycleCountHeader]([intCycleCountHeaderId]), 
	CONSTRAINT [FK_tblWHCycleCountDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])


)

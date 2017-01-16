CREATE TABLE [dbo].[tblLGLoadContainerStg]
(
	[intLoadContainerStgId] INT IDENTITY(1,1) PRIMARY KEY,
	[intLoadStgId] INT,
	[intLoadId] INT,
	[intLoadContainerId] INT,
	[strContainerNo] NVARCHAR(100)  COLLATE Latin1_General_CI_AS, 
	[strContainerSizeCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strPackagingMaterialType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strExternalPONumber] NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[strSeq] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblContainerQty] NUMERIC(18,6), 
	[strContainerUOM] NVARCHAR(100), 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[dtmFeedCreated] DATETIME,

	CONSTRAINT [FK_tblLGLoadContainerStg_tblLGLoadStg_intLoadStgId] FOREIGN KEY ([intLoadStgId]) REFERENCES [dbo].[tblLGLoadStg] ([intLoadStgId]) ON DELETE CASCADE,
)

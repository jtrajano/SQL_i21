CREATE TABLE [dbo].[tblLGLoadContainerLog]
(
	[intLoadContainerLogId] INT IDENTITY(1,1) PRIMARY KEY,
	[intLoadLogId] INT,
	[intLoadId] INT,
	[intLoadContainerId] INT,
	[strContainerNo] NVARCHAR(100)  COLLATE Latin1_General_CI_AS, 
	[strContainerSizeCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[strPackagingMaterialType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[strExternalPONumber] NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[strSeq] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblContainerQty] NUMERIC(18,6), 
	[strContainerUOM] NVARCHAR(100), 
	[dblNetWt] NUMERIC(18,6), 
	[dblGrossWt] NUMERIC(18,6), 
	[strWeightUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strExternalContainerId] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
)

CREATE TABLE [dbo].[tblMFPickForWOStaging]
(
	[intPickForStagingId] INT IDENTITY(1,1) NOT NULL,
	[intOrderHeaderId] INT NOT NULL,
	[strOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intTaskId] INT NULL,
	[intOrderLotId] INT NULL,
	[intPickedLotId] INT NULL,
	[dblOrderQty] NUMERIC(38, 20) NULL,
	[dblPickedQty] NUMERIC(38, 20) NULL,
	[intUserId] INT NULL,
	[strPickedFrom] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
)
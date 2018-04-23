CREATE TABLE [dbo].[tblSMOfflineLog]
(
	[intOfflineLogId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [strOfflineGuid]  NVARCHAR(200)  COLLATE Latin1_General_CI_AS UNIQUE NULL,
	[strUrl] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strData] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnSent] BIT NULL,
	[ysnLock] BIT NULL,
	[strContextId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strMethod] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[intFailed] INT NULL,
	[strDetails] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateUpdated] DATETIME NULL,
	[ysnComplete] BIT NULL,
	[ysnDetail] BIT NULL,
	[ysnReadyToTransfer] BIT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0
)

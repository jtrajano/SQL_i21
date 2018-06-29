CREATE TABLE [dbo].[tblPATAdjustVolume]
(
	[intAdjustmentId] INT NOT NULL IDENTITY, 
	[intCustomerId] INT NULL,
    [dtmAdjustmentDate] DATETIME NULL, 
    [strAdjustmentNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATAdjustVolume] PRIMARY KEY ([intAdjustmentId]) 
)
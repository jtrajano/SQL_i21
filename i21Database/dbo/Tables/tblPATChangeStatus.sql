CREATE TABLE [dbo].[tblPATChangeStatus]
(
	[intChangeStatusId] INT NOT NULL IDENTITY, 
    [dtmUpdateDate] DATETIME NULL, 
    [strUpdateNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmLastActivityDate] DATETIME NULL, 
    [strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATChangeStatus] PRIMARY KEY ([intChangeStatusId]) 
)
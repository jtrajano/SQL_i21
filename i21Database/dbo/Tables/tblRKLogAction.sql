CREATE TABLE [dbo].[tblRKLogAction]
(
	[intLogActionId] INT NOT NULL IDENTITY,
	[strActionIn] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strActionOut] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKLogAction] PRIMARY KEY ([intLogActionId])
)

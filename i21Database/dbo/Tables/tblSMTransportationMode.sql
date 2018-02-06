CREATE TABLE [dbo].[tblSMTransportationMode]
(
	[intTransportationModeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCode] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT 1, 
    CONSTRAINT [AK_tblSMTransportationMode_strCode] UNIQUE ([strCode])
)

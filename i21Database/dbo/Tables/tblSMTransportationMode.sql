CREATE TABLE [dbo].[tblSMTransportationMode]
(
	[intTransportationModeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCode] NVARCHAR(10) NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 1, 
    CONSTRAINT [AK_tblSMTransportationMode_strCode] UNIQUE ([strCode])
)

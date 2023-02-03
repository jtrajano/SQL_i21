CREATE TABLE [dbo].[tblCTContractDetailImportHeader]
(
	[intContractDetailImportHeaderId] INT IDENTITY NOT NULL, 
	[guiUniqueId] UNIQUEIDENTIFIER NULL,
    [dtmImportDate] DATETIME NULL, 
    [strFileName] NVARCHAR(100) NULL, 
    [intUserId] INT NULL, 
    [strContractNumber] NVARCHAR(50) NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),     
    CONSTRAINT [PK_tblCTContractDetailImportHeader] PRIMARY KEY ([intContractDetailImportHeaderId]) 
)

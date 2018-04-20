CREATE TABLE [dbo].[tblSMInterCompanyTransactionConfiguration]
(
	[intInterCompanyTransactionConfigurationId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strFromTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intFromCompanyId] INT NOT NULL,	
	[intFromProfitCenterId] INT NULL,	
	[strToTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intToCompanyId] INT NOT NULL,	
	[intToProfitCenterId] INT NULL,
	[intToEntityId] INT NULL,
	[strInsert] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strUpdate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDelete] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblSMMultiCompany_From] FOREIGN KEY ([intFromCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblCTBook_From] FOREIGN KEY ([intFromProfitCenterId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblSMMultiCompany_To] FOREIGN KEY ([intToCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblCTBook_To] FOREIGN KEY ([intToProfitCenterId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblEMEntity_To] FOREIGN KEY ([intToEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)

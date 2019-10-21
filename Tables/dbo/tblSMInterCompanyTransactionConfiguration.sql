CREATE TABLE [dbo].[tblSMInterCompanyTransactionConfiguration]
(
	[intInterCompanyTransactionConfigurationId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intFromTransactionTypeId] INT NOT NULL, 
    [intFromCompanyId] INT NOT NULL,	
	[intFromBookId] INT NULL,	
	[intToTransactionTypeId] INT NOT NULL, 
	[intToCompanyId] INT NOT NULL,	
	[intToBookId] INT NULL,
	[intEntityId] INT NULL,
	[intCompanyLocationId] INT NULL,
	[strInsert] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strUpdate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDelete] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblSMMultiCompany_From] FOREIGN KEY ([intFromCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblCTBook_From] FOREIGN KEY ([intFromBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblSMMultiCompany_To] FOREIGN KEY ([intToCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblCTBook_To] FOREIGN KEY ([intToBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblSMInterCompanyTransactionConfiguration_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)

CREATE TABLE [dbo].[tblSTRegisterFileConfiguration]
(
	[intRegisterFileConfigId] INT NOT NULL IDENTITY, 
    [intRegisterId] INT NULL, 
    [intImportFileHeaderId] INT NULL, 
    [strFileType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strFilePrefix] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strFileNamePattern] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strFolderPath] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strURICommand] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strStoredProcedure] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTRegisterFileConfiguration_intRegisterFileConfigId] PRIMARY KEY CLUSTERED ([intRegisterFileConfigId] ASC), 
    CONSTRAINT [FK_tblSTRegisterFileConfiguration_tblSTRegister_intRegisterId] FOREIGN KEY ([intRegisterId]) REFERENCES [tblSTRegister]([intRegisterId]), 
    CONSTRAINT [FK_tblSTRegisterFileConfiguration_tblSMImportFileHeader_intImportFileHeaderId] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])

)

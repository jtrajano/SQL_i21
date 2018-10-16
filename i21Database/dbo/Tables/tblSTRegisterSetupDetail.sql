CREATE TABLE [dbo].[tblSTRegisterSetupDetail]
(
	[intRegisterSetupDetailId] INT NOT NULL IDENTITY, 
    [intRegisterSetupId] INT NOT NULL, 
    [strImportFileHeaderName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strFileType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strFilePrefix] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strFileNamePattern] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    --[strFolderPath] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strURICommand] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strStoredProcedure] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblSTRegisterSetupDetail] PRIMARY KEY CLUSTERED ([intRegisterSetupDetailId] ASC), 
    CONSTRAINT [FK_tblSTRegisterSetupDetail_tblSTRegisterSetup_intRegisterId] FOREIGN KEY ([intRegisterSetupId]) REFERENCES [tblSTRegisterSetup]([intRegisterSetupId]),
	CONSTRAINT [AK_tblSTRegisterSetupDetail_intRegisterSetupId_strImportFileHeaderName_strStoredProcedure] UNIQUE ([intRegisterSetupId], [strImportFileHeaderName], [strStoredProcedure]),   
)
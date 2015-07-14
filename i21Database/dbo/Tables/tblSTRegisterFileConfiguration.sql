﻿CREATE TABLE [dbo].[tblSTRegisterFileConfiguration]
(
	[intRegisterFileConfigId] INT NOT NULL, 
    [intRegisterId] INT NULL, 
    [intLayoutId] INT NULL, 
    [strFileType] NVARCHAR(50) NULL, 
    [strFilePrefix] NVARCHAR(50) NULL, 
    [strFolderPath] NVARCHAR(MAX) NULL, 
    [strURICommand] NVARCHAR(MAX) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTRegisterFileConfiguration_intRegisterFileConfigId] PRIMARY KEY CLUSTERED ([intRegisterFileConfigId] ASC), 
    CONSTRAINT [FK_tblSTRegisterFileConfiguration_tblSTRegister_intRegisterId] FOREIGN KEY ([intRegisterId]) REFERENCES [tblSTRegister]([intRegisterId]), 
    CONSTRAINT [FK_tblSTRegisterFileConfiguration_tblSMGridLayout_intGridLayoutId] FOREIGN KEY ([intLayoutId]) REFERENCES [tblSMGridLayout]([intGridLayoutId])

)

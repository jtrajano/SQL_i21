CREATE TABLE [dbo].[tblSMDocumentType] (
    [intDocumentTypeId]	INT             IDENTITY (1, 1) NOT NULL,
    [strName]			NVARCHAR (150)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]	INT				NOT NULL,
    CONSTRAINT [PK_dbo.tblSMDocumentType] PRIMARY KEY CLUSTERED ([intDocumentTypeId] ASC), 
    CONSTRAINT [AK_tblSMDocumentType_strName] UNIQUE ([strName])
);
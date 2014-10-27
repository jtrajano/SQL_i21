CREATE TABLE [dbo].[tblSMMappingDictionary] (
    [intMappingDictionaryId] INT            IDENTITY (1, 1) NOT NULL,
    [intColumnDictionaryId]  INT            NOT NULL,
    [strSourceTable]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldName]           NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldType]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intSize]                INT            NULL,
    [strFieldStatus]         NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strConversionType]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT            NOT NULL,
    CONSTRAINT [PK_tblSMMappingDictionary] PRIMARY KEY CLUSTERED ([intMappingDictionaryId] ASC),
    CONSTRAINT [FK_tblSMMappingDictionary_tblSMColumnDictionary] FOREIGN KEY ([intColumnDictionaryId]) REFERENCES [dbo].[tblSMColumnDictionary] ([intColumnDictionaryId])
);


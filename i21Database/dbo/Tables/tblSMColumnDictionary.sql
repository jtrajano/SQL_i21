CREATE TABLE [dbo].[tblSMColumnDictionary] (
    [intColumnDictionaryId] INT            IDENTITY (1, 1) NOT NULL,
    [intTableDictionaryId]  INT            NOT NULL,
    [strFieldName]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFieldType]          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intSize]               INT            NULL,
    [strDescription]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            NOT NULL,
    CONSTRAINT [PK_tblSMColumnDictionary] PRIMARY KEY CLUSTERED ([intColumnDictionaryId] ASC),
    CONSTRAINT [FK_tblSMColumnDictionary_tblSMTableDictionary] FOREIGN KEY ([intTableDictionaryId]) REFERENCES [dbo].[tblSMTableDictionary] ([intTableDictionaryId])
);


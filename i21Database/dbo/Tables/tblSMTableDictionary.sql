CREATE TABLE [dbo].[tblSMTableDictionary] (
    [intTableDictionaryId] INT            IDENTITY (1, 1) NOT NULL,
    [strModuleName]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strTableName]         NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intManagerId]         INT            NOT NULL,
    [strLink]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            NOT NULL,
    CONSTRAINT [PK__tblSMTableDictionary] PRIMARY KEY CLUSTERED ([intTableDictionaryId] ASC)
);


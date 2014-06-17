CREATE TABLE [dbo].[tblFRRow] (
    [intRowId]         INT            IDENTITY (1, 1) NOT NULL,
    [strRowName]       NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intMapId]         INT            NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRRow] PRIMARY KEY CLUSTERED ([intRowId] ASC)
);


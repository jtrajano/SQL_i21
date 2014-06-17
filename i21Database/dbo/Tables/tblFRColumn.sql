CREATE TABLE [dbo].[tblFRColumn] (
    [intColumnId]      INT            IDENTITY (1, 1) NOT NULL,
    [intRowId]         INT            NULL,
    [strColumnName]    NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRColumn] PRIMARY KEY CLUSTERED ([intColumnId] ASC)
);


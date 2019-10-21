CREATE TABLE [dbo].[tblFRHeader] (
    [intHeaderId]      INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHeaderName]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHeaderType]    NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intColumnId]      INT            NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRHeader] PRIMARY KEY CLUSTERED ([intHeaderId] ASC)
);


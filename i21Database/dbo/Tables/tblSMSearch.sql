CREATE TABLE [dbo].[tblSMSearch] (
    [intSearchId]      INT           IDENTITY (1, 1) NOT NULL,
    [strScreen]        NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strModule]        NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intEntityId]      INT           NOT NULL,
    [intConcurrencyId] INT           NOT NULL,
    CONSTRAINT [PK_tblSMSearch] PRIMARY KEY CLUSTERED ([intSearchId] ASC),
    CONSTRAINT [FK_tblSMSearch_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
);




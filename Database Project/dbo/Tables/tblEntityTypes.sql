CREATE TABLE [dbo].[tblEntityTypes] (
    [intEntityTypeId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strType]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID] INT            NULL,
    CONSTRAINT [PK_dbo.tblEntityTypes] PRIMARY KEY CLUSTERED ([intEntityTypeId] ASC),
    CONSTRAINT [FK_dbo.tblEntityTypes_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId]) ON DELETE CASCADE
);




GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityTypes]([intEntityId] ASC);


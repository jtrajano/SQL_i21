CREATE TABLE [dbo].[tblEntityType] (
    [intEntityTypeId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strType]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_dbo.tblEntityType] PRIMARY KEY CLUSTERED ([intEntityTypeId] ASC),
    CONSTRAINT [FK_dbo.tblEntityType_dbo.tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEntityType]([intEntityId] ASC);


CREATE TABLE [dbo].[tblEMEntityType] (
    [intEntityTypeId]  INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strType]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_dbo.tblEMEntityType] PRIMARY KEY CLUSTERED ([intEntityTypeId] ASC),
    CONSTRAINT [FK_dbo.tblEMEntityType_dbo.tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblEMEntityType]([intEntityId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblEMEntityType_intEntityId_strType]
    ON [dbo].[tblEMEntityType]([intEntityId] ASC, [strType] ASC);


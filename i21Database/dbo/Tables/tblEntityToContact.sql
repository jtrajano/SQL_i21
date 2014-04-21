CREATE TABLE [dbo].[tblEntityToContact] (
    [intEntityToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intEntityId]          INT NULL,
    [intContactId]         INT NULL,
    [intLocationId]        INT NULL,
    [intConcurrencyId]     INT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblEntity2Contact] PRIMARY KEY CLUSTERED ([intEntityToContactId] ASC),
    CONSTRAINT [FK_tblEntityToContact_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [FK_tblEntityToContact_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityId]) ON DELETE SET DEFAULT,
    CONSTRAINT [FK_tblEntityToContact_tblEntityLocation] FOREIGN KEY ([intLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);


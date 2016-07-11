CREATE TABLE [dbo].[tblEMEntityToContact] (
    [intEntityToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intEntityId]          INT NULL,
    [intEntityContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,
	[strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL,
	[ysnPortalAccess]          BIT          NOT NULL,    
	[ysnDefaultContact] BIT NOT NULL DEFAULT ((0)), 
	[intEntityRoleId] INT NULL, 
    [intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntity2Contact1] PRIMARY KEY CLUSTERED ([intEntityToContactId] ASC),
    --CONSTRAINT [FK_tblEMEntityToContact_tblEMEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEMEntityContact] ([intEntityId]) ON DELETE CASCADE
	CONSTRAINT [FK_tblEMEntityToContact_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,    
    CONSTRAINT [FK_tblEMEntityToContact_tblEMEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT [FK_tblEMEntityToContact_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
    CONSTRAINT [FK_tblEMEntityToContact_tblSMUserRole] FOREIGN KEY ([intEntityRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID])
);

GO

CREATE NONCLUSTERED INDEX [IX_tblEMEntityToContact_intEntityId_ysnDefaultContact] ON [dbo].[tblEMEntityToContact] ([intEntityId], [ysnDefaultContact])




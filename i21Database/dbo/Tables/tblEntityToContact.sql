CREATE TABLE [dbo].[tblEntityToContact] (
    [intEntityToContactId] INT IDENTITY (1, 1) NOT NULL,
    [intEntityId]          INT NULL,
    [intEntityContactId]         INT NULL,
    [intEntityLocationId]        INT NULL,
	[strUserType]              NVARCHAR (5) COLLATE Latin1_General_CI_AS NULL,
	[ysnPortalAccess]          BIT          NOT NULL,    
	[ysnDefaultContact] BIT NOT NULL DEFAULT ((0)), 
    [intConcurrencyId]     INT DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEntity2Contact1] PRIMARY KEY CLUSTERED ([intEntityToContactId] ASC),
    --CONSTRAINT [FK_tblEntityToContact_tblEntityContact] FOREIGN KEY ([intContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityId]) ON DELETE CASCADE
	CONSTRAINT [FK_tblEntityToContact_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE,    
    CONSTRAINT [FK_tblEntityToContact_tblEntityContact] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT [FK_tblEntityToContact_tblEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId])
);






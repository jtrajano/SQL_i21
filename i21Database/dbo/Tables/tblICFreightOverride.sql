CREATE TABLE [dbo].[tblICFreightOverride]
(
	[intFreightOverrideId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] [int] NOT NULL,
	[intFreightOverrideItemId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[ysnActive] [bit] NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL,
	[dtmDateCreated] [datetime] NULL,
	[dtmDateModified] [datetime] NULL,
	[intCreatedByUserId] [int] NULL,
	[intModifiedByUserId] [int] NULL,
	[intRowNumber] [int] NULL,
	[guiApiUniqueId] [uniqueidentifier] NULL,
	CONSTRAINT [PK_tblICFreightOverride] PRIMARY KEY ([intFreightOverrideId]),
	CONSTRAINT [FK_tblICFreightOverride_Item] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICFreightOverride_FreightOverride] FOREIGN KEY ([intFreightOverrideItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblICFreightOverride_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
)

GO

CREATE NONCLUSTERED INDEX [IX_tblICFreightOverride_intFreightOverrideItemId]
	ON [dbo].[tblICFreightOverride]([intFreightOverrideItemId] ASC)
	INCLUDE ([intItemId])
GO

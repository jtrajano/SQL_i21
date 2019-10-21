CREATE TABLE [dbo].[tblSMUserSecurityFilterType]
(
	[intUserSecurityFilterTypeId]    INT             IDENTITY (1, 1) NOT NULL,
    [intEntityUserSecurityId]                   INT NOT NULL,    
    [strEntityType]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS  NULL,
	[ysnFilter]						BIT NOT NULL DEFAULT(0),
    [intConcurrencyId]              INT CONSTRAINT [DF_tblSMUserSecurityFilterType_intConcurrencyId] DEFAULT ((0)) NOT NULL,

	CONSTRAINT [FK_tblSMUserSecurityFilterType_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblSMUserSecurityFilterType_intEntityId_strType] UNIQUE NONCLUSTERED ([intEntityUserSecurityId] ASC, [strEntityType] ASC),
    CONSTRAINT [PK_tblSMUserSecurityFilterType] PRIMARY KEY CLUSTERED ([intUserSecurityFilterTypeId] ASC)
)

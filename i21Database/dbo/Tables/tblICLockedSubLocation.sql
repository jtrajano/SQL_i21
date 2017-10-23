CREATE TABLE [dbo].[tblICLockedSubLocation]
(
	[intLockedLocationId] INT NOT NULL IDENTITY(1, 1),
	[intTransactionId] INT NULL,
	[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSubLocationId] INT NOT NULL,
	[dtmDateCreated] DATETIME NULL,
	[intUserSecurityId] INT NULL,

	CONSTRAINT [PK_tblICLockedSubLocation] PRIMARY KEY ([intLockedLocationId]),
	CONSTRAINT [FK_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation](intCompanyLocationSubLocationId)
)

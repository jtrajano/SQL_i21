CREATE TABLE [dbo].[tblICLockedStorageLocation]
(
	[intLockedLocationId] INT NOT NULL IDENTITY(1, 1),
	[intTransactionId] INT NULL,
	[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intStorageLocationId] INT NOT NULL,
	[dtmDateCreated] DATETIME NULL,
	[intUserSecurityId] INT NULL,

	CONSTRAINT [PK_tblICLockedStorageLocation] PRIMARY KEY ([intLockedLocationId]),
	CONSTRAINT [FK_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation](intStorageLocationId)
)

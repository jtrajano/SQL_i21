CREATE TABLE [dbo].[tblICEdiMap]
(
	[Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[UniqueId] uniqueidentifier NULL,
	[Filename] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[FileType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[FileLength] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,
	[intConcurrencyId] INT NULL
)

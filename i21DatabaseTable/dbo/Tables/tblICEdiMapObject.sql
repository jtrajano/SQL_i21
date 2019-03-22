CREATE TABLE [dbo].[tblICEdiMapObject]
(
	[Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MapId] INT NULL,
	[Key] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[Value] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[Content] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[RecordIndex] INT NULL,
	[Length] INT NULL,
	[Index] INT NULL,
	[FileIndex] INT NULL,
	[Identifier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[DataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	[intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblICEdiMap_Id_tblICEdiMapObject_Id] FOREIGN KEY (MapId) REFERENCES [dbo].[tblICEdiMap]([Id]) ON DELETE CASCADE
)

CREATE TABLE [dbo].[tblICEdiMapTemplate]
(
	[intEdiMapTemplateId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [AK_tblICEdiMapTemplate_strName] UNIQUE ([strName])
)
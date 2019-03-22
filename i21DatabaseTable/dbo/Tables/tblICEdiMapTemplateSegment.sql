CREATE TABLE [dbo].[tblICEdiMapTemplateSegment]
(
	[intEdiMapTemplateSegmentId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intEdiMapTemplateId] INT NULL,
	[strKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strIdentifier] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDelimiter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intSequenceNo] INT NULL,
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	[intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblICEdiMapTemplate_intEdiMapTemplateId_tblICEdiMapTemplateSegment_intEdiMapTemplateId] FOREIGN KEY (intEdiMapTemplateId) REFERENCES [dbo].[tblICEdiMapTemplate]([intEdiMapTemplateId]) ON DELETE CASCADE
)
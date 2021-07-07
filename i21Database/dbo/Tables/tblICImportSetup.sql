CREATE TABLE [dbo].[tblICImportSetup]
(
	[intImportSetupId] INT IDENTITY(1, 1) NOT NULL,
	[strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFolder] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[strArchiveFolder] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[intEdiMapTemplateId] INT NULL,	
	[intScheduleId] INT NULL,	
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblICImportSetup] PRIMARY KEY ([intImportSetupId]), 
	CONSTRAINT [AK_tblICImportSetup_strName] UNIQUE ([strName]), 
	CONSTRAINT [FK_tblICImportSetup_tblSCHSchedule] FOREIGN KEY ([intScheduleId]) REFERENCES [tblSCHSchedule]([intScheduleId]), 
	CONSTRAINT [FK_tblICImportSetup_tblICEdiMapTemplate] FOREIGN KEY ([intEdiMapTemplateId]) REFERENCES [tblICEdiMapTemplate]([intEdiMapTemplateId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICImportSetup_strName]
	ON [dbo].[tblICImportSetup]([strName] ASC)
GO

CREATE TABLE [dbo].[tblICEdiMapTemplateSegmentDetail]
(
	[intEdiMapTemplateSegmentDetailId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intEdiMapTemplateSegmentId] INT NULL,
	[strKey] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDefaultValue] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[intLength] INT NULL,
	[intIndex] INT NULL,
	[strDataType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	[intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblICEdiMapTemplateSegment_intEdiMapTemplateSegmentId_tblICEdiMapTemplateSegmentDetail_intEdiMapTemplateSegmentId] FOREIGN KEY (intEdiMapTemplateSegmentId) REFERENCES [dbo].[tblICEdiMapTemplateSegment]([intEdiMapTemplateSegmentId]) ON DELETE CASCADE
)
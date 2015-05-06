CREATE TABLE [dbo].[tblQMConditionalProductProperty]
(
	[intConditionalProductPropertyId] INT NOT NULL IDENTITY, 
	[intProductPropertyId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMConditionalProductProperty_intConcurrencyId] DEFAULT 0, 
	[intOnSuccessPropertyId] INT NULL, 
	[intOnFailurePropertyId] INT NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMConditionalProductProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMConditionalProductProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMConditionalProductProperty] PRIMARY KEY ([intConditionalProductPropertyId]), 
	CONSTRAINT [FK_tblQMConditionalProductProperty_tblQMProductProperty] FOREIGN KEY ([intProductPropertyId]) REFERENCES [tblQMProductProperty]([intProductPropertyId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMConditionalProductProperty_tblQMProperty_intOnSuccessPropertyId] FOREIGN KEY ([intOnSuccessPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMConditionalProductProperty_tblQMProperty_intOnFailurePropertyId] FOREIGN KEY ([intOnFailurePropertyId]) REFERENCES [tblQMProperty]([intPropertyId]) 
)
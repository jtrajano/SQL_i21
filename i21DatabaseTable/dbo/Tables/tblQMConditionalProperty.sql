CREATE TABLE [dbo].[tblQMConditionalProperty]
(
	[intConditionalPropertyId] INT NOT NULL IDENTITY, 
	[intPropertyId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMConditionalProperty_intConcurrencyId] DEFAULT 0, 
	[intOnSuccessPropertyId] INT NULL, 
	[intOnFailurePropertyId] INT NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMConditionalProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMConditionalProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMConditionalProperty] PRIMARY KEY ([intConditionalPropertyId]), 
	CONSTRAINT [FK_tblQMConditionalProperty_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMConditionalProperty_tblQMProperty_intOnSuccessPropertyId] FOREIGN KEY ([intOnSuccessPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMConditionalProperty_tblQMProperty_intOnFailurePropertyId] FOREIGN KEY ([intOnFailurePropertyId]) REFERENCES [tblQMProperty]([intPropertyId]) 
)
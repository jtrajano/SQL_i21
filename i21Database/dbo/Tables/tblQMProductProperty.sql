CREATE TABLE [dbo].[tblQMProductProperty]
(
	[intProductPropertyId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProductProperty_intConcurrencyId] DEFAULT 0, 
	[intProductId] INT NOT NULL, 
	[intTestId] INT NOT NULL, 
	[intPropertyId] INT NOT NULL, 
	[strFormulaParser] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strComputationMethod] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
	[intSequenceNo] INT NOT NULL CONSTRAINT [DF_tblQMProductProperty_intSequenceNo] DEFAULT 1, 
	[intComputationTypeId] INT NOT NULL CONSTRAINT [DF_tblQMProductProperty_intComputationTypeId] DEFAULT 1, 
	[strFormulaField] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProductProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProductProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProductProperty] PRIMARY KEY ([intProductPropertyId]), 
	CONSTRAINT [FK_tblQMProductProperty_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMProductProperty_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]), 
	CONSTRAINT [FK_tblQMProductProperty_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMProductProperty_tblQMComputationType] FOREIGN KEY ([intComputationTypeId]) REFERENCES [tblQMComputationType]([intComputationTypeId]) 
)
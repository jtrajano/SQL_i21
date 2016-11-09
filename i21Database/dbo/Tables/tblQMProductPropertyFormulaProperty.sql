CREATE TABLE [dbo].[tblQMProductPropertyFormulaProperty]
(
	[intProductPropertyFormulaPropertyId] INT NOT NULL IDENTITY, 
	[intProductPropertyId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProductPropertyFormulaProperty_intConcurrencyId] DEFAULT 0, 
	[intTestId] INT NULL, 
	[intPropertyId] INT NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProductPropertyFormulaProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProductPropertyFormulaProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProductPropertyFormulaProperty] PRIMARY KEY ([intProductPropertyFormulaPropertyId]), 
	CONSTRAINT [FK_tblQMProductPropertyFormulaProperty_tblQMProductProperty] FOREIGN KEY ([intProductPropertyId]) REFERENCES [tblQMProductProperty]([intProductPropertyId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMProductPropertyFormulaProperty_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]),
	CONSTRAINT [FK_tblQMProductPropertyFormulaProperty_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId])
)
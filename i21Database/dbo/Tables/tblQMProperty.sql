CREATE TABLE [dbo].[tblQMProperty]
(
	[intPropertyId] INT NOT NULL IDENTITY, 
	[intAnalysisTypeId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProperty_intConcurrencyId] DEFAULT 0, 
	[strPropertyName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intDataTypeId] INT NOT NULL, 
	[intListId] INT, 
	[intDecimalPlaces] INT, 
	[strIsMandatory] NVARCHAR(20) COLLATE Latin1_General_CI_AS DEFAULT 'No', 
	[ysnActive] BIT NOT NULL CONSTRAINT [DF_tblQMProperty_ysnActive] DEFAULT 1, 
	[strFormula] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strFormulaParser] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProperty] PRIMARY KEY ([intPropertyId]), 
	CONSTRAINT [AK_tblQMProperty_strPropertyName] UNIQUE ([strPropertyName]), 
	CONSTRAINT [FK_tblQMProperty_tblQMAnalysisType] FOREIGN KEY ([intAnalysisTypeId]) REFERENCES [tblQMAnalysisType]([intAnalysisTypeId]), 
	CONSTRAINT [FK_tblQMProperty_tblQMDataType] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblQMDataType]([intDataTypeId]), 
	CONSTRAINT [FK_tblQMProperty_tblQMList] FOREIGN KEY ([intListId]) REFERENCES [tblQMList]([intListId]) 
)
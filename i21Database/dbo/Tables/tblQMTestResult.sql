CREATE TABLE [dbo].[tblQMTestResult]
(
	[intTestResultId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMTestResult_intConcurrencyId] DEFAULT 0, 
	[intSampleId] INT NOT NULL, 
	[intProductId] INT, 
	[intProductTypeId] INT NOT NULL, 
	[intProductValueId] INT NOT NULL, -- Foreign Key
	[intTestId] INT NOT NULL, 
	[intPropertyId] INT NOT NULL, 
	[strPanelList] NVARCHAR(50) COLLATE Latin1_General_CI_AS DEFAULT '', 
	[strPropertyValue] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[dtmCreateDate] DATETIME, 
	[strResult] NVARCHAR(20) COLLATE Latin1_General_CI_AS, 
	[ysnFinal] BIT NOT NULL CONSTRAINT [DF_tblQMTestResult_ysnFinal] DEFAULT 0,  
	[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[intSequenceNo] INT NOT NULL CONSTRAINT [DF_tblQMTestResult_intSequenceNo] DEFAULT 1, 
	[dtmValidFrom] DATETIME NOT NULL, 
    [dtmValidTo] DATETIME NOT NULL, 
	[strPropertyRangeText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblQMTestResult_strPropertyRangeText] DEFAULT '', 
	[dblMinValue] NUMERIC(18, 6) NULL,
	[dblMaxValue] NUMERIC(18, 6) NULL,
	[dblLowValue] NUMERIC(18, 6) NULL,
	[dblHighValue] NUMERIC(18, 6) NULL,
	[intUnitMeasureId] INT NULL, 
	[strFormulaParser] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[intTransactionTypeId] INT, -- is it reqd?
	[intTransactionTypeObjectId] INT, -- Foreign Key. is it reqd?
	[dblCrdrPrice] NUMERIC(18, 6) NULL,
	[dblCrdrQty] NUMERIC(18, 6) NULL,
	[intProductPropertyValidityPeriodId] INT, 
	[intControlPointId] INT, 
	[intParentPropertyId] INT NULL, -- Foreign Key. is it reqd?
	[intRepNo] INT NULL, 
	[strFormula] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMTestResult_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMTestResult_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMTestResult] PRIMARY KEY ([intTestResultId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMSample] FOREIGN KEY ([intSampleId]) REFERENCES [tblQMSample]([intSampleId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMTestResult_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMTestResult_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProductPropertyValidityPeriod] FOREIGN KEY ([intProductPropertyValidityPeriodId]) REFERENCES [tblQMProductPropertyValidityPeriod]([intProductPropertyValidityPeriodId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMControlPoint] FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId]) 
)

﻿CREATE TABLE [dbo].[tblQMTestResult]
(
	[intTestResultId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMTestResult_intConcurrencyId] DEFAULT 0, 
	[intSampleId] INT, 
	[intProductId] INT, 
	[intProductTypeId] INT NOT NULL, 
	[intProductValueId] INT NULL CONSTRAINT [DF_tblQMTestResult_intProductValueId] DEFAULT 0, 
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
	[dblMinValue] NUMERIC(18, 6),
	[dblMaxValue] NUMERIC(18, 6),
	[dblLowValue] NUMERIC(18, 6),
	[dblHighValue] NUMERIC(18, 6),
	[intUnitMeasureId] INT, 
	[strFormulaParser] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[dblCrdrPrice] NUMERIC(18, 6),
	[dblCrdrQty] NUMERIC(18, 6),
	[intProductPropertyValidityPeriodId] INT, -- Keeping it as dummy since will not allow to modify properties in template
	[intPropertyValidityPeriodId] INT, -- For Conditional Property
	[intControlPointId] INT, 
	[intParentPropertyId] INT, 
	[intRepNo] INT, 
	[strFormula] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[intListItemId] INT, 
	[strIsMandatory] NVARCHAR(20) COLLATE Latin1_General_CI_AS DEFAULT 'No', 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMTestResult_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMTestResult_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMTestResult] PRIMARY KEY ([intTestResultId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMSample] FOREIGN KEY ([intSampleId]) REFERENCES [tblQMSample]([intSampleId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMTestResult_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProductType] FOREIGN KEY ([intProductTypeId]) REFERENCES [tblQMProductType]([intProductTypeId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProperty_intPropertyId] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMTestResult_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMPropertyValidityPeriod] FOREIGN KEY ([intPropertyValidityPeriodId]) REFERENCES [tblQMPropertyValidityPeriod]([intPropertyValidityPeriodId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMControlPoint] FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMProperty_intParentPropertyId] FOREIGN KEY ([intParentPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMTestResult_tblQMListItem] FOREIGN KEY ([intListItemId]) REFERENCES [tblQMListItem]([intListItemId]) 
)

GO

CREATE INDEX [IX_tblQMTestResult_intSampleId] ON [dbo].[tblQMTestResult] ([intSampleId])

GO

CREATE INDEX [IX_tblQMTestResult_intPropertyId] ON [dbo].[tblQMTestResult] ([intPropertyId])

GO

CREATE INDEX [IX_tblQMTestResult_intSampleId_intPropertyId] ON [dbo].[tblQMTestResult] ([intSampleId], [intPropertyId])

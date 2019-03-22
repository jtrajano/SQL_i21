CREATE TABLE [dbo].[tblQMProductPropertyValidityPeriod]
(
	[intProductPropertyValidityPeriodId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProductPropertyValidityPeriod_intConcurrencyId] DEFAULT 0, 
	[intProductPropertyId] INT NOT NULL, 
	[dtmValidFrom] DATETIME NOT NULL, 
    [dtmValidTo] DATETIME NOT NULL, 
	[strPropertyRangeText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblQMProductPropertyValidityPeriod_strPropertyRangeText] DEFAULT '', 
	[dblMinValue] NUMERIC(18, 6) NULL,
	[dblMaxValue] NUMERIC(18, 6) NULL,
	[dblLowValue] NUMERIC(18, 6) NULL,
	[dblHighValue] NUMERIC(18, 6) NULL,
	[intUnitMeasureId] INT NULL, 
	[strFormula] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strFormulaParser] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProductPropertyValidityPeriod_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProductPropertyValidityPeriod_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProductPropertyValidityPeriod] PRIMARY KEY ([intProductPropertyValidityPeriodId]), 
	CONSTRAINT [FK_tblQMProductPropertyValidityPeriod_tblQMProductProperty] FOREIGN KEY ([intProductPropertyId]) REFERENCES [tblQMProductProperty]([intProductPropertyId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMProductPropertyValidityPeriod_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
)
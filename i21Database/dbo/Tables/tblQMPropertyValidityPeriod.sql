CREATE TABLE [dbo].[tblQMPropertyValidityPeriod]
(
	[intPropertyValidityPeriodId] INT NOT NULL IDENTITY, 
	[intPropertyId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMPropertyValidityPeriod_intConcurrencyId] DEFAULT 0, 
	[dtmValidFrom] DATETIME NOT NULL, 
    [dtmValidTo] DATETIME NOT NULL, 
	[strPropertyRangeText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblQMPropertyValidityPeriod_strPropertyRangeText] DEFAULT '', 
	[dblMinValue] NUMERIC(18, 6) NULL,
	[dblMaxValue] NUMERIC(18, 6) NULL,
	[dblLowValue] NUMERIC(18, 6) NULL,
	[dblHighValue] NUMERIC(18, 6) NULL,
	[intUnitMeasureId] INT NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMPropertyValidityPeriod_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMPropertyValidityPeriod_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMPropertyValidityPeriod] PRIMARY KEY ([intPropertyValidityPeriodId]), 
	CONSTRAINT [FK_tblQMPropertyValidityPeriod_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMPropertyValidityPeriod_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
)
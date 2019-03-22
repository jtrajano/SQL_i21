CREATE TABLE tblGRReadingRanges
(
	[intReadingRangeId] INT NOT NULL IDENTITY(1,1),
    [strReadingRange] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intMinValue] DECIMAL(18,6) NULL,
    [intMaxValue] DECIMAL(18,6) NULL,
	[intReadingType] INT NULL
)
CREATE TABLE [dbo].[tblIPSecondaryStepDetail]
(
	[intSecondaryStepDetailId] INT NOT NULL IDENTITY,
	[intStepId] INT NOT NULL,
	[strDestinationColumnName] NVARCHAR(128) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDataTypeId] INT NOT NULL,
	[intSize] INT DEFAULT 0,
	[intPrecision] INT DEFAULT 0,
	[intScale] INT DEFAULT 0,
	[intPosition] INT DEFAULT 0,
	[strSourceColumnName] NVARCHAR(128) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblIPSecondaryStepDetail_intStepDetailId] PRIMARY KEY ([intSecondaryStepDetailId]),
	CONSTRAINT [FK_tblIPSecondaryStepDetail_tblIPStep_intStepId] FOREIGN KEY ([intStepId]) REFERENCES [tblIPStep]([intStepId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblIPSecondaryStepDetail_tblIPDataType_intDataTypeId] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblIPDataType]([intDataTypeId]),
)

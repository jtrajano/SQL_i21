CREATE TABLE [dbo].[tblIPStepDetail]
(
	[intStepDetailId] INT NOT NULL IDENTITY,
	[intStepId] INT NOT NULL,
	[strDestinationColumnName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDataTypeId] INT NOT NULL,
	[intSize] INT DEFAULT 0,
	[intPrecision] INT DEFAULT 0,
	[intScale] INT DEFAULT 0,
	[intPosition] INT DEFAULT 0,
	[strSourceColumnName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
	[intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblIPStepDetail_intStepDetailId] PRIMARY KEY ([intStepDetailId]),
	CONSTRAINT [FK_tblIPStepDetail_tblIPStep_intStepId] FOREIGN KEY ([intStepId]) REFERENCES [tblIPStep]([intStepId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblIPStepDetail_tblIPDataType_intDataTypeId] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblIPDataType]([intDataTypeId]),
)

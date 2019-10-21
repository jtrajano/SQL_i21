CREATE TABLE [dbo].[tblIPParameter]
(
	[intParameterId] INT NOT NULL IDENTITY, 
    [intStepId] INT NOT NULL, 
    [strParameterName] NVARCHAR(50) NULL, 
    [intDataTypeId] INT NULL,
	[intSize] INT DEFAULT 0,
	[intPrecision] INT DEFAULT 0,
	[intScale] INT DEFAULT 0, 
    [strValue] NVARCHAR(512) NULL, 
    [ysnValueFromPreviousStep] BIT NULL DEFAULT 0, 
	[intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblIPParameter_intParameterId] PRIMARY KEY ([intParameterId]),
	CONSTRAINT [FK_tblIPParameter_tblIPStep_intStepId] FOREIGN KEY ([intStepId]) REFERENCES [tblIPStep]([intStepId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblIPParameter_tblIPDataType_intDataTypeId] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblIPDataType]([intDataTypeId]),
)

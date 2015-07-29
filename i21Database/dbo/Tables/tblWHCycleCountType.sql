CREATE TABLE [dbo].[tblWHCycleCountType]
(
	[intCycleCountTypeID] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strCycleCountTypeCode] NVARCHAR(32),

	CONSTRAINT [PK_tblWHCycleCountType_intCycleCountTypeID] PRIMARY KEY ([intCycleCountTypeID])

)

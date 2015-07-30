CREATE TABLE [dbo].[tblWHCycleCountType]
(
	[intCycleCountTypeID] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL,
	[strCycleCountTypeCode] NVARCHAR(32) COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [PK_tblWHCycleCountType_intCycleCountTypeID] PRIMARY KEY ([intCycleCountTypeID])

)

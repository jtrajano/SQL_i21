CREATE TABLE [dbo].[tblBBRate](
	[intRateId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NULL, 
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRate_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [intCustomerLocationId] INT NULL, 
    [intUnitMeasureId] INT NULL, 
    [dtmBeginDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NULL, 
    CONSTRAINT [PK_tblBBRate] PRIMARY KEY CLUSTERED ([intRateId] ASC), 
    CONSTRAINT [FK_tblBBRate_tblBBProgramCharge] FOREIGN KEY ([intProgramChargeId]) REFERENCES [tblBBProgramCharge] ([intProgramChargeId]) ON DELETE CASCADE,
)
GO

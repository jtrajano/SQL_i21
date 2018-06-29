CREATE TABLE [dbo].[tblBBRateLocation](
	[intRateLocationId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NOT NULL, 
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRateLocation_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblBBRateLocation_dblRatePerUnit]  DEFAULT ((0)), 
	[intVendorLocationId] INT NULL,
    [intUnitMeasureId] INT NULL, 
    [intCustomerLocationId] INT NULL, 
    CONSTRAINT [PK_tblBBRateLocation] PRIMARY KEY CLUSTERED ([intRateLocationId] ASC),
	CONSTRAINT [FK_tblBBRateLocation_tblBBProgramCharge] FOREIGN KEY (intProgramChargeId) REFERENCES [tblBBProgramCharge]([intProgramChargeId]), 
)
GO
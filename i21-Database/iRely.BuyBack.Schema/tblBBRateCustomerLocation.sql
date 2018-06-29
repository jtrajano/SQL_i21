CREATE TABLE [dbo].[tblBBRateCustomerLocation](
	[intRateCustomerLocationId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NULL, 
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRateCustomerLocation_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblBBRateCustomerLocation_dblRatePerUnit]  DEFAULT ((0)), 
	[intCustomerLocationId] INT NOT NULL,
    [intUnitMeasureId] INT NULL, 
    CONSTRAINT [PK_tblBBRateCustomerLocation] PRIMARY KEY CLUSTERED ([intRateCustomerLocationId] ASC),
	CONSTRAINT [FK_tblBBRateCustomerLocation_tblBBProgramCharge] FOREIGN KEY (intProgramChargeId) REFERENCES [tblBBProgramCharge]([intProgramChargeId]), 
)
GO

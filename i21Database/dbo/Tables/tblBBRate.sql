CREATE TABLE [dbo].[tblBBRate](
	[intRateId] [int] IDENTITY(1,1) NOT NULL,
	
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRate_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [strType] NVARCHAR(20) NOT NULL, 
    [intVendorLocationId] INT NULL, 
    [intCustomerLocationId] INT NULL, 
    [intUnitMeasureId] INT NULL, 
    [dtmBeginDate] DATETIME NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NULL, 
    CONSTRAINT [PK_tblBBRate] PRIMARY KEY CLUSTERED ([intRateId] ASC),
)
GO

CREATE TABLE [dbo].[tblBBRateVendorLocation](
	[intRateVendorLocationId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NOT NULL, 
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRateVendorLocation_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblBBRateVendorLocation_dblRatePerUnit]  DEFAULT ((0)), 
	[intVendorLocationId] INT NOT NULL,
    [intUnitMeasureId] INT NULL, 
    CONSTRAINT [PK_tblBBRateVendorLocation] PRIMARY KEY CLUSTERED ([intRateVendorLocationId] ASC),
	CONSTRAINT [FK_tblBBRateVendorLocation_tblBBProgramCharge] FOREIGN KEY (intProgramChargeId) REFERENCES [tblBBProgramCharge]([intProgramChargeId]), 
)
GO

CREATE TABLE [dbo].[tblMBILShift]
(
	[intShiftId] INT NOT NULL IDENTITY, 
    [dtmShiftDate] DATETIME NULL, 
    [intDriverId] INT NULL, 
    [intLocationId] INT NULL, 
    [intShiftNumber] INT NULL, 
    [dtmStartTime] DATETIME NULL, 
    [dtmEndTime] DATETIME NULL, 
    [intTruckId] INT NULL, 
    [intStartOdometer] INT NULL, 
    [intEndOdometer] INT NULL, 
    [dblFuelGallonsDelievered] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblFuelSales] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblMBILShift] PRIMARY KEY ([intShiftId])
)

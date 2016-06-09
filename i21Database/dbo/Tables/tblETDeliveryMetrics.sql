CREATE TABLE [dbo].[tblETDeliveryMetrics]
(
    [intDeliveryMetricsId] INT NOT NULL IDENTITY , 
    [intBeginningOdometerReading] INT NULL, 
    [intEndingOdometerReading] INT NULL, 
    [dblGallonsDelivered] NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblTotalFuelSales] NUMERIC(18, 6) NULL DEFAULT 0, 
    [intTotalInvoice] INT NULL, 
    [strDriverNumber] NVARCHAR(50) NULL, 
    [strTruckNumber] NVARCHAR(50) NULL, 
    [strShiftNumber] NVARCHAR(10) NULL, 
    [dtmShiftBeginDate] DATETIME NULL, 
	[dtmShiftEndDate] DATETIME NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblETDeliveryMetrics] PRIMARY KEY ([intDeliveryMetricsId])
)
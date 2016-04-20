CREATE TABLE [dbo].[tblETDeliveryMetrics]
(
	[intDeliveryMetricsId] INT NOT NULL PRIMARY KEY, 
    [intBeginningOdometerReading ] INT NULL, 
    [intEndingOdometerReading] INT NULL, 
    [dblGallonsDelivered] NUMERIC(18, 6) NULL DEFAULT 0, 
    [dblTotalFuelSales] NUMERIC(18, 6) NULL DEFAULT 0, 
    [intTotalInvoice] INT NULL, 
    [strDriverNumber] NVARCHAR(50) NULL, 
    [strTruckNumber] NVARCHAR(50) NULL
)

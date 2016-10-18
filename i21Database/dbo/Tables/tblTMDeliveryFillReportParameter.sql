CREATE TABLE [dbo].[tblTMDeliveryFillReportParameter]
(
	[intDeliveryFillReportParameterId] INT             IDENTITY (1, 1) NOT NULL,
	[strLocations]               NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
	[strProductIds]               NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
	[strFillMethods]               NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
	[strDriverIds]               NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
	[strRouteIds]               NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS  NULL,
	[strstrPending]               NVARCHAR(10)   COLLATE Latin1_General_CI_AS  NULL,
	[strOnHold]               NVARCHAR(10)   COLLATE Latin1_General_CI_AS  NULL,
	[dblEstimatedPercentLeft]               NUMERIC(18,6)    NULL,
	[dblCalculatedQuantityFrom] NUMERIC(18, 6) NULL, 
    [dblCalculatedQuantityTo] NUMERIC(18, 6) NULL, 
    [intNextDeliveryDegreeDayFrom] INT NULL, 
    [intNextDeliveryDegreeDayTo] INT NULL, 
    [dtmNextDeliveryFrom] DATETIME NULL, 
    [dtmNextDeliveryTo] DATETIME NULL, 
    [dtmRequestedTo] DATETIME NULL, 
    [dtmRequestedFrom] DATETIME NULL, 
    [dtmForecastedDeliveryTo] DATETIME NULL, 
    [dtmForecastedDeliveryFrom] DATETIME NULL, 
    [intEntityUserId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblTMDeliveryFillReportParameter] PRIMARY KEY CLUSTERED ([intDeliveryFillReportParameterId] ASC),
)

GO

CREATE INDEX [IX_tblTMDeliveryFillReportParameter_intEntityUserId] ON [dbo].[tblTMDeliveryFillReportParameter] ([intEntityUserId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strLocations'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Product',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strProductIds'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strFillMethods'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strDriverIds'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strRouteIds'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pending',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strstrPending'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Hold',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'strOnHold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated Percent Left',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedPercentLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculated Quantity From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dblCalculatedQuantityFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculated Quantity To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dblCalculatedQuantityTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Delivery Degree Day From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'intNextDeliveryDegreeDayFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Delivery Degree Day To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'intNextDeliveryDegreeDayTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nest Delivery Date From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmNextDeliveryFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nest Delivery Date To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmNextDeliveryTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requested Date From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmRequestedTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requested Date To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmRequestedFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Forecasted Delivery To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmForecastedDeliveryTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Forecasted Delivery From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'dtmForecastedDeliveryFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'intEntityUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeliveryFillReportParameter',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
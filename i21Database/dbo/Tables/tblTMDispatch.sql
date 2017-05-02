CREATE TABLE [dbo].[tblTMDispatch] (
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    [intDispatchID]            INT             IDENTITY (1, 1) NOT NULL,
    [intSiteID]                INT             DEFAULT 0 NULL,
    [dblPercentLeft]           NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblQuantity]              NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblMinimumQuantity]       NUMERIC (18, 6) DEFAULT 0 NULL,
    [intProductID]             INT             DEFAULT 0 NULL,
    [intSubstituteProductID]   INT             DEFAULT 0 NULL,
    [dblPrice]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblTotal]                 NUMERIC (18, 6) DEFAULT 0 NULL,
    [dtmRequestedDate]         DATETIME        DEFAULT 0 NULL,
    [intPriority]              INT             DEFAULT 0 NULL,
    [strComments]              NVARCHAR (200)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [ysnCallEntryPrinted]      BIT             DEFAULT 0 NULL,
    [intDriverID]              INT             DEFAULT 0 NULL,
    [intDispatchDriverID]      INT             DEFAULT 0 NULL,
    [strDispatchLoadNumber]    NVARCHAR (3)    COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [dtmCallInDate]            DATETIME        DEFAULT 0 NULL,
    [ysnSelected]              BIT             DEFAULT 0 NULL,
    [strRoute]                 NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strSequence]              NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intUserID]                INT             DEFAULT 0 NULL,
    [dtmLastUpdated]           DATETIME        DEFAULT 0 NULL,
    [ysnDispatched]            BIT             NULL,
    [strCancelDispatchMessage] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intDeliveryTermID]        INT             NULL,
    [dtmDispatchingDate]       DATETIME        NULL,
    [strWillCallStatus] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT ('Generated'), 
    [strPricingMethod] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT ('Regular'), 
    [strOrderNumber] NCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDeliveryDate] DATETIME NULL, 
    [dblDeliveryQuantity] NUMERIC(18, 6) NULL, 
    [dblDeliveryPrice] NUMERIC(18, 6) NULL, 
    [dblDeliveryTotal] NUMERIC(18, 6) NULL, 
    [intContractId] INT NULL, 
    [ysnLockPrice] BIT NOT NULL DEFAULT 0, 
    [intRouteId] INT NULL, 
    [ysnReceived] BIT NOT NULL DEFAULT 0, 
    [ysnLeakCheckRequired] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblTMDispatch] PRIMARY KEY CLUSTERED ([intDispatchID] ASC),
    CONSTRAINT [FK_tblTMDispatch_tblTMSite1] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblTMDispatch_tblLGRoute] FOREIGN KEY ([intRouteId]) REFERENCES [dbo].[tblLGRoute] ([intRouteId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intDispatchID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent Left',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentLeft'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblMinimumQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intProductID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Substitute Item ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intSubstituteProductID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requested Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dtmRequestedDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Priority',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intPriority'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strComments'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if call entry is printed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnCallEntryPrinted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intDriverID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dispatch Driver ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intDispatchDriverID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strDispatchLoadNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Call in Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dtmCallInDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolete/Unused',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnSelected'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strRoute'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sequence',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strSequence'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Updated',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if call entry is already dispatched',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnDispatched'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cancel Dispatch Message',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strCancelDispatchMessage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Term',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intDeliveryTermID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date of Dispatch',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dtmDispatchingDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status for Orders/Will Call',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strWillCallStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pricing method used in will call order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strPricingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Number for the will call',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'strOrderNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ET Delivery Date Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dtmDeliveryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ET Delivery Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblDeliveryQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ET Delivery Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblDeliveryPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ET Delivery Total including Taxes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'dblDeliveryTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Id Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intContractId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lock Price Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnLockPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route Sequence Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'intRouteId'
GO

CREATE INDEX [IX_tblTMDispatch_intSiteID] ON [dbo].[tblTMDispatch] ([intSiteID])

GO

CREATE INDEX [IX_tblTMDispatch_intRouteId] ON [dbo].[tblTMDispatch] ([intRouteId])

GO

CREATE INDEX [IX_tblTMDispatch_intProductID] ON [dbo].[tblTMDispatch] ([intProductID])

GO

CREATE INDEX [IX_tblTMDispatch_intSubstituteProductID] ON [dbo].[tblTMDispatch] ([intSubstituteProductID])

GO

CREATE INDEX [IX_tblTMDispatch_intDriverID] ON [dbo].[tblTMDispatch] ([intDriverID])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Received Flag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Leak Check Required Flag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDispatch',
    @level2type = N'COLUMN',
    @level2name = N'ysnLeakCheckRequired'

GO
CREATE NONCLUSTERED INDEX [IX_tblTMDispatch_strOrderNumber] ON [dbo].[tblTMDispatch]
(
	[strOrderNumber] ASC
)
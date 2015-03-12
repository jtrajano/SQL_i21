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
    CONSTRAINT [PK_tblTMDispatch] PRIMARY KEY CLUSTERED ([intDispatchID] ASC),
    CONSTRAINT [FK_tblTMDispatch_tblTMSite1] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID])
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
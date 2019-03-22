CREATE TABLE [dbo].[tblTMWorkOrder] (
    [intWorkOrderID]      INT            IDENTITY (1, 1) NOT NULL,
    [strWorkOrderNumber]  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intWorkStatusTypeID] INT            NOT NULL,
    [intPerformerID]      INT            NOT NULL,
    [strAdditionalInfo]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intEnteredByID]      INT            NULL,
    [dtmDateCreated]      DATETIME       NULL,
    [dtmDateClosed]       DATETIME       NULL,
    [dtmDateScheduled]    DATETIME       NULL,
    [intCloseReasonID]    INT            NULL,
    [strComments]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intSiteID]           INT            NOT NULL,
	[intWorkOrderCategoryId] INT NULL, 
    [intConcurrencyId]    INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMWork] PRIMARY KEY CLUSTERED ([intWorkOrderID] ASC),
    CONSTRAINT [FK_tblTMWork_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
    CONSTRAINT [FK_tblTMWork_tblTMWorkCloseReason] FOREIGN KEY ([intCloseReasonID]) REFERENCES [dbo].[tblTMWorkCloseReason] ([intCloseReasonID]),
    CONSTRAINT [FK_tblTMWork_tblTMWorkStatus] FOREIGN KEY ([intWorkStatusTypeID]) REFERENCES [dbo].[tblTMWorkStatusType] ([intWorkStatusID]), 
    CONSTRAINT [FK_tblTMWorkOrder_tblTMWorkOrderCategory] FOREIGN KEY ([intWorkOrderCategoryId]) REFERENCES [dbo].[tblTMWorkOrderCategory]([intWorkOrderCategoryId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intWorkOrderID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Obsolet/Unused use Identity field as reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strWorkOrderNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Status Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intWorkStatusTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Performer ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intPerformerID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Additional Information',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strAdditionalInfo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entered By ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intEnteredByID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date CLosed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateClosed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scheduled Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateScheduled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Close Reason ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intCloseReasonID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strComments'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intSiteID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work Order Category ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intWorkOrderCategoryId'

GO

CREATE INDEX [IX_tblTMWorkOrder_intSiteID] ON [dbo].[tblTMWorkOrder] ([intSiteID])

GO

CREATE INDEX [IX_tblTMWorkOrder_intCloseReasonID] ON [dbo].[tblTMWorkOrder] ([intCloseReasonID])

GO

CREATE INDEX [IX_tblTMWorkOrder_intWorkStatusTypeID] ON [dbo].[tblTMWorkOrder] ([intWorkStatusTypeID])

GO

CREATE INDEX [IX_tblTMWorkOrder_intWorkOrderCategoryId] ON [dbo].[tblTMWorkOrder] ([intWorkOrderCategoryId])


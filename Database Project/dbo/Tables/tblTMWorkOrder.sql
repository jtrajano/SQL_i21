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
    [intConcurrencyID]    INT            NULL,
    CONSTRAINT [PK_tblTMWork] PRIMARY KEY CLUSTERED ([intWorkOrderID] ASC),
    CONSTRAINT [FK_tblTMWork_tblTMSite] FOREIGN KEY ([intSiteID]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
    CONSTRAINT [FK_tblTMWork_tblTMWorkCloseReason] FOREIGN KEY ([intCloseReasonID]) REFERENCES [dbo].[tblTMWorkCloseReason] ([intCloseReasonID]),
    CONSTRAINT [FK_tblTMWork_tblTMWorkStatus] FOREIGN KEY ([intWorkStatusTypeID]) REFERENCES [dbo].[tblTMWorkStatusType] ([intWorkStatusID])
);


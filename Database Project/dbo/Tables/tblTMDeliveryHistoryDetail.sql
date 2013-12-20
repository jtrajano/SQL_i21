CREATE TABLE [dbo].[tblTMDeliveryHistoryDetail] (
    [intDeliveryHistoryDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [strInvoiceNumber]           NVARCHAR (8)    COLLATE Latin1_General_CI_AS NULL,
    [dblQuantityDelivered]       NUMERIC (18, 6) CONSTRAINT [DF_tblTMDeliveryHistoryDetail_dblQuantityDelivered] DEFAULT ((0)) NOT NULL,
    [strItemNumber]              NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [intDeliveryHistoryID]       INT             NOT NULL,
    [intConcurrencyID]           INT             NULL,
    [dblPercentAfterDelivery]    DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [dbltmpExtendedAmount]       NUMERIC (18, 6) NULL,
    CONSTRAINT [PK_tblTMDeliveryHistoryDetail] PRIMARY KEY CLUSTERED ([intDeliveryHistoryDetailID] ASC),
    CONSTRAINT [FK_tblTMDeliveryHistoryDetail_tblTMDeliveryHistory] FOREIGN KEY ([intDeliveryHistoryID]) REFERENCES [dbo].[tblTMDeliveryHistory] ([intDeliveryHistoryID])
);


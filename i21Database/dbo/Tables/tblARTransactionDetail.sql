﻿CREATE TABLE [dbo].[tblARTransactionDetail]
(
	[intId]									INT				IDENTITY (1, 1) NOT NULL,
    [intTransactionDetailId]				INT				NOT NULL,	
    [intTransactionId]						INT             NOT NULL,
    [strTransactionType]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strTransactionStatus]			        NVARCHAR (25)   COLLATE Latin1_General_CI_AS NULL,
    [intItemId]								INT             NULL,
	[intItemUOMId]							INT             NULL,
    [dblQtyOrdered]							NUMERIC (38, 20) NULL,
    [dblQtyShipped]							NUMERIC (38, 20) NULL,
    [dblPrice]								NUMERIC (18, 6) NULL,
	[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[intInventoryShipmentItemId]			INT				NULL,
	[intSalesOrderDetailId]					INT				NULL,
	[intContractHeaderId]					INT				NULL,    
	[intContractDetailId]					INT				NULL,
	[intItemContractHeaderId]				INT				NULL,
	[intItemContractDetailId]				INT				NULL,
	[intShipmentId]							INT				NULL,
	[intLoadDetailId]						INT				NULL,
	[intTicketId]							INT				NULL,
	[intTicketHoursWorkedId]				INT				NULL,
	[intOriginalInvoiceDetailId]			INT				NULL,
	[intSiteId]								INT				NULL,
	[intCompanyLocationSubLocationId]		INT				NULL,
	[intStorageLocationId]					INT				NULL,
	[intSubLocationId]						INT				NULL,
	[intOwnershipTypeId]					INT				NULL,
	[intStorageScheduleTypeId]				INT				NULL,
	[intCurrencyId]							INT				NULL,
	[intSubCurrencyId]						INT				NULL,
    [dblAmountDue]							NUMERIC (18, 6) NULL,
	[intCompanyLocationId]					INT 			NULL,	
	[intEntityUserId]						INT 			NULL,
	[intConcurrencyId]						INT				CONSTRAINT [DF_tblARTransactionDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARTransactionDetail] PRIMARY KEY CLUSTERED ([intId] ASC)
);
GO
CREATE INDEX [idx_tblARTransactionDetail] ON [dbo].[tblARTransactionDetail] (intTransactionId, intTransactionDetailId)
GO
CREATE INDEX [idx_tblARTransactionDetail_intTransactionDetailId] ON [dbo].[tblARTransactionDetail] (intTransactionDetailId)
GO

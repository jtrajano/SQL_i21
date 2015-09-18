﻿CREATE TABLE [dbo].[tblARTransactionDetail]
(
	[intId]							INT				IDENTITY (1, 1) NOT NULL,
    [intTransactionDetailId]		INT				NOT NULL,
    [intTransactionId]				INT             NOT NULL,
    [strTransactionType]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [intItemId]						INT             NULL,
	[intItemUOMId]					INT             NULL,
    [dblQtyOrdered]					NUMERIC (18, 6) NULL,
    [dblQtyShipped]					NUMERIC (18, 6) NULL,
    [dblPrice]						NUMERIC (18, 6) NULL,
	[intInventoryShipmentItemId]	INT				NULL,
	[intSalesOrderDetailId]			INT				NULL,
	[intContractHeaderId]			INT				NULL,
    [intContractDetailId]			INT				NULL,
	[intConcurrencyId]				INT				CONSTRAINT [DF_tblARTransactionDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARTransactionDetail] PRIMARY KEY CLUSTERED ([intId] ASC)
)

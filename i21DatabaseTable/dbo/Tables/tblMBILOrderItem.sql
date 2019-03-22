CREATE TABLE [dbo].[tblMBILOrderItem](
	[intOrderItemId]	INT				IDENTITY(1,1) NOT NULL,	
	[intOrderId]			INT				NOT NULL,
	[intSiteId] INT NULL,
	[intContractDetailId] INT NULL,
	[intItemId]				INT				NULL,
	[intItemUOMId]			INT				NULL,
	[dblQuantity]			NUMERIC (18, 6) NULL,
	[dblPrice]				NUMERIC (18, 6) NULL,	
	[intConcurrencyId]		INT				DEFAULT 1 NOT NULL,
	CONSTRAINT [PK_tblMBILOrderItem] PRIMARY KEY CLUSTERED ([intOrderItemId] ASC), 
    CONSTRAINT [FK_tblMBILOrderItem_tblMBILOrder] FOREIGN KEY ([intOrderId]) REFERENCES [tblMBILOrder]([intOrderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBILOrderItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblMBILOrderItem_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
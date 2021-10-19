CREATE TABLE [dbo].[tblGRTicketDiscountItemInfo]
(
	[intTicketDiscountInfoId] INT NOT NULL IDENTITY
	,[intTicketDiscountId] INT NOT NULL
	,[ysnInventoryCost] bit null
	,[intItemId] int null

	,CONSTRAINT [PK_tblGRTicketDiscountItemInfo_intTicketDiscountInfoId] PRIMARY KEY ([intTicketDiscountInfoId])	
	,CONSTRAINT [FK_tblGRTicketDiscountItemInfo_tblICItem_intDiscountItem] FOREIGN key ([intItemId]) REFERENCES [tblICItem](intItemId)
	,CONSTRAINT [FK_tblGRTicketDiscountItemInfo_tblICItem_intTicketDiscountId] FOREIGN key ([intTicketDiscountId]) REFERENCES [tblQMTicketDiscount]([intTicketDiscountId]) ON DELETE CASCADE
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGRTicketDiscountItemInfo_intDiscountItemId_intTicketDiscountId] ON [dbo].[tblGRTicketDiscountItemInfo]([intItemId],[intTicketDiscountId]) INCLUDE ([ysnInventoryCost]);
GO
CREATE NONCLUSTERED INDEX [IX_tblGRTicketDiscountItemInfo_intTicketDiscountId]
ON [dbo].[tblGRTicketDiscountItemInfo]([intTicketDiscountId]) INCLUDE ([intItemId]);
GO

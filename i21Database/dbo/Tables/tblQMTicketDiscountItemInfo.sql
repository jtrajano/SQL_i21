CREATE TABLE [dbo].[tblQMTicketDiscountItemInfo]
(
	[intTicketDiscountInfoId] INT NOT NULL IDENTITY
	,[intTicketDiscountId] INT NOT NULL
	,[ysnInventoryCost] bit null
	,[intItemId] int null

	,CONSTRAINT [PK_tblQMTicketDiscountItemInfo_intTicketDiscountInfoId] PRIMARY KEY ([intTicketDiscountInfoId])	
	,CONSTRAINT [FK_tblQMTicketDiscountItemInfo_tblICItem_intDiscountItem] FOREIGN key ([intItemId]) REFERENCES [tblICItem](intItemId)
	,CONSTRAINT [FK_tblQMTicketDiscountItemInfo_tblICItem_intTicketDiscountId] FOREIGN key ([intTicketDiscountId]) REFERENCES [tblQMTicketDiscount]([intTicketDiscountId]) ON DELETE CASCADE
)
GO
CREATE NONCLUSTERED INDEX [IX_tblQMTicketDiscountItemInfo_intDiscountItemId_intTicketDiscountId] ON [dbo].[tblQMTicketDiscountItemInfo]([intItemId],[intTicketDiscountId]) INCLUDE ([ysnInventoryCost]);
GO

CREATE TABLE [dbo].[tblSCDeliverySheetShrinkReceiptDistribution]
(
	intDeliverySheetShrinkReceiptDistribution	int identity(1,1)
	,intDeliverySheetId int not null
	,intInventoryReceiptId int null
	,intInventoryReceiptItemId int null
	,dblDSShrink NUMERIC(38, 20) not null default(0)
	,dblIRNet NUMERIC(38, 20) not null default(0)
	,dblComputedShrinkPerIR NUMERIC(38, 20) not null default(0)


	,CONSTRAINT [PK_tblSCDeliverySheetShrinkReceiptDistribution_intDeliverySheetShrinkReceiptDistribution] PRIMARY KEY ([intDeliverySheetShrinkReceiptDistribution])
	,CONSTRAINT [FK_tblSCDeliverySheetShrinkReceiptDistribution_tblSCDeliverySheet_intDeliverySheetId] FOREIGN KEY ([intDeliverySheetId]) REFERENCES tblSCDeliverySheet([intDeliverySheetId])
		ON DELETE CASCADE
)

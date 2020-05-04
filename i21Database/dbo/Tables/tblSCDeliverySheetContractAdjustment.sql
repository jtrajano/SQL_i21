CREATE TABLE [dbo].[tblSCDeliverySheetContractAdjustment]
(
	[intDeliverySheetContractAdjustmentId] INT NOT NULL IDENTITY, 
	[intDeliverySheetId] INT NULL, 
    [intContractDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblQuantity] DECIMAL(18,6) NULL,
	[intItemUOMId] INT NOT NULL,
	[ysnReversed] BIT NOT NULL DEFAULT ((0)),
	[intConcurrencyId] INT NOT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblSCDeliverySheetContractAdjustment_intDeliverySheetContractAdjustmentId] PRIMARY KEY ([intDeliverySheetContractAdjustmentId]), 
   
)

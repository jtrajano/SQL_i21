CREATE TABLE [dbo].[tblLGShippingInstructionContractQty]
(
[intShippingInstructionContractQtyId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intShippingInstructionId] INT NOT NULL,
[intContractDetailId] INT NOT NULL,
[intContractNumber] INT NOT NULL,
[intContractSeq] INT NOT NULL,
[intItemId] INT NOT NULL,
[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intUnitMeasureId] INT NOT NULL,
[intPurchaseSale] INT NOT NULL,

CONSTRAINT [PK_tblLGShippingInstructionContractQty] PRIMARY KEY ([intShippingInstructionContractQtyId]), 
CONSTRAINT [FK_tblLGShippingInstructionContractQty_tblLGShippingInstruction_intShippingInstructionId] FOREIGN KEY ([intShippingInstructionId]) REFERENCES [tblLGShippingInstruction]([intShippingInstructionId]) ON DELETE CASCADE,
CONSTRAINT [FK_tblLGShippingInstructionContractQty_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
CONSTRAINT [FK_tblLGShippingInstructionContractQty_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblLGShippingInstructionContractQty_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)

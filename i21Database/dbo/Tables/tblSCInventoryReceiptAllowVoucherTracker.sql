CREATE TABLE [dbo].[tblSCInventoryReceiptAllowVoucherTracker]
(
	[intInventoryReceiptAllowVoucherTrackerId] INT NOT NULL  IDENTITY, 
    [ysnAllowVoucher] BIT NULL, 
    [intInventoryReceiptId] INT NOT NULL, 
    [intInventoryReceiptChargeId] INT NULL, 
    [intInventoryReceiptItemId] INT NULL, 
    
)
GO

CREATE INDEX [IDX_tblSCInventoryReceiptAllowVoucherTracker]
	ON [dbo].[tblSCInventoryReceiptAllowVoucherTracker] ([intInventoryReceiptId] ASC, [intInventoryReceiptChargeId] ASC, [intInventoryReceiptItemId] ASC);
GO

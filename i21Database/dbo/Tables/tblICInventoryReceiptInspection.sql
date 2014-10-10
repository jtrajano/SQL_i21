CREATE TABLE [dbo].[tblICInventoryReceiptInspection]
(
	[intInventoryReceiptInspectionId] INT NOT NULL IDENTITY, 
    [intInventoryReceiptId] INT NOT NULL, 
    [intQAPropertyId] INT NOT NULL, 
    [ysnSelected] BIT NOT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceiptInspection] PRIMARY KEY ([intInventoryReceiptInspectionId]), 
    CONSTRAINT [FK_tblICInventoryReceiptInspection_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE
)

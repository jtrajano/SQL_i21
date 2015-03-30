CREATE TABLE [dbo].[tblICInventoryAdjustmentNote]
(
	[intInventoryAdjustmentNoteId] INT NOT NULL IDENTITY, 
    [intInventoryAdjustmentId] INT NOT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [strNotes] NVARCHAR(MAX) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryAdjustmentNote] PRIMARY KEY ([intInventoryAdjustmentNoteId]), 
    CONSTRAINT [FK_tblICInventoryAdjustmentNote_tblICInventoryAdjustment] FOREIGN KEY ([intInventoryAdjustmentId]) REFERENCES [tblICInventoryAdjustment]([intInventoryAdjustmentId]) ON DELETE CASCADE
)

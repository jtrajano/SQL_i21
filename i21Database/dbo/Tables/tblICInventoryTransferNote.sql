CREATE TABLE [dbo].[tblICInventoryTransferNote]
(
	[intInventoryTransferNoteId] INT NOT NULL IDENTITY, 
    [intInventoryTransferId] INT NOT NULL, 
    [strNoteType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryTransferNote] PRIMARY KEY ([intInventoryTransferNoteId]),
	CONSTRAINT [FK_tblICInventoryTransferNote_tblICInventoryTransfer] FOREIGN KEY ([intInventoryTransferId]) REFERENCES [tblICInventoryTransfer]([intInventoryTransferId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryTransferNoteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Transfer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryTransferId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Note Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'strNoteType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'strNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryTransferNote',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
CREATE TABLE [dbo].[tblICInventoryTransactionType]
(
	[intTransactionTypeId] INT NOT NULL IDENTITY, 
    [strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblICInventoryTransactionType] PRIMARY KEY CLUSTERED ([intTransactionTypeId])
)

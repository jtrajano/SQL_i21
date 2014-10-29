CREATE TABLE [dbo].[tblICInventoryAveCost]
(
	[intInventoryAveCostId] INT NOT NULL  IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intItemLocationId] INT NOT NULL, 
    [intTransactionId] INT NULL, 
    [strTransactionId] NVARCHAR(20) NULL, 
    CONSTRAINT [PK_tblICInventoryAveCost] PRIMARY KEY CLUSTERED ([intInventoryAveCostId])
)

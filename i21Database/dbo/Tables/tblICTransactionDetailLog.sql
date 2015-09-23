﻿CREATE TABLE [dbo].[tblICTransactionDetailLog]
(
	[intTransactionDetailLogId] INT NOT NULL IDENTITY, 
    [strTransactionType] NVARCHAR(50) NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [intTransactionDetailId] INT NOT NULL, 
    [intOrderNumberId] INT NULL, 
    [intSourceNumberId] INT NULL, 
    [intLineNo] INT NULL, 
    [intItemId] INT NULL, 
    [intItemUOMId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICTransactionDetailLog] PRIMARY KEY ([intTransactionDetailLogId]) 
)

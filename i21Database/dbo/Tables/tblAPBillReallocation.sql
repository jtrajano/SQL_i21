CREATE TABLE [dbo].[tblAPBillReallocation]
(
	[intReallocationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[intAccountReallocationId] INT NOT NULL,
	[dblAmount] DECIMAL(18,2) DEFAULT 0,
	[dblUnits] DECIMAL(18,2) DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblAPBillReallocation_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPBillReallocation_tblGLAccountReallocation] FOREIGN KEY ([intAccountReallocationId]) REFERENCES [dbo].[tblGLAccountReallocation] ([intAccountReallocationId]) 
)

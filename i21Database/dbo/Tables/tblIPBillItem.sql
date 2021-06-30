CREATE TABLE [dbo].[tblIPBillItem]
(
	intBillItemId INT IDENTITY(1, 1),
	intTransactionType INT,
	intItemId INT,

	CONSTRAINT [PK_tblIPBillItem_intBillItemId] PRIMARY KEY (intBillItemId) 
)

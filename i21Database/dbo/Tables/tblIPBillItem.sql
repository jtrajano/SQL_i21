CREATE TABLE [dbo].[tblIPBillItem]
(
	intBillItemId INT IDENTITY(1, 1),
	intTransactionType INT,
	intItemId INT,
	intLocationId int,
	CONSTRAINT [PK_tblIPBillItem_intBillItemId] PRIMARY KEY (intBillItemId) 
)

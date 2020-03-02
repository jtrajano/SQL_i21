/****** Object:  UserDefinedTableType [dbo].[BillPayment]    Script Date: 02/03/2020 9:50:56 PM ******/
CREATE TYPE [dbo].[BillPayment] AS TABLE(
	[intBillId] [int],
	[dblPayment] [decimal](18, 2) 
)
GO


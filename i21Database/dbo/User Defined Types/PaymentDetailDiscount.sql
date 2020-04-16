CREATE TYPE [dbo].[PaymentDetailDiscountTemp] AS TABLE(
	[intBillId] [int] NOT NULL,
	[dblDiscount] [decimal](18, 6) NOT NULL DEFAULT ((0))
)
GO
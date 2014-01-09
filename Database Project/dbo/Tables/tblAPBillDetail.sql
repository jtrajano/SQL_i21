CREATE TABLE [dbo].[tblAPBillDetail](
	[intBillDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intBillId] [int] NOT NULL,
	[strDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] [int] NOT NULL,
	[dblTotal] [decimal](18, 6) NULL,
 CONSTRAINT [PK__tblAPBil__DCE2CCF4681FF753] PRIMARY KEY CLUSTERED 
(
	[intBillDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblAPBillDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblAPBillDetail_tblAPBill] FOREIGN KEY([intBillId])
REFERENCES [dbo].[tblAPBill] ([intBillId])
GO

ALTER TABLE [dbo].[tblAPBillDetail] CHECK CONSTRAINT [FK_tblAPBillDetail_tblAPBill]
GO
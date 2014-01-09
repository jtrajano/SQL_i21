CREATE TABLE [dbo].[tblAPBill](
	[intBillId] [int] IDENTITY(1,1) NOT NULL,
	[intBillBatchId] [int] NULL,
	[strVendorId] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVendorOrderNumber] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intTermsId] [int] NOT NULL,
	[intTaxCodeId] [int] NULL,
	[dtmDate] [datetime] NOT NULL,
	[dtmBillDate] [datetime] NOT NULL,
	[dtmDueDate] [datetime] NOT NULL,
	[intAccountId] [int] NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dblTotal] [decimal](18, 2) NOT NULL,
	[ysnPosted] [bit] NOT NULL,
	[ysnPaid] [bit] NOT NULL,
	[strBillId] [NVARCHAR](50) collate Latin1_General_CI_AS NOT NULL,
	[dblAmountDue] [decimal](18, 2) NOT NULL,
	[dtmDatePaid] [datetime] NULL,
 CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED 
(
	[intBillId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblAPBill]  WITH NOCHECK ADD  CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId] FOREIGN KEY([intBillBatchId])
REFERENCES [dbo].[tblAPBillBatch] ([intBillBatchId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblAPBill] CHECK CONSTRAINT [FK_dbo.tblAPBill_dbo.tblAPBillBatch_intBillBatchId]
GO

GO
CREATE NONCLUSTERED INDEX [IX_intBillBatchId]
    ON [dbo].[tblAPBill]([intBillBatchId] ASC);


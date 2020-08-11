/****** Object:  Index [IX_tblARInvoiceGrossMarginSummary]    Script Date: 11/08/2020 12:42:28 PM ******/
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceGrossMarginSummary] ON [dbo].[tblARInvoiceGrossMarginSummary]
(
	[strType] ASC,
	[dtmDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



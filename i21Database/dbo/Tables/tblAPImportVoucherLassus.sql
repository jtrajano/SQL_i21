CREATE TABLE [dbo].[tblAPImportVoucherLassus]
(
	[strIdentity] CHAR(1) NOT NULL,
	[strInvoiceNumber] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intVoucherType] TINYINT,
	[strReference] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] NVARCHAR(500) NOT NULL,
	[strVendorId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblTotal] DECIMAL(18,2) NOT NULL,
	[strDateOrAccount] NVARCHAR(500) NOT NULL,
	[strDetailInfo] NVARCHAR(500) NOT NULL,
	[dblDebit] DECIMAL(18,2) NOT NULL,
	[dblCredit] DECIMAL(18,2) NOT NULL,
	[strItemDescription] NVARCHAR (500)  COLLATE Latin1_General_CI_AS NOT NULL
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description',
 @value=N'I - If a header record = date-store reference (Not used) / If GL Detail record = GL Distribution type indicator (2 = "PAY" line, or A/P detail journal entry, 6 = "PURCH" line, or expense line)' ,
  @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblAPImportVoucherLassus', @level2type=N'COLUMN',@level2name=N'intDetailInfo' 
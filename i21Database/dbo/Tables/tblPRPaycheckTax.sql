CREATE TABLE [dbo].[tblPRPaycheckTax](
	[cntId] [int] IdENTITY(1,1) NOT NULL,
	[strPaycheckId] [nvarchar](20) NOT NULL,
	[strTaxId] [nvarchar](15) NOT NULL,
	[strEmployeeId] [nvarchar](40) NOT NULL,
	[strCalculationType] [nvarchar](20) NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblPercent] [numeric](18, 6) NULL,
	[dblLimit] [numeric](18, 6) NULL,
	[strStateTax] [nvarchar](20) NULL,
	[dblExtraWithholding] [numeric](18, 6) NOT NULL,
	[dblAdjustedGross] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NOT NULL,
	[strFilingStatus] [nvarchar](25) NULL,
	[intAllowance] [int] NULL,
	[strAccountId] [nvarchar](40) NULL,
	[strCounty] [nvarchar](25) NULL,
	[strVal1] [nvarchar](5) NULL,
	[strVal2] [nvarchar](5) NULL,
	[strVal3] [nvarchar](5) NULL,
	[strVal4] [nvarchar](5) NULL,
	[intSort] [int] NULL,
	[ysnSet] [bit] NOT NULL,
	[strType] [nvarchar](10) NULL,
	[strExpenseAccountId] [nvarchar](40) NULL,
	[strPaidBy] [nvarchar](10) NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRPaycheckTax] PRIMARY KEY CLUSTERED 
(
	[strPaycheckId] ASC,
	[strTaxId] ASC,
	[strEmployeeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__dblAm__150B6AEE]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF__tblPRPayc__dblPe__15FF8F27]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblPercent]
GO
/****** Object:  Default [DF__tblPRPayc__dblLi__16F3B360]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblLimit]
GO
/****** Object:  Default [DF__tblPRPayc__dblEx__17E7D799]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblExtraWithholding]
GO
/****** Object:  Default [DF__tblPRPayc__dblAd__18DBFBD2]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblAdjustedGross]
GO
/****** Object:  Default [DF__tblPRPayc__dblTo__19D0200B]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnSe__1AC44444]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((0)) FOR [ysnSet]
GO
/****** Object:  Default [DF__tblPRPayc__strPa__1BB8687D]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ('Employee') FOR [strPaidBy]
GO
/****** Object:  Default [DF__tblPRPayc__intCo__1CAC8CB6]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckTax] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
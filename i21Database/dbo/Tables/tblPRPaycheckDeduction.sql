CREATE TABLE [dbo].[tblPRPaycheckDeduction](
	[intPaycheckDeductionId] [int] IDENTITY(1,1) NOT NULL,
	[intPaycheckId] [int] NOT NULL,
	[strDeductionId] [nvarchar](15) NOT NULL,
	[strDeductFrom] [nvarchar](10) NULL,
	[strCalculationType] [nvarchar](15) NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblPercent] [numeric](18, 6) NULL,
	[dblLimit] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NOT NULL,
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[strAccountId] [nvarchar](40) NULL,
	[ysnSet] [bit] NOT NULL,
	[strPaidBy] [nvarchar](10) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRPaycheckDeduction] PRIMARY KEY CLUSTERED 
(
	[intPaycheckId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__dblAm__2FBF612A]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF__tblPRPayc__dblPe__30B38563]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblPercent]
GO
/****** Object:  Default [DF__tblPRPayc__dblLi__31A7A99C]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblLimit]
GO
/****** Object:  Default [DF__tblPRPayc__dblTo__329BCDD5]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnSe__338FF20E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((0)) FOR [ysnSet]
GO
/****** Object:  Default [DF__tblPRPayc__strPa__34841647]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ('Employee') FOR [strPaidBy]
GO
/****** Object:  Default [DF__tblPRPayc__intCo__35783A80]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckDeduction] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
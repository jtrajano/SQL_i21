CREATE TABLE [dbo].[tblPRPaycheck](
	[intPaycheckId] [int] NOT NULL IDENTITY,
	[strPaycheckId] [nvarchar](20) NOT NULL,
	[ysnGLless] [bit] NULL,
	[strStoreId] [nvarchar](20) NULL,
	[strEmployeeId] [nvarchar](40) NULL,
	[dtmDateFrom] [datetime] NOT NULL,
	[dtmDateTo] [datetime] NOT NULL,
	[strAccountId] [nvarchar](40) NULL,
	[strCheckNumber] [nvarchar](30) NULL,
	[strJobId] [nvarchar](40) NULL,
	[dtmPayDate] [datetime] NOT NULL,
	[strPayPeriod] [nvarchar](15) NULL,
	[dblGross] [numeric](18, 6) NULL,
	[dblAdjustedGross] [numeric](18, 6) NULL,
	[dblTax] [numeric](18, 6) NULL,
	[dblDeduction] [numeric](18, 6) NULL,
	[dblLiability] [numeric](18, 6) NULL,
	[dblNet] [numeric](18, 6) NULL,
	[ysnVoid] [bit] NOT NULL,
	[strTransactionType] [nvarchar](35) NULL,
	[dtmPosted] [datetime] NULL,
	[ysnPosted] [bit] NOT NULL,
	[ysnPrinted] [bit] NOT NULL,
	[ysnDirectDeposit] [bit] NOT NULL,
	[dtmCreated] [datetime] NOT NULL,
	[intConcurrencyId] [int] NULL,
	[ysnToBePrinted] [bit] NULL,
 CONSTRAINT [PK_tblPRPaycheck] PRIMARY KEY CLUSTERED 
([intPaycheckId])WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__ysnGL__3D195C48]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnGLless]
GO
/****** Object:  Default [DF__tblPRPayc__dtmDa__3E0D8081]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmDateFrom]
GO
/****** Object:  Default [DF__tblPRPayc__dtmDa__3F01A4BA]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmDateTo]
GO
/****** Object:  Default [DF__tblPRPayc__dtmPa__3FF5C8F3]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmPayDate]
GO
/****** Object:  Default [DF__tblPRPayc__dblGr__40E9ED2C]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblGross]
GO
/****** Object:  Default [DF__tblPRPayc__dblAd__41DE1165]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblAdjustedGross]
GO
/****** Object:  Default [DF__tblPRPayc__dblTa__42D2359E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblTax]
GO
/****** Object:  Default [DF__tblPRPayc__dblDe__43C659D7]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblDeduction]
GO
/****** Object:  Default [DF__tblPRPayc__dblLi__44BA7E10]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblLiability]
GO
/****** Object:  Default [DF__tblPRPayc__dblNe__45AEA249]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [dblNet]
GO
/****** Object:  Default [DF__tblPRPayc__ysnVo__46A2C682]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnVoid]
GO
/****** Object:  Default [DF__tblPRPayc__ysnPo__4796EABB]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnPosted]
GO
/****** Object:  Default [DF__tblPRPayc__ysnPr__488B0EF4]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnPrinted]
GO
/****** Object:  Default [DF__tblPRPayc__ysnDi__497F332D]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnDirectDeposit]
GO
/****** Object:  Default [DF__tblPRPayc__dtmCr__4A735766]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT (getdate()) FOR [dtmCreated]
GO
/****** Object:  Default [DF__tblPRPayc__intCo__4B677B9F]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
GO
/****** Object:  Default [DF__tblPRPayc__ysnTo__4C5B9FD8]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheck] ADD  DEFAULT ((0)) FOR [ysnToBePrinted]
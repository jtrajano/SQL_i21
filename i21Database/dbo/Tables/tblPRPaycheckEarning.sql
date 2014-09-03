CREATE TABLE [dbo].[tblPRPaycheckEarning](
	[cntId] [int] IdENTITY(1,1) NOT NULL,
	[strPaycheckId] [nvarchar](20) NOT NULL,
	[strEarningId] [nvarchar](15) NOT NULL,
	[strCalculationType] [nvarchar](15) NULL,
	[dblHours] [numeric](18, 6) NOT NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NULL,
	[ysnTimeOff] [bit] NOT NULL,
	[strW2Code] [nvarchar](5) NULL,
	[strTimeOffId] [nvarchar](15) NULL,
	[strWorkCode] [nvarchar](15) NULL,
	[strAccountId] [nvarchar](40) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblPRPaycheckEarning] PRIMARY KEY CLUSTERED 
(
	[cntId] ASC,
	[strPaycheckId] ASC,
	[strEarningId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF__tblPRPayc__dblHo__244DAE7E]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblHours]
GO
/****** Object:  Default [DF__tblPRPayc__dblAm__2541D2B7]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF__tblPRPayc__dblTo__2635F6F0]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DF__tblPRPayc__ysnTi__272A1B29]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((0)) FOR [ysnTimeOff]
GO
/****** Object:  Default [DF__tblPRPayc__intCo__281E3F62]    Script Date: 08/14/2014 10:50:11 ******/
ALTER TABLE [dbo].[tblPRPaycheckEarning] ADD  DEFAULT ((1)) FOR [intConcurrencyId]
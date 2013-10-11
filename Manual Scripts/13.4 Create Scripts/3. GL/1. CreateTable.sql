
GO
/****** Object:  Table [dbo].[tblGLRecurringHistory]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLRecurringHistory](
	[intRecurringHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalRecurringID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strGroup] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](75)  COLLATE Latin1_General_CI_AS NULL,
	[dtmLastProcess] [datetime] NULL,
	[dtmNextProcess] [datetime] NULL,
	[dtmProcessDate] [datetime] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLRecurringHistory] PRIMARY KEY CLUSTERED 
(
	[intRecurringHistoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLPreferenceCompany]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLPreferenceCompany](
	[intPreferenceCompanyID] [int] IDENTITY(1,1) NOT NULL,
	[ysnUnitAccounting] [bit] NOT NULL,
	[intUnitDecimalPlaces] [int] NULL,
	[intDecimalPlaces] [int] NULL,
	[strBatchPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intBatchStartNo] [int] NULL,
	[strJournalPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intJournalStartID] [int] NULL,
	[strAuditAdjustmentPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intAuditAdjustmentStartID] [int] NULL,
	[strOpeningBalancePrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intOpeningBalanceID] [int] NULL,
	[strReversalJournalPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intReversalJournalID] [int] NULL,
	[strRecurringJournalPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intRecurringJournalID] [int] NULL,
	[strCOAAdjustmentPrefix] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intCOAAdjustmentID] [int] NULL,
	[strCurrency] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[strEmailAddress] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLPreferenceCompany] PRIMARY KEY CLUSTERED 
(
	[intPreferenceCompanyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLPostHistory]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLPostHistory](
	[intPostHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[strBatchID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strSource] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](75)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[dtmPostDate] [datetime] NOT NULL,
	[dblTotal] [numeric](18, 6) NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLPostHistory] PRIMARY KEY CLUSTERED 
(
	[intPostHistoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLModuleList]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLModuleList](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[strModule] [nvarchar](20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnOpen] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLModuleList] PRIMARY KEY CLUSTERED 
(
	[cntID] ASC,
	[strModule] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLTempAccountToBuild]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLTempAccountToBuild](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountSegmentID] [int] NOT NULL,
	[intUserID] [int] NOT NULL,
	[dtmCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_tblTempGLAccountToBuild] PRIMARY KEY CLUSTERED 
(
	[cntID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLTempAccount]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLTempAccount](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[strAccountID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountGroup] [nvarchar](75)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountGroupID] [int] NULL,
	[strAccountSegmentID] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NULL,
	[dtmCreated] [datetime] NOT NULL,
 CONSTRAINT [PK_tblTempGLAccount] PRIMARY KEY CLUSTERED 
(
	[cntID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLJournalRecurring]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLJournalRecurring](
	[intJournalRecurringID] [int] IDENTITY(1,1) NOT NULL,
	[strJournalRecurringID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strStoreID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[intCurrencyID] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NULL,
	[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[strMode] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strUserMode] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intAdvanceReminder] [int] NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[strRecurringPeriod] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intInterval] [int] NULL,
	[strDays] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[dtmNextDueDate] [datetime] NULL,
	[dtmSingle] [datetime] NULL,
	[dtmLastDueDate] [datetime] NULL,
	[intMonthInterval] [int] NULL,
 CONSTRAINT [PK_tblGLJournalRecurring] PRIMARY KEY CLUSTERED 
(
	[intJournalRecurringID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCurrentFiscalYear]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCurrentFiscalYear](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[intFiscalYearID] [int] NOT NULL,
	[dtmBeginDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[dblPeriods] [numeric](18, 6) NULL,
	[ysnShowAllPeriods] [bit] NOT NULL,
	[ysnDuplicates] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLFiscalYear] PRIMARY KEY CLUSTERED 
(
	[cntID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLJournal]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLJournal](
	[intJournalID] [int] IDENTITY(1,1) NOT NULL,
	[dtmReverseDate] [datetime] NULL,
	[strJournalID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] [nvarchar](25)  COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strReverseLink] [nvarchar](25)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyID] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NULL,
	[dtmPosted] [datetime] NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[ysnPosted] [bit] NULL,
	[intConcurrencyID] [int] NULL,
	[dtmJournalDate] [datetime] NULL,
	[intUserID] [int] NULL,
	[strSourceID] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strRecurringStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strSourceType] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLJournal] PRIMARY KEY CLUSTERED 
(
	[intJournalID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLImportFiles]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLImportFiles](
	[intUploadCSV] [int] IDENTITY(1,1) NOT NULL,
	[strFilename] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[dtmUploaded] [datetime] NULL,
	[dtmLastImported] [datetime] NULL,
	[dblSize] [decimal](18, 6) NULL,
	[strType] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLImportFiles] PRIMARY KEY CLUSTERED 
(
	[intUploadCSV] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLIjemst]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGLIjemst](
	[glije_period] [int] NOT NULL,
	[glije_acct_no] [decimal](16, 8) NOT NULL,
	[glije_src_sys] [char](3) NOT NULL,
	[glije_src_no] [char](5) NOT NULL,
	[glije_line_no] [int] NOT NULL,
	[glije_date] [int] NULL,
	[glije_time] [int] NULL,
	[glije_ref] [char](25) NULL,
	[glije_doc] [char](25) NULL,
	[glije_comments] [char](25) NULL,
	[glije_dr_cr_ind] [char](1) NULL,
	[glije_amt] [decimal](12, 2) NULL,
	[glije_units] [decimal](16, 4) NULL,
	[glije_correcting] [char](1) NULL,
	[glije_source_pgm] [char](8) NULL,
	[glije_work_area] [char](40) NULL,
	[glije_cbk_no] [char](2) NULL,
	[glije_user_id] [char](16) NULL,
	[glije_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGLFiscalYear]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLFiscalYear](
	[intFiscalYearID] [int] IDENTITY(1,1) NOT NULL,
	[strFiscalYear] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intRetainAccount] [int] NULL,
	[dtmDateFrom] [datetime] NULL,
	[dtmDateTo] [datetime] NULL,
	[ysnStatus] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLFiscalYearPeriod_1] PRIMARY KEY CLUSTERED 
(
	[intFiscalYearID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountUnit]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGLAccountUnit](
	[intAccountUnitID] [int] IDENTITY(1,1) NOT NULL,
	[strUOMCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strUOMDesc] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblLbsPerUnit] [decimal](16, 4) NULL,
	[intUserID] [char](16) NULL,
	[gluom_user_rev_dt] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountUnit] PRIMARY KEY CLUSTERED 
(
	[intAccountUnitID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGLCOATemplate]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOATemplate](
	[intAccountTemplateID] [int] IDENTITY(1,1) NOT NULL,
	[strAccountTemplateName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountTemplate] PRIMARY KEY CLUSTERED 
(
	[intAccountTemplateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOAAdjustment]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOAAdjustment](
	[intCOAAdjustmentID] [int] IDENTITY(1,1) NOT NULL,
	[strCOAAdjustmentID] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NULL,
	[dtmDate] [datetime] NULL,
	[memNotes] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[ysnposted] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLCOAAdjustment] PRIMARY KEY CLUSTERED 
(
	[intCOAAdjustmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLBudgetDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLBudgetDetail](
	[cntID] [int] IDENTITY(1,1) NOT NULL,
	[strAccountID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmYear] [datetime] NOT NULL,
	[curLastYear01] [numeric](18, 6) NULL,
	[curLastYear02] [numeric](18, 6) NULL,
	[curLastYear03] [numeric](18, 6) NULL,
	[curLastYear04] [numeric](18, 6) NULL,
	[curLastYear05] [numeric](18, 6) NULL,
	[curLastYear06] [numeric](18, 6) NULL,
	[curLastYear07] [numeric](18, 6) NULL,
	[curLastYear08] [numeric](18, 6) NULL,
	[curLastYear09] [numeric](18, 6) NULL,
	[curLastYear10] [numeric](18, 6) NULL,
	[curLastYear11] [numeric](18, 6) NULL,
	[curLastYear12] [numeric](18, 6) NULL,
	[curThisYear01] [numeric](18, 6) NULL,
	[curThisYear02] [numeric](18, 6) NULL,
	[curThisYear03] [numeric](18, 6) NULL,
	[curThisYear04] [numeric](18, 6) NULL,
	[curThisYear05] [numeric](18, 6) NULL,
	[curThisYear06] [numeric](18, 6) NULL,
	[curThisYear07] [numeric](18, 6) NULL,
	[curThisYear08] [numeric](18, 6) NULL,
	[curThisYear09] [numeric](18, 6) NULL,
	[curThisYear10] [numeric](18, 6) NULL,
	[curThisYear11] [numeric](18, 6) NULL,
	[curThisYear12] [numeric](18, 6) NULL,
	[curBudget01] [numeric](18, 6) NULL,
	[curBudget02] [numeric](18, 6) NULL,
	[curBudget03] [numeric](18, 6) NULL,
	[curBudget04] [numeric](18, 6) NULL,
	[curBudget05] [numeric](18, 6) NULL,
	[curBudget06] [numeric](18, 6) NULL,
	[curBudget07] [numeric](18, 6) NULL,
	[curBudget08] [numeric](18, 6) NULL,
	[curBudget09] [numeric](18, 6) NULL,
	[curBudget10] [numeric](18, 6) NULL,
	[curBudget11] [numeric](18, 6) NULL,
	[curBudget12] [numeric](18, 6) NULL,
	[curOperPlan01] [numeric](18, 6) NULL,
	[curOperPlan02] [numeric](18, 6) NULL,
	[curOperPlan03] [numeric](18, 6) NULL,
	[curOperPlan04] [numeric](18, 6) NULL,
	[curOperPlan05] [numeric](18, 6) NULL,
	[curOperPlan06] [numeric](18, 6) NULL,
	[curOperPlan07] [numeric](18, 6) NULL,
	[curOperPlan08] [numeric](18, 6) NULL,
	[curOperPlan09] [numeric](18, 6) NULL,
	[curOperPlan10] [numeric](18, 6) NULL,
	[curOperPlan11] [numeric](18, 6) NULL,
	[curOperPlan12] [numeric](18, 6) NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLBudgetDetail] PRIMARY KEY CLUSTERED 
(
	[strAccountID] ASC,
	[dtmYear] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLBudgetCode]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLBudgetCode](
	[intBudgetCode] [int] IDENTITY(1,1) NOT NULL,
	[ysnDefault] [bit] NULL,
	[strBudgetCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strBudgetEnglishDescription] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLBudgetCode] PRIMARY KEY CLUSTERED 
(
	[intBudgetCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOAImportLog]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOAImportLog](
	[intImportLogID] [int] IDENTITY(1,1) NOT NULL,
	[strEvent] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strIrelySuiteVersion] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NULL,
	[dtmDate] [datetime] NULL,
	[strMachineName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalType] [nchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLCOAImportLog] PRIMARY KEY CLUSTERED 
(
	[intImportLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOAImportCSV]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOAImportCSV](
	[intUploadCSV] [int] IDENTITY(1,1) NOT NULL,
	[strFilename] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[dtmUploaded] [datetime] NULL,
	[dtmLastImported] [datetime] NULL,
	[dblSize] [decimal](18, 6) NULL,
 CONSTRAINT [PK_tblGLCOAImportCSV] PRIMARY KEY CLUSTERED 
(
	[intUploadCSV] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountTemplate]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountTemplate](
	[intGLAccountTemplateID] [int] IDENTITY(1,1) NOT NULL,
	[strTemplate] [nvarchar](30)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLCOATemplate] PRIMARY KEY CLUSTERED 
(
	[intGLAccountTemplateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountStructure]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountStructure](
	[intAccountStructureID] [int] IDENTITY(1,1) NOT NULL,
	[intStructureType] [int] NOT NULL,
	[strStructureName] [nvarchar](25)  COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](7)  COLLATE Latin1_General_CI_AS NULL,
	[intLength] [int] NULL,
	[strMask] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[ysnBuild] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
	[intStartingPosition] [int] NULL,
	[intLegacyLength] [int] NULL,
	[strOtherSoftwareColumn] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_GLAccountStructure_AccountStructureID] PRIMARY KEY CLUSTERED 
(
	[intAccountStructureID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountReallocation]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountReallocation](
	[intAccountReallocationID] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountReallocation] PRIMARY KEY CLUSTERED 
(
	[intAccountReallocationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountGroup]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountGroup](
	[intAccountGroupID] [int] IDENTITY(1,1) NOT NULL,
	[strAccountGroup] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strAccountType] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intParentGroupID] [int] NULL,
	[intGroup] [int] NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
	[intAccountBegin] [int] NULL,
	[intAccountEnd] [int] NULL,
	[strAccountGroupNamespace] [nvarchar](1000)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_GLAccountGroup_AccountGroupID] PRIMARY KEY CLUSTERED 
(
	[intAccountGroupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccount](
	[intAccountID] [int] IDENTITY(1,1) NOT NULL,
	[strAccountID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strNote] [ntext]  COLLATE Latin1_General_CI_AS NULL,
	[intAccountGroupID] [int] NULL,
	[dblOpeningBalance] [numeric](18, 6) NULL,
	[ysnIsUsed] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
	[intAccountUnitID] [int] NULL,
	[strComments] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] [bit] NULL,
	[ysnSystem] [bit] NULL,
	[strCashFlow] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_GLAccount_AccountID] PRIMARY KEY CLUSTERED 
(
	[intAccountID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountDefault]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountDefault](
	[intAccountDefaultID] [int] IDENTITY(1,1) NOT NULL,
	[intSecurityUserID] [int] NOT NULL,
	[intGLAccountTemplateID] [int] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountDefault] PRIMARY KEY CLUSTERED 
(
	[intAccountDefaultID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountSegment]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountSegment](
	[intAccountSegmentID] [int] IDENTITY(1,1) NOT NULL,
	[strCode] [nvarchar](20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountStructureID] [int] NOT NULL,
	[intAccountGroupID] [int] NULL,
	[ysnActive] [bit] NULL,
	[ysnSelected] [bit] NOT NULL,
	[ysnBuild] [bit] NOT NULL,
	[ysnIsNotExisting] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_GLAccountSegment_AccountSegmentID] PRIMARY KEY CLUSTERED 
(
	[intAccountSegmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOAImportLogDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOAImportLogDetail](
	[intImportLogDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intImportLogID] [int] NULL,
	[strEventDescription] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[strPeriod] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strSourceSystem] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLCOAImportLogDetail] PRIMARY KEY CLUSTERED 
(
	[intImportLogDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLFiscalYearPeriod]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLFiscalYearPeriod](
	[intGLFiscalYearPeriodID] [int] IDENTITY(1,1) NOT NULL,
	[intFiscalYearID] [int] NOT NULL,
	[strPeriod] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[ysnOpen] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLPeriod] PRIMARY KEY CLUSTERED 
(
	[intGLFiscalYearPeriodID] ASC,
	[intFiscalYearID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOATemplateDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOATemplateDetail](
	[intAccountTemplateDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountTemplateID] [int] NULL,
	[strCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountGroupID] [int] NULL,
	[intAccountStructureID] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountTemplateDetail] PRIMARY KEY CLUSTERED 
(
	[intAccountTemplateDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOAAdjustmentDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOAAdjustmentDetail](
	[intCOAAdjustmentDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intCOAAdjustmentID] [int] NULL,
	[strAction] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strNew] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strPrimaryField] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[strOriginal] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountID] [int] NULL,
	[intAccountGroupID] [int] NULL,
 CONSTRAINT [PK_tblGLCOAAdjustmentDetail] PRIMARY KEY CLUSTERED 
(
	[intCOAAdjustmentDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLSummary]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLSummary](
	[intSummaryID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountID] [int] NULL,
	[dtmDate] [datetime] NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLSummary] PRIMARY KEY CLUSTERED 
(
	[intSummaryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLJournalRecurringDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLJournalRecurringDetail](
	[intJournalRecurringDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intLineNo] [int] NULL,
	[ysnAllocatingEntry] [bit] NULL,
	[intJournalRecurringID] [int] NOT NULL,
	[dtmDate] [datetime] NULL,
	[intAccountID] [int] NULL,
	[intCurrencyID] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblDebitRate] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblCreditRate] [numeric](18, 6) NULL,
	[strNameID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intJobID] [int] NULL,
	[strLink] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[dblUnitsInLBS] [numeric](18, 6) NULL,
	[strDocument] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strComments] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblGLJournalRecurringDetail] PRIMARY KEY CLUSTERED 
(
	[intJournalRecurringDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLJournalDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLJournalDetail](
	[intJournalDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intLineNo] [int] NULL,
	[intJournalID] [int] NOT NULL,
	[dtmDate] [datetime] NULL,
	[intAccountID] [int] NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblDebitRate] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblCreditRate] [numeric](18, 6) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[dblUnitsInLBS] [numeric](18, 6) NULL,
	[strDocument] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strComments] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[dblDebitUnitsInLBS] [numeric](18, 6) NULL,
	[strCorrecting] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strSourcePgm] [nvarchar](8)  COLLATE Latin1_General_CI_AS NULL,
	[strCheckBookNo] [nvarchar](2)  COLLATE Latin1_General_CI_AS NULL,
	[strWorkArea] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGLJournalDetail] PRIMARY KEY CLUSTERED 
(
	[intJournalDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblGLDetail](
	[intGLDetailID] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[strBatchID] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intAccountID] [int] NULL,
	[strAccountGroup] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[dblDebit] [numeric](18, 6) NULL,
	[dblCredit] [numeric](18, 6) NULL,
	[dblDebitUnit] [numeric](18, 6) NULL,
	[dblCreditUnit] [numeric](18, 6) NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strCode] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strReference] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strJobID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyID] [int] NULL,
	[dblExchangeRate] [numeric](38, 20) NOT NULL,
	[dtmDateEntered] [datetime] NOT NULL,
	[dtmTransactionDate] [datetime] NULL,
	[strProductID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strWarehouseID] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
	[strNum] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strBillInvoiceNumber] [nvarchar](35)  COLLATE Latin1_General_CI_AS NULL,
	[strJournalLineDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[ysnIsUnposted] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
	[intUserID] [int] NULL,
	[strTransactionForm] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strModuleName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strUOMCode] [char](6)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblGL] PRIMARY KEY CLUSTERED 
(
	[intGLDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblGLAccountTemplateDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountTemplateDetail](
	[intGLAccountTempalteDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intGLAccountTemplateID] [int] NULL,
	[strTemplate] [nvarchar](30)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName] [nvarchar](25)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDefaultName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strRowFilter] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[ysnSelected] [bit] NULL,
	[intAccountID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountTemplateDetail_1] PRIMARY KEY CLUSTERED 
(
	[intGLAccountTempalteDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLCOACrossReference]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLCOACrossReference](
	[intCrossReferenceID] [int] IDENTITY(1,1) NOT NULL,
	[inti21ID] [int] NOT NULL,
	[stri21ID] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strExternalID] [nvarchar](max)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strCurrentExternalID] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyID] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[intLegacyReferenceID] [numeric](9, 0) NULL,
 CONSTRAINT [PK_tblCrossReference] PRIMARY KEY CLUSTERED 
(
	[intCrossReferenceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLBudget]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLBudget](
	[intBudgetID] [int] IDENTITY(1,1) NOT NULL,
	[intBudgetCode] [int] NOT NULL,
	[strPeriod] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmStartDate] [datetime] NULL,
	[intFiscalYearID] [int] NOT NULL,
	[intAccountID] [int] NOT NULL,
	[intAccountGroupID] [int] NULL,
	[curActual] [numeric](18, 6) NULL,
	[intSort] [int] NULL,
	[dtmEndDate] [datetime] NULL,
	[curThisYear] [numeric](18, 6) NULL,
	[dtmDate] [datetime] NOT NULL,
	[curLastYear] [numeric](18, 6) NULL,
	[curBudget] [numeric](18, 6) NULL,
	[curOperPlan] [numeric](18, 6) NULL,
	[intConcurrencyID] [int] NULL,
	[ysnSelect] [bit] NULL,
 CONSTRAINT [PK_tblGLBudget] PRIMARY KEY CLUSTERED 
(
	[intBudgetID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountSegmentMapping]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountSegmentMapping](
	[intAccountSegmentMappingID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountID] [int] NULL,
	[intAccountSegmentID] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountSegmentMapping] PRIMARY KEY CLUSTERED 
(
	[intAccountSegmentMappingID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountReallocationDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountReallocationDetail](
	[intAccountReallocationDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountReallocationID] [int] NULL,
	[intAccountID] [int] NOT NULL,
	[strJobID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[dblPercentage] [numeric](10, 2) NULL,
	[intConcurrencyID] [int] NULL,
	[dblUnit] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblGLAccountReallocationDetail] PRIMARY KEY CLUSTERED 
(
	[intAccountReallocationDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountAllocationDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountAllocationDetail](
	[intAccountAllocationDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intAllocatedAccountID] [int] NOT NULL,
	[intAccountID] [int] NOT NULL,
	[strJobID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[dblPercentage] [numeric](10, 2) NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblGLAccountAllocationDetail_1] PRIMARY KEY CLUSTERED 
(
	[intAccountAllocationDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblGLAccountDefaultDetail]    Script Date: 10/07/2013 18:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGLAccountDefaultDetail](
	[intAccountDefaultDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intAccountDefaultID] [int] NOT NULL,
	[strModuleName] [nvarchar](25)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDefaultName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strRowFilter] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[intAccountID] [int] NULL,
 CONSTRAINT [PK_GLAccountDefault_AccountDefaultID] PRIMARY KEY CLUSTERED 
(
	[intAccountDefaultDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DF_tblGLAccount_ysnIsUsed]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccount] ADD  CONSTRAINT [DF_tblGLAccount_ysnIsUsed]  DEFAULT ((0)) FOR [ysnIsUsed]
GO
/****** Object:  Default [DF__tblGLAcco__intCo__695C9DA1]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountAllocationDetail] ADD  CONSTRAINT [DF__tblGLAcco__intCo__695C9DA1]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF_tblGLAccountReallocation_intConcurrencyID]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountReallocation] ADD  CONSTRAINT [DF_tblGLAccountReallocation_intConcurrencyID]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF_tblGLAccountReallocationDetail_intConcurrencyID]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountReallocationDetail] ADD  CONSTRAINT [DF_tblGLAccountReallocationDetail_intConcurrencyID]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF_tblGLAccountSegment_ysnActive]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment] ADD  CONSTRAINT [DF_tblGLAccountSegment_ysnActive]  DEFAULT ((1)) FOR [ysnActive]
GO
/****** Object:  Default [DF_tblGLAccountSegment_ysnSelected]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment] ADD  CONSTRAINT [DF_tblGLAccountSegment_ysnSelected]  DEFAULT ((0)) FOR [ysnSelected]
GO
/****** Object:  Default [DF_tblGLAccountSegment_ysnBuild]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment] ADD  CONSTRAINT [DF_tblGLAccountSegment_ysnBuild]  DEFAULT ((0)) FOR [ysnBuild]
GO
/****** Object:  Default [DF_tblGLAccountSegment_ysnIsNotExisting]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment] ADD  CONSTRAINT [DF_tblGLAccountSegment_ysnIsNotExisting]  DEFAULT ((0)) FOR [ysnIsNotExisting]
GO
/****** Object:  Default [DF_tblGLAccountStructure_ysnBuild]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountStructure] ADD  CONSTRAINT [DF_tblGLAccountStructure_ysnBuild]  DEFAULT ((0)) FOR [ysnBuild]
GO
/****** Object:  Default [DF__tblGLCOAT__intCo__05F8DC4F]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountTemplateDetail] ADD  CONSTRAINT [DF__tblGLCOAT__intCo__05F8DC4F]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblGLBudg__ysnDe__76818E95]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLBudgetCode] ADD  CONSTRAINT [DF__tblGLBudg__ysnDe__76818E95]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DF_tblGLUploadFile_dtmUploaded]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOAImportCSV] ADD  CONSTRAINT [DF_tblGLUploadFile_dtmUploaded]  DEFAULT (getdate()) FOR [dtmUploaded]
GO
/****** Object:  Default [DF_tblGLUploadFile_intImported]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOAImportCSV] ADD  CONSTRAINT [DF_tblGLUploadFile_intImported]  DEFAULT ((0)) FOR [dblSize]
GO
/****** Object:  Default [DF_tblGLAccountTemplate_intConcurrencyID]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOATemplate] ADD  CONSTRAINT [DF_tblGLAccountTemplate_intConcurrencyID]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblGLCurr__dtmBe__5090EFD7]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCurrentFiscalYear] ADD  CONSTRAINT [DF__tblGLCurr__dtmBe__5090EFD7]  DEFAULT (getdate()) FOR [dtmBeginDate]
GO
/****** Object:  Default [DF__tblGLCurr__dtmEn__51851410]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCurrentFiscalYear] ADD  CONSTRAINT [DF__tblGLCurr__dtmEn__51851410]  DEFAULT (getdate()) FOR [dtmEndDate]
GO
/****** Object:  Default [DF__tblGLCurr__dblPe__52793849]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCurrentFiscalYear] ADD  CONSTRAINT [DF__tblGLCurr__dblPe__52793849]  DEFAULT ((0)) FOR [dblPeriods]
GO
/****** Object:  Default [DF__tblGLCurr__ysnSh__536D5C82]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCurrentFiscalYear] ADD  CONSTRAINT [DF__tblGLCurr__ysnSh__536D5C82]  DEFAULT ((0)) FOR [ysnShowAllPeriods]
GO
/****** Object:  Default [DF__tblGLCurr__intCo__546180BB]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCurrentFiscalYear] ADD  CONSTRAINT [DF__tblGLCurr__intCo__546180BB]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblGLFisc__ysnSt__4BCC3ABA]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYear] ADD  CONSTRAINT [DF__tblGLFisc__ysnSt__4BCC3ABA]  DEFAULT ((0)) FOR [ysnStatus]
GO
/****** Object:  Default [DF__tblGLFisc__intCo__4CC05EF3]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYear] ADD  CONSTRAINT [DF__tblGLFisc__intCo__4CC05EF3]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblGLPeri__dtmSt__3F6663D5]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYearPeriod] ADD  CONSTRAINT [DF__tblGLPeri__dtmSt__3F6663D5]  DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/01/01',(0))) FOR [dtmStartDate]
GO
/****** Object:  Default [DF__tblGLPeri__dtmEn__405A880E]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYearPeriod] ADD  CONSTRAINT [DF__tblGLPeri__dtmEn__405A880E]  DEFAULT (CONVERT([datetime],CONVERT([char](4),datepart(year,getdate()),(0))+'/12/31',(0))) FOR [dtmEndDate]
GO
/****** Object:  Default [DF__tblGLPeri__ysnOp__414EAC47]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYearPeriod] ADD  CONSTRAINT [DF__tblGLPeri__ysnOp__414EAC47]  DEFAULT ((1)) FOR [ysnOpen]
GO
/****** Object:  Default [DF__tblGLPeri__intCo__4242D080]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYearPeriod] ADD  CONSTRAINT [DF__tblGLPeri__intCo__4242D080]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF_tblGLRecurringHistory_dtmLastProcess]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLRecurringHistory] ADD  CONSTRAINT [DF_tblGLRecurringHistory_dtmLastProcess]  DEFAULT (getdate()) FOR [dtmLastProcess]
GO
/****** Object:  Default [DF_tblGLRecurringHistory_dtmNextProcess]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLRecurringHistory] ADD  CONSTRAINT [DF_tblGLRecurringHistory_dtmNextProcess]  DEFAULT (getdate()) FOR [dtmNextProcess]
GO
/****** Object:  Default [DF_tblGLRecurringHistory_dtmProcessDate]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLRecurringHistory] ADD  CONSTRAINT [DF_tblGLRecurringHistory_dtmProcessDate]  DEFAULT (getdate()) FOR [dtmProcessDate]
GO
/****** Object:  Default [DF_tblGLRecurringHistory_intConcurrencyID]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLRecurringHistory] ADD  CONSTRAINT [DF_tblGLRecurringHistory_intConcurrencyID]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF_tblTempGLAccount_dtmCreated]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLTempAccount] ADD  CONSTRAINT [DF_tblTempGLAccount_dtmCreated]  DEFAULT (getdate()) FOR [dtmCreated]
GO
/****** Object:  Default [DF_tblTempGLAccountToBuild_dtmCreated]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLTempAccountToBuild] ADD  CONSTRAINT [DF_tblTempGLAccountToBuild_dtmCreated]  DEFAULT (getdate()) FOR [dtmCreated]
GO
/****** Object:  ForeignKey [FK_tblGLAccount_tblGLAccountGroup]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccount]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccount_tblGLAccountGroup] FOREIGN KEY([intAccountGroupID])
REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLAccount] CHECK CONSTRAINT [FK_tblGLAccount_tblGLAccountGroup]
GO
/****** Object:  ForeignKey [FK_tblGLAccount_tblGLAccountUnit]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccount]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGLAccount_tblGLAccountUnit] FOREIGN KEY([intAccountUnitID])
REFERENCES [dbo].[tblGLAccountUnit] ([intAccountUnitID])
GO
ALTER TABLE [dbo].[tblGLAccount] CHECK CONSTRAINT [FK_tblGLAccount_tblGLAccountUnit]
GO
/****** Object:  ForeignKey [FK_tblGLAccountAllocationDetail_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountAllocationDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLAccountAllocationDetail] CHECK CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLAccountAllocationDetail_tblGLAccount1]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountAllocationDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount1] FOREIGN KEY([intAllocatedAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLAccountAllocationDetail] CHECK CONSTRAINT [FK_tblGLAccountAllocationDetail_tblGLAccount1]
GO
/****** Object:  ForeignKey [FK_tblGLAccountDefault_tblGLAccountTemplate]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountDefault]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountDefault_tblGLAccountTemplate] FOREIGN KEY([intGLAccountTemplateID])
REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateID])
GO
ALTER TABLE [dbo].[tblGLAccountDefault] CHECK CONSTRAINT [FK_tblGLAccountDefault_tblGLAccountTemplate]
GO
/****** Object:  ForeignKey [FK_tblGLAccountDefault_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountDefaultDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountDefault_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLAccountDefaultDetail] CHECK CONSTRAINT [FK_tblGLAccountDefault_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLAccountDefaultDetail_tblGLAccountDefault]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountDefaultDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountDefaultDetail_tblGLAccountDefault] FOREIGN KEY([intAccountDefaultID])
REFERENCES [dbo].[tblGLAccountDefault] ([intAccountDefaultID])
GO
ALTER TABLE [dbo].[tblGLAccountDefaultDetail] CHECK CONSTRAINT [FK_tblGLAccountDefaultDetail_tblGLAccountDefault]
GO
/****** Object:  ForeignKey [FK_tblGLAccountReallocationDetail_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountReallocationDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLAccountReallocationDetail] CHECK CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountReallocationDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation] FOREIGN KEY([intAccountReallocationID])
REFERENCES [dbo].[tblGLAccountReallocation] ([intAccountReallocationID])
GO
ALTER TABLE [dbo].[tblGLAccountReallocationDetail] CHECK CONSTRAINT [FK_tblGLAccountReallocationDetail_tblGLAccountReallocation]
GO
/****** Object:  ForeignKey [FK_tblGLAccountSegment_tblGLAccountGroup]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountGroup] FOREIGN KEY([intAccountGroupID])
REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID])
GO
ALTER TABLE [dbo].[tblGLAccountSegment] CHECK CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountGroup]
GO
/****** Object:  ForeignKey [FK_tblGLAccountSegment_tblGLAccountStructure]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegment]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountStructure] FOREIGN KEY([intAccountStructureID])
REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureID])
GO
ALTER TABLE [dbo].[tblGLAccountSegment] CHECK CONSTRAINT [FK_tblGLAccountSegment_tblGLAccountStructure]
GO
/****** Object:  ForeignKey [FK_tblGLAccountSegmentMapping_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegmentMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLAccountSegmentMapping] CHECK CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLAccountSegmentMapping_tblGLAccountSegment]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountSegmentMapping]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccountSegment] FOREIGN KEY([intAccountSegmentID])
REFERENCES [dbo].[tblGLAccountSegment] ([intAccountSegmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLAccountSegmentMapping] CHECK CONSTRAINT [FK_tblGLAccountSegmentMapping_tblGLAccountSegment]
GO
/****** Object:  ForeignKey [FK_tblGLAccountTemplateDetail_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountTemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLAccountTemplateDetail] CHECK CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLAccountTemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1] FOREIGN KEY([intGLAccountTemplateID])
REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateID])
GO
ALTER TABLE [dbo].[tblGLAccountTemplateDetail] CHECK CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1]
GO
/****** Object:  ForeignKey [FK_tblGLBudget_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLBudget]  WITH CHECK ADD  CONSTRAINT [FK_tblGLBudget_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLBudget] CHECK CONSTRAINT [FK_tblGLBudget_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLBudget_tblGLBudgetCode]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLBudget]  WITH CHECK ADD  CONSTRAINT [FK_tblGLBudget_tblGLBudgetCode] FOREIGN KEY([intBudgetCode])
REFERENCES [dbo].[tblGLBudgetCode] ([intBudgetCode])
GO
ALTER TABLE [dbo].[tblGLBudget] CHECK CONSTRAINT [FK_tblGLBudget_tblGLBudgetCode]
GO
/****** Object:  ForeignKey [FK_tblGLBudget_tblGLFiscalYear]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLBudget]  WITH CHECK ADD  CONSTRAINT [FK_tblGLBudget_tblGLFiscalYear] FOREIGN KEY([intFiscalYearID])
REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearID])
GO
ALTER TABLE [dbo].[tblGLBudget] CHECK CONSTRAINT [FK_tblGLBudget_tblGLFiscalYear]
GO
/****** Object:  ForeignKey [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOAAdjustmentDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup] FOREIGN KEY([intAccountGroupID])
REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID])
GO
ALTER TABLE [dbo].[tblGLCOAAdjustmentDetail] CHECK CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLAccountGroup]
GO
/****** Object:  ForeignKey [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOAAdjustmentDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment] FOREIGN KEY([intCOAAdjustmentID])
REFERENCES [dbo].[tblGLCOAAdjustment] ([intCOAAdjustmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLCOAAdjustmentDetail] CHECK CONSTRAINT [FK_tblGLCOAAdjustmentDetail_tblGLCOAAdjustment]
GO
/****** Object:  ForeignKey [FK_tblGLCOACrossReference_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOACrossReference]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGLCOACrossReference_tblGLAccount] FOREIGN KEY([inti21ID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLCOACrossReference] CHECK CONSTRAINT [FK_tblGLCOACrossReference_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOAImportLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog] FOREIGN KEY([intImportLogID])
REFERENCES [dbo].[tblGLCOAImportLog] ([intImportLogID])
GO
ALTER TABLE [dbo].[tblGLCOAImportLogDetail] CHECK CONSTRAINT [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog]
GO
/****** Object:  ForeignKey [FK_tblGLAccountTemplateDetail_tblGLAccountGroup]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOATemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountGroup] FOREIGN KEY([intAccountGroupID])
REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupID])
GO
ALTER TABLE [dbo].[tblGLCOATemplateDetail] CHECK CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountGroup]
GO
/****** Object:  ForeignKey [FK_tblGLAccountTemplateDetail_tblGLAccountStructure]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOATemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountStructure] FOREIGN KEY([intAccountStructureID])
REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureID])
GO
ALTER TABLE [dbo].[tblGLCOATemplateDetail] CHECK CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountStructure]
GO
/****** Object:  ForeignKey [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLCOATemplateDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate] FOREIGN KEY([intAccountTemplateID])
REFERENCES [dbo].[tblGLCOATemplate] ([intAccountTemplateID])
GO
ALTER TABLE [dbo].[tblGLCOATemplateDetail] CHECK CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate]
GO
/****** Object:  ForeignKey [FK_tblGL_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGL_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLDetail] CHECK CONSTRAINT [FK_tblGL_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLPeriod_tblGLFiscalYearPeriod]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLFiscalYearPeriod]  WITH CHECK ADD  CONSTRAINT [FK_tblGLPeriod_tblGLFiscalYearPeriod] FOREIGN KEY([intFiscalYearID])
REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearID])
GO
ALTER TABLE [dbo].[tblGLFiscalYearPeriod] CHECK CONSTRAINT [FK_tblGLPeriod_tblGLFiscalYearPeriod]
GO
/****** Object:  ForeignKey [FK_tblGLJournalDetail_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLJournalDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLJournalDetail_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLJournalDetail] CHECK CONSTRAINT [FK_tblGLJournalDetail_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLJournalDetail_tblGLJournal]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLJournalDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLJournalDetail_tblGLJournal] FOREIGN KEY([intJournalID])
REFERENCES [dbo].[tblGLJournal] ([intJournalID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblGLJournalDetail] CHECK CONSTRAINT [FK_tblGLJournalDetail_tblGLJournal]
GO
/****** Object:  ForeignKey [FK_tblGLJournalRecurringDetail_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLJournalRecurringDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLJournalRecurringDetail] CHECK CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLAccount]
GO
/****** Object:  ForeignKey [FK_tblGLJournalRecurringDetail_tblGLJournalRecurring]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLJournalRecurringDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLJournalRecurring] FOREIGN KEY([intJournalRecurringID])
REFERENCES [dbo].[tblGLJournalRecurring] ([intJournalRecurringID])
GO
ALTER TABLE [dbo].[tblGLJournalRecurringDetail] CHECK CONSTRAINT [FK_tblGLJournalRecurringDetail_tblGLJournalRecurring]
GO
/****** Object:  ForeignKey [FK_tblGLSummary_tblGLAccount]    Script Date: 10/07/2013 18:13:45 ******/
ALTER TABLE [dbo].[tblGLSummary]  WITH CHECK ADD  CONSTRAINT [FK_tblGLSummary_tblGLAccount] FOREIGN KEY([intAccountID])
REFERENCES [dbo].[tblGLAccount] ([intAccountID])
GO
ALTER TABLE [dbo].[tblGLSummary] CHECK CONSTRAINT [FK_tblGLSummary_tblGLAccount]
GO


GO
/****** Object:  Table [dbo].[tblFRSegmentFilterGroupDetail]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRSegmentFilterGroupDetail](
	[intSegmentFilterGroupDetailID] [int] IDENTITY(1,1) NOT NULL,
	[strJoin] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strSegmentCode] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strSegmentFilterGroup] [nvarchar](75)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSegmentName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[ysnDisplayToHeader] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRSegmentFilterGroupDetail] PRIMARY KEY CLUSTERED 
(
	[intSegmentFilterGroupDetailID] ASC,
	[strSegmentFilterGroup] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRSegmentFilterGroup]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRSegmentFilterGroup](
	[intSegmentFilterGroupID] [int] IDENTITY(1,1) NOT NULL,
	[strFilterString] [nvarchar](4000)  COLLATE Latin1_General_CI_AS NULL,
	[strSegmentFilterGroup] [nvarchar](75)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSegmentString] [nvarchar](4000)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRSegmentFilterGroup] PRIMARY KEY CLUSTERED 
(
	[intSegmentFilterGroupID] ASC,
	[strSegmentFilterGroup] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRRowDesignFilterAccount]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRRowDesignFilterAccount](
	[intRowFilterAccountID] [int] IDENTITY(1,1) NOT NULL,
	[intRowID] [int] NOT NULL,
	[intRefNoID] [int] NOT NULL,
	[strName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCondition] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strCriteria] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strCriteriaBetween] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strJoin] [nvarchar](15)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblFRRowDesignAccounts] PRIMARY KEY CLUSTERED 
(
	[intRowFilterAccountID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRRowDesignCalculation]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRRowDesignCalculation](
	[intRowCalculationID] [int] IDENTITY(1,1) NOT NULL,
	[intRowID] [int] NOT NULL,
	[intRefNoID] [int] NOT NULL,
	[intRefNoCalc] [int] NULL,
	[strAction] [nchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
 CONSTRAINT [PK_tblFRRowDesignCalculation] PRIMARY KEY CLUSTERED 
(
	[intRowCalculationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRRowDesign]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRRowDesign](
	[intRowDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intRowID] [int] NOT NULL,
	[intRefNo] [int] NOT NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strRowType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strBalanceSide] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strRelatedRows] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strAccountsUsed] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[ysnShowCredit] [bit] NULL,
	[ysnShowDebit] [bit] NULL,
	[ysnShowOthers] [bit] NULL,
	[ysnLinktoGL] [bit] NULL,
	[dblHeight] [numeric](18, 6) NULL,
	[strFontName] [nchar](35)  COLLATE Latin1_General_CI_AS NULL,
	[strFontStyle] [nchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intFontSize] [int] NULL,
	[strOverrideFormatMask] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[ysnForceReversedExpense] [bit] NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRRowDesign_1] PRIMARY KEY CLUSTERED 
(
	[intRowDetailID] ASC,
	[intRowID] ASC,
	[intRefNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRRow]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRRow](
	[intRowID] [int] IDENTITY(1,1) NOT NULL,
	[strRowName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intMapID] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRRow] PRIMARY KEY CLUSTERED 
(
	[intRowID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRReport]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRReport](
	[intReportID] [int] IDENTITY(1,1) NOT NULL,
	[strOtherEmails] [nvarchar](4000)  COLLATE Latin1_General_CI_AS NULL,
	[ysnIncludeAuditAdjustment] [bit] NULL,
	[ysnShowRedLine] [bit] NULL,
	[dblGutter] [numeric](18, 6) NULL,
	[dblMarginBottom] [numeric](18, 6) NULL,
	[dblMarginLeft] [numeric](18, 6) NULL,
	[dblMarginRight] [numeric](18, 6) NULL,
	[dblMarginTop] [numeric](18, 6) NULL,
	[intSegmentCode] [int] NULL,
	[intBudgetCode] [int] NULL,
	[strSegment] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[ysnShowReportSettings] [bit] NULL,
	[ysnSupressZero] [bit] NULL,
	[dtmAsOfDate] [datetime] NULL,
	[intPageFooterID] [int] NULL,
	[intPageHeaderID] [int] NULL,
	[intReportFooterID] [int] NULL,
	[intReportHeaderID] [int] NULL,
	[ysnDefaultHeader] [bit] NULL,
	[ysnPageFooter] [bit] NULL,
	[ysnPageHeader] [bit] NULL,
	[ysnReportFooter] [bit] NULL,
	[ysnReportHeader] [bit] NULL,
	[strReportName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strReportType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intRowID] [int] NULL,
	[intColumnID] [int] NULL,
	[intMapID] [int] NULL,
	[strOrientation] [nchar](15)  COLLATE Latin1_General_CI_AS NULL,
	[ysnLowPriority] [bit] NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRReport] PRIMARY KEY CLUSTERED 
(
	[intReportID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRMappingDetails]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRMappingDetails](
	[intMapDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intMapID] [int] NOT NULL,
	[strTableName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strTableSourceName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnType] [nchar](25)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnSourceName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblFRMapping_1] PRIMARY KEY CLUSTERED 
(
	[intMapDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRMapping]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRMapping](
	[intMapID] [int] IDENTITY(1,1) NOT NULL,
	[strMapName] [nvarchar](70)  COLLATE Latin1_General_CI_AS NULL,
	[intConnectionID] [int] NULL,
 CONSTRAINT [PK_tblFRMapping1] PRIMARY KEY CLUSTERED 
(
	[intMapID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRHeaderDesign]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRHeaderDesign](
	[intHeaderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[intHeaderID] [int] NOT NULL,
	[intRefNo] [int] NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[dblHeight] [numeric](18, 6) NULL,
	[strFontName] [nchar](35)  COLLATE Latin1_General_CI_AS NULL,
	[strFontStyle] [nchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intFontSize] [int] NULL,
	[strFontColor] [nchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strAllignment] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intGroup] [int] NULL,
	[strWith] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[intColumnRefNo] [int] NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRHeaderDesign] PRIMARY KEY CLUSTERED 
(
	[intHeaderDetailID] ASC,
	[intHeaderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRHeader]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRHeader](
	[intHeaderID] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strHeaderName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strHeaderType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intColumnID] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRHeader_1] PRIMARY KEY CLUSTERED 
(
	[intHeaderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRGroupsDetail]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRGroupsDetail](
	[intGroupDetailID] [int] IDENTITY(1,1) NOT NULL,
	[strSegmentFilter] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[strGroupName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[ysnShowReportSettings] [bit] NULL,
	[strReportName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strReportDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRGroupsDetail] PRIMARY KEY CLUSTERED 
(
	[intGroupDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRGroupOtherReports]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRGroupOtherReports](
	[intGroupOtherReportID] [int] IDENTITY(1,1) NOT NULL,
	[strReportGroup] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strFRReportGroup] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strReportName] [nvarchar](200)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strFullpath] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[ysnShowCriteria] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRGroupOtherReports] PRIMARY KEY CLUSTERED 
(
	[intGroupOtherReportID] ASC,
	[strFRReportGroup] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFREmailFinancials]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFREmailFinancials](
	[intEmailFinancialID] [int] IDENTITY(1,1) NOT NULL,
	[strContactID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strContactType] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strReportName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strIdentifierID] [nvarchar](40)  COLLATE Latin1_General_CI_AS NULL,
	[strExtraNotes] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFREmailFinancials] PRIMARY KEY CLUSTERED 
(
	[strContactID] ASC,
	[strContactType] ASC,
	[strReportName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRConnection]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRConnection](
	[intConnectionID] [int] IDENTITY(1,1) NOT NULL,
	[intUserID] [int] NOT NULL,
	[intTimeout] [int] NOT NULL,
	[strConnectionName] [nvarchar](500)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDataType] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strDSN] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strAuthentication] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strUserID] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strDatabase] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strProduct] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strPort] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strWebServiceURI] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[ysnWebService] [bit] NOT NULL,
 CONSTRAINT [PK_dbo.tblFRConnection] PRIMARY KEY CLUSTERED 
(
	[intConnectionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRColumnDesignSegment]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRColumnDesignSegment](
	[intColumnSegmentID] [int] IDENTITY(1,1) NOT NULL,
	[strJoin] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intSegmentType] [int] NOT NULL,
	[strSegment] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[strSegmentCode] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intColumnID] [int] NOT NULL,
	[intRefNo] [int] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRColumnDesignSegment_1] PRIMARY KEY CLUSTERED 
(
	[intColumnSegmentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRColumnDesignCalculation]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRColumnDesignCalculation](
	[intColumnCalculationID] [int] IDENTITY(1,1) NOT NULL,
	[intColumnID] [int] NOT NULL,
	[intRefNoID] [int] NOT NULL,
	[intRefNoCalc] [int] NULL,
	[strAction] [nchar](10)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblFRColumnDesignCalculation] PRIMARY KEY CLUSTERED 
(
	[intColumnCalculationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRColumnDesign]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRColumnDesign](
	[intColumnDetailID] [int] IDENTITY(1,1) NOT NULL,
	[strSegmentUsed] [nvarchar](4000)  COLLATE Latin1_General_CI_AS NULL,
	[intColumnID] [int] NOT NULL,
	[intRefNo] [int] NOT NULL,
	[ysnReverseSignforExpense] [bit] NOT NULL,
	[strColumnHeader] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumnCaption] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnType] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnCode] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strFilterType] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[strJustification] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strFormatMask] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strColumnFormula] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[ysnHiddenColumn] [bit] NULL,
	[dblWidth] [numeric](18, 6) NULL,
	[intSort] [int] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRColumnDesign] PRIMARY KEY CLUSTERED 
(
	[intColumnDetailID] ASC,
	[intColumnID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRColumn]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRColumn](
	[intColumnID] [int] IDENTITY(1,1) NOT NULL,
	[intRowID] [int] NULL,
	[strColumnName] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRColumn] PRIMARY KEY CLUSTERED 
(
	[intColumnID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRCalculationFormula]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRCalculationFormula](
	[intCalculationFormulaID] [int] IDENTITY(1,1) NOT NULL,
	[intColumnID] [int] NULL,
	[intRowID] [int] NULL,
	[intColumnRefNo] [int] NULL,
	[intRowRefNo] [int] NULL,
	[strFormula] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyID] [int] NULL,
	[strLocFormula] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblFRCalculationFormula] PRIMARY KEY CLUSTERED 
(
	[intCalculationFormulaID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblFRCalculation]    Script Date: 10/07/2013 17:58:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFRCalculation](
	[intCalculationID] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](25)  COLLATE Latin1_General_CI_AS NULL,
	[intComponentID] [int] NULL,
	[strCalculation] [nvarchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[imgCalcTree] [image] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblFRCalculation] PRIMARY KEY CLUSTERED 
(
	[intCalculationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Default [DF__tblFRCalc__intCo__59FA5E80]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRCalculation] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRCalc__intCo__571DF1D5]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRCalculationFormula] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRColu__intCo__276EDEB3]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRColumn] ADD  CONSTRAINT [DF__tblFRColu__intCo__276EDEB3]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRColu__ysnRe__42793730]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRColumnDesign] ADD  CONSTRAINT [DF__tblFRColu__ysnRe__42793730]  DEFAULT ((0)) FOR [ysnReverseSignforExpense]
GO
/****** Object:  Default [DF__tblFRColu__intCo__436D5B69]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRColumnDesign] ADD  CONSTRAINT [DF__tblFRColu__intCo__436D5B69]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRColu__intCo__4BAC3F29]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRColumnDesignSegment] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFREmai__intCo__46E78A0C]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFREmailFinancials] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRGrou__ysnSh__4316F928]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRGroupOtherReports] ADD  DEFAULT ((0)) FOR [ysnShowCriteria]
GO
/****** Object:  Default [DF__tblFRGrou__intCo__440B1D61]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRGroupOtherReports] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRGrou__intCo__403A8C7D]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRGroupsDetail] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRHead__intCo__40058253]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRHeader] ADD  CONSTRAINT [DF__tblFRHead__intCo__40058253]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRHead__intCo__3DE0CF80]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRHeaderDesign] ADD  CONSTRAINT [DF__tblFRHead__intCo__3DE0CF80]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRRepo__ysnIn__0C0220C2]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__ysnIn__0C0220C2]  DEFAULT ((1)) FOR [ysnIncludeAuditAdjustment]
GO
/****** Object:  Default [DF__tblFRRepo__dblGu__0CF644FB]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__dblGu__0CF644FB]  DEFAULT ((0)) FOR [dblGutter]
GO
/****** Object:  Default [DF__tblFRRepo__dblMa__0DEA6934]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__dblMa__0DEA6934]  DEFAULT ((1)) FOR [dblMarginBottom]
GO
/****** Object:  Default [DF__tblFRRepo__dblMa__0EDE8D6D]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__dblMa__0EDE8D6D]  DEFAULT ((1)) FOR [dblMarginLeft]
GO
/****** Object:  Default [DF__tblFRRepo__dblMa__0FD2B1A6]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__dblMa__0FD2B1A6]  DEFAULT ((1)) FOR [dblMarginRight]
GO
/****** Object:  Default [DF__tblFRRepo__dblMa__10C6D5DF]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__dblMa__10C6D5DF]  DEFAULT ((1)) FOR [dblMarginTop]
GO
/****** Object:  Default [DF__tblFRRepo__ysnDe__11BAFA18]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__ysnDe__11BAFA18]  DEFAULT ((1)) FOR [ysnDefaultHeader]
GO
/****** Object:  Default [DF__tblFRRepo__ysnLo__12AF1E51]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__ysnLo__12AF1E51]  DEFAULT ((0)) FOR [ysnLowPriority]
GO
/****** Object:  Default [DF__tblFRRepo__intSo__0B0DFC89]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__intSo__0B0DFC89]  DEFAULT ((0)) FOR [intSort]
GO
/****** Object:  Default [DF__tblFRRepo__intCo__13A3428A]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRReport] ADD  CONSTRAINT [DF__tblFRRepo__intCo__13A3428A]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRRow__intCon__4B7734FF]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRow] ADD  CONSTRAINT [DF__tblFRRow__intCon__4B7734FF]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRRowD__ysnSh__3C69FB99]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRowDesign] ADD  CONSTRAINT [DF__tblFRRowD__ysnSh__3C69FB99]  DEFAULT ((1)) FOR [ysnShowCredit]
GO
/****** Object:  Default [DF__tblFRRowD__ysnSh__3D5E1FD2]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRowDesign] ADD  CONSTRAINT [DF__tblFRRowD__ysnSh__3D5E1FD2]  DEFAULT ((1)) FOR [ysnShowDebit]
GO
/****** Object:  Default [DF__tblFRRowD__ysnSh__3E52440B]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRowDesign] ADD  CONSTRAINT [DF__tblFRRowD__ysnSh__3E52440B]  DEFAULT ((1)) FOR [ysnShowOthers]
GO
/****** Object:  Default [DF__tblFRRowD__ysnFo__3B75D760]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRowDesign] ADD  CONSTRAINT [DF__tblFRRowD__ysnFo__3B75D760]  DEFAULT ((0)) FOR [ysnForceReversedExpense]
GO
/****** Object:  Default [DF__tblFRRowD__intCo__3F466844]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRRowDesign] ADD  CONSTRAINT [DF__tblFRRowD__intCo__3F466844]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRSegm__intCo__1B0907CE]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRSegmentFilterGroup] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DF__tblFRSegm__ysnDi__173876EA]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRSegmentFilterGroupDetail] ADD  DEFAULT ((0)) FOR [ysnDisplayToHeader]
GO
/****** Object:  Default [DF__tblFRSegm__intCo__182C9B23]    Script Date: 10/07/2013 17:58:00 ******/
ALTER TABLE [dbo].[tblFRSegmentFilterGroupDetail] ADD  DEFAULT ((1)) FOR [intConcurrencyID]
GO

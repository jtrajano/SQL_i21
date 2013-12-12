
GO
/****** Object:  Table [dbo].[tblTMWorkCloseReason]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMWorkCloseReason](
	[intCloseReasonID] [int] IDENTITY(1,1) NOT NULL,
	[strCloseReason] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMWorkCloseReason] PRIMARY KEY CLUSTERED 
(
	[intCloseReasonID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMTankType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMTankType](
	[intConcurrencyID] [int] NULL,
	[intTankTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strTankType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMTankType] PRIMARY KEY CLUSTERED 
(
	[intTankTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMTankTownship]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMTankTownship](
	[intTankTownshipID] [int] IDENTITY(1,1) NOT NULL,
	[strTankTownship] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMTownShip] PRIMARY KEY CLUSTERED 
(
	[intTankTownshipID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMTankMeasurement]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMTankMeasurement](
	[intConcurrencyID] [int] NULL,
	[intTankMeasurementID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteDeviceID] [int] NOT NULL,
	[dblTankSize] [numeric](18, 6) NULL,
	[dblTankCapacity] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblTMTankMeasurement] PRIMARY KEY CLUSTERED 
(
	[intTankMeasurementID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSyncPurged]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSyncPurged](
	[intSyncPurged] [int] IDENTITY(1,1) NOT NULL,
	[strCustomerNumber] [nvarchar](10)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerName] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber] [nvarchar](4)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSiteAddress] [nchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[dblMeterReading] [decimal](18, 6) NULL,
	[strInvoiceNumber] [nvarchar](8)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strBulkPlantNumber] [nvarchar](3)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmInvoiceDate] [datetime] NULL,
	[strItemNumber] [nvarchar](13)  COLLATE Latin1_General_CI_AS NULL,
	[strItemAvailableForTM] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strReversePreviousDelivery] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strPerformerID] [nvarchar](3)  COLLATE Latin1_General_CI_AS NULL,
	[intInvoiceLineNumber] [int] NOT NULL,
	[dblExtendedAmount] [decimal](18, 6) NULL,
	[dblQuantityDelivered] [decimal](18, 6) NULL,
	[dblActualPercentAfterDelivery] [decimal](18, 6) NULL,
	[strInvoiceType] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strSalesPersonID] [nvarchar](3)  COLLATE Latin1_General_CI_AS NULL,
	[strReason] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NOT NULL,
	[dtmPurgeDate] [datetime] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMSyncPurged] PRIMARY KEY CLUSTERED 
(
	[intSyncPurged] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSyncOutOfRange]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSyncOutOfRange](
	[intSyncOutOfRangeID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteID] [int] NOT NULL,
	[dtmDateSync] [datetime] NOT NULL,
	[ysnCommit] [bit] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMSyncOutOfRange] PRIMARY KEY CLUSTERED 
(
	[intSyncOutOfRangeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSyncFailed]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSyncFailed](
	[intSyncFailedID] [int] IDENTITY(1,1) NOT NULL,
	[strCustomerNumber] [nvarchar](10)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerName] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber] [nvarchar](4)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSiteAddress] [nchar](500)  COLLATE Latin1_General_CI_AS NULL,
	[dblMeterReading] [decimal](18, 6) NULL,
	[strInvoiceNumber] [nvarchar](10)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strBulkPlantNumber] [nvarchar](3)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmInvoiceDate] [datetime] NULL,
	[strItemNumber] [nvarchar](13)  COLLATE Latin1_General_CI_AS NULL,
	[strItemAvailableForTM] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strReversePreviousDelivery] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strPerformerID] [nvarchar](3)  COLLATE Latin1_General_CI_AS NULL,
	[intInvoiceLineNumber] [int] NOT NULL,
	[dblExtendedAmount] [decimal](18, 6) NULL,
	[dblQuantityDelivered] [decimal](18, 6) NULL,
	[dblActualPercentAfterDelivery] [decimal](18, 6) NULL,
	[strInvoiceType] [nvarchar](1)  COLLATE Latin1_General_CI_AS NULL,
	[strSalesPersonID] [nvarchar](3)  COLLATE Latin1_General_CI_AS NULL,
	[strReason] [nvarchar](250)  COLLATE Latin1_General_CI_AS NULL,
	[ysnTemp] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMSyncFailed] PRIMARY KEY CLUSTERED 
(
	[intSyncFailedID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSiteSeasonResetArchive]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSiteSeasonResetArchive](
	[intSiteSeasonResetArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[intSeasonResetArchiveID] [int] NOT NULL,
	[intSiteID] [int] NOT NULL,
	[dblLastDeliveryDegreeDay] [numeric](18, 6) NOT NULL,
	[dblYTDGallonsThisSeason] [numeric](18, 6) NOT NULL,
	[dblYTDGalsLastSeason] [numeric](18, 6) NOT NULL,
	[dblYTDGals2SeasonsAgo] [numeric](18, 6) NOT NULL,
	[dblYTDSalesThisSeason] [numeric](18, 6) NOT NULL,
	[dblYTDSalesLastSeason] [numeric](18, 6) NOT NULL,
	[dblYTDSales2SeasonsAgo] [numeric](18, 6) NOT NULL,
	[intConcurrencyID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeployedStatus]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeployedStatus](
	[intConcurrencyID] [int] NULL,
	[intDeployedStatusID] [int] IDENTITY(1,1) NOT NULL,
	[strDeployedStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMDeployedStatus] PRIMARY KEY CLUSTERED 
(
	[intDeployedStatusID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMWorkStatusType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMWorkStatusType](
	[intWorkStatusID] [int] IDENTITY(1,1) NOT NULL,
	[strWorkStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMWorkStatus] PRIMARY KEY CLUSTERED 
(
	[intWorkStatusID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMWorkToDoItem]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMWorkToDoItem](
	[intToDoItemID] [int] IDENTITY(1,1) NOT NULL,
	[strToDoItem] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMToDoItem] PRIMARY KEY CLUSTERED 
(
	[intToDoItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDDReadingSeasonResetArchive]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDDReadingSeasonResetArchive](
	[intDDReadingSeasonResetArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[intSeasonResetArchiveID] [int] NOT NULL,
	[intDDReadingID] [int] NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intDegreeDays] [int] NOT NULL,
	[dblAccumulatedDD] [numeric](18, 6) NOT NULL,
	[intClockID] [int] NOT NULL,
	[intConcurrencyID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMCustomer]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMCustomer](
	[intConcurrencyID] [int] NULL,
	[intCustomerID] [int] IDENTITY(1,1) NOT NULL,
	[intCurrentSiteNumber] [int] NOT NULL,
	[intCustomerNumber] [int] NOT NULL,
 CONSTRAINT [PK_tblTMCustomer] PRIMARY KEY CLUSTERED 
(
	[intCustomerID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMCOBOLWRITE]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTMCOBOLWRITE](
	[CustomerNumber] [char](10) NOT NULL,
	[SiteNumber] [char](4) NOT NULL,
	[MeterReading] [decimal](18, 6) NULL,
	[InvoiceNumber] [char](8) NOT NULL,
	[BulkPlantNumber] [char](3) NOT NULL,
	[InvoiceDate] [char](8) NULL,
	[ItemNumber] [char](13) NULL,
	[ItemAvailableForTM] [char](1) NULL,
	[ReversePreviousDelivery] [char](1) NULL,
	[PerformerID] [char](3) NULL,
	[InvoiceLineNumber] [decimal](18, 6) NOT NULL,
	[ExtendedAmount] [decimal](18, 6) NULL,
	[QuantityDelivered] [decimal](18, 6) NULL,
	[ActualPercentAfterDelivery] [decimal](18, 6) NULL,
	[InvoiceType] [char](1) NULL,
	[SalesPersonID] [char](3) NULL,
 CONSTRAINT [PK_tblTMCOBOLWRITE] PRIMARY KEY CLUSTERED 
(
	[BulkPlantNumber] ASC,
	[CustomerNumber] ASC,
	[InvoiceLineNumber] ASC,
	[InvoiceNumber] ASC,
	[SiteNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTMCOBOLREADSiteLink]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTMCOBOLREADSiteLink](
	[CustomerNumber] [char](10) NOT NULL,
	[SiteNumber] [char](4) NOT NULL,
	[ContractCustomerNumber] [char](10) NOT NULL,
	[ContractNumber] [char](8) NOT NULL,
 CONSTRAINT [PK_tblTMCOBOLREADSiteLink] PRIMARY KEY CLUSTERED 
(
	[ContractCustomerNumber] ASC,
	[ContractNumber] ASC,
	[CustomerNumber] ASC,
	[SiteNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTMCOBOLREADSite]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTMCOBOLREADSite](
	[CustomerNumber] [char](10) NOT NULL,
	[SiteNumber] [char](4) NOT NULL,
	[ClockNumber] [char](3) NULL,
	[SiteAddress] [char](200) NULL,
	[BillingBy] [char](50) NULL,
	[TotalCapacity] [decimal](18, 6) NULL,
	[ClassFillOption] [char](20) NULL,
	[ItemNumber] [char](13) NULL,
	[Taxable] [char](1) NULL,
	[TaxState] [char](2) NULL,
	[TaxLocale1] [char](3) NULL,
	[TaxLocale2] [char](3) NULL,
	[AllowPriceChange] [char](1) NULL,
	[PriceAdjustment] [decimal](18, 6) NULL,
	[AcctStatus] [char](1) NULL,
	[PromptForPercentFull] [char](1) NULL,
	[AdjustBurnRate] [char](1) NULL,
	[RecurringPONumber] [char](15) NULL,
	[LastDeliveryDate] [char](8) NULL,
	[LastMeterReading] [decimal](18, 6) NULL,
	[MeterType] [char](50) NULL,
	[ConversionFactor] [decimal](18, 8) NULL,
	[Description] [char](200) NULL,
	[SerialNumber] [char](50) NULL,
 CONSTRAINT [PK_tblTMCOBOLREADSite] PRIMARY KEY CLUSTERED 
(
	[CustomerNumber] ASC,
	[SiteNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTMCOBOLLeaseBilling]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTMCOBOLLeaseBilling](
	[strConsumptionSiteCustomerNo] [char](10) NOT NULL,
	[strBillToCustomerNo] [char](10) NOT NULL,
	[strSiteNumber] [char](4) NOT NULL,
	[strDeviceSerialNumber] [char](10) NOT NULL,
	[strBatchNumber] [numeric](3, 0) NULL,
	[intPostDate] [numeric](8, 0) NULL,
	[strLocationNumber] [char](3) NULL,
	[strItemNumber] [char](13) NULL,
	[dblTotalQty] [numeric](13, 4) NULL,
	[dblLeaseAmount] [numeric](11, 2) NULL,
	[strConsolidateDevice] [char](1) NULL,
	[intDeviceID] [numeric](8, 0) NULL,
	[strInvoiceNumber] [char](8) NULL,
	[strStatus] [char](50) NULL,
	[dblBillAmount] [numeric](11, 2) NULL,
	[strSiteTaxable] [char](1) NULL,
	[strSiteState] [char](2) NULL,
	[strSiteLocale1] [char](3) NULL,
	[strSiteLocale2] [char](3) NULL,
 CONSTRAINT [PK_tblTMCOBOLLeaseBilling] PRIMARY KEY CLUSTERED 
(
	[strConsumptionSiteCustomerNo] ASC,
	[strBillToCustomerNo] ASC,
	[strSiteNumber] ASC,
	[strDeviceSerialNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTMClock]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMClock](
	[intConcurrencyID] [int] NULL,
	[intClockID] [int] IDENTITY(1,1) NOT NULL,
	[strClockNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmSummerChangeDate] [datetime] NULL,
	[dtmWinterChangeDate] [datetime] NULL,
	[strDeliveryTicketPrinter] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDeliveryTicketNumber] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strDeliveryTicketFormat] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strReadingEntryMethod] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intBaseTemperature] [int] NULL,
	[dblAccumulatedWinterClose] [numeric](18, 6) NULL,
	[dblJanuaryDailyAverage] [numeric](18, 6) NULL,
	[dblFebruaryDailyAverage] [numeric](18, 6) NULL,
	[dblMarchDailyAverage] [numeric](18, 6) NULL,
	[dblAprilDailyAverage] [numeric](18, 6) NULL,
	[dblMayDailyAverage] [numeric](18, 6) NULL,
	[dblJuneDailyAverage] [numeric](18, 6) NULL,
	[dblJulyDailyAverage] [numeric](18, 6) NULL,
	[dblAugustDailyAverage] [numeric](18, 6) NULL,
	[dblSeptemberDailyAverage] [numeric](18, 6) NULL,
	[dblOctoberDailyAverage] [numeric](18, 6) NULL,
	[dblNovemberDailyAverage] [numeric](18, 6) NULL,
	[dblDecemberDailyAverage] [numeric](18, 6) NULL,
	[strAddress] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCity] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCountry] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strCurrentSeason] [nvarchar](6)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strState] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblTMClock] PRIMARY KEY CLUSTERED 
(
	[intClockID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMApplianceType]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMApplianceType](
	[intConcurrencyID] [int] NULL,
	[intApplianceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strApplianceType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
 CONSTRAINT [PK_tblTMApplianceType] PRIMARY KEY CLUSTERED 
(
	[intApplianceTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_tblTMApplianceType_strApplianceType] UNIQUE NONCLUSTERED 
(
	[strApplianceType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeliveryMethod]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeliveryMethod](
	[intConcurrencyID] [int] NULL,
	[intDeliveryMethodID] [int] IDENTITY(1,1) NOT NULL,
	[strDeliveryMethod] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMDeliveryMethod] PRIMARY KEY CLUSTERED 
(
	[intDeliveryMethodID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeviceType]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeviceType](
	[intConcurrencyID] [int] NULL,
	[intDeviceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strDeviceType] [nvarchar](70)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
 CONSTRAINT [PK_tblTMDeviceType] PRIMARY KEY CLUSTERED 
(
	[intDeviceTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_tblTMDeviceType_strDeviceType] UNIQUE NONCLUSTERED 
(
	[strDeviceType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMInventoryStatusType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMInventoryStatusType](
	[intConcurrencyID] [int] NULL,
	[intInventoryStatusTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strInventoryStatusType] [nvarchar](70)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
 CONSTRAINT [PK_tblTMInventoryStatusType] PRIMARY KEY CLUSTERED 
(
	[intInventoryStatusTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMHoldReason]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMHoldReason](
	[intConcurrencyID] [int] NULL,
	[intHoldReasonID] [int] IDENTITY(1,1) NOT NULL,
	[strHoldReason] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMHoldReason] PRIMARY KEY CLUSTERED 
(
	[intHoldReasonID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMFillMethod]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMFillMethod](
	[intConcurrencyID] [int] NULL,
	[intFillMethodID] [int] IDENTITY(1,1) NOT NULL,
	[strFillMethod] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
 CONSTRAINT [PK_tblTMFillMethod] PRIMARY KEY CLUSTERED 
(
	[intFillMethodID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMFillGroup]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMFillGroup](
	[intFillGroupID] [int] IDENTITY(1,1) NOT NULL,
	[strFillGroupCode] [nvarchar](6)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMFillGroup] PRIMARY KEY CLUSTERED 
(
	[intFillGroupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_tblTMFillGroup_strFillGroupCode] UNIQUE NONCLUSTERED 
(
	[strFillGroupCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMEventType]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMEventType](
	[intConcurrencyID] [int] NULL,
	[intEventTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strEventType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NOT NULL,
	[strDescription] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblTMEventType] PRIMARY KEY CLUSTERED 
(
	[intEventTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSeasonResetArchive]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSeasonResetArchive](
	[intSeasonResetArchiveID] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intUserID] [int] NOT NULL,
	[strNewSeason] [nvarchar](6)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strCurrentSeason] [nvarchar](6)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSeason] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intClockID] [int] NOT NULL,
	[intConcurrencyID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMRoute]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMRoute](
	[intRouteID] [int] IDENTITY(1,1) NOT NULL,
	[strRouteID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMRoute] PRIMARY KEY CLUSTERED 
(
	[intRouteID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMRegulatorType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMRegulatorType](
	[intConcurrencyID] [int] NULL,
	[intRegulatorTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strRegulatorType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED 
(
	[intRegulatorTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMPreferenceCompany]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMPreferenceCompany](
	[intConcurrencyID] [int] NULL,
	[strSummitIntegration] [nvarchar](10)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intPreferenceCompanyID] [int] IDENTITY(1,1) NOT NULL,
	[intCeilingBurnRate] [int] NULL,
	[intFloorBurnRate] [int] NULL,
	[ysnAllowClassFill] [bit] NULL,
	[dblDefaultReservePercent] [numeric](18, 6) NULL,
	[strSMTPServer] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strSMTPUsername] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strSMTPPassword] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strFromMail] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strFromName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intMailServerPort] [int] NULL,
	[ysnEnableAuthentication] [bit] NULL,
	[ysnEnableSSL] [bit] NULL,
	[strLeaseProductNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[ysnEnableETracker] [bit] NULL,
	[strETrackerURL] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[ysnUseDeliveryTermOnCS] [bit] NULL,
	[ysnEnableLeaseBillingAboveMinUse] [bit] NULL,
 CONSTRAINT [PK_tblTMPreferenceCompany] PRIMARY KEY CLUSTERED 
(
	[intPreferenceCompanyID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMPossessionType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMPossessionType](
	[intConcurrencyID] [int] NULL,
	[intPossessionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strPossessionType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMPossessionType] PRIMARY KEY CLUSTERED 
(
	[intPossessionTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMMeterType]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMMeterType](
	[intConcurrencyID] [int] NULL,
	[intMeterTypeID] [int] IDENTITY(1,1) NOT NULL,
	[strMeterType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dblConversionFactor] [numeric](18, 8) NULL,
	[ysnDefault] [bit] NULL,
 CONSTRAINT [PK_tblTMMeterType] PRIMARY KEY CLUSTERED 
(
	[intMeterTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMLeaseMinimumUse]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMLeaseMinimumUse](
	[intLeaseMinimumUseID] [int] IDENTITY(1,1) NOT NULL,
	[dblSiteCapacity] [numeric](18, 6) NOT NULL,
	[dblMinimumUsage] [numeric](18, 6) NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMLeaseMinimumUse] PRIMARY KEY CLUSTERED 
(
	[intLeaseMinimumUseID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMLeaseCode]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMLeaseCode](
	[intConcurrencyID] [int] NULL,
	[intLeaseCodeID] [int] IDENTITY(1,1) NOT NULL,
	[strLeaseCode] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150)  COLLATE Latin1_General_CI_AS NULL,
	[dblAmount] [numeric](18, 6) NOT NULL,
 CONSTRAINT [PK_tblTMLeaseCode] PRIMARY KEY CLUSTERED 
(
	[intLeaseCodeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_tblTMLeaseCode_strLeaseCode] UNIQUE NONCLUSTERED 
(
	[strLeaseCode] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMLease]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMLease](
	[intConcurrencyID] [int] NULL,
	[intLeaseID] [int] IDENTITY(1,1) NOT NULL,
	[intLeaseCodeID] [int] NULL,
	[strLeaseNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intBillToCustomerID] [int] NULL,
	[ysnLeaseToOwn] [bit] NULL,
	[strLeaseStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strBillingFrequency] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intBillingMonth] [int] NULL,
	[strBillingType] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmDontBillAfter] [datetime] NULL,
	[strRentalStatus] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[dtmLastLeaseBillingDate] [datetime] NULL,
 CONSTRAINT [PK_tblTMLease] PRIMARY KEY CLUSTERED 
(
	[intLeaseID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_tblTMLease_strLeaseNumber] UNIQUE NONCLUSTERED 
(
	[strLeaseNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMEventAutomation]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMEventAutomation](
	[intConcurrencyID] [int] NULL,
	[intEventAutomationID] [int] IDENTITY(1,1) NOT NULL,
	[intEventTypeID] [int] NULL,
	[strProduct] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
 CONSTRAINT [PK_tblTMEventAutomation] PRIMARY KEY CLUSTERED 
(
	[intEventAutomationID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMEvent]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMEvent](
	[intConcurrencyID] [int] NULL,
	[intEventID] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NULL,
	[intEventTypeID] [int] NOT NULL,
	[intPerformerID] [int] NULL,
	[intUserID] [int] NOT NULL,
	[intDeviceID] [int] NULL,
	[dtmLastUpdated] [datetime] NULL,
	[strDeviceOwnership] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strDeviceSerialNumber] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[strDeviceType] [nvarchar](70)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[intSiteID] [int] NULL,
	[strLevel] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblTMEvent] PRIMARY KEY CLUSTERED 
(
	[intEventID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDegreeDayReading]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDegreeDayReading](
	[intConcurrencyID] [int] NULL,
	[intDegreeDayReadingID] [int] IDENTITY(1,1) NOT NULL,
	[intClockLocationID] [int] NOT NULL,
	[dtmDate] [datetime] NULL,
	[intDegreeDays] [int] NULL,
	[dblAccumulatedDegreeDay] [numeric](18, 6) NULL,
	[strSeason] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NULL,
	[dtmLastUpdated] [datetime] NULL,
	[intClockID] [int] NOT NULL,
 CONSTRAINT [PK_tblTMDDReading] PRIMARY KEY CLUSTERED 
(
	[intDegreeDayReadingID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSite](
	[intConcurrencyID] [int] NULL,
	[intSiteID] [int] IDENTITY(1,1) NOT NULL,
	[strSiteAddress] [nvarchar](1000)  COLLATE Latin1_General_CI_AS NULL,
	[intProduct] [int] NULL,
	[intCustomerID] [int] NOT NULL,
	[dblTotalCapacity] [numeric](18, 6) NULL,
	[ysnOnHold] [bit] NULL,
	[ysnActive] [bit] NULL,
	[strDescription] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[strAcctStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblPriceAdjustment] [numeric](18, 6) NULL,
	[intClockID] [int] NULL,
	[dblDegreeDayBetweenDelivery] [numeric](18, 6) NULL,
	[dblSummerDailyUse] [numeric](18, 6) NULL,
	[dblWinterDailyUse] [numeric](18, 6) NULL,
	[ysnTaxable] [bit] NULL,
	[intTaxStateID] [int] NULL,
	[ysnPrintDeliveryTicket] [bit] NULL,
	[ysnAdjustBurnRate] [bit] NULL,
	[intDriverID] [int] NULL,
	[strRouteID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strSequenceID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblYTDGalsThisSeason] [numeric](18, 6) NULL,
	[dblYTDGalsLastSeason] [numeric](18, 6) NULL,
	[dtmRunOutDate] [datetime] NULL,
	[dblEstimatedPercentLeft] [numeric](18, 6) NULL,
	[dblConfidenceFactor] [numeric](18, 6) NULL,
	[strZipCode] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strCity] [nvarchar](70)  COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](70)  COLLATE Latin1_General_CI_AS NULL,
	[dblLatitude] [numeric](18, 6) NOT NULL,
	[dblLongitude] [numeric](18, 6) NOT NULL,
	[intSiteNumber] [int] NOT NULL,
	[dtmOnHoldStartDate] [datetime] NULL,
	[dtmOnHoldEndDate] [datetime] NULL,
	[ysnHoldDDCalculations] [bit] NULL,
	[dblYTDSales] [numeric](18, 6) NULL,
	[intUserID] [int] NULL,
	[strBillingBy] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblPreviousBurnRate] [numeric](18, 6) NULL,
	[dblTotalReserve] [numeric](18, 6) NULL,
	[dblLastGalsInTank] [numeric](18, 6) NULL,
	[dblLastDeliveredGal] [numeric](18, 6) NULL,
	[intDeliveryTicketNumber] [int] NULL,
	[dblEstimatedGallonsLeft] [numeric](18, 6) NULL,
	[dtmLastDeliveryDate] [datetime] NULL,
	[dtmNextDeliveryDate] [datetime] NULL,
	[strCountry] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intFillMethodID] [int] NULL,
	[intHoldReasonID] [int] NULL,
	[dblYTDGals2SeasonsAgo] [numeric](18, 6) NULL,
	[intTaxLocale1] [int] NULL,
	[intTaxLocale2] [int] NULL,
	[ysnAllowPriceChange] [bit] NULL,
	[intRecurringPONumber] [int] NULL,
	[ysnPrintARBalance] [bit] NULL,
	[ysnPromptForPercentFull] [bit] NULL,
	[strFillGroup] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblBurnRate] [numeric](18, 6) NULL,
	[strTankTownship] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[dtmLastUpdated] [datetime] NULL,
	[intLastDeliveryDegreeDay] [int] NULL,
	[intNextDeliveryDegreeDay] [int] NULL,
	[ysnDeliveryTicketPrinted] [bit] NULL,
	[strComment] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strInstruction] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[strClassFillOption] [nvarchar](20)  COLLATE Latin1_General_CI_AS NULL,
	[dblLastMeterReading] [numeric](18, 6) NULL,
	[strLocation] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intRoute] [int] NULL,
	[dtmLastReadingUpdate] [datetime] NULL,
	[intFillGroupID] [int] NULL,
	[intRouteID] [int] NULL,
	[intTankTownshipID] [int] NULL,
	[dtmForecastedDelivery] [datetime] NULL,
	[intParentSiteID] [int] NULL,
	[intDeliveryTermID] [int] NULL,
	[dblYTDSalesLastSeason] [numeric](18, 6) NULL,
	[dblYTDSales2SeasonsAgo] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblTMSite] PRIMARY KEY CLUSTERED 
(
	[intSiteID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSiteLink]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSiteLink](
	[intConcurrencyID] [int] NULL,
	[intSiteLinkID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteID] [int] NULL,
	[intContractID] [int] NOT NULL,
 CONSTRAINT [PK_tblTMSiteLink] PRIMARY KEY CLUSTERED 
(
	[intSiteLinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSiteJulianCalendar]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSiteJulianCalendar](
	[intConcurrencyID] [int] NULL,
	[intSiteJulianCalendarID] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[dtmStartDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[ysnAutoRenew] [bit] NULL,
	[intSiteID] [int] NOT NULL,
	[intRecurInterval] [int] NOT NULL,
	[intRecurMonth] [int] NULL,
	[intRecurPattern] [int] NOT NULL,
	[ysnSunday] [bit] NOT NULL,
	[ysnMonday] [bit] NOT NULL,
	[ysnTuesday] [bit] NOT NULL,
	[ysnWednesday] [bit] NOT NULL,
	[ysnThursday] [bit] NOT NULL,
	[ysnFriday] [bit] NOT NULL,
	[ysnSaturday] [bit] NOT NULL,
	[dtmLastLeaseBillingDate] [datetime] NULL,
	[ysnSingleDateOverride] [bit] NOT NULL
 CONSTRAINT [PK_tblTMSiteJulianCalendar] PRIMARY KEY CLUSTERED 
(
	[intSiteJulianCalendarID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMWorkOrder]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMWorkOrder](
	[intWorkOrderID] [int] IDENTITY(1,1) NOT NULL,
	[strWorkOrderNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intWorkStatusTypeID] [int] NOT NULL,
	[intPerformerID] [int] NOT NULL,
	[strAdditionalInfo] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[intEnteredByID] [int] NULL,
	[dtmDateCreated] [datetime] NULL,
	[dtmDateClosed] [datetime] NULL,
	[dtmDateScheduled] [datetime] NULL,
	[intCloseReasonID] [int] NULL,
	[strComments] [nvarchar](max)  COLLATE Latin1_General_CI_AS NULL,
	[intSiteID] [int] NOT NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMWork] PRIMARY KEY CLUSTERED 
(
	[intWorkOrderID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeliverySchedule]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeliverySchedule](
	[intConcurrencyID] [int] NULL,
	[intDeliveryScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[intInterval] [int] NULL,
	[ysnOnWeekDay] [bit] NULL,
	[strRecurrencePattern] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intSiteID] [int] NOT NULL,
	[ysnSunday] [bit] NULL,
	[ysnMonday] [bit] NULL,
	[ysnTuesday] [bit] NULL,
	[ysnWednesday] [bit] NULL,
	[ysnThursday] [bit] NULL,
	[ysnFriday] [bit] NULL,
	[ysnSaturday] [bit] NULL,
 CONSTRAINT [PK_tblTMDeliverySchedule] PRIMARY KEY CLUSTERED 
(
	[intDeliveryScheduleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDevice]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDevice](
	[intConcurrencyID] [int] NULL,
	[intDeviceID] [int] IDENTITY(1,1) NOT NULL,
	[strSerialNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strManufacturerID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strManufacturerName] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strModelNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strBulkPlant] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[strOwnership] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strAssetNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dtmPurchaseDate] [datetime] NULL,
	[dblPurchasePrice] [numeric](18, 6) NULL,
	[dtmManufacturedDate] [datetime] NULL,
	[strComment] [nvarchar](300)  COLLATE Latin1_General_CI_AS NULL,
	[ysnUnderground] [bit] NOT NULL,
	[intTankSize] [int] NOT NULL,
	[intTankCapacity] [int] NOT NULL,
	[dblTankReserve] [numeric](18, 6) NULL,
	[dblEstimatedGalTank] [numeric](18, 6) NULL,
	[intMeterCycle] [int] NOT NULL,
	[intDeviceTypeID] [int] NULL,
	[intLeaseID] [int] NULL,
	[intDeployedStatusID] [int] NULL,
	[intParentDeviceID] [int] NULL,
	[intInventoryStatusTypeID] [int] NULL,
	[intTankTypeID] [int] NULL,
	[intMeterTypeID] [int] NULL,
	[intRegulatorTypeID] [int] NULL,
	[intLinkedToTankID] [int] NULL,
	[strMeterStatus] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblMeterReading] [numeric](18, 6) NULL,
	[ysnAppliance] [bit] NOT NULL,
	[intApplianceTypeID] [int] NULL,
 CONSTRAINT [PK_tblTMDevice] PRIMARY KEY CLUSTERED 
(
	[intDeviceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeliveryHistory]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeliveryHistory](
	[intConcurrencyID] [int] NULL,
	[intDeliveryHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[strInvoiceNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[strBulkPlantNumber] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dtmInvoiceDate] [datetime] NULL,
	[strProductDelivered] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dblQuantityDelivered] [numeric](18, 6) NULL,
	[intDegreeDayOnDeliveryDate] [int] NULL,
	[intDegreeDayOnLastDeliveryDate] [int] NULL,
	[dblBurnRateAfterDelivery] [numeric](18, 6) NULL,
	[dblCalculatedBurnRate] [numeric](18, 6) NULL,
	[ysnAdjustBurnRate] [bit] NULL,
	[intElapsedDegreeDaysBetweenDeliveries] [int] NULL,
	[intElapsedDaysBetweenDeliveries] [int] NULL,
	[strSeason] [nvarchar](15)  COLLATE Latin1_General_CI_AS NULL,
	[dblWinterDailyUsageBetweenDeliveries] [numeric](18, 6) NULL,
	[dblSummerDailyUsageBetweenDeliveries] [numeric](18, 6) NULL,
	[dblGallonsInTankbeforeDelivery] [numeric](18, 6) NULL,
	[dblGallonsInTankAfterDelivery] [numeric](18, 6) NULL,
	[dblEstimatedPercentBeforeDelivery] [numeric](18, 6) NULL,
	[dblActualPercentAfterDelivery] [numeric](18, 6) NULL,
	[dblMeterReading] [numeric](18, 6) NULL,
	[dblLastMeterReading] [numeric](18, 6) NULL,
	[intUserID] [int] NULL,
	[dtmLastUpdated] [datetime] NULL,
	[intSiteID] [int] NULL,
	[strSalesPersonID] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[dbltmpExtendedAmount] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblTMDeliveryHistory] PRIMARY KEY CLUSTERED 
(
	[intDeliveryHistoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDispatch]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDispatch](
	[intConcurrencyID] [int] NULL,
	[intDispatchID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteID] [int] NULL,
	[dblPercentLeft] [numeric](18, 6) NULL,
	[dblQuantity] [numeric](18, 6) NULL,
	[dblMinimumQuantity] [numeric](18, 6) NULL,
	[intProductID] [int] NULL,
	[intSubstituteProductID] [int] NULL,
	[dblPrice] [numeric](18, 6) NULL,
	[dblTotal] [numeric](18, 6) NULL,
	[dtmRequestedDate] [datetime] NULL,
	[intPriority] [int] NULL,
	[strComments] [nvarchar](200)  COLLATE Latin1_General_CI_AS NULL,
	[ysnCallEntryPrinted] [bit] NULL,
	[intDriverID] [int] NULL,
	[intDispatchDriverID] [int] NULL,
	[strDispatchLoadNumber] [nvarchar](3)  COLLATE Latin1_General_CI_AS NULL,
	[dtmCallInDate] [datetime] NULL,
	[ysnSelected] [bit] NULL,
	[strRoute] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[strSequence] [nvarchar](10)  COLLATE Latin1_General_CI_AS NULL,
	[intUserID] [int] NULL,
	[dtmLastUpdated] [datetime] NULL,
	[ysnDispatched] [bit] NULL,
	[strCancelDispatchMessage] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intDeliveryTermID] [int] NULL,
	[dtmDispatchingDate] [datetime] NULL,
 CONSTRAINT [PK_tblTMDispatch] PRIMARY KEY CLUSTERED 
(
	[intDispatchID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMJulianCalendarDelivery]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMJulianCalendarDelivery](
	[intConcurrencyID] [int] NULL,
	[intJulianCalendarDeliveryID] [int] IDENTITY(1,1) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intSiteJulianCalendarID] [int] NOT NULL,
 CONSTRAINT [PK_tblTMJulianCalendarDelivery] PRIMARY KEY CLUSTERED 
(
	[intJulianCalendarDeliveryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMDeliveryHistoryDetail]    Script Date: 10/07/2013 15:06:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMDeliveryHistoryDetail](
	[intDeliveryHistoryDetailID] [int] IDENTITY(1,1) NOT NULL,
	[strInvoiceNumber] [nvarchar](8)  COLLATE Latin1_General_CI_AS NULL,
	[dblQuantityDelivered] [numeric](18, 6) NOT NULL,
	[strItemNumber] [nvarchar](15)  COLLATE Latin1_General_CI_AS NULL,
	[intDeliveryHistoryID] [int] NOT NULL,
	[intConcurrencyID] [int] NULL,
	[dblPercentAfterDelivery] [decimal](18, 6) NOT NULL,
	[dbltmpExtendedAmount] [numeric](18, 6) NULL,
 CONSTRAINT [PK_tblTMDeliveryHistoryDetail] PRIMARY KEY CLUSTERED 
(
	[intDeliveryHistoryDetailID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMWorkToDo]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMWorkToDo](
	[intWorkToDoID] [int] IDENTITY(1,1) NOT NULL,
	[intWorkToDoItemID] [int] NOT NULL,
	[intWorkOrderID] [int] NOT NULL,
	[ysnCompleted] [bit] NULL,
	[intConcurrencyID] [int] NULL,
 CONSTRAINT [PK_tblTMWorkToDo] PRIMARY KEY CLUSTERED 
(
	[intWorkToDoID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSiteDevice]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSiteDevice](
	[intConcurrencyID] [int] NULL,
	[intSiteDeviceID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteID] [int] NULL,
	[intDeviceID] [int] NULL,
	[ysnAtCustomerToBeTransferred] [bit] NULL,
 CONSTRAINT [PK_tblTMSiteDevice] PRIMARY KEY CLUSTERED 
(
	[intSiteDeviceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblTMSiteDeviceLink]    Script Date: 10/07/2013 15:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTMSiteDeviceLink](
	[intConcurrencyID] [int] NULL,
	[intSiteDeviceLinkID] [int] IDENTITY(1,1) NOT NULL,
	[intSiteID] [int] NULL,
	[intSiteDeviceID] [int] NULL,
 CONSTRAINT [PK_tblTMSiteDeviceLink] PRIMARY KEY CLUSTERED 
(
	[intSiteDeviceLinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Default [DEF_tblTMApplianceType_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMApplianceType] ADD  CONSTRAINT [DEF_tblTMApplianceType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMApplianceType_strApplianceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMApplianceType] ADD  CONSTRAINT [DEF_tblTMApplianceType_strApplianceType]  DEFAULT ('') FOR [strApplianceType]
GO
/****** Object:  Default [DEF_tblTMApplianceType_ysnDefault]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMApplianceType] ADD  CONSTRAINT [DEF_tblTMApplianceType_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMClock_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMClock_strClockNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strClockNumber]  DEFAULT ('') FOR [strClockNumber]
GO
/****** Object:  Default [DEF_tblTMClock_dtmSummerChangeDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dtmSummerChangeDate]  DEFAULT ((0)) FOR [dtmSummerChangeDate]
GO
/****** Object:  Default [DEF_tblTMClock_dtmWinterChangeDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dtmWinterChangeDate]  DEFAULT ((0)) FOR [dtmWinterChangeDate]
GO
/****** Object:  Default [DEF_tblTMClock_strDeliveryTicketPrinter]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strDeliveryTicketPrinter]  DEFAULT ('') FOR [strDeliveryTicketPrinter]
GO
/****** Object:  Default [DEF_tblTMClock_strDeliveryTicketNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strDeliveryTicketNumber]  DEFAULT ('') FOR [strDeliveryTicketNumber]
GO
/****** Object:  Default [DEF_tblTMClock_strDeliveryTicketFormat]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strDeliveryTicketFormat]  DEFAULT ('') FOR [strDeliveryTicketFormat]
GO
/****** Object:  Default [DEF_tblTMClock_strReadingEntryMethod]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strReadingEntryMethod]  DEFAULT ('') FOR [strReadingEntryMethod]
GO
/****** Object:  Default [DEF_tblTMClock_intBaseTemperature]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_intBaseTemperature]  DEFAULT ((0)) FOR [intBaseTemperature]
GO
/****** Object:  Default [DEF_tblTMClock_dblAccDDWinterClose]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblAccDDWinterClose]  DEFAULT ((0)) FOR [dblAccumulatedWinterClose]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD01]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD01]  DEFAULT ((0)) FOR [dblJanuaryDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD02]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD02]  DEFAULT ((0)) FOR [dblFebruaryDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD03]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD03]  DEFAULT ((0)) FOR [dblMarchDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD04]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD04]  DEFAULT ((0)) FOR [dblAprilDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD05]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD05]  DEFAULT ((0)) FOR [dblMayDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD06]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD06]  DEFAULT ((0)) FOR [dblJuneDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD07]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD07]  DEFAULT ((0)) FOR [dblJulyDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD08]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD08]  DEFAULT ((0)) FOR [dblAugustDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD09]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD09]  DEFAULT ((0)) FOR [dblSeptemberDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD10]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD10]  DEFAULT ((0)) FOR [dblOctoberDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD11]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD11]  DEFAULT ((0)) FOR [dblNovemberDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_dblDailyAverageDD12]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_dblDailyAverageDD12]  DEFAULT ((0)) FOR [dblDecemberDailyAverage]
GO
/****** Object:  Default [DEF_tblTMClock_strAddress]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strAddress]  DEFAULT ('') FOR [strAddress]
GO
/****** Object:  Default [DEF_tblTMClock_strZipCode]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strZipCode]  DEFAULT ('') FOR [strZipCode]
GO
/****** Object:  Default [DEF_tblTMClock_strCity]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strCity]  DEFAULT ('') FOR [strCity]
GO
/****** Object:  Default [DEF_tblTMClock_strCountry]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strCountry]  DEFAULT ('') FOR [strCountry]
GO
/****** Object:  Default [DEF_tblTMClock_strCurrentSeason]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strCurrentSeason]  DEFAULT (N'Winter') FOR [strCurrentSeason]
GO
/****** Object:  Default [DEF_tblTMClock_strState]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMClock] ADD  CONSTRAINT [DEF_tblTMClock_strState]  DEFAULT ((0)) FOR [strState]
GO
/****** Object:  Default [DF_tblTMCOBOLLeaseBilling_dblBillAmount]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLLeaseBilling] ADD  CONSTRAINT [DF_tblTMCOBOLLeaseBilling_dblBillAmount]  DEFAULT ((0)) FOR [dblBillAmount]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_CustomerNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_CustomerNumber]  DEFAULT ((0)) FOR [CustomerNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_SiteNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_SiteNumber]  DEFAULT ((0)) FOR [SiteNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_ClockNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_ClockNumber]  DEFAULT ((0)) FOR [ClockNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_SiteAddress]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_SiteAddress]  DEFAULT ((0)) FOR [SiteAddress]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_BillingBy]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_BillingBy]  DEFAULT ((0)) FOR [BillingBy]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_TotalCapacity]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_TotalCapacity]  DEFAULT ((0)) FOR [TotalCapacity]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_ClassFillOption]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_ClassFillOption]  DEFAULT ((0)) FOR [ClassFillOption]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_ItemNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_ItemNumber]  DEFAULT ((0)) FOR [ItemNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_Taxable]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_Taxable]  DEFAULT ((0)) FOR [Taxable]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_TaxState]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxState]  DEFAULT ((0)) FOR [TaxState]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_TaxLocale1]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxLocale1]  DEFAULT ((0)) FOR [TaxLocale1]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_TaxLocale2]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_TaxLocale2]  DEFAULT ((0)) FOR [TaxLocale2]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_AllowPriceChange]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_AllowPriceChange]  DEFAULT ((0)) FOR [AllowPriceChange]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_PriceAdjustment]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_PriceAdjustment]  DEFAULT ((0)) FOR [PriceAdjustment]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_AcctStatus]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_AcctStatus]  DEFAULT ((0)) FOR [AcctStatus]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_PromptForPercentFull]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_PromptForPercentFull]  DEFAULT ((0)) FOR [PromptForPercentFull]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_AdjustBurnRate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_AdjustBurnRate]  DEFAULT ((0)) FOR [AdjustBurnRate]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_RecurringPONumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_RecurringPONumber]  DEFAULT ((0)) FOR [RecurringPONumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_LastDeliveryDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_LastDeliveryDate]  DEFAULT ((0)) FOR [LastDeliveryDate]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_LastMeterReading]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_LastMeterReading]  DEFAULT ((0)) FOR [LastMeterReading]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_MeterType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_MeterType]  DEFAULT ((0)) FOR [MeterType]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_ConversionFactor]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_ConversionFactor]  DEFAULT ((0)) FOR [ConversionFactor]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSite_Description]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSite] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSite_Description]  DEFAULT ((0)) FOR [Description]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSiteLink_CustomerNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSiteLink] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_CustomerNumber]  DEFAULT ((0)) FOR [CustomerNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSiteLink_SiteNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSiteLink] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_SiteNumber]  DEFAULT ((0)) FOR [SiteNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSiteLink_ContractCustomerNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSiteLink] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractCustomerNumber]  DEFAULT ((0)) FOR [ContractCustomerNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLREADSiteLink_ContractNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLREADSiteLink] ADD  CONSTRAINT [DEF_tblTMCOBOLREADSiteLink_ContractNumber]  DEFAULT ((0)) FOR [ContractNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_CustomerNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_CustomerNumber]  DEFAULT ((0)) FOR [CustomerNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_SiteNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_SiteNumber]  DEFAULT ((0)) FOR [SiteNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_MeterReading]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_MeterReading]  DEFAULT ((0)) FOR [MeterReading]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_InvoiceNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceNumber]  DEFAULT ((0)) FOR [InvoiceNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_BulkPlantNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_BulkPlantNumber]  DEFAULT ((0)) FOR [BulkPlantNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_InvoiceDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceDate]  DEFAULT ((0)) FOR [InvoiceDate]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_ItemNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemNumber]  DEFAULT ((0)) FOR [ItemNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_ItemAvailableForTM]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_ItemAvailableForTM]  DEFAULT ((0)) FOR [ItemAvailableForTM]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_ReversePreviousDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_ReversePreviousDelivery]  DEFAULT ((0)) FOR [ReversePreviousDelivery]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_PerformerID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_PerformerID]  DEFAULT ((0)) FOR [PerformerID]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_InvoiceLineNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceLineNumber]  DEFAULT ((0)) FOR [InvoiceLineNumber]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_ExtendedAmount]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_ExtendedAmount]  DEFAULT ((0)) FOR [ExtendedAmount]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_QuantityDelivered]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_QuantityDelivered]  DEFAULT ((0)) FOR [QuantityDelivered]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_ActualPercentAfterDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_ActualPercentAfterDelivery]  DEFAULT ((0)) FOR [ActualPercentAfterDelivery]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_InvoiceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_InvoiceType]  DEFAULT ((0)) FOR [InvoiceType]
GO
/****** Object:  Default [DEF_tblTMCOBOLWRITE_SalesPersonID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCOBOLWRITE] ADD  CONSTRAINT [DEF_tblTMCOBOLWRITE_SalesPersonID]  DEFAULT ((0)) FOR [SalesPersonID]
GO
/****** Object:  Default [DEF_tblTMCustomer_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCustomer] ADD  CONSTRAINT [DEF_tblTMCustomer_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMCustomer_intCurrentSiteNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCustomer] ADD  CONSTRAINT [DEF_tblTMCustomer_intCurrentSiteNumber]  DEFAULT ((0)) FOR [intCurrentSiteNumber]
GO
/****** Object:  Default [DEF_tblTMCustomer_intCustomerNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMCustomer] ADD  CONSTRAINT [DEF_tblTMCustomer_intCustomerNumber]  DEFAULT ((0)) FOR [intCustomerNumber]
GO
/****** Object:  Default [DEF_tblTMDDReading_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDDReading_intDDClockLocationID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_intDDClockLocationID]  DEFAULT ((0)) FOR [intClockLocationID]
GO
/****** Object:  Default [DEF_tblTMDDReading_dtmDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_dtmDate]  DEFAULT ((0)) FOR [dtmDate]
GO
/****** Object:  Default [DEF_tblTMDDReading_intDegreeDays]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_intDegreeDays]  DEFAULT ((0)) FOR [intDegreeDays]
GO
/****** Object:  Default [DEF_tblTMDDReading_dblAccumulatedDD]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_dblAccumulatedDD]  DEFAULT ((0)) FOR [dblAccumulatedDegreeDay]
GO
/****** Object:  Default [DEF_tblTMDDReading_strSeason]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_strSeason]  DEFAULT ('') FOR [strSeason]
GO
/****** Object:  Default [DEF_tblTMDDReading_intUserID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_intUserID]  DEFAULT ((0)) FOR [intUserID]
GO
/****** Object:  Default [DEF_tblTMDDReading_dtmLastUpdated]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_dtmLastUpdated]  DEFAULT ((0)) FOR [dtmLastUpdated]
GO
/****** Object:  Default [DEF_tblTMDDReading_intClockID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading] ADD  CONSTRAINT [DEF_tblTMDDReading_intClockID]  DEFAULT ((0)) FOR [intClockID]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_strInvoiceNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_strInvoiceNumber]  DEFAULT ('') FOR [strInvoiceNumber]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_strBulkPlantNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_strBulkPlantNumber]  DEFAULT ('') FOR [strBulkPlantNumber]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dtmInvoiceDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dtmInvoiceDate]  DEFAULT ((0)) FOR [dtmInvoiceDate]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_strProductDelivered]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_strProductDelivered]  DEFAULT ('') FOR [strProductDelivered]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblQuantityDelivered]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblQuantityDelivered]  DEFAULT ((0)) FOR [dblQuantityDelivered]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intDegreeDayOnDeliveryDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intDegreeDayOnDeliveryDate]  DEFAULT ((0)) FOR [intDegreeDayOnDeliveryDate]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intDegreeDayOnLastDeliveryDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intDegreeDayOnLastDeliveryDate]  DEFAULT ((0)) FOR [intDegreeDayOnLastDeliveryDate]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblBurnRateAfterDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblBurnRateAfterDelivery]  DEFAULT ((0)) FOR [dblBurnRateAfterDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblCalculatedBurnRate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblCalculatedBurnRate]  DEFAULT ((0)) FOR [dblCalculatedBurnRate]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_ysnAdjustBurnRate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_ysnAdjustBurnRate]  DEFAULT ((0)) FOR [ysnAdjustBurnRate]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intElapsedDegreeDaysBetweenDeliveries]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intElapsedDegreeDaysBetweenDeliveries]  DEFAULT ((0)) FOR [intElapsedDegreeDaysBetweenDeliveries]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intElapsedDaysBetweenDeliveries]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intElapsedDaysBetweenDeliveries]  DEFAULT ((0)) FOR [intElapsedDaysBetweenDeliveries]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_strSeason]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_strSeason]  DEFAULT ('') FOR [strSeason]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblWinterDailyUsageBetweenDeliveries]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblWinterDailyUsageBetweenDeliveries]  DEFAULT ((0)) FOR [dblWinterDailyUsageBetweenDeliveries]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblSummerDailyUsageBetweenDeliveries]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblSummerDailyUsageBetweenDeliveries]  DEFAULT ((0)) FOR [dblSummerDailyUsageBetweenDeliveries]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblGallonsInTankbeforeDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblGallonsInTankbeforeDelivery]  DEFAULT ((0)) FOR [dblGallonsInTankbeforeDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblGallonsInTankAfterDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblGallonsInTankAfterDelivery]  DEFAULT ((0)) FOR [dblGallonsInTankAfterDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblEstimatedPercentBeforeDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblEstimatedPercentBeforeDelivery]  DEFAULT ((0)) FOR [dblEstimatedPercentBeforeDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblActualPercentAfterDelivery]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblActualPercentAfterDelivery]  DEFAULT ((0)) FOR [dblActualPercentAfterDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblMeterReading]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblMeterReading]  DEFAULT ((0)) FOR [dblMeterReading]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dblLastMeterReading]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dblLastMeterReading]  DEFAULT ((0)) FOR [dblLastMeterReading]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intUserID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intUserID]  DEFAULT ((0)) FOR [intUserID]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_dtmLastUpdated]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_dtmLastUpdated]  DEFAULT ((0)) FOR [dtmLastUpdated]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_intSiteID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMDeliveryHistory_strSalesPersonID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory] ADD  CONSTRAINT [DEF_tblTMDeliveryHistory_strSalesPersonID]  DEFAULT ((0)) FOR [strSalesPersonID]
GO
/****** Object:  Default [DF_tblTMDeliveryHistoryDetail_dblQuantityDelivered]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistoryDetail] ADD  CONSTRAINT [DF_tblTMDeliveryHistoryDetail_dblQuantityDelivered]  DEFAULT ((0)) FOR [dblQuantityDelivered]
GO
/****** Object:  Default [DF__tblTMDeli__dblPe__5986288B]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistoryDetail] ADD  DEFAULT ((0)) FOR [dblPercentAfterDelivery]
GO
/****** Object:  Default [DEF_tblTMDeliveryMethod_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryMethod] ADD  CONSTRAINT [DEF_tblTMDeliveryMethod_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDeliveryMethod_strDeliveryMethod]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryMethod] ADD  CONSTRAINT [DEF_tblTMDeliveryMethod_strDeliveryMethod]  DEFAULT ('') FOR [strDeliveryMethod]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_dtmStartDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_dtmStartDate]  DEFAULT ((0)) FOR [dtmStartDate]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_dtmEndDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_dtmEndDate]  DEFAULT ((0)) FOR [dtmEndDate]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_intInterval]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_intInterval]  DEFAULT ((0)) FOR [intInterval]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnOnWeekDay]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnOnWeekDay]  DEFAULT ((0)) FOR [ysnOnWeekDay]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_strRecurrencePattern]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_strRecurrencePattern]  DEFAULT ('') FOR [strRecurrencePattern]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_intSiteID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnSunday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnSunday]  DEFAULT ((0)) FOR [ysnSunday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnMonday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnMonday]  DEFAULT ((0)) FOR [ysnMonday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnTuesday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnTuesday]  DEFAULT ((0)) FOR [ysnTuesday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnWednesday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnWednesday]  DEFAULT ((0)) FOR [ysnWednesday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnThursday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnThursday]  DEFAULT ((0)) FOR [ysnThursday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnFriday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnFriday]  DEFAULT ((0)) FOR [ysnFriday]
GO
/****** Object:  Default [DEF_tblTMDeliverySchedule_ysnSaturday]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule] ADD  CONSTRAINT [DEF_tblTMDeliverySchedule_ysnSaturday]  DEFAULT ((0)) FOR [ysnSaturday]
GO
/****** Object:  Default [DEF_tblTMDeployedStatus_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeployedStatus] ADD  CONSTRAINT [DEF_tblTMDeployedStatus_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDeployedStatus_strDeployedStatus]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeployedStatus] ADD  CONSTRAINT [DEF_tblTMDeployedStatus_strDeployedStatus]  DEFAULT ('') FOR [strDeployedStatus]
GO
/****** Object:  Default [DEF_tblTMDevice_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDevice_strSerialNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strSerialNumber]  DEFAULT ('') FOR [strSerialNumber]
GO
/****** Object:  Default [DEF_tblTMDevice_strManufacturerID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strManufacturerID]  DEFAULT ('') FOR [strManufacturerID]
GO
/****** Object:  Default [DEF_tblTMDevice_strManufacturerName]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strManufacturerName]  DEFAULT ('') FOR [strManufacturerName]
GO
/****** Object:  Default [DEF_tblTMDevice_strModelNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strModelNumber]  DEFAULT ('') FOR [strModelNumber]
GO
/****** Object:  Default [DEF_tblTMDevice_strBulkPlant]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strBulkPlant]  DEFAULT ('') FOR [strBulkPlant]
GO
/****** Object:  Default [DEF_tblTMDevice_strDescription]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DEF_tblTMDevice_strOwnership]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strOwnership]  DEFAULT ('') FOR [strOwnership]
GO
/****** Object:  Default [DEF_tblTMDevice_strAssetNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strAssetNumber]  DEFAULT ('') FOR [strAssetNumber]
GO
/****** Object:  Default [DEF_tblTMDevice_dtmPurchaseDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_dtmPurchaseDate]  DEFAULT ((0)) FOR [dtmPurchaseDate]
GO
/****** Object:  Default [DEF_tblTMDevice_dblPurchasePrice]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_dblPurchasePrice]  DEFAULT ((0)) FOR [dblPurchasePrice]
GO
/****** Object:  Default [DEF_tblTMDevice_dtmManufacturedDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_dtmManufacturedDate]  DEFAULT ((0)) FOR [dtmManufacturedDate]
GO
/****** Object:  Default [DEF_tblTMDevice_strComment]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strComment]  DEFAULT ('') FOR [strComment]
GO
/****** Object:  Default [DEF_tblTMDevice_ysnUnderground]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_ysnUnderground]  DEFAULT ((0)) FOR [ysnUnderground]
GO
/****** Object:  Default [DEF_tblTMDevice_intTankSize]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intTankSize]  DEFAULT ((0)) FOR [intTankSize]
GO
/****** Object:  Default [DEF_tblTMDevice_intTankCapacity]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intTankCapacity]  DEFAULT ((0)) FOR [intTankCapacity]
GO
/****** Object:  Default [DF_tblTMDevice_dblTankReserve]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DF_tblTMDevice_dblTankReserve]  DEFAULT ((0)) FOR [dblTankReserve]
GO
/****** Object:  Default [DEF_tblTMDevice_dblEstimatedGalTank]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_dblEstimatedGalTank]  DEFAULT ('0') FOR [dblEstimatedGalTank]
GO
/****** Object:  Default [DEF_tblTMDevice_intMeterCycle]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intMeterCycle]  DEFAULT ((0)) FOR [intMeterCycle]
GO
/****** Object:  Default [DEF_tblTMDevice_intDeviceTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intDeviceTypeID]  DEFAULT ((0)) FOR [intDeviceTypeID]
GO
/****** Object:  Default [DEF_tblTMDevice_intLeaseID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intLeaseID]  DEFAULT ((0)) FOR [intLeaseID]
GO
/****** Object:  Default [DEF_tblTMDevice_intDeployedStatusID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intDeployedStatusID]  DEFAULT ((0)) FOR [intDeployedStatusID]
GO
/****** Object:  Default [DEF_tblTMDevice_intParentDeviceID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intParentDeviceID]  DEFAULT ((0)) FOR [intParentDeviceID]
GO
/****** Object:  Default [DEF_tblTMDevice_intInventoryStatusTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intInventoryStatusTypeID]  DEFAULT ((0)) FOR [intInventoryStatusTypeID]
GO
/****** Object:  Default [DEF_tblTMDevice_intTankTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intTankTypeID]  DEFAULT ((0)) FOR [intTankTypeID]
GO
/****** Object:  Default [DEF_tblTMDevice_intMeterTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intMeterTypeID]  DEFAULT ((0)) FOR [intMeterTypeID]
GO
/****** Object:  Default [DEF_tblTMDevice_intRegulatorTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intRegulatorTypeID]  DEFAULT ((0)) FOR [intRegulatorTypeID]
GO
/****** Object:  Default [DEF_tblTMDevice_intLinkedToTankID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intLinkedToTankID]  DEFAULT ((0)) FOR [intLinkedToTankID]
GO
/****** Object:  Default [DEF_tblTMDevice_strMeterStatus]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_strMeterStatus]  DEFAULT ('') FOR [strMeterStatus]
GO
/****** Object:  Default [DEF_tblTMDevice_dblMeterReading]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_dblMeterReading]  DEFAULT ((0)) FOR [dblMeterReading]
GO
/****** Object:  Default [DEF_tblTMDevice_ysnAppliance]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_ysnAppliance]  DEFAULT ((0)) FOR [ysnAppliance]
GO
/****** Object:  Default [DEF_tblTMDevice_intApplianceTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice] ADD  CONSTRAINT [DEF_tblTMDevice_intApplianceTypeID]  DEFAULT ((0)) FOR [intApplianceTypeID]
GO
/****** Object:  Default [DEF_tblTMDeviceType_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeviceType] ADD  CONSTRAINT [DEF_tblTMDeviceType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDeviceType_strDeviceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeviceType] ADD  CONSTRAINT [DEF_tblTMDeviceType_strDeviceType]  DEFAULT ('') FOR [strDeviceType]
GO
/****** Object:  Default [DEF_tblTMDeviceType_ysnDefault]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeviceType] ADD  CONSTRAINT [DEF_tblTMDeviceType_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMDispatch_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMDispatch_intSiteID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMDispatch_dblPercentLeft]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dblPercentLeft]  DEFAULT ((0)) FOR [dblPercentLeft]
GO
/****** Object:  Default [DEF_tblTMDispatch_dblQuantity]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dblQuantity]  DEFAULT ((0)) FOR [dblQuantity]
GO
/****** Object:  Default [DEF_tblTMDispatch_dblMinimumQuantity]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dblMinimumQuantity]  DEFAULT ((0)) FOR [dblMinimumQuantity]
GO
/****** Object:  Default [DEF_tblTMDispatch_intProductID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intProductID]  DEFAULT ((0)) FOR [intProductID]
GO
/****** Object:  Default [DEF_tblTMDispatch_intSubstituteProductID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intSubstituteProductID]  DEFAULT ((0)) FOR [intSubstituteProductID]
GO
/****** Object:  Default [DEF_tblTMDispatch_dblPrice]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dblPrice]  DEFAULT ((0)) FOR [dblPrice]
GO
/****** Object:  Default [DEF_tblTMDispatch_dblTotal]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dblTotal]  DEFAULT ((0)) FOR [dblTotal]
GO
/****** Object:  Default [DEF_tblTMDispatch_dtmRequestedDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dtmRequestedDate]  DEFAULT ((0)) FOR [dtmRequestedDate]
GO
/****** Object:  Default [DEF_tblTMDispatch_intPriority]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intPriority]  DEFAULT ((0)) FOR [intPriority]
GO
/****** Object:  Default [DEF_tblTMDispatch_strComments]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_strComments]  DEFAULT ('') FOR [strComments]
GO
/****** Object:  Default [DEF_tblTMDispatch_ysnCallEntryPrinted]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_ysnCallEntryPrinted]  DEFAULT ((0)) FOR [ysnCallEntryPrinted]
GO
/****** Object:  Default [DEF_tblTMDispatch_intDriverID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intDriverID]  DEFAULT ((0)) FOR [intDriverID]
GO
/****** Object:  Default [DEF_tblTMDispatch_intDispatchDriverID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intDispatchDriverID]  DEFAULT ((0)) FOR [intDispatchDriverID]
GO
/****** Object:  Default [DEF_tblTMDispatch_strDispatchLoadNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_strDispatchLoadNumber]  DEFAULT ('') FOR [strDispatchLoadNumber]
GO
/****** Object:  Default [DEF_tblTMDispatch_dtmDispatchDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dtmDispatchDate]  DEFAULT ((0)) FOR [dtmCallInDate]
GO
/****** Object:  Default [DEF_tblTMDispatch_ysnSelected]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_ysnSelected]  DEFAULT ((0)) FOR [ysnSelected]
GO
/****** Object:  Default [DEF_tblTMDispatch_strRoute]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_strRoute]  DEFAULT ('') FOR [strRoute]
GO
/****** Object:  Default [DEF_tblTMDispatch_strSequence]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_strSequence]  DEFAULT ('') FOR [strSequence]
GO
/****** Object:  Default [DEF_tblTMDispatch_intUserID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_intUserID]  DEFAULT ((0)) FOR [intUserID]
GO
/****** Object:  Default [DEF_tblTMDispatch_dtmLastUpdated]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch] ADD  CONSTRAINT [DEF_tblTMDispatch_dtmLastUpdated]  DEFAULT ((0)) FOR [dtmLastUpdated]
GO
/****** Object:  Default [DEF_tblTMEvent_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMEvent_dtmDate]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_dtmDate]  DEFAULT ((0)) FOR [dtmDate]
GO
/****** Object:  Default [DEF_tblTMEvent_intEventTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intEventTypeID]  DEFAULT ((0)) FOR [intEventTypeID]
GO
/****** Object:  Default [DEF_tblTMEvent_intPerformerID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intPerformerID]  DEFAULT ((0)) FOR [intPerformerID]
GO
/****** Object:  Default [DEF_tblTMEvent_intUserID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intUserID]  DEFAULT ((0)) FOR [intUserID]
GO
/****** Object:  Default [DEF_tblTMEvent_intDeviceID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intDeviceID]  DEFAULT ((0)) FOR [intDeviceID]
GO
/****** Object:  Default [DEF_tblTMEvent_dtmLastUpdated]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_dtmLastUpdated]  DEFAULT ((0)) FOR [dtmLastUpdated]
GO
/****** Object:  Default [DEF_tblTMEvent_strDeviceOwnership]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_strDeviceOwnership]  DEFAULT ('') FOR [strDeviceOwnership]
GO
/****** Object:  Default [DEF_tblTMEvent_strDeviceSerialNumber]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_strDeviceSerialNumber]  DEFAULT ('') FOR [strDeviceSerialNumber]
GO
/****** Object:  Default [DEF_tblTMEvent_strDeviceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_strDeviceType]  DEFAULT ('') FOR [strDeviceType]
GO
/****** Object:  Default [DEF_tblTMEvent_strDescription]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DEF_tblTMEvent_intSiteID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMEvent_strLevel]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent] ADD  CONSTRAINT [DEF_tblTMEvent_strLevel]  DEFAULT ('') FOR [strLevel]
GO
/****** Object:  Default [DEF_tblTMEventAutomation_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventAutomation] ADD  CONSTRAINT [DEF_tblTMEventAutomation_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMEventAutomation_intEventTypeID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventAutomation] ADD  CONSTRAINT [DEF_tblTMEventAutomation_intEventTypeID]  DEFAULT ((0)) FOR [intEventTypeID]
GO
/****** Object:  Default [DEF_tblTMEventAutomation_strProduct]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventAutomation] ADD  CONSTRAINT [DEF_tblTMEventAutomation_strProduct]  DEFAULT ('') FOR [strProduct]
GO
/****** Object:  Default [DEF_tblTMEventType_intConcurrencyID]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventType] ADD  CONSTRAINT [DEF_tblTMEventType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMEventType_strEventType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventType] ADD  CONSTRAINT [DEF_tblTMEventType_strEventType]  DEFAULT ('') FOR [strEventType]
GO
/****** Object:  Default [DEF_tblTMEventType_ysnDefault]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMEventType] ADD  CONSTRAINT [DEF_tblTMEventType_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMEventType_strDescription]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMEventType] ADD  CONSTRAINT [DEF_tblTMEventType_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DF_tblTMFillGroup_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMFillGroup] ADD  CONSTRAINT [DF_tblTMFillGroup_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMFillMethod_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMFillMethod] ADD  CONSTRAINT [DEF_tblTMFillMethod_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMFillMethod_strFillMethod]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMFillMethod] ADD  CONSTRAINT [DEF_tblTMFillMethod_strFillMethod]  DEFAULT ('') FOR [strFillMethod]
GO
/****** Object:  Default [DEF_tblTMFillMethod_ysnDefault]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMFillMethod] ADD  CONSTRAINT [DEF_tblTMFillMethod_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMHoldReason_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMHoldReason] ADD  CONSTRAINT [DEF_tblTMHoldReason_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMHoldReason_strHoldReason]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMHoldReason] ADD  CONSTRAINT [DEF_tblTMHoldReason_strHoldReason]  DEFAULT ('') FOR [strHoldReason]
GO
/****** Object:  Default [DEF_tblTMInventoryStatusType_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMInventoryStatusType] ADD  CONSTRAINT [DEF_tblTMInventoryStatusType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMInventoryStatusType_strInventoryStatusType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMInventoryStatusType] ADD  CONSTRAINT [DEF_tblTMInventoryStatusType_strInventoryStatusType]  DEFAULT ('') FOR [strInventoryStatusType]
GO
/****** Object:  Default [DEF_tblTMInventoryStatusType_ysnDefault]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMInventoryStatusType] ADD  CONSTRAINT [DEF_tblTMInventoryStatusType_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMJulianCalendarDelivery_dtmDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMJulianCalendarDelivery] ADD  CONSTRAINT [DEF_tblTMJulianCalendarDelivery_dtmDate]  DEFAULT ((0)) FOR [dtmDate]
GO
/****** Object:  Default [DEF_tblTMJulianCalendarDelivery_intSiteJulianCalendarID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMJulianCalendarDelivery] ADD  CONSTRAINT [DEF_tblTMJulianCalendarDelivery_intSiteJulianCalendarID]  DEFAULT ((0)) FOR [intSiteJulianCalendarID]
GO
/****** Object:  Default [DEF_tblTMLease_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMLease_intLeaseCodeID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_intLeaseCodeID]  DEFAULT ((0)) FOR [intLeaseCodeID]
GO
/****** Object:  Default [DEF_tblTMLease_strLeaseNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_strLeaseNumber]  DEFAULT ('') FOR [strLeaseNumber]
GO
/****** Object:  Default [DEF_tblTMLease_intBillToCustomerID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_intBillToCustomerID]  DEFAULT ((0)) FOR [intBillToCustomerID]
GO
/****** Object:  Default [DEF_tblTMLease_ysnLeaseToOwn]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_ysnLeaseToOwn]  DEFAULT ((0)) FOR [ysnLeaseToOwn]
GO
/****** Object:  Default [DEF_tblTMLease_strLeaseStatus]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_strLeaseStatus]  DEFAULT ('') FOR [strLeaseStatus]
GO
/****** Object:  Default [DEF_tblTMLease_strBillingFrequency]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_strBillingFrequency]  DEFAULT ('') FOR [strBillingFrequency]
GO
/****** Object:  Default [DEF_tblTMLease_intBillingMonth]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_intBillingMonth]  DEFAULT ((0)) FOR [intBillingMonth]
GO
/****** Object:  Default [DEF_tblTMLease_strBillingType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_strBillingType]  DEFAULT ('') FOR [strBillingType]
GO
/****** Object:  Default [DEF_tblTMLease_dtmStartDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_dtmStartDate]  DEFAULT ((0)) FOR [dtmStartDate]
GO
/****** Object:  Default [DEF_tblTMLease_dtmDontBillAfter]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_dtmDontBillAfter]  DEFAULT ((0)) FOR [dtmDontBillAfter]
GO
/****** Object:  Default [DEF_tblTMLease_strRentalStatus]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease] ADD  CONSTRAINT [DEF_tblTMLease_strRentalStatus]  DEFAULT ('') FOR [strRentalStatus]
GO
/****** Object:  Default [DEF_tblTMLeaseCode_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseCode] ADD  CONSTRAINT [DEF_tblTMLeaseCode_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMLeaseCode_strLeaseCode]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseCode] ADD  CONSTRAINT [DEF_tblTMLeaseCode_strLeaseCode]  DEFAULT ('') FOR [strLeaseCode]
GO
/****** Object:  Default [DEF_tblTMLeaseCode_strDescription]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseCode] ADD  CONSTRAINT [DEF_tblTMLeaseCode_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DEF_tblTMLeaseCode_dblAmount]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseCode] ADD  CONSTRAINT [DEF_tblTMLeaseCode_dblAmount]  DEFAULT ((0)) FOR [dblAmount]
GO
/****** Object:  Default [DF_tblTMLeaseMinimumUse_dblSiteCapacity]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseMinimumUse] ADD  CONSTRAINT [DF_tblTMLeaseMinimumUse_dblSiteCapacity]  DEFAULT ((0)) FOR [dblSiteCapacity]
GO
/****** Object:  Default [DF_tblTMLeaseMinimumUse_dblMinimumUsage]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseMinimumUse] ADD  CONSTRAINT [DF_tblTMLeaseMinimumUse_dblMinimumUsage]  DEFAULT ((0)) FOR [dblMinimumUsage]
GO
/****** Object:  Default [DF_tblTMLeaseMinimumUse_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLeaseMinimumUse] ADD  CONSTRAINT [DF_tblTMLeaseMinimumUse_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMMeterType_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMMeterType] ADD  CONSTRAINT [DEF_tblTMMeterType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMMeterType_strMeterType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMMeterType] ADD  CONSTRAINT [DEF_tblTMMeterType_strMeterType]  DEFAULT ('') FOR [strMeterType]
GO
/****** Object:  Default [DEF_tblTMMeterType_dblConversionFactor]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMMeterType] ADD  CONSTRAINT [DEF_tblTMMeterType_dblConversionFactor]  DEFAULT ((0)) FOR [dblConversionFactor]
GO
/****** Object:  Default [DEF_tblTMMeterType_ysnDefault]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMMeterType] ADD  CONSTRAINT [DEF_tblTMMeterType_ysnDefault]  DEFAULT ((0)) FOR [ysnDefault]
GO
/****** Object:  Default [DEF_tblTMPossessionType_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPossessionType] ADD  CONSTRAINT [DEF_tblTMPossessionType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMPossessionType_strPossessionType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPossessionType] ADD  CONSTRAINT [DEF_tblTMPossessionType_strPossessionType]  DEFAULT ('') FOR [strPossessionType]
GO
/****** Object:  Default [DEF_tblTMPreferenceCompany_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DEF_tblTMPreferenceCompany_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMPreferenceCompany_strSummitIntegration]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DEF_tblTMPreferenceCompany_strSummitIntegration]  DEFAULT (N'AG') FOR [strSummitIntegration]
GO
/****** Object:  Default [DEF_tblTMPreferenceCompany_intCeilingBurnRate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DEF_tblTMPreferenceCompany_intCeilingBurnRate]  DEFAULT ((0)) FOR [intCeilingBurnRate]
GO
/****** Object:  Default [DEF_tblTMPreferenceCompany_intFloorBurnRate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DEF_tblTMPreferenceCompany_intFloorBurnRate]  DEFAULT ((0)) FOR [intFloorBurnRate]
GO
/****** Object:  Default [DEF_tblTMPreferenceCompany_ysnAllowClassFill]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DEF_tblTMPreferenceCompany_ysnAllowClassFill]  DEFAULT ((0)) FOR [ysnAllowClassFill]
GO
/****** Object:  Default [DF_tblTMPreferenceCompany_ysnUseDeliveryTermOnCS]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DF_tblTMPreferenceCompany_ysnUseDeliveryTermOnCS]  DEFAULT ((0)) FOR [ysnUseDeliveryTermOnCS]
GO
/****** Object:  Default [DF_tblTMPreferenceCompany_ysnEnableLeaseBillingAboveMinUse]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMPreferenceCompany] ADD  CONSTRAINT [DF_tblTMPreferenceCompany_ysnEnableLeaseBillingAboveMinUse]  DEFAULT ((0)) FOR [ysnEnableLeaseBillingAboveMinUse]
GO
/****** Object:  Default [DEF_tblTMRegulatorType_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMRegulatorType] ADD  CONSTRAINT [DEF_tblTMRegulatorType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMRegulatorType_strRegulatorType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMRegulatorType] ADD  CONSTRAINT [DEF_tblTMRegulatorType_strRegulatorType]  DEFAULT ('') FOR [strRegulatorType]
GO
/****** Object:  Default [DF_tblTMRoute_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMRoute] ADD  CONSTRAINT [DF_tblTMRoute_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSite_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSite_strSiteAddress]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strSiteAddress]  DEFAULT ('') FOR [strSiteAddress]
GO
/****** Object:  Default [DEF_tblTMSite_intProduct]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intProduct]  DEFAULT ((0)) FOR [intProduct]
GO
/****** Object:  Default [DEF_tblTMSite_intCustomerID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intCustomerID]  DEFAULT ((0)) FOR [intCustomerID]
GO
/****** Object:  Default [DEF_tblTMSite_dblTotalCapacity]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblTotalCapacity]  DEFAULT ((0)) FOR [dblTotalCapacity]
GO
/****** Object:  Default [DEF_tblTMSite_ysnOnHold]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnOnHold]  DEFAULT ((0)) FOR [ysnOnHold]
GO
/****** Object:  Default [DEF_tblTMSite_ysnActive]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnActive]  DEFAULT ((1)) FOR [ysnActive]
GO
/****** Object:  Default [DEF_tblTMSite_strDescription]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DEF_tblTMSite_strAcctStatus]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strAcctStatus]  DEFAULT ('') FOR [strAcctStatus]
GO
/****** Object:  Default [DEF_tblTMSite_dblPriceAdjustment]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblPriceAdjustment]  DEFAULT ((0)) FOR [dblPriceAdjustment]
GO
/****** Object:  Default [DEF_tblTMSite_intClockLocno]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intClockLocno]  DEFAULT ((0)) FOR [intClockID]
GO
/****** Object:  Default [DEF_tblTMSite_dblDDBetweenDlvry]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblDDBetweenDlvry]  DEFAULT ((0)) FOR [dblDegreeDayBetweenDelivery]
GO
/****** Object:  Default [DEF_tblTMSite_dblSummerDailyUse]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblSummerDailyUse]  DEFAULT ((0)) FOR [dblSummerDailyUse]
GO
/****** Object:  Default [DEF_tblTMSite_dblWinterDailyUse]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblWinterDailyUse]  DEFAULT ((0)) FOR [dblWinterDailyUse]
GO
/****** Object:  Default [DEF_tblTMSite_ysnTaxable]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnTaxable]  DEFAULT ((0)) FOR [ysnTaxable]
GO
/****** Object:  Default [DEF_tblTMSite_intTaxStateID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intTaxStateID]  DEFAULT ((0)) FOR [intTaxStateID]
GO
/****** Object:  Default [DEF_tblTMSite_ysnPrintDlvryTicket]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnPrintDlvryTicket]  DEFAULT ((0)) FOR [ysnPrintDeliveryTicket]
GO
/****** Object:  Default [DEF_tblTMSite_ysnAdjustBurnRate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnAdjustBurnRate]  DEFAULT ((0)) FOR [ysnAdjustBurnRate]
GO
/****** Object:  Default [DEF_tblTMSite_intDriverID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intDriverID]  DEFAULT ((0)) FOR [intDriverID]
GO
/****** Object:  Default [DEF_tblTMSite_strRouteID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strRouteID]  DEFAULT ('') FOR [strRouteID]
GO
/****** Object:  Default [DEF_tblTMSite_strSequenceID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strSequenceID]  DEFAULT ('') FOR [strSequenceID]
GO
/****** Object:  Default [DEF_tblTMSite_dblYTDGalsThisSeason]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblYTDGalsThisSeason]  DEFAULT ((0)) FOR [dblYTDGalsThisSeason]
GO
/****** Object:  Default [DEF_tblTMSite_dblYTDGalsLastSeason]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblYTDGalsLastSeason]  DEFAULT ((0)) FOR [dblYTDGalsLastSeason]
GO
/****** Object:  Default [DEF_tblTMSite_dtmRunOutDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmRunOutDate]  DEFAULT ((0)) FOR [dtmRunOutDate]
GO
/****** Object:  Default [DEF_tblTMSite_dblEstimatedPercentLeft]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblEstimatedPercentLeft]  DEFAULT ((0)) FOR [dblEstimatedPercentLeft]
GO
/****** Object:  Default [DEF_tblTMSite_dblConfidenceFactor]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblConfidenceFactor]  DEFAULT ((0)) FOR [dblConfidenceFactor]
GO
/****** Object:  Default [DEF_tblTMSite_strZipCode]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strZipCode]  DEFAULT ('') FOR [strZipCode]
GO
/****** Object:  Default [DEF_tblTMSite_strCity]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strCity]  DEFAULT ('') FOR [strCity]
GO
/****** Object:  Default [DEF_tblTMSite_strState]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strState]  DEFAULT ('') FOR [strState]
GO
/****** Object:  Default [DEF_tblTMSite_dblLatitude]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblLatitude]  DEFAULT ((0)) FOR [dblLatitude]
GO
/****** Object:  Default [DEF_tblTMSite_dblLongitude]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblLongitude]  DEFAULT ((0)) FOR [dblLongitude]
GO
/****** Object:  Default [DEF_tblTMSite_intSiteNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intSiteNumber]  DEFAULT ((0)) FOR [intSiteNumber]
GO
/****** Object:  Default [DEF_tblTMSite_dtmOnHoldStartDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmOnHoldStartDate]  DEFAULT ((0)) FOR [dtmOnHoldStartDate]
GO
/****** Object:  Default [DEF_tblTMSite_dtmOnHoldEndDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmOnHoldEndDate]  DEFAULT ((0)) FOR [dtmOnHoldEndDate]
GO
/****** Object:  Default [DEF_tblTMSite_ysnHoldDDCalculations]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnHoldDDCalculations]  DEFAULT ((0)) FOR [ysnHoldDDCalculations]
GO
/****** Object:  Default [DEF_tblTMSite_dblYTDSales]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblYTDSales]  DEFAULT ((0)) FOR [dblYTDSales]
GO
/****** Object:  Default [DEF_tblTMSite_intUserID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intUserID]  DEFAULT ((0)) FOR [intUserID]
GO
/****** Object:  Default [DEF_tblTMSite_strBillingBy]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strBillingBy]  DEFAULT ('') FOR [strBillingBy]
GO
/****** Object:  Default [DEF_tblTMSite_dblPreviousBurnRate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblPreviousBurnRate]  DEFAULT ((0)) FOR [dblPreviousBurnRate]
GO
/****** Object:  Default [DEF_tblTMSite_dblTotalReserve]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblTotalReserve]  DEFAULT ((0)) FOR [dblTotalReserve]
GO
/****** Object:  Default [DEF_tblTMSite_dblLastGalsInTank]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblLastGalsInTank]  DEFAULT ((0)) FOR [dblLastGalsInTank]
GO
/****** Object:  Default [DEF_tblTMSite_dblLastDeliveredGal]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblLastDeliveredGal]  DEFAULT ((0)) FOR [dblLastDeliveredGal]
GO
/****** Object:  Default [DEF_tblTMSite_intDeliveryTicketNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intDeliveryTicketNumber]  DEFAULT ((0)) FOR [intDeliveryTicketNumber]
GO
/****** Object:  Default [DEF_tblTMSite_dblEstimatedGallonsLeft]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblEstimatedGallonsLeft]  DEFAULT ((0)) FOR [dblEstimatedGallonsLeft]
GO
/****** Object:  Default [DEF_tblTMSite_dtmLastDeliveryDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmLastDeliveryDate]  DEFAULT ((0)) FOR [dtmLastDeliveryDate]
GO
/****** Object:  Default [DEF_tblTMSite_dtmNextDeliveryDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmNextDeliveryDate]  DEFAULT ((0)) FOR [dtmNextDeliveryDate]
GO
/****** Object:  Default [DEF_tblTMSite_strCountry]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strCountry]  DEFAULT ('') FOR [strCountry]
GO
/****** Object:  Default [DEF_tblTMSite_intFillMethodID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intFillMethodID]  DEFAULT ((0)) FOR [intFillMethodID]
GO
/****** Object:  Default [DEF_tblTMSite_intHoldReasonID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intHoldReasonID]  DEFAULT ((0)) FOR [intHoldReasonID]
GO
/****** Object:  Default [DEF_tblTMSite_dblYTDGals2SeasonsAgo]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblYTDGals2SeasonsAgo]  DEFAULT ((0)) FOR [dblYTDGals2SeasonsAgo]
GO
/****** Object:  Default [DEF_tblTMSite_intTaxLocale1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intTaxLocale1]  DEFAULT ((0)) FOR [intTaxLocale1]
GO
/****** Object:  Default [DEF_tblTMSite_intTaxLocale2]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intTaxLocale2]  DEFAULT ((0)) FOR [intTaxLocale2]
GO
/****** Object:  Default [DEF_tblTMSite_ysnAllowPriceChange]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnAllowPriceChange]  DEFAULT ((0)) FOR [ysnAllowPriceChange]
GO
/****** Object:  Default [DEF_tblTMSite_intRecurringPONumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intRecurringPONumber]  DEFAULT ((0)) FOR [intRecurringPONumber]
GO
/****** Object:  Default [DEF_tblTMSite_ysnPrintARBalance]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnPrintARBalance]  DEFAULT ((0)) FOR [ysnPrintARBalance]
GO
/****** Object:  Default [DEF_tblTMSite_ysnPromptForPercentFull]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnPromptForPercentFull]  DEFAULT ((0)) FOR [ysnPromptForPercentFull]
GO
/****** Object:  Default [DEF_tblTMSite_strFillGroup]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strFillGroup]  DEFAULT ('') FOR [strFillGroup]
GO
/****** Object:  Default [DEF_tblTMSite_dblBurnRate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblBurnRate]  DEFAULT ((0)) FOR [dblBurnRate]
GO
/****** Object:  Default [DEF_tblTMSite_strTankTownship]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strTankTownship]  DEFAULT ('') FOR [strTankTownship]
GO
/****** Object:  Default [DEF_tblTMSite_dtmLastUpdated]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dtmLastUpdated]  DEFAULT ((0)) FOR [dtmLastUpdated]
GO
/****** Object:  Default [DEF_tblTMSite_intLastDeliveryDegreeDay]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intLastDeliveryDegreeDay]  DEFAULT ((0)) FOR [intLastDeliveryDegreeDay]
GO
/****** Object:  Default [DEF_tblTMSite_intNextDeliveryDegreeDay]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_intNextDeliveryDegreeDay]  DEFAULT ((0)) FOR [intNextDeliveryDegreeDay]
GO
/****** Object:  Default [DEF_tblTMSite_ysnDeliveryTicketPrinted]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_ysnDeliveryTicketPrinted]  DEFAULT ((0)) FOR [ysnDeliveryTicketPrinted]
GO
/****** Object:  Default [DEF_tblTMSite_strComment]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strComment]  DEFAULT ('') FOR [strComment]
GO
/****** Object:  Default [DEF_tblTMSite_strInstruction]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strInstruction]  DEFAULT ('') FOR [strInstruction]
GO
/****** Object:  Default [DEF_tblTMSite_strClassFillOption]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strClassFillOption]  DEFAULT (N'No') FOR [strClassFillOption]
GO
/****** Object:  Default [DEF_tblTMSite_dblLastMeterReading]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_dblLastMeterReading]  DEFAULT ((0)) FOR [dblLastMeterReading]
GO
/****** Object:  Default [DEF_tblTMSite_strLocation]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite] ADD  CONSTRAINT [DEF_tblTMSite_strLocation]  DEFAULT ((0)) FOR [strLocation]
GO
/****** Object:  Default [DEF_tblTMSiteDevice_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice] ADD  CONSTRAINT [DEF_tblTMSiteDevice_intConcurrencyID]  DEFAULT ((1)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSiteDevice_intSiteID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice] ADD  CONSTRAINT [DEF_tblTMSiteDevice_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMSiteDevice_intDeviceID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice] ADD  CONSTRAINT [DEF_tblTMSiteDevice_intDeviceID]  DEFAULT ((0)) FOR [intDeviceID]
GO
/****** Object:  Default [DEF_tblTMSiteDevice_ysnAtCustomerToBeTransferred]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice] ADD  CONSTRAINT [DEF_tblTMSiteDevice_ysnAtCustomerToBeTransferred]  DEFAULT ((0)) FOR [ysnAtCustomerToBeTransferred]
GO
/****** Object:  Default [DEF_tblTMSiteDeviceLink_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDeviceLink] ADD  CONSTRAINT [DEF_tblTMSiteDeviceLink_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSiteDeviceLink_intSiteID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDeviceLink] ADD  CONSTRAINT [DEF_tblTMSiteDeviceLink_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMSiteDeviceLink_intSiteDeviceID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDeviceLink] ADD  CONSTRAINT [DEF_tblTMSiteDeviceLink_intSiteDeviceID]  DEFAULT ((0)) FOR [intSiteDeviceID]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_strDescription]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_strDescription]  DEFAULT ('') FOR [strDescription]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_dtmStartDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_dtmStartDate]  DEFAULT ((0)) FOR [dtmStartDate]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_dtmEndDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_dtmEndDate]  DEFAULT ((0)) FOR [dtmEndDate]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnAutoRenew]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnAutoRenew]  DEFAULT ((0)) FOR [ysnAutoRenew]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_intSiteID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_intRecurInterval]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurInterval]  DEFAULT ((1)) FOR [intRecurInterval]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_intRecurMonth]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurMonth]  DEFAULT ((0)) FOR [intRecurMonth]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_intRecurPattern]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_intRecurPattern]  DEFAULT ((0)) FOR [intRecurPattern]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnSunday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnSunday]  DEFAULT ((0)) FOR [ysnSunday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnMonday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnMonday]  DEFAULT ((0)) FOR [ysnMonday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnTuesday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnTuesday]  DEFAULT ((0)) FOR [ysnTuesday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnWednesday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnWednesday]  DEFAULT ((0)) FOR [ysnWednesday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnThursday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnThursday]  DEFAULT ((0)) FOR [ysnThursday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnFriday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnFriday]  DEFAULT ((0)) FOR [ysnFriday]
GO
/****** Object:  Default [DEF_tblTMSiteJulianCalendar_ysnSaturday]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DEF_tblTMSiteJulianCalendar_ysnSaturday]  DEFAULT ((0)) FOR [ysnSaturday]
GO
/****** Object:  Default [DF_tblTMSiteJulianCalendar_ysnSingleDateOverride]    Script Date: 11/29/2013  ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] ADD  CONSTRAINT [DF_tblTMSiteJulianCalendar_ysnSingleDateOverride]  DEFAULT ((0)) FOR [ysnSingleDateOverride]
GO

/****** Object:  Default [DEF_tblTMSiteLink_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteLink] ADD  CONSTRAINT [DEF_tblTMSiteLink_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMSiteLink_intSiteID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteLink] ADD  CONSTRAINT [DEF_tblTMSiteLink_intSiteID]  DEFAULT ((0)) FOR [intSiteID]
GO
/****** Object:  Default [DEF_tblTMSiteLink_intContractID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteLink] ADD  CONSTRAINT [DEF_tblTMSiteLink_intContractID]  DEFAULT ((0)) FOR [intContractID]
GO
/****** Object:  Default [DF_Table_1_BulkPlantNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_BulkPlantNumber]  DEFAULT ((0)) FOR [strBulkPlantNumber]
GO
/****** Object:  Default [DF_Table_1_InvoiceDate]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_InvoiceDate]  DEFAULT ((0)) FOR [dtmInvoiceDate]
GO
/****** Object:  Default [DF_Table_1_ItemNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_ItemNumber]  DEFAULT ((0)) FOR [strItemNumber]
GO
/****** Object:  Default [DF_Table_1_ItemAvailableForTM]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_ItemAvailableForTM]  DEFAULT ((0)) FOR [strItemAvailableForTM]
GO
/****** Object:  Default [DF_Table_1_ReversePreviousDelivery]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_ReversePreviousDelivery]  DEFAULT ((0)) FOR [strReversePreviousDelivery]
GO
/****** Object:  Default [DF_Table_1_PerformerID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_PerformerID]  DEFAULT ((0)) FOR [strPerformerID]
GO
/****** Object:  Default [DF_Table_1_InvoiceLineNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_InvoiceLineNumber]  DEFAULT ((0)) FOR [intInvoiceLineNumber]
GO
/****** Object:  Default [DF_Table_1_ExtendedAmount]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_ExtendedAmount]  DEFAULT ((0)) FOR [dblExtendedAmount]
GO
/****** Object:  Default [DF_Table_1_QuantityDelivered]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_QuantityDelivered]  DEFAULT ((0)) FOR [dblQuantityDelivered]
GO
/****** Object:  Default [DF_Table_1_ActualPercentAfterDelivery]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_ActualPercentAfterDelivery]  DEFAULT ((0)) FOR [dblActualPercentAfterDelivery]
GO
/****** Object:  Default [DF_Table_1_InvoiceType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_InvoiceType]  DEFAULT ((0)) FOR [strInvoiceType]
GO
/****** Object:  Default [DF_Table_1_SalesPersonID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncFailed] ADD  CONSTRAINT [DF_Table_1_SalesPersonID]  DEFAULT ((0)) FOR [strSalesPersonID]
GO
/****** Object:  Default [DF_tblTMSyncOutOfRange_ysnCommit]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncOutOfRange] ADD  CONSTRAINT [DF_tblTMSyncOutOfRange_ysnCommit]  DEFAULT ((0)) FOR [ysnCommit]
GO
/****** Object:  Default [DF_Table_1_CustomerNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_CustomerNumber]  DEFAULT ((0)) FOR [strCustomerNumber]
GO
/****** Object:  Default [DF_Table_1_SiteNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_SiteNumber]  DEFAULT ((0)) FOR [strSiteNumber]
GO
/****** Object:  Default [DF_Table_1_MeterReading]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_MeterReading]  DEFAULT ((0)) FOR [dblMeterReading]
GO
/****** Object:  Default [DF_Table_1_InvoiceNumber]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_InvoiceNumber]  DEFAULT ((0)) FOR [strInvoiceNumber]
GO
/****** Object:  Default [DF_Table_1_BulkPlantNumber_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_BulkPlantNumber_1]  DEFAULT ((0)) FOR [strBulkPlantNumber]
GO
/****** Object:  Default [DF_Table_1_InvoiceDate_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_InvoiceDate_1]  DEFAULT ((0)) FOR [dtmInvoiceDate]
GO
/****** Object:  Default [DF_Table_1_ItemNumber_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_ItemNumber_1]  DEFAULT ((0)) FOR [strItemNumber]
GO
/****** Object:  Default [DF_Table_1_ItemAvailableForTM_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_ItemAvailableForTM_1]  DEFAULT ((0)) FOR [strItemAvailableForTM]
GO
/****** Object:  Default [DF_Table_1_ReversePreviousDelivery_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_ReversePreviousDelivery_1]  DEFAULT ((0)) FOR [strReversePreviousDelivery]
GO
/****** Object:  Default [DF_Table_1_PerformerID_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_PerformerID_1]  DEFAULT ((0)) FOR [strPerformerID]
GO
/****** Object:  Default [DF_Table_1_InvoiceLineNumber_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_InvoiceLineNumber_1]  DEFAULT ((0)) FOR [intInvoiceLineNumber]
GO
/****** Object:  Default [DF_Table_1_ExtendedAmount_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_ExtendedAmount_1]  DEFAULT ((0)) FOR [dblExtendedAmount]
GO
/****** Object:  Default [DF_Table_1_QuantityDelivered_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_QuantityDelivered_1]  DEFAULT ((0)) FOR [dblQuantityDelivered]
GO
/****** Object:  Default [DF_Table_1_ActualPercentAfterDelivery_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_ActualPercentAfterDelivery_1]  DEFAULT ((0)) FOR [dblActualPercentAfterDelivery]
GO
/****** Object:  Default [DF_Table_1_InvoiceType_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_InvoiceType_1]  DEFAULT ((0)) FOR [strInvoiceType]
GO
/****** Object:  Default [DF_Table_1_SalesPersonID_1]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSyncPurged] ADD  CONSTRAINT [DF_Table_1_SalesPersonID_1]  DEFAULT ((0)) FOR [strSalesPersonID]
GO
/****** Object:  Default [DEF_tblTMTankMeasurement_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankMeasurement] ADD  CONSTRAINT [DEF_tblTMTankMeasurement_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMTankMeasurement_intSiteDeviceID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankMeasurement] ADD  CONSTRAINT [DEF_tblTMTankMeasurement_intSiteDeviceID]  DEFAULT ((0)) FOR [intSiteDeviceID]
GO
/****** Object:  Default [DEF_tblTMTankMeasurement_dblTankSize]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankMeasurement] ADD  CONSTRAINT [DEF_tblTMTankMeasurement_dblTankSize]  DEFAULT ((0)) FOR [dblTankSize]
GO
/****** Object:  Default [DEF_tblTMTankMeasurement_dblTankCapacity]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankMeasurement] ADD  CONSTRAINT [DEF_tblTMTankMeasurement_dblTankCapacity]  DEFAULT ((0)) FOR [dblTankCapacity]
GO
/****** Object:  Default [DF_tblTMTownShip_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankTownship] ADD  CONSTRAINT [DF_tblTMTownShip_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMTankType_intConcurrencyID]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankType] ADD  CONSTRAINT [DEF_tblTMTankType_intConcurrencyID]  DEFAULT ((0)) FOR [intConcurrencyID]
GO
/****** Object:  Default [DEF_tblTMTankType_strTankType]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMTankType] ADD  CONSTRAINT [DEF_tblTMTankType_strTankType]  DEFAULT ('') FOR [strTankType]
GO
/****** Object:  ForeignKey [FK_tblTMDDReading_tblTMClock]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDegreeDayReading]  WITH CHECK ADD  CONSTRAINT [FK_tblTMDDReading_tblTMClock] FOREIGN KEY([intClockID])
REFERENCES [dbo].[tblTMClock] ([intClockID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMDegreeDayReading] CHECK CONSTRAINT [FK_tblTMDDReading_tblTMClock]
GO
/****** Object:  ForeignKey [FK_tblTMDeliveryHistory_tblTMSite]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistory]  WITH CHECK ADD  CONSTRAINT [FK_tblTMDeliveryHistory_tblTMSite] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMDeliveryHistory] CHECK CONSTRAINT [FK_tblTMDeliveryHistory_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMDeliveryHistoryDetail_tblTMDeliveryHistory]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliveryHistoryDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblTMDeliveryHistoryDetail_tblTMDeliveryHistory] FOREIGN KEY([intDeliveryHistoryID])
REFERENCES [dbo].[tblTMDeliveryHistory] ([intDeliveryHistoryID])
GO
ALTER TABLE [dbo].[tblTMDeliveryHistoryDetail] CHECK CONSTRAINT [FK_tblTMDeliveryHistoryDetail_tblTMDeliveryHistory]
GO
/****** Object:  ForeignKey [FK_tblTMDeliverySchedule_tblTMDeliverySchedule]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDeliverySchedule]  WITH CHECK ADD  CONSTRAINT [FK_tblTMDeliverySchedule_tblTMDeliverySchedule] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMDeliverySchedule] CHECK CONSTRAINT [FK_tblTMDeliverySchedule_tblTMDeliverySchedule]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMApplianceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMApplianceType] FOREIGN KEY([intApplianceTypeID])
REFERENCES [dbo].[tblTMApplianceType] ([intApplianceTypeID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMApplianceType]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMDeployedStatus]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMDeployedStatus] FOREIGN KEY([intDeployedStatusID])
REFERENCES [dbo].[tblTMDeployedStatus] ([intDeployedStatusID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMDeployedStatus]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMDevice]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMDevice] FOREIGN KEY([intParentDeviceID])
REFERENCES [dbo].[tblTMDevice] ([intDeviceID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMDevice]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMDeviceType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMDeviceType] FOREIGN KEY([intDeviceTypeID])
REFERENCES [dbo].[tblTMDeviceType] ([intDeviceTypeID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMDeviceType]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMInventoryStatus]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMInventoryStatus] FOREIGN KEY([intInventoryStatusTypeID])
REFERENCES [dbo].[tblTMInventoryStatusType] ([intInventoryStatusTypeID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMInventoryStatus]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMLease]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMLease] FOREIGN KEY([intLeaseID])
REFERENCES [dbo].[tblTMLease] ([intLeaseID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMLease]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMMeterType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMMeterType] FOREIGN KEY([intMeterTypeID])
REFERENCES [dbo].[tblTMMeterType] ([intMeterTypeID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMMeterType]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMRegulatorType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMRegulatorType] FOREIGN KEY([intRegulatorTypeID])
REFERENCES [dbo].[tblTMRegulatorType] ([intRegulatorTypeID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMRegulatorType]
GO
/****** Object:  ForeignKey [FK_tblTMDevice_tblTMTankType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTMDevice_tblTMTankType] FOREIGN KEY([intTankTypeID])
REFERENCES [dbo].[tblTMTankType] ([intTankTypeID])
GO
ALTER TABLE [dbo].[tblTMDevice] CHECK CONSTRAINT [FK_tblTMDevice_tblTMTankType]
GO
/****** Object:  ForeignKey [FK_tblTMDispatch_tblTMSite1]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMDispatch]  WITH CHECK ADD  CONSTRAINT [FK_tblTMDispatch_tblTMSite1] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMDispatch] CHECK CONSTRAINT [FK_tblTMDispatch_tblTMSite1]
GO
/****** Object:  ForeignKey [FK_tblTMEvent_tblTMEventType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEvent]  WITH CHECK ADD  CONSTRAINT [FK_tblTMEvent_tblTMEventType] FOREIGN KEY([intEventTypeID])
REFERENCES [dbo].[tblTMEventType] ([intEventTypeID])
GO
ALTER TABLE [dbo].[tblTMEvent] CHECK CONSTRAINT [FK_tblTMEvent_tblTMEventType]
GO
/****** Object:  ForeignKey [FK_tblTMEventAutomation_tblTMEventType]    Script Date: 10/07/2013 15:06:44 ******/
ALTER TABLE [dbo].[tblTMEventAutomation]  WITH CHECK ADD  CONSTRAINT [FK_tblTMEventAutomation_tblTMEventType] FOREIGN KEY([intEventTypeID])
REFERENCES [dbo].[tblTMEventType] ([intEventTypeID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblTMEventAutomation] CHECK CONSTRAINT [FK_tblTMEventAutomation_tblTMEventType]
GO
/****** Object:  ForeignKey [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMJulianCalendarDelivery]  WITH CHECK ADD  CONSTRAINT [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar] FOREIGN KEY([intSiteJulianCalendarID])
REFERENCES [dbo].[tblTMSiteJulianCalendar] ([intSiteJulianCalendarID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMJulianCalendarDelivery] CHECK CONSTRAINT [FK_tblTMJulianCalendarDelivery_tblTMSiteJulianCalendar]
GO
/****** Object:  ForeignKey [FK_tblTMLease_tblTMLeaseCode]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMLease]  WITH CHECK ADD  CONSTRAINT [FK_tblTMLease_tblTMLeaseCode] FOREIGN KEY([intLeaseCodeID])
REFERENCES [dbo].[tblTMLeaseCode] ([intLeaseCodeID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblTMLease] CHECK CONSTRAINT [FK_tblTMLease_tblTMLeaseCode]
GO
/****** Object:  ForeignKey [FK_tblTMSite_tblTMClock]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSite_tblTMClock] FOREIGN KEY([intClockID])
REFERENCES [dbo].[tblTMClock] ([intClockID])
GO
ALTER TABLE [dbo].[tblTMSite] CHECK CONSTRAINT [FK_tblTMSite_tblTMClock]
GO
/****** Object:  ForeignKey [FK_tblTMSite_tblTMCustomer]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSite_tblTMCustomer] FOREIGN KEY([intCustomerID])
REFERENCES [dbo].[tblTMCustomer] ([intCustomerID])
GO
ALTER TABLE [dbo].[tblTMSite] CHECK CONSTRAINT [FK_tblTMSite_tblTMCustomer]
GO
/****** Object:  ForeignKey [FK_tblTMSite_tblTMFillMethod]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSite_tblTMFillMethod] FOREIGN KEY([intFillMethodID])
REFERENCES [dbo].[tblTMFillMethod] ([intFillMethodID])
GO
ALTER TABLE [dbo].[tblTMSite] CHECK CONSTRAINT [FK_tblTMSite_tblTMFillMethod]
GO
/****** Object:  ForeignKey [FK_tblTMSite_tblTMHoldReason]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSite_tblTMHoldReason] FOREIGN KEY([intHoldReasonID])
REFERENCES [dbo].[tblTMHoldReason] ([intHoldReasonID])
GO
ALTER TABLE [dbo].[tblTMSite] CHECK CONSTRAINT [FK_tblTMSite_tblTMHoldReason]
GO
/****** Object:  ForeignKey [FK_tblTMSite_tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSite]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSite_tblTMSite] FOREIGN KEY([intParentSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMSite] CHECK CONSTRAINT [FK_tblTMSite_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMSiteDevice_tblTMDevice]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteDevice_tblTMDevice] FOREIGN KEY([intDeviceID])
REFERENCES [dbo].[tblTMDevice] ([intDeviceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMSiteDevice] CHECK CONSTRAINT [FK_tblTMSiteDevice_tblTMDevice]
GO
/****** Object:  ForeignKey [FK_tblTMSiteDevice_tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDevice]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteDevice_tblTMSite] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMSiteDevice] CHECK CONSTRAINT [FK_tblTMSiteDevice_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMSiteDeviceLink_tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDeviceLink]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSite] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMSiteDeviceLink] CHECK CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMSiteDeviceLink_tblTMSiteDevice]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteDeviceLink]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSiteDevice] FOREIGN KEY([intSiteDeviceID])
REFERENCES [dbo].[tblTMSiteDevice] ([intSiteDeviceID])
GO
ALTER TABLE [dbo].[tblTMSiteDeviceLink] CHECK CONSTRAINT [FK_tblTMSiteDeviceLink_tblTMSiteDevice]
GO
/****** Object:  ForeignKey [FK_tblTMSiteJulianCalendar_tblTMSiteJulianCalendar]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteJulianCalendar]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteJulianCalendar_tblTMSiteJulianCalendar] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMSiteJulianCalendar] CHECK CONSTRAINT [FK_tblTMSiteJulianCalendar_tblTMSiteJulianCalendar]
GO
/****** Object:  ForeignKey [FK_tblTMSiteLink_tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMSiteLink]  WITH CHECK ADD  CONSTRAINT [FK_tblTMSiteLink_tblTMSite] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblTMSiteLink] CHECK CONSTRAINT [FK_tblTMSiteLink_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMWork_tblTMSite]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMWorkOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblTMWork_tblTMSite] FOREIGN KEY([intSiteID])
REFERENCES [dbo].[tblTMSite] ([intSiteID])
GO
ALTER TABLE [dbo].[tblTMWorkOrder] CHECK CONSTRAINT [FK_tblTMWork_tblTMSite]
GO
/****** Object:  ForeignKey [FK_tblTMWork_tblTMWorkCloseReason]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMWorkOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblTMWork_tblTMWorkCloseReason] FOREIGN KEY([intCloseReasonID])
REFERENCES [dbo].[tblTMWorkCloseReason] ([intCloseReasonID])
GO
ALTER TABLE [dbo].[tblTMWorkOrder] CHECK CONSTRAINT [FK_tblTMWork_tblTMWorkCloseReason]
GO
/****** Object:  ForeignKey [FK_tblTMWork_tblTMWorkStatus]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMWorkOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblTMWork_tblTMWorkStatus] FOREIGN KEY([intWorkStatusTypeID])
REFERENCES [dbo].[tblTMWorkStatusType] ([intWorkStatusID])
GO
ALTER TABLE [dbo].[tblTMWorkOrder] CHECK CONSTRAINT [FK_tblTMWork_tblTMWorkStatus]
GO
/****** Object:  ForeignKey [FK_tblTMWorkToDo_tblTMWork]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMWorkToDo]  WITH CHECK ADD  CONSTRAINT [FK_tblTMWorkToDo_tblTMWork] FOREIGN KEY([intWorkOrderID])
REFERENCES [dbo].[tblTMWorkOrder] ([intWorkOrderID])
GO
ALTER TABLE [dbo].[tblTMWorkToDo] CHECK CONSTRAINT [FK_tblTMWorkToDo_tblTMWork]
GO
/****** Object:  ForeignKey [FK_tblTMWorkToDo_tblTMWorkToDoItem]    Script Date: 10/07/2013 15:06:45 ******/
ALTER TABLE [dbo].[tblTMWorkToDo]  WITH CHECK ADD  CONSTRAINT [FK_tblTMWorkToDo_tblTMWorkToDoItem] FOREIGN KEY([intWorkToDoItemID])
REFERENCES [dbo].[tblTMWorkToDoItem] ([intToDoItemID])
GO
ALTER TABLE [dbo].[tblTMWorkToDo] CHECK CONSTRAINT [FK_tblTMWorkToDo_tblTMWorkToDoItem]
GO

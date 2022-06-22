﻿CREATE TABLE [dbo].[tblCFInvoiceHistoryStagingTable] (
    [intInvoiceHistoryStagingId]			INT            IDENTITY (1, 1) NOT NULL,
	[intCustomerGroupId]					INT             NULL,
    [intTransactionId]						INT             NULL,
    [intOdometer]							INT             NULL,
    [intOdometerAging]						INT             NULL,
    [intInvoiceId]							INT             NULL,
    [intProductId]							INT             NULL,
    [intCardId]								INT             NULL,
    [intAccountId]							INT             NULL,
    [intInvoiceCycle]						INT             NULL,
    [intSubAccountId]						INT             NULL,
    [intCustomerId]							INT             NULL,
    [intDiscountScheduleId]					INT             NULL,
    [intTermsCode]							INT             NULL,
    [intTermsId]							INT             NULL,
    [intARItemId]							INT             NULL,
    [intSalesPersonId]						INT             NULL,
    [intTermID]								INT             NULL,
    [intBalanceDue]							INT             NULL,
    [intDiscountDay]						INT             NULL,
    [intDayofMonthDue]						INT             NULL,
    [intDueNextMonth]						INT             NULL,
    [intSort]								INT             NULL,
    [intFeeLoopId]							INT             NULL,
    [intItemId]								INT             NULL,
    [intARLocationId]						INT             NULL,
    [strGroupName]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShipTo]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBillTo]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyName]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCompanyAddress]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strType]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLocationName]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionId]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTransactionType]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceReportNumber]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strTempInvoiceReportNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strMiscellaneous]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strName]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCardNumber]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCardDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNetwork]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceCycle]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimarySortOptions]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSecondarySortOptions]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintRemittancePage]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintPricePerGallon]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintSiteAddress]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteNumber]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteName]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProductNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemNo]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strVehicleNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strVehicleDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxState]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartment]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteType]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strState]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteAddress]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strSiteCity]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintTimeStamp]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strEmailDistributionOption]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDepartmentDescription]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strShortName]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProductDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemNumber]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strItemDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTerm]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTermCode]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTermType]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCalculationType]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFeeDescription]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strFee]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceFormat]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strProductDescriptionForTotals]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate]					DATETIME        NULL,
    [dtmDate]								DATETIME        NULL,
    [dtmPostedDate]							DATETIME        NULL,
    [dtmDiscountDate]						DATETIME        NULL,
    [dtmDueDate]							DATETIME        NULL,
    [dtmInvoiceDate]						DATETIME        NULL,
    [dtmStartDate]							DATETIME        NULL,
    [dtmEndDate]							DATETIME        NULL,
	[dblAccountTotalDiscountQuantity]		NUMERIC (18, 6) NULL,
    [dblTotalMiles]							NUMERIC (18, 6) NULL,
    [dblQuantity]							NUMERIC (18, 6) NULL,
    [dblCalculatedTotalAmount]				NUMERIC (18, 6) NULL,
    [dblOriginalTotalAmount]				NUMERIC (18, 6) NULL,
    [dblCalculatedGrossAmount]				NUMERIC (18, 6) NULL,
    [dblOriginalGrossAmount]				NUMERIC (18, 6) NULL,
    [dblCalculatedNetAmount]				NUMERIC (18, 6) NULL,
    [dblOriginalNetAmount]					NUMERIC (18, 6) NULL,
    [dblMargin]								NUMERIC (18, 6) NULL,
    [dblTotalTax]							NUMERIC (18, 6) NULL,
    [dblTotalSST]							NUMERIC (18, 6) NULL,
    [dblTaxExceptSST]						NUMERIC (18, 6) NULL,
    [dblInvoiceTotal]						NUMERIC (18, 6) NULL,
    [dblTotalQuantity]						NUMERIC (18, 6) NULL,
    [dblTotalGrossAmount]					NUMERIC (18, 6) NULL,
    [dblTotalNetAmount]						NUMERIC (18, 6) NULL,
    [dblTotalAmount]						NUMERIC (18, 6) NULL,
    [dblTotalTaxAmount]						NUMERIC (18, 6) NULL,
    [TotalFET]								NUMERIC (18, 6) NULL,
    [TotalSET]								NUMERIC (18, 6) NULL,
    [TotalSST]								NUMERIC (18, 6) NULL,
    [TotalLC]								NUMERIC (18, 6) NULL,
    [dblDiscountRate]						NUMERIC (18, 6) NULL,
    [dblDiscount]							NUMERIC (18, 6) NULL,
    [dblAccountTotalAmount]					NUMERIC (18, 6) NULL,
    [dblAccountTotalDiscount]				NUMERIC (18, 6) NULL,
    [dblAccountTotalLessDiscount]			NUMERIC (18, 6) NULL,
    [dblDiscountEP]							NUMERIC (18, 6) NULL,
    [dblAPR]								NUMERIC (18, 6) NULL,
    [dblFeeAmount]							NUMERIC (18, 6) NULL,
    [dblFeeRate]							NUMERIC (18, 6) NULL,
    [dblEligableGallon]						NUMERIC (18, 6) NULL,
    [ysnPrintMiscellaneous]					BIT             NULL,
    [ysnSummaryByCard]						BIT             NULL,
    [ysnSummaryByDepartmentProduct]			BIT             NULL,
    [ysnSummaryByDepartment]				BIT             NULL,
    [ysnSummaryByMiscellaneous]				BIT             NULL,
    [ysnSummaryByProduct]					BIT             NULL,
    [ysnSummaryByVehicle]					BIT             NULL,
    [ysnSummaryByDeptCardProd]				BIT             NULL,
    [ysnSummaryByCardProd]					BIT             NULL,
    [ysnPrintTimeOnInvoices]				BIT             NULL,
    [ysnPrintTimeOnReports]					BIT             NULL,
    [ysnInvalid]							BIT             NULL,
    [ysnPostedCSV]							BIT             NULL,
    [ysnPosted]								BIT             NULL,
    [ysnIncludeInQuantityDiscount]			BIT             NULL,
    [ysnAllowEFT]							BIT             NULL,
    [ysnActive]								BIT             NULL,
    [ysnEnergyTrac]							BIT             NULL,
    [strDiscountSchedule]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnShowOnCFInvoice]					BIT             NULL,
    [ysnPostForeignSales]					BIT             NULL,
    [ysnSummaryByDeptVehicleProd]			BIT             NULL,
    [ysnDepartmentGrouping]					BIT             NULL,
    [strGuid]								NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strUserId]								NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceNumberHistory]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmDueDateBaseOnTermsHistory]			DATETIME        NULL,
    [dtmDiscountDateBaseOnTermsHistory]		DATETIME        NULL,
    [strDriverPinNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strDriverDescription]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intDriverPinId]						INT             NULL,
    [ysnSummaryByDriverPin]					BIT             NULL,
    [strDetailDisplay]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnMPGCalculation]						BIT             NULL,
	[strDetailDisplayValue]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDetailDisplayLabel]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnShowVehicleDescriptionOnly]			BIT             NULL,
    [ysnShowDriverPinDescriptionOnly]		BIT             NULL,
    [ysnPageBreakByPrimarySortOrder]		BIT             NULL,
	[ysnSummaryByDeptDriverPinProd]			BIT             NULL,
    [strDepartmentGrouping]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [InvoiceHistoryUserAndTransactionId] UNIQUE NONCLUSTERED ([intTransactionId] ASC, [strUserId] ASC) WITH (FILLFACTOR = 70),
	CONSTRAINT [PK_tblCFInvoiceHistoryStagingTable] PRIMARY KEY CLUSTERED ([intInvoiceHistoryStagingId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_tblCFInvoiceHistoryStagingTable_strInvoiceReportNumber]
ON [dbo].[tblCFInvoiceHistoryStagingTable]([strInvoiceReportNumber])
GO
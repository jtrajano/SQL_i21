﻿CREATE TABLE [dbo].[tblSTTranslogRebates]
(
	[intTranslogId] int IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	[dtmOpenedTime] datetime NULL,
	[dtmClosedTime] datetime NULL,
	[dblInsideSales] decimal(18, 6) NULL,
	[dblInsideGrand] decimal(18, 6) NULL,
	[dblOutsideSales] decimal(18, 6) NULL,
	[dblOutsideGrand] decimal(18, 6) NULL,
	[dblOverallSales] decimal(18, 6) NULL,
	[dblOverallGrand] decimal(18, 6) NULL,
	[strTransType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransRecalled] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTermMsgSNtype] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[intTermMsgSNterm] int NULL,
	[intTermMsgSN] int NULL,
	[intPeriodLevel] int NULL,
	[intPeriodSeq] int NULL,
	[strPeriodName] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strPeriod] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] datetime NULL,
	[intDuration] bigint NULL,
	[intTill] int NULL,
	[intCashierSysId] int NULL,
	[intCashierEmpNum] int NULL,
	[intCashierPosNum] int NULL,
	[intCashierPeriod] int NULL,
	[intCashierDrawer] int NULL,
	[strCashier] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[intStoreNumber] int NULL,
	[strTrFuelOnlyCst] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intPosNum] int NULL,
	[intTrSeq] bigint NULL,
	[dblTrTotNoTax] decimal(18, 2) NULL,
	[dblTrTotWTax] decimal(18, 2) NULL,
	[dblTrTotTax] decimal(18, 2) NULL,
	[strTrTax] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrCurrTotLocale] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[dblTrCurrTot] decimal(18, 2) NULL,
	[dblTrSTotalizer] decimal(18, 2) NULL,
	[dblTrGTotalizer] decimal(18, 2) NULL,
	[strTrLinetype] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlTaxes] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlags] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlDeptnumber] int NULL,
	[strTrlDeptType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlDept] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlCatnumber] int NULL,
	[strTrlCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlNetwCode] int NULL,
	[dblTrlQty] decimal(18, 3) NULL,
	[dblTrlSign] decimal(18, 2) NULL,
	[dblTrlUnitPrice] decimal(18, 3) NULL,
	[dblTrlLineTot] decimal(18, 2) NULL,
	[strTrlUPC] nvarchar(14) COLLATE Latin1_General_CI_AS NULL,
	[strTrlDesc] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrPaylineType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrPaylineSysId] int NULL,
	[strTrPaylinelocale] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpPaycodemop] int NULL,
	[intTrpPaycodecat] int NULL,
	[strTrpPaycodenacstendercode] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTrpPaycodenacstendersubcode] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTrpPaycode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrpAmt] decimal(18, 2) NULL,
	[intStoreId] int NOT NULL,
	[intCheckoutId] int NOT NULL,
	[ysnSubmitted] bit NOT NULL,
	[intConcurrencyId] int NOT NULL,
)

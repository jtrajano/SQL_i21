﻿CREATE TABLE [dbo].[tblSTTranslogRebates]
(
	--[intTranslogId] int IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	[intTranslogId] INT NOT NULL IDENTITY,

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
	[strTransRollback] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransFuelPrepayCompletion] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTermMsgSNtype] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[intTermMsgSNterm] int NULL,

	[intScanTransactionId] int NULL,

	[intTermMsgSN] int NULL,
	[intPeriodLevel] int NULL,
	[intPeriodSeq] int NULL,
	[strPeriodName] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] datetime NULL,
	[intDuration] double precision NULL,
	[intTill] int NULL,
	[intCashierSysId] int NULL,
	[intCashierEmpNum] int NULL,
	[intCashierPosNum] int NULL,
	[intCashierPeriod] int NULL,
	[intCashierDrawer] int NULL,
	[strCashier] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[intOriginalCashierSysid] int NULL,
	[intOriginalCashierEmpNum] int NULL,
	[intOriginalCashierPosNum] int NULL,
	[intOriginalCashierPeriod] int NULL,
	[intOriginalCashierDrawer] int NULL,
	[strOriginalCashier] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[intStoreNumber] int NULL,
	[dblCoinDispensed] decimal(18, 2) NULL,
	[strPopDiscTran] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strTrFuelOnlyCst] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[intTrTickNumPosNum] int NULL,
	[intTrTickNumTrSeq] bigint NULL,
	[dblTrValueTrTotNoTax] decimal(18, 2) NULL,
	[dblTrValueTrTotWTax] decimal(18, 2) NULL,
	[dblTrValueTrTotTax] decimal(18, 2) NULL,
	[strTrCurrTotLocale] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblTrCurrTot] decimal(18, 2) NULL,
	[dblTrSTotalizer] decimal(18, 2) NULL,
	[dblTrGTotalizer] decimal(18, 2) NULL,
	[strCustDOB] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblRecallAmt] decimal(18, 2) NULL,
	[intTaxAmtsTaxAmtSysid] int NULL,
	[strTaxAmtsTaxAmtCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxAmt] decimal(18, 2) NULL,
	[intTaxAmtsTaxRateSysid] int NULL,
	[strTaxAmtsTaxRateCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxRate] decimal(18, 2) NULL,
	[intTaxAmtsTaxNetSysid] int NULL,
	[strTaxAmtsTaxNetCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxNet] decimal(18, 2) NULL,
	[intTaxAmtsTaxAttributeSysid] int NULL,
	[strTaxAmtsTaxAttributeCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxAttribute] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpTot] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpTax] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpChg] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpTnd] decimal(18, 2) NULL,
	[dblTrCshBkAmtMop] int NULL,
	[dblTrCshBkAmtCat] int NULL,
	[dblTrCshBkAmt] decimal(18, 2) NULL,
	[intTrExNetProdTrENPPcode] int NULL,
	[dblTrExNetProdTrENPAmount] decimal(18, 2) NULL,
	[strTrLoyaltyProgramProgramID] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblTrLoyaltyProgramTrloSubTotal] decimal(18, 2) NULL,
	[dblTrLoyaltyProgramTrloAutoDisc] decimal(18, 2) NULL,
	[dblTrLoyaltyProgramTrloCustDisc] decimal(18, 2) NULL,
	[strTrLoyaltyProgramTrloAccount] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLoyaltyProgramTrloEntryMeth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLoyaltyProgramTrloAuthReply] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLineType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLineUnsettled] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlDeptNumber] int NULL,
	[strTrlDeptType] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTrlDept] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlNetwCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlQty] decimal(18, 2) NULL,
	[dblTrlSign] decimal(18, 2) NULL,
	[dblTrlSellUnitPrice] decimal(18, 3) NULL,
	[dblTrlUnitPrice] decimal(18, 3) NULL,
	[dblTrlLineTot] decimal(18, 3) NULL,
	[strTrlDesc] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlUPC] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlModifier] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlUPCEntryType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlCatNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlTaxesTrlTaxSysid] int NULL,
	[strTrlTaxesTrlTaxCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlTaxesTrlTaxReverse] int NULL,
	[dblTrlTaxesTrlTax] decimal(18, 2) NULL,
	[intTrlTaxesTrlRateSysid] int NULL,
	[strTrlTaxesTrlRateCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlTaxesTrlRate] decimal(18, 2) NULL,
	[strTrlFlagsTrlPLU] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlUpdPluCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlUpdDepCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlCatCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlFuelSale] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlMatch] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlBdayVerif] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlMatchLineTrlMatchNumber] int NULL,
	[strTrlMatchLineTrlMatchName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlMatchLineTrlMatchQuantity] decimal(18, 3) NULL,
	[dblTrlMatchLineTrlMatchPrice] decimal(18, 3) NULL,
	[intTrlMatchLineTrlMatchMixes] int NULL,
	[dblTrlMatchLineTrlPromoAmount] decimal(18, 3) NULL,
	[strTrlMatchLineTrlPromotionIDPromoType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlMatchLineTrlPromotionID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrPaylineType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrPaylineSysid] int NULL,
	[strTrPaylineLocale] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpPaycodeMop] int NULL,
	[intTrpPaycodeCat] int NULL,
	[strTrPaylineNacstendercode] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTrPaylineNacstendersubcode] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTrpPaycode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrpAmt] decimal(18, 3) NULL,
	[strTrpCardInfoTrpcAccount] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpCardInfoTrpcCCNameProdSysid] int NULL,
	[strTrpCardInfoTrpcCCName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcHostID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcAuthCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcAuthSrc] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcTicket] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcEntryMeth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcBatchNr] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcSeqNr] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmTrpCardInfoTrpcAuthDateTime] datetime NULL,
	[strTrpCardInfoTrpcRefNum] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoMerchInfoTrpcmMerchID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoMerchInfoTrpcmTermID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	[intStoreId] int NOT NULL,
	[intCheckoutId] int NOT NULL,
	[ysnSubmitted] bit NOT NULL,
	[ysnPMMSubmitted] BIT NOT NULL DEFAULT ((0)),
	[ysnRJRSubmitted] BIT NOT NULL DEFAULT ((0)),
	[intConcurrencyId] int NOT NULL,
	CONSTRAINT [PK_tblSTTranslogRebates] PRIMARY KEY ([intTranslogId])
	--CONSTRAINT [PK_tblSTTranslogRebates] PRIMARY KEY NONCLUSTERED ([intTranslogId])
)
Go

CREATE NONCLUSTERED INDEX [IDX_tblSTTranslogRebates]
		ON [dbo].[tblSTTranslogRebates]([dtmDate] ASC, [intTermMsgSN] ASC, [intTermMsgSNterm] ASC, [intStoreId] ASC, [intCheckoutId] ASC);


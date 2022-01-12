CREATE TYPE StagingTransactionLog AS TABLE
(
	[intRowCount] INT NULL,
	-- transSet
	[intTransSetPeriodID] INT NULL,
	[strTransSetPeriodame] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransSetLongId] DATETIME NULL,
	[dtmTransSetShortId] DATETIME NULL,
	[intTransSetSite] INT NULL,
	[dtmOpenedTime] datetime NULL,
	[dtmClosedTime] datetime NULL,
	-- startTotals
	[dblInsideSales] decimal(18, 6) NULL,
	[dblInsideGrand] decimal(18, 6) NULL,
	[dblOutsideSales] decimal(18, 6) NULL,
	[dblOutsideGrand] decimal(18, 6) NULL,
	[dblOverallSales] decimal(18, 6) NULL,
	[dblOverallGrand] decimal(18, 6) NULL,

	-- trans
	[strTransType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransRecalled] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransRollback] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransFuelPrepayCompletion] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	-- trHeader
    [intTermMsgSN] bigint NULL,
	[strTermMsgSNtype] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[intTermMsgSNterm] int NULL,
	-- trTickNum
	[intTrTickNumPosNum] int NULL,
	[intTrTickNumTrSeq] bigint NULL,
	[intTrUniqueSN] bigint NULL,                                                    -- NEW 
	[strPeriodNameHOUR] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,             -- Modified 
    [intPeriodNameHOURSeq] int NULL,                                                -- Modified 
    [intPeriodNameHOURLevel] int NULL,	                                            -- Modified 
	[strPeriodNameSHIFT] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,            -- Modified 
    [intPeriodNameSHIFTSeq] int NULL,                                               -- Modified 
    [intPeriodNameSHIFTLevel] int NULL,                                             -- Modified 
	[strPeriodNameDAILY] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,            -- Modified 
    [intPeriodNameDAILYSeq] int NULL,                                               -- Modified 
    [intPeriodNameDAILYLevel] int NULL,                                             -- Modified 
    [dtmDate] datetime NULL,
	[intDuration] BIGINT NULL,
    [intTill] int NULL,

	-- cashier
    [strCashier] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[intCashierSysId] int NULL, 
	[strCashierEmpNum] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
    [intCashierPosNum] int NULL,
    [intCashierPeriod] int NULL, 
    [intCashierDrawer] int NULL, 
	-- originalCashier
    [strOriginalCashier] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
	[intOriginalCashierSysid] int NULL, 
	[strOriginalCashierEmpNum] nvarchar(200) COLLATE Latin1_General_CI_AS NULL,
    [intOriginalCashierPosNum] int NULL,
    [intOriginalCashierPeriod] int NULL, 
    [intOriginalCashierDrawer] int NULL,

	[intStoreNumber] int NULL,
    [strTrFuelOnlyCst] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [strPopDiscTran] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
    [dblCoinDispensed] decimal(18, 2) NULL,

	-- trValue
	[dblTrValueTrTotNoTax] decimal(18, 2) NULL,
	[dblTrValueTrTotWTax] decimal(18, 2) NULL,
	[dblTrValueTrTotTax] decimal(18, 2) NULL,
	-- taxAmts
	[dblTaxAmtsTaxAmt] decimal(18, 2) NULL,
	[intTaxAmtsTaxAmtSysid] int NULL,
	[strTaxAmtsTaxAmtCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxRate] decimal(18, 2) NULL,
	[intTaxAmtsTaxRateSysid] int NULL,
	[strTaxAmtsTaxRateCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxNet] decimal(18, 2) NULL,
	[intTaxAmtsTaxNetSysid] int NULL,
	[strTaxAmtsTaxNetCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTaxAmtsTaxAttribute] decimal(18, 2) NULL,
	[intTaxAmtsTaxAttributeSysid] int NULL,
	[strTaxAmtsTaxAttributeCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	[dblTrCurrTot] decimal(18, 2) NULL,
	[strTrCurrTotLocale] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,	
	[dblTrSTotalizer] decimal(18, 2) NULL,
	[dblTrGTotalizer] decimal(18, 2) NULL,
	-- trFstmp
	[dblTrFstmpTrFstmpTot] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpTax] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpChg] decimal(18, 2) NULL,
	[dblTrFstmpTrFstmpTnd] decimal(18, 2) NULL,
	-- trCshBk
	[dblTrCshBkAmt] decimal(18, 2) NULL,
	[dblTrCshBkAmtMop] int NULL,
	[dblTrCshBkAmtCat] int NULL,
    [strCustDOB] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
    [dblRecallAmt] decimal(18, 2) NULL,

	-- trExNetProds
	[intTrExNetProdTrENPPcode] int NULL,
	[dblTrExNetProdTrENPAmount] decimal(18, 2) NULL,
	[dblTrExNetProdTrENPItemCnt] decimal(18, 2) NULL, 

	-- trLoyalty
	[strTrLoyaltyProgramProgramID] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblTrLoyaltyProgramTrloSubTotal] decimal(18, 2) NULL,
	[dblTrLoyaltyProgramTrloAutoDisc] decimal(18, 2) NULL,
	[dblTrLoyaltyProgramTrloCustDisc] decimal(18, 2) NULL,
	[strTrLoyaltyProgramTrloAccount] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLoyaltyProgramTrloEntryMeth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrLoyaltyProgramTrloAuthReply] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	-- trLines
	[ysnTrLineDuplicate] bit NULL,  
	[strTrLineType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrLineUnsettled] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlTaxesTrlTax] decimal(18, 2) NULL,
	[intTrlTaxesTrlTaxSysid] int NULL,
	[strTrlTaxesTrlTaxCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlTaxesTrlTaxReverse] int NULL,
	[dblTrlTaxesTrlRate] decimal(18, 2) NULL,
	[intTrlTaxesTrlRateSysid] int NULL,
	[strTrlTaxesTrlRateCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	-- trlFlags
	[strTrlFlagsTrlBdayVerif] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrlFlagsTrlFstmp] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,            -- NEW
	[strTrlFlagsTrlPLU] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlUpdPluCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlUpdDepCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlCatCust] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlFuelSale] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFlagsTrlMatch] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,

	[strTrlDept] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlDeptNumber] int NULL,
    [strTrlDeptType] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTrlCat] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,                     --													trLine type="preFuel"
	[intTrlCatNumber] INT NULL,														-- MODIFIED FROM NVARCHAR(50) to INT				trLine type="preFuel"
	[strTrlNetwCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrlQty] decimal(18, 2) NULL,
	[dblTrlSign] decimal(18, 2) NULL,
	[dblTrlSellUnitPrice] decimal(18, 3) NULL,
	[dblTrlUnitPrice] decimal(18, 3) NULL,
	[dblTrlLineTot] decimal(18, 3) NULL,
	[dblTrlPrcOvrd] decimal(18, 3) NULL,
	[strTrlDesc] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlUPC] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlModifier] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlUPCEntryType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrloLnItemDiscProgramId] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblTrloLnItemDiscDiscAmt] decimal(18, 3) NULL, 
	[dblTrloLnItemDiscQty] decimal(18, 3) NULL,
	[intTrloLnItemDiscTaxCred] INT NULL,

	-- NEW
	-- trlFuel
	[strTrlFuelType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFuelSeq] INT NULL,	
	[strTrlFuelPosition] INT NULL,
	[strTrlFuelDepst] DECIMAL(18, 3) NULL,
	[strTrlFuelProd] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFuelProdSysid] INT NULL,
	[strTrlFuelProdNAXMLFuelGradeID] INT NULL,
	[strTrlFuelSvcMode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFuelSvcModeSysid] INT NULL,
	[strTrlFuelMOP] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTrlFuelMOPSysid] INT NULL,
	[strTrlFuelVolume] DECIMAL(18, 3) NULL,
	[strTrlFuelBasePrice] DECIMAL(18, 3) NULL,

	-- trPayline
	[strTrPaylineType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrPaylineSysid] int NULL,
	[strTrPaylineLocale] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpPaycode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpPaycodeMop] int NULL,
    [intTrpPaycodeCat] int NULL,
	[strTrPaylineNacstendercode] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTrPaylineNacstendersubcode] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblTrpAmt] decimal(18, 3) NULL,

	-- trpCardInfo
	[strTrpCardInfoTrpcAccount] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrpCardInfoTrpcCCName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpCardInfoTrpcCCNameProdSysid] int NULL,
	[strTrpCardInfoTrpcHostID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcAuthCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcAuthSrc] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcTicket] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoTrpcEntryMeth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrpCardInfoTrpcBatchNr] INT NULL,												-- MODIFIED FROM NVARCHAR(50) to INT
	[intTrpCardInfoTrpcSeqNr] INT NULL,													-- MODIFIED FROM NVARCHAR(50) to INT
	[dtmTrpCardInfoTrpcAuthDateTime] DATETIME NULL,
	[strTrpCardInfoTrpcRefNum] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoMerchInfoTrpcmMerchID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTrpCardInfoMerchInfoTrpcmTermID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,	

	[strTrpCardInfoTrpcAcquirerBatchNr] INT NULL,

	-- trlMatchLine
	[strTrlMatchLineTrlMatchName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [dblTrlMatchLineTrlMatchQuantity] decimal(18, 3) NULL,
    [dblTrlMatchLineTrlMatchPrice] decimal(18, 3) NULL,
    [intTrlMatchLineTrlMatchMixes] int NULL,
    [dblTrlMatchLineTrlPromoAmount] decimal(18, 3) NULL,
    [strTrlMatchLineTrlPromotionID] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    [strTrlMatchLineTrlPromotionIDPromoType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[intTrlMatchLineTrlMatchNumber] int NULL
)


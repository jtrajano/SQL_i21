CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
@intCheckoutId Int
AS
BEGIN
--Insert #tempCheckoutInsert to tblSTTranslogRebates
	INSERT INTO dbo.tblSTTranslogRebates 
	(
		strOpenedTime
		, strClosedTime
		, dblInsideSales
		, dblInsideGrand
		, dblOutsideSales
		, dblOutsideGrand
		, dblOverallSales
		, dblOverallGrand
		, strTransType
		, strTransRecalled
		, strTermMsgSNtype
		, intTermMsgSNterm
		, intTermMsgSN
		, intPeriodLevel
		, intPeriodSeq
		, strPeriodName 
		, strPeriod
		, strDate
		, intDuration
		, intTill
		, intCashierSysId
		, intCashierEmpNum
		, intCashierPosNum
		, intCashierPeriod
		, intCashierDrawer
		, strCashier
		, intStoreNumber
		, strTrFuelOnlyCst
		, intPosNum
		, intTrSeq
		, dblTrTotNoTax
		, dblTrTotWTax
		, dblTrTotTax
		, strTrTax
		, strTrCurrTotLocale
		, dblTrCurrTot
		, dblTrSTotalizer
		, dblTrGTotalizer
		, strTrLinetype
		, dblTrlTaxes
		, strTrlFlags
		, intTrlDeptnumber
		, strTrlDeptType
		, strTrlDept
		, intTrlCatnumber
		, strTrlCat
		, intTrlNetwCode
		, dblTrlQty
		, dblTrlSign
		, dblTrlUnitPrice
		, dblTrlLineTot
		, strTrlDesc
		, strTrPaylineType
		, intTrPaylineSysId
		, strTrPaylinelocale
		, intTrpPaycodemop
		, intTrpPaycodecat
		, strTrpPaycodenacstendercode
		, strTrpPaycodenacstendersubcode
		, strTrpPaycode
		, dblTrpAmt
	)
	SELECT 
		openedTime
		, closedTime
		, insideSales
		, insideGrand
		, outsideSales
		, outsideGrand
		, overallSales
		, overallGrand
		, transtype
		, transrecalled
		, termMsgSNtype
		, termMsgSNterm
		, termMsgSN
		, periodlevel
		, periodseq
		, periodname
		, period
		, date
		, duration
		, till
		, cashiersysid
		, cashierempNum
		, cashierposNum
		, cashierperiod
		, cashierdrawer
		, cashier
		, storeNumber
		, trFuelOnlyCst
		, posNum
		, trSeq
		, trTotNoTax
		, trTotWTax
		, trTotTax
		, trTax
		, trCurrTotlocale
		, trCurrTot
		, trSTotalizer
		, trGTotalizer
		, trLinetype
		, trlTaxes
		, trlFlags
		, trlDeptnumber
		, trlDepttype
		, trlDept
		, trlCatnumber
		, trlCat
		, trlNetwCode
		, trlQty
		, trlSign
		, trlUnitPrice
		, trlLineTot
		, trlDesc
		, trPaylinetype
		, trPaylinesysid
		, trPaylinelocale
		, trpPaycodemop
		, trpPaycodecat
		, trpPaycodenacstendercode
		, trpPaycodenacstendersubcode
		, trpPaycode
		, trpAmt
	FROM #tempCheckoutInsert chk
	WHERE chk.transtype = 'sale' AND chk.trlDept = 'CIGARETTES'

END
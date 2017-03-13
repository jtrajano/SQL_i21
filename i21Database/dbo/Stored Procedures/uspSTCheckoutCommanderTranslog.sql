CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
@intCheckoutId Int
AS
BEGIN
	--Insert #tempCheckoutInsert to tblSTTranslogRebates
	INSERT INTO dbo.tblSTTranslogRebates 
	(
		dtmOpenedTime
		, dtmClosedTime
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
		, dtmDate
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
		left(REPLACE(openedTime, 'T', ' '), len(openedTime) - 6)
		, left(REPLACE(closedTime, 'T', ' '), len(closedTime) - 6)
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
		, left(REPLACE(date, 'T', ' '), len(date) - 6)
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
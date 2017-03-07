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
	SELECT *
	FROM #tempCheckoutInsert chk
	WHERE chk.transtype = 'sale' AND chk.trlDept = 'CIGARETTES'

END
CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslog]
@intCheckoutId Int,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows int OUTPUT
AS
BEGIN
	Begin Try

	--Get StoreId
	DECLARE @intStoreId int
	SELECT @intStoreId = intStoreId FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId

	--Get Number of rows
	SELECT @intCountRows = COUNT(*) 
	FROM #tempCheckoutInsert chk
	JOIN
	(
		SELECT c.termMsgSN as termMsgSN
		FROM #tempCheckoutInsert c
		WHERE c.trlDept = 'CIGARETTES' AND c.transtype = 'sale'
		GROUP BY c.termMsgSN
	) x ON x.termMsgSN = chk.termMsgSN
	WHERE NOT EXISTS
	(
	    SELECT * 
	    FROM dbo.tblSTTranslogRebates TR
	    WHERE TR.dtmDate = CAST(left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) AS DATETIME)
		AND TR.intTermMsgSN = chk.termMsgSN
		AND TR.intTrSeq = chk.trSeq
		AND TR.strTrlUPC COLLATE DATABASE_DEFAULT = chk.trlUPC COLLATE DATABASE_DEFAULT
		AND TR.strTrlDesc COLLATE DATABASE_DEFAULT = chk.trlDesc COLLATE DATABASE_DEFAULT
		AND TR.intDuration = chk.duration
		AND TR.strTrpPaycode COLLATE DATABASE_DEFAULT = chk.trpPaycode COLLATE DATABASE_DEFAULT
		AND TR.dblTrpAmt = chk.trpAmt
	)

	--PRINT 'Rows count: ' + Cast(@intCountRows as nvarchar(50))

	IF(@intCountRows > 0)
	BEGIN
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
			, strTrlUPC
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
			, intStoreId
			, intCheckoutId
			, ysnSubmitted
			, intConcurrencyId
		)
		SELECT 	
			left(REPLACE(chk.openedTime, 'T', ' '), len(chk.openedTime) - 6)
			, left(REPLACE(chk.closedTime, 'T', ' '), len(chk.closedTime) - 6)
			, chk.insideSales
			, chk.insideGrand
			, chk.outsideSales
			, chk.outsideGrand
			, chk.overallSales
			, chk.overallGrand
			, chk.transtype
			, chk.transrecalled
			, chk.termMsgSNtype
			, chk.termMsgSNterm
			, chk.termMsgSN
			, chk.periodlevel
			, chk.periodseq
			, chk.periodname
			, chk.period
			, left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6)
			, chk.duration
			, chk.till
			, chk.cashiersysid
			, chk.cashierempNum
			, chk.cashierposNum
			, chk.cashierperiod
			, chk.cashierdrawer
			, chk.cashier
			, chk.storeNumber
			, chk.trFuelOnlyCst
			, chk.posNum
			, chk.trSeq
			, chk.trTotNoTax
			, chk.trTotWTax
			, chk.trTotTax
			, chk.trTax
			, chk.trCurrTotlocale
			, chk.trCurrTot
			, chk.trSTotalizer
			, chk.trGTotalizer
			, chk.trLinetype
			, chk.trlTaxes
			, chk.trlFlags
			, chk.trlDeptnumber
			, chk.trlDepttype
			, chk.trlDept
			, chk.trlCatnumber
			, chk.trlCat
			, chk.trlNetwCode
			, chk.trlQty
			, chk.trlSign
			, chk.trlUnitPrice
			, chk.trlLineTot
			, chk.trlUPC
			, chk.trlDesc
			, chk.trPaylinetype
			, chk.trPaylinesysid
			, chk.trPaylinelocale
			, chk.trpPaycodemop
			, chk.trpPaycodecat
			, chk.trpPaycodenacstendercode
			, chk.trpPaycodenacstendersubcode
			, chk.trpPaycode
			, chk.trpAmt
			, @intStoreId
			, @intCheckoutId
			, 0
			, 0
		FROM #tempCheckoutInsert chk
		JOIN
		(
			SELECT c.termMsgSN as termMsgSN
			FROM #tempCheckoutInsert c
			WHERE c.trlDept = 'CIGARETTES' AND c.transtype = 'sale'
			GROUP BY c.termMsgSN
		) x ON x.termMsgSN = chk.termMsgSN
		WHERE NOT EXISTS
		(
			SELECT * 
			FROM dbo.tblSTTranslogRebates TR
			WHERE TR.dtmDate = CAST(left(REPLACE(chk.date, 'T', ' '), len(chk.date) - 6) AS DATETIME)
			AND TR.intTermMsgSN = chk.termMsgSN
			AND TR.intTrSeq = chk.trSeq
			AND TR.strTrlUPC COLLATE DATABASE_DEFAULT = chk.trlUPC COLLATE DATABASE_DEFAULT
			AND TR.strTrlDesc COLLATE DATABASE_DEFAULT = chk.trlDesc COLLATE DATABASE_DEFAULT
			AND TR.intDuration = chk.duration
			AND TR.strTrpPaycode COLLATE DATABASE_DEFAULT = chk.trpPaycode COLLATE DATABASE_DEFAULT
			AND TR.dblTrpAmt = chk.trpAmt
		)

		SET @strStatusMsg = 'Success'
	END
	ELSE IF(@intCountRows = 0)
	BEGIN
	    SET @strStatusMsg = 'XML file is already been exported'
		SET @intCountRows = 0
	END

	End Try

	Begin Catch
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	End Catch
END
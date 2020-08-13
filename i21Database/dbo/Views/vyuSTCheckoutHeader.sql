CREATE VIEW [dbo].[vyuSTCheckoutHeader]
AS
SELECT
	  chk.[intCheckoutId]
      ,chk.[intStoreId]
      ,chk.[dtmCheckoutDate]
      ,chk.[intShiftNo]
      ,chk.[strCheckoutType]
      ,chk.[strManagersName]
      ,chk.[strManagersPassword]
      ,chk.[dtmShiftDateForImport]
      ,chk.[dtmShiftClosedDate]
      ,chk.[strCheckoutCloseDate]
      ,chk.[dblProcessXMLVersion]
      ,chk.[strStatus]
      ,chk.[strRegister]
      ,chk.[intPeriod]
      ,chk.[intSet]
      ,chk.[dtmPollDate]
      ,chk.[strHHMM]
      ,chk.[strAP]
      ,chk.[dblTotalToDeposit]
      ,chk.[dblTotalDeposits]
      ,chk.[dblTotalPaidOuts]
      ,chk.[dblEnteredPaidOuts]

	  ,dblTotalPaidOutsOrig = (SELECT SUM(ISNULL(po.dblAmount, 0))
							  FROM tblSTCheckoutPaymentOptions po
							  WHERE po.intCheckoutId = chk.intCheckoutId)

      ,chk.[dblCustomerCharges]
      ,chk.[dblCustomerPayments]
      ,chk.[dblTotalSales]
      ,chk.[dblTotalTax]
      ,chk.[dblCustomerCount]
      ,chk.[dblCashOverShort]
      
	  --,chk.[strCheckoutStatus]
      ,strCheckoutStatus = CASE 
								WHEN Inv.ysnPosted = 1
									THEN 'Posted'
								ELSE chk.strCheckoutStatus
						  END

	  ,chk.[dblTotalNoSalesCount]
      ,chk.[dblFuelAdjustmentCount]
      ,chk.[dblFuelAdjustmentAmount]
      ,chk.[dblTotalRefundCount]
      ,chk.[dblTotalRefundAmount]
      
	  ,chk.[dblATMBegBalance]
    --   ,dblATMBegBalance = (
	-- 						ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceActual
	-- 						FROM tblSTCheckoutHeader _chk
	-- 						WHERE _chk.intStoreId = vst.intStoreId
	-- 							AND ((_chk.dtmCheckoutDate < chk.dtmCheckoutDate) 
	-- 							OR  (_chk.dtmCheckoutDate = chk.dtmCheckoutDate  AND _chk.intShiftNo < chk.intShiftNo))
	-- 						ORDER BY _chk.dtmCheckoutDate DESC), 0)
	-- 					)
	  
	  ,chk.[dblATMReplenished]
      ,chk.[dblATMWithdrawal]

      --,chk.[dblATMEndBalanceCalculated]
	  -- Calculate: (dblATMBegBalance - dblATMWithdrawal) + dblATMReplenished
	  ,dblATMEndBalanceCalculated = (
										(
											ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceActual
											FROM tblSTCheckoutHeader _chk
											WHERE _chk.intStoreId = vst.intStoreId
												AND ((_chk.dtmCheckoutDate < chk.dtmCheckoutDate) 
												OR  (_chk.dtmCheckoutDate = chk.dtmCheckoutDate  AND _chk.intShiftNo < chk.intShiftNo))
											ORDER BY _chk.dtmCheckoutDate DESC , _chk.intShiftNo DESC), 0)
										
											- 
										
											ISNULL(chk.dblATMWithdrawal, 0)
										) + ISNULL(chk.dblATMReplenished, 0)
									)

      ,chk.[dblATMEndBalanceActual]
      
	  --,chk.[dblATMVariance]
	  -- Calculate: dblATMEndBalanceActual - dblATMEndBalanceCalculated
	  , dblATMVariance = ISNULL(chk.dblATMEndBalanceActual, 0) - (
																	(
																		ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceActual
																		FROM tblSTCheckoutHeader _chk
																		WHERE _chk.intStoreId = vst.intStoreId
																			AND ((_chk.dtmCheckoutDate < chk.dtmCheckoutDate) 
																			OR  (_chk.dtmCheckoutDate = chk.dtmCheckoutDate  AND _chk.intShiftNo < chk.intShiftNo))
																		ORDER BY _chk.dtmCheckoutDate DESC, _chk.intShiftNo DESC), 0)
										
																		- 
										
																		ISNULL(chk.dblATMWithdrawal, 0)
																	) + ISNULL(chk.dblATMReplenished, 0)
																 )

    ,chk.[dblChangeFundBegBalance]
	  --,dblChangeFundBegBalance = (
			--						ISNULL((SELECT TOP 1 ISNULL(_chk.dblChangeFundEndBalance, 0)
			--						FROM tblSTCheckoutHeader _chk
			--						WHERE _chk.intStoreId = vst.intStoreId
			--							AND _chk.intCheckoutId < chk.intCheckoutId
			--						ORDER BY _chk.intCheckoutId DESC), 0)
			--					)

	-- ,dblChangeFundBegBalance = (
	-- 								ISNULL((SELECT TOP 1 ISNULL(_chk.dblChangeFundEndBalance, 0)
	-- 								FROM tblSTCheckoutHeader _chk
	-- 								WHERE _chk.intStoreId = vst.intStoreId
	-- 									AND ((_chk.dtmCheckoutDate < chk.dtmCheckoutDate) 
	-- 									OR  (_chk.dtmCheckoutDate = chk.dtmCheckoutDate  AND _chk.intShiftNo < chk.intShiftNo))
	-- 								ORDER BY _chk.dtmCheckoutDate DESC), 0)
	-- 							)

      --,chk.[dblChangeFundEndBalance]
      ,dblChangeFundEndBalance = (SELECT SUM(ISNULL(cf.dblValue, 0))
							      FROM tblSTCheckoutChangeFund cf
							      WHERE cf.intCheckoutId = chk.intCheckoutId)
	  
	  ,chk.[dblChangeFundChangeReplenishment]
      
	  --,chk.[dblChangeFundIncreaseDecrease]
      ,dblChangeFundIncreaseDecrease = ISNULL(
										(
							             (SELECT SUM(ISNULL(cf.dblValue, 0)) FROM tblSTCheckoutChangeFund cf WHERE cf.intCheckoutId = chk.intCheckoutId) 
										 - 
										 chk.dblChangeFundBegBalance
									    )
									,0)

	  ,chk.[intCategoryId]
      ,chk.[intCommodityId]
      ,chk.[intCountGroupId]
      ,chk.[dtmCountDate]
      ,chk.[strCountNo]
      ,chk.[intStorageLocationId]
      ,chk.[intCompanyLocationSubLocationId]
      --,chk.[intEntityId]
      ,chk.[strDescription]
      ,chk.[ysnIncludeZeroOnHand]
      ,chk.[ysnIncludeOnHand]
      ,chk.[ysnScannedCountEntry]
      ,chk.[ysnCountByLots]
      ,chk.[strCountBy]
      ,chk.[ysnCountByPallets]
      ,chk.[ysnRecountMismatch]
      ,chk.[ysnExternal]
      ,chk.[ysnRecount]
      ,chk.[intRecountReferenceId]
      ,chk.[intStatus]
      ,chk.[ysnPosted]
      ,chk.[dtmPosted]
      ,chk.[intImportFlagInternal]
      ,chk.[intLockType]
      ,chk.[intSort]
      ,chk.[intInvoiceId]
      ,chk.[strAllInvoiceIdList]
      ,chk.[strXml]
      ,chk.[strMarkUpDownBatchNo]
      ,chk.[intSalesInvoiceIntegrationLogId]
      ,chk.[intReceivePaymentsIntegrationLogId]
      ,chk.[intCheckoutCurrentProcess]

	  -- Store
	  ,vst.[intStoreNo]
	  ,vst.[strRegisterClass]
	  ,vst.[intEntityId]  
	  ,vst.[strState]
	  ,strReportDepartmentAtGrossOrNet = CASE	
											WHEN st.strReportDepartmentAtGrossOrNet = 'G'
												THEN 'Gross'
											WHEN st.strReportDepartmentAtGrossOrNet = 'N'
												THEN 'Net'
										END  COLLATE Latin1_General_CI_AS
	  ,strAllowRegisterMarkUpDown = CASE	
										WHEN st.strAllowRegisterMarkUpDown = 'I'
											THEN 'Item Price Differences'
										WHEN st.strReportDepartmentAtGrossOrNet = 'D'
											THEN 'Department Discounts'
										WHEN st.strReportDepartmentAtGrossOrNet = 'N'
											THEN 'None'
									END  COLLATE Latin1_General_CI_AS
	  ,intCompanyLocationId = st.intCompanyLocationId
	  ,strLocationName = cl.strLocationName
	  ,strSubLocationName = cls.strSubLocationName
	  ,strStorageLocation = sl.strName
	  ,strCategory = cat.strCategoryCode
	  ,strCommodity = comm.strCommodityCode
	  ,ysnInvoicePostStatus = CASE
								WHEN Inv.intInvoiceId IS NOT NULL
									THEN CAST(1 AS BIT)
								ELSE  
									CAST(0 AS BIT)
							END
	  ,ysnStoreManager = vst.ysnIsUserStoreManager
	  
      ,chk.[intConcurrencyId]  
FROM tblSTCheckoutHeader chk
INNER JOIN vyuSTStoreOnUserRole vst
	ON chk.intStoreId = vst.intStoreId
INNER JOIN tblSTStore st
	ON vst.intStoreId = st.intStoreId
INNER JOIN tblSMCompanyLocation cl
	ON st.intCompanyLocationId = cl.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation cls
	ON chk.intCompanyLocationSubLocationId = cls.intCompanyLocationSubLocationId
LEFT JOIN tblICStorageLocation sl
	ON chk.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblICCategory cat
	ON chk.intCategoryId = cat.intCategoryId
LEFT JOIN tblICCommodity comm
	ON chk.intCommodityId = comm.intCommodityId
LEFT JOIN tblARInvoice Inv
	ON chk.intInvoiceId = Inv.intInvoiceId
GROUP BY 
	  chk.[intCheckoutId]
      ,chk.[intStoreId]
      ,chk.[dtmCheckoutDate]
      ,chk.[intShiftNo]
      ,chk.[strCheckoutType]
      ,chk.[strManagersName]
      ,chk.[strManagersPassword]
      ,chk.[dtmShiftDateForImport]
      ,chk.[dtmShiftClosedDate]
      ,chk.[strCheckoutCloseDate]
      ,chk.[dblProcessXMLVersion]
      ,chk.[strStatus]
      ,chk.[strRegister]
      ,chk.[intPeriod]
      ,chk.[intSet]
      ,chk.[dtmPollDate]
      ,chk.[strHHMM]
      ,chk.[strAP]
      ,chk.[dblTotalToDeposit]
      ,chk.[dblTotalDeposits]
      ,chk.[dblTotalPaidOuts]
      ,chk.[dblEnteredPaidOuts]
      ,chk.[dblCustomerCharges]
      ,chk.[dblCustomerPayments]
      ,chk.[dblTotalSales]
      ,chk.[dblTotalTax]
      ,chk.[dblCustomerCount]
      ,chk.[dblCashOverShort]
      ,chk.[strCheckoutStatus]
      ,chk.[dblTotalNoSalesCount]
      ,chk.[dblFuelAdjustmentCount]
      ,chk.[dblFuelAdjustmentAmount]
      ,chk.[dblTotalRefundCount]
      ,chk.[dblTotalRefundAmount]
      ,chk.[dblATMBegBalance]
      ,chk.[dblATMReplenished]
      ,chk.[dblATMWithdrawal]
      ,chk.[dblATMEndBalanceCalculated]
      ,chk.[dblATMEndBalanceActual]
      ,chk.[dblATMVariance]
      ,chk.[dblChangeFundBegBalance]
      ,chk.[dblChangeFundEndBalance]
      ,chk.[dblChangeFundChangeReplenishment]
      ,chk.[dblChangeFundIncreaseDecrease]
      ,chk.[intCategoryId]
      ,chk.[intCommodityId]
      ,chk.[intCountGroupId]
      ,chk.[dtmCountDate]
      ,chk.[strCountNo]
      ,chk.[intStorageLocationId]
      ,chk.[intCompanyLocationSubLocationId]
      ,chk.[strDescription]
      ,chk.[ysnIncludeZeroOnHand]
      ,chk.[ysnIncludeOnHand]
      ,chk.[ysnScannedCountEntry]
      ,chk.[ysnCountByLots]
      ,chk.[strCountBy]
      ,chk.[ysnCountByPallets]
      ,chk.[ysnRecountMismatch]
      ,chk.[ysnExternal]
      ,chk.[ysnRecount]
      ,chk.[intRecountReferenceId]
      ,chk.[intStatus]
      ,chk.[ysnPosted]
      ,chk.[dtmPosted]
      ,chk.[intImportFlagInternal]
      ,chk.[intLockType]
      ,chk.[intSort]
      ,chk.[intInvoiceId]
      ,chk.[strAllInvoiceIdList]
      ,chk.[strXml]
      ,chk.[strMarkUpDownBatchNo]
      ,chk.[intSalesInvoiceIntegrationLogId]
      ,chk.[intReceivePaymentsIntegrationLogId]
      ,chk.[intCheckoutCurrentProcess]
      ,chk.[intConcurrencyId]
	  ,Inv.[ysnPosted]
	  ,vst.[intStoreId]
	  ,vst.[intEntityId]
	  ,vst.[intStoreNo]
	  ,vst.[strState]
	  ,vst.[strRegisterClass]
	  ,vst.[ysnIsUserStoreManager]
	  ,st.[strReportDepartmentAtGrossOrNet]
	  ,st.[strAllowRegisterMarkUpDown]
	  ,st.[intCompanyLocationId]
	  ,cl.[strLocationName]	  
	  ,cls.[strSubLocationName]
	  ,sl.[strName]
	  ,cat.[strCategoryCode]
	  ,comm.[strCommodityCode]
	  ,Inv.[intInvoiceId]
	  ,chk.intEntityId


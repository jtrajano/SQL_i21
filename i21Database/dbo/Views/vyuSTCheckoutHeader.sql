CREATE VIEW [dbo].[vyuSTCheckoutHeader]
AS
SELECT DISTINCT
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

	  ,dblTotalPaidOutsOrig = SUM(po.dblAmount) OVER()

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
      
	  --,chk.[dblATMBegBalance]
      ,dblATMBegBalance = (
							ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceCalculated
							FROM tblSTCheckoutHeader _chk
							WHERE _chk.intStoreId = vst.intStoreId
								AND _chk.intCheckoutId != chk.intCheckoutId
							ORDER BY _chk.intCheckoutId DESC), 0)
						)
	  
	  ,chk.[dblATMReplenished]
      ,chk.[dblATMWithdrawal]

      --,chk.[dblATMEndBalanceCalculated]
	  -- Calculate: (dblATMBegBalance - dblATMWithdrawal) + dblATMReplenished
	  ,dblATMEndBalanceCalculated = (
										(
											ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceCalculated
											FROM tblSTCheckoutHeader _chk
											WHERE _chk.intStoreId = vst.intStoreId
												AND _chk.intCheckoutId != chk.intCheckoutId
											ORDER BY _chk.intCheckoutId DESC), 0) 
										
											- 
										
											ISNULL(chk.dblATMWithdrawal, 0)
										) + ISNULL(chk.dblATMReplenished, 0)
									)

      ,chk.[dblATMEndBalanceActual]
      
	  --,chk.[dblATMVariance]
	  -- Calculate: dblATMEndBalanceActual - dblATMEndBalanceCalculated
	  , dblATMVariance = ISNULL(chk.dblATMEndBalanceActual, 0) - (
																	(
																		ISNULL((SELECT TOP 1 _chk.dblATMEndBalanceCalculated
																		FROM tblSTCheckoutHeader _chk
																		WHERE _chk.intStoreId = vst.intStoreId
																			AND _chk.intCheckoutId != chk.intCheckoutId
																		ORDER BY _chk.intCheckoutId DESC), 0) 
										
																		- 
										
																		ISNULL(chk.dblATMWithdrawal, 0)
																	) + ISNULL(chk.dblATMReplenished, 0)
																 )

      --,chk.[dblChangeFundBegBalance]
	  ,dblChangeFundBegBalance = (
									ISNULL((SELECT TOP 1 _chk.dblChangeFundEndBalance
									FROM tblSTCheckoutHeader _chk
									WHERE _chk.intStoreId = vst.intStoreId
										AND _chk.intCheckoutId != chk.intCheckoutId
									ORDER BY _chk.intCheckoutId DESC), 0)
								)

      --,chk.[dblChangeFundEndBalance]
      ,dblChangeFundEndBalance = SUM(ISNULL(cf.dblValue, 0)) OVER()
	  
	  ,chk.[dblChangeFundChangeReplenishment]
      
	  --,chk.[dblChangeFundIncreaseDecrease]
      ,dblChangeFundIncreaseDecrease = ISNULL(SUM(ISNULL(cf.dblValue, 0)) OVER() - chk.dblChangeFundBegBalance, 0)

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
	  ,strReportDepartmentAtGrossOrNet = CASE	
											WHEN st.strReportDepartmentAtGrossOrNet = 'G'
												THEN 'Gross'
											WHEN st.strReportDepartmentAtGrossOrNet = 'N'
												THEN 'Net'
										END
	  ,strAllowRegisterMarkUpDown = CASE	
										WHEN st.strAllowRegisterMarkUpDown = 'I'
											THEN 'Item Price Differences'
										WHEN st.strReportDepartmentAtGrossOrNet = 'D'
											THEN 'Department Discounts'
										WHEN st.strReportDepartmentAtGrossOrNet = 'N'
											THEN 'None'
									END
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
INNER JOIN tblSTCheckoutPaymentOptions po
	ON chk.intCheckoutId = po.intCheckoutId
LEFT JOIN tblSMCompanyLocationSubLocation cls
	ON chk.intCompanyLocationSubLocationId = cls.intCompanyLocationSubLocationId
LEFT JOIN tblICStorageLocation sl
	ON chk.intStorageLocationId = sl.intStorageLocationId
LEFT JOIN tblICCategory cat
	ON chk.intCategoryId = cat.intCategoryId
LEFT JOIN tblICCommodity comm
	ON chk.intCommodityId = comm.intCommodityId
LEFT JOIN tblSTCheckoutChangeFund cf
	ON chk.intCheckoutId = cf.intCheckoutId
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
      ,chk.[intConcurrencyId]
	  ,po.[dblAmount]
	  ,Inv.[ysnPosted]
	  ,vst.[intStoreId]
	  ,vst.[intEntityId]
	  ,vst.[intStoreNo]
	  ,vst.[strRegisterClass]
	  ,vst.[ysnIsUserStoreManager]
	  ,st.[strReportDepartmentAtGrossOrNet]
	  ,st.[strAllowRegisterMarkUpDown]
	  ,st.[intCompanyLocationId]
	  ,cf.[dblValue]
	  ,cl.[strLocationName]	  
	  ,cls.[strSubLocationName]
	  ,sl.[strName]
	  ,cat.[strCategoryCode]
	  ,comm.[strCommodityCode]
	  ,Inv.[intInvoiceId]


GO
	PRINT 'START OF CREATING [uspTMRecreateBudgetCalculationSiteSP] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateBudgetCalculationSiteSP]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateBudgetCalculationSiteSP
GO

CREATE PROCEDURE uspTMRecreateBudgetCalculationSiteSP 
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMGetBudgetCalculationSite]') AND type in (N'P', N'PC'))
		DROP PROCEDURE [dbo].uspTMGetBudgetCalculationSite

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricingPrice]') AND type IN (N'FN'))
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwlocmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
	)
	BEGIN
		EXEC ('
			CREATE PROCEDURE [dbo].[uspTMGetBudgetCalculationSite]  
				@ysnIncludeInvoices		BIT
				,@ysnIncludeCredits		BIT	
				,@ysnIncludeEstimatedTankInventory	BIT
				,@strCalculateBudgetFor NVARCHAR(10)
				,@intNumberOfMonthsInBudget INT
				,@dblMinimumBudgetAmount NUMERIC(18,6)
			AS
			BEGIN
	
				IF OBJECT_ID(''tempdb..#tmpStage1'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage1 END
				SELECT 
					strCustomerNumber = C.vwcus_key COLLATE Latin1_General_CI_AS 
					,strCustomerName = (CASE WHEN C.vwcus_co_per_ind_cp = ''C''   
														THEN  ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_first_name),'''') + ISNULL(RTRIM(C.vwcus_mid_init),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''')   
														ELSE    
															CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
																THEN     ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''')    
																ELSE     ISNULL(RTRIM(C.vwcus_last_name),'''') + ISNULL(RTRIM(C.vwcus_name_suffix),'''') + '', '' + ISNULL(RTRIM(C.vwcus_first_name),'''') + ISNULL(RTRIM(C.vwcus_mid_init),'''')    
															END   
													END) COLLATE Latin1_General_CI_AS 
					,strLocation = D.vwloc_loc_no  COLLATE Latin1_General_CI_AS 
					,intSiteNumber = A.intSiteNumber
					,strSiteDescription  = A.strDescription
					,strSiteAddress = A.strSiteAddress
					,dblYTDGalsThisSeason = ISNULL(HH.dblTotalGallons,0.0)
					,dblYTDGalsLastSeason = ISNULL(II.dblTotalGallons,0.0)
					,dblYTDGals2SeasonsAgo = ISNULL(JJ.dblTotalGallons,0.0)
					,dblSiteBurnRate = A.dblBurnRate
					,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
					,dblSeasonExpectedUsage = CAST((F.intProjectedDegreeDay / A.dblBurnRate) AS NUMERIC(18,6))
					,dblRequiredQuantity = CAST((CASE WHEN @strCalculateBudgetFor = ''Next Year'' AND @ysnIncludeEstimatedTankInventory = 1 
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - dblEstimatedGallonsLeft
												WHEN @strCalculateBudgetFor = ''This Year'' AND @ysnIncludeEstimatedTankInventory = 1
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - (ISNULL(HH.dblTotalGallons,0.0) - A.dblEstimatedGallonsLeft)
												WHEN @strCalculateBudgetFor = ''Next Year'' AND @ysnIncludeEstimatedTankInventory = 0
													THEN (F.intProjectedDegreeDay / A.dblBurnRate)
												WHEN @strCalculateBudgetFor = ''This Year'' AND @ysnIncludeEstimatedTankInventory = 0
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - ISNULL(HH.dblTotalGallons,0.0)
												ELSE 0
												END) AS NUMERIC(18,6))
					,dblCurrentARBalance = C.vwcus_balance
					,intSiteID = A.intSiteID
					,dblUnappliedCredits = ISNULL(C.vwcus_cred_reg,0.0)
					,intEntityCustomerId = C.A4GLIdentity
					,A.intLocationId
					,intSiteItemId = A.intProduct
					,ysnBudgetCustomers = CAST((CASE WHEN ISNULL(C.vwcus_budget_amt_due,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
					,A.intFillMethodId
					--,dblPrice = 
					--,dblEstimatedBudget = 
					,intCustomerId = A.intCustomerID
					,strItemNumber = RTRIM(E.vwitm_no) COLLATE Latin1_General_CI_AS 
					,strItemClass = RTRIM(E.vwitm_class) COLLATE Latin1_General_CI_AS 
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= G.intBeginSummerMonth AND  MONTH(GETDATE()) < G.intBeginWinterMonth THEN ISNULL(A.dblSummerDailyUse,0.0) ELSE ISNULL(A.dblWinterDailyUse,0) END)
				INTO #tmpStage1
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN vwcusmst C
					ON B.intCustomerNumber = C.A4GLIdentity
				INNER JOIN tblTMBudgetCalculationProjection F
					ON A.intClockID = F.intClockId
				INNER JOIN vwitmmst E
					ON A.intProduct = E.A4GLIdentity
				LEFT JOIN vwlocmst D
					ON A.intLocationId = D.A4GLIdentity
				LEFT JOIN tblTMClock G
					ON A.intClockID = G.intClockID
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND intCurrentSeasonYear = intSeasonYear
				)HH
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 1) = intSeasonYear
				)II
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 2) = intSeasonYear
				)JJ
	

				IF OBJECT_ID(''tempdb..#tmpStage2'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage2 END
	
				SELECT 
					A.* 
					,dblPrice = ISNULL((CASE WHEN B.intItemId IS NULL
									THEN  dbo.fnTMGetSpecialPricingPrice(
												strCustomerNumber
												,strItemNumber
												,strLocation 
												,strItemClass
												,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
												,A.dblRequiredQuantity
												,NULL
											)
									ELSE
										B.dblPrice
									END),0.0)
				INTO #tmpStage2
				FROM #tmpStage1 A
				INNER JOIN tblTMBudgetCalculationItemPricing B
					ON A.intSiteItemId = B.intItemId


				IF OBJECT_ID(''tempdb..#tmpStage3'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage3 END		
				SELECT 
					*
					,dblTempEstimatedBudget = (CASE WHEN @ysnIncludeCredits = 0 AND @ysnIncludeInvoices = 0
													THEN ROUND((dblRequiredQuantity * dblPrice / @intNumberOfMonthsInBudget),0)
												WHEN @ysnIncludeCredits = 1 AND @ysnIncludeInvoices = 0
													THEN ROUND((((dblRequiredQuantity * dblPrice) - dblUnappliedCredits) / @intNumberOfMonthsInBudget),0) 
												WHEN @ysnIncludeCredits = 1 AND @ysnIncludeInvoices = 1
													THEN ROUND((((dblRequiredQuantity * dblPrice) + dblCurrentARBalance) / @intNumberOfMonthsInBudget),0) 
												WHEN @ysnIncludeCredits = 0 AND @ysnIncludeInvoices = 1
													THEN ROUND((((dblRequiredQuantity * dblPrice) + dblCurrentARBalance + dblUnappliedCredits) / @intNumberOfMonthsInBudget),0)
											END)
				INTO #tmpStage3
				FROM #tmpStage2
	
				SELECT 
					*
					,dblEstimatedBudget = (CASE WHEN dblTempEstimatedBudget < @dblMinimumBudgetAmount 
												THEN @dblMinimumBudgetAmount
												ELSE dblTempEstimatedBudget
											END)	
				FROM #tmpStage3	
			END

			
		')
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE PROCEDURE [dbo].[uspTMGetBudgetCalculationSite]  
				@ysnIncludeInvoices		BIT
				,@ysnIncludeCredits		BIT	
				,@ysnIncludeEstimatedTankInventory	BIT
				,@strCalculateBudgetFor NVARCHAR(10)
				,@intNumberOfMonthsInBudget INT
				,@dblMinimumBudgetAmount NUMERIC(18,6)
			AS
			BEGIN
	
				--DECLARE @ysnIncludeInvoices		BIT
				--DECLARE @ysnIncludeCredits		BIT	
				--DECLARE @ysnIncludeEstimatedTankInventory	BIT
				--DECLARE @strCalculateBudgetFor NVARCHAR(10)
				--DECLARE @intNumberOfMonthsInBudget INT
				--DECLARE @dblMinimumBudgetAmount NUMERIC(18,6)
	
				--DECLARE @ysnIncludeNonBudgetCustomer BIT
				--DECLARE @intLocationId INT
				--DECLARE @intFillMethod INT
				--DECLARE @intCustomerId INT
	
	
				--SET @ysnIncludeInvoices = 1
				--SET @ysnIncludeCredits = 1
				--SET @ysnIncludeEstimatedTankInventory = 1
				--SET @strCalculateBudgetFor = 1
				--SET @intNumberOfMonthsInBudget = 1
				--SET @dblMinimumBudgetAmount = 1
	
				--SET @ysnIncludeNonBudgetCustomer = 1
				--SET @intLocationId = 1
				--SET @intFillMethod = 1
				--SET @intCustomerId = 1
	
				IF OBJECT_ID(''tempdb..#tmpStage1'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage1 END

				SELECT 
					strCustomerNumber = C.strEntityNo
					,strCustomerName = C.strName
					,strLocation = D.strLocationName 
					,intSiteNumber = A.intSiteNumber
					,strSiteDescription  = A.strDescription
					,strSiteAddress = A.strSiteAddress
					,dblYTDGalsThisSeason = ISNULL(HH.dblTotalGallons,0.0)
					,dblYTDGalsLastSeason = ISNULL(II.dblTotalGallons,0.0)
					,dblYTDGals2SeasonsAgo = ISNULL(JJ.dblTotalGallons,0.0)
					,dblSiteBurnRate = A.dblBurnRate
					,dblSiteEstimatedGallonsLeft = A.dblEstimatedGallonsLeft
					,dblSeasonExpectedUsage = CAST((F.intProjectedDegreeDay / A.dblBurnRate) AS NUMERIC(18,6))
					,dblRequiredQuantity = CAST((CASE WHEN @strCalculateBudgetFor = ''Next Year'' AND @ysnIncludeEstimatedTankInventory = 1 
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - dblEstimatedGallonsLeft
												WHEN @strCalculateBudgetFor = ''This Year'' AND @ysnIncludeEstimatedTankInventory = 1
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - (ISNULL(HH.dblTotalGallons,0.0) - A.dblEstimatedGallonsLeft)
												WHEN @strCalculateBudgetFor = ''Next Year'' AND @ysnIncludeEstimatedTankInventory = 0
													THEN (F.intProjectedDegreeDay / A.dblBurnRate)
												WHEN @strCalculateBudgetFor = ''This Year'' AND @ysnIncludeEstimatedTankInventory = 0
													THEN (F.intProjectedDegreeDay / A.dblBurnRate) - ISNULL(HH.dblTotalGallons,0.0)
												ELSE 0
												END) AS NUMERIC(18,6))
					,dblCurrentARBalance = CAST((ISNULL(G.dbl10Days,0.0) + ISNULL(G.dbl30Days,0.0) + ISNULL(G.dbl60Days,0.0) + ISNULL(G.dbl90Days,0.0) + ISNULL(G.dbl91Days,0.0) + ISNULL(G.dblFuture,0.0) - ISNULL(G.dblUnappliedCredits,0.0)) AS NUMERIC(18,6))
					,intSiteID = A.intSiteID
					,dblUnappliedCredits = ISNULL(G.dblUnappliedCredits,0.0)
					,intEntityCustomerId = C.intEntityId
					,A.intLocationId
					,intSiteItemId = A.intProduct
					,ysnBudgetCustomers = CAST((CASE WHEN ISNULL(G.dblTotalDue,0.0) > 0 THEN 1 ELSE 0 END) AS BIT)
					,A.intFillMethodId
					--,dblPrice = 
					--,dblEstimatedBudget = 
					,intCustomerId = A.intCustomerID
					,dblDailyUse = (CASE WHEN MONTH(GETDATE()) >= E.intBeginSummerMonth AND  MONTH(GETDATE()) < E.intBeginWinterMonth THEN ISNULL(A.dblSummerDailyUse,0.0) ELSE ISNULL(A.dblWinterDailyUse,0) END)
				INTO #tmpStage1
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN tblEMEntity C
					ON B.intCustomerNumber = C.intEntityId
				INNER JOIN tblTMBudgetCalculationProjection F
					ON A.intClockID = F.intClockId
				LEFT JOIN vyuARCustomerInquiryReport G
					ON C.intEntityId = G.intEntityCustomerId
				LEFT JOIN tblSMCompanyLocation D
					ON A.intLocationId = D.intCompanyLocationId
				LEFT JOIN tblTMClock E
					ON A.intClockID = E.intClockID
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND intCurrentSeasonYear = intSeasonYear
				)HH
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 1) = intSeasonYear
				)II
				OUTER APPLY (
					SELECT TOP 1 dblTotalGallons = SUM(dblTotalGallons) FROM vyuTMSiteDeliveryHistoryTotal 
					WHERE intSiteId = A.intSiteID
						AND (intCurrentSeasonYear - 2) = intSeasonYear
				)JJ

				IF OBJECT_ID(''tempdb..#tmpStage2'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage2 END
	
				SELECT 
					A.* 
					,dblPrice = ISNULL((CASE WHEN B.intItemId IS NULL
									THEN  dbo.fnARGetItemPrice(
												A.intSiteItemId --@ItemId 				
											,A.intEntityCustomerId	--@CustomerId	
											,A.intLocationId	--@LocationId		
											,NULL	--@ItemUOMId		
											,NULL	--@CurrencyId	 
											,DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)	 --@TransactionDate	
											,A.dblRequiredQuantity	--@Quantity			
											,NULL --@ContractHeaderId		
											,NULL --@ContractDetailId		
											,NULL --@ContractNumber		
											,NULL --@ContractSeq			
											,NULL --@OriginalQuantity		
											,NULL --@CustomerPricingOnly
											,NULL --@ItemPricingOnly
											,NULL --@ExcludeContractPricing	
											,NULL --@VendorId			
											,NULL --@SupplyPointId		
											,NULL --@LastCost			
											,NULL --@ShipToLocationId  
											,NULL --@VendorLocationId
											,NULL --@InvoiceType
											,0	  --@GetAllAvailablePricing
											,(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference )
											)
									ELSE
										B.dblPrice
									END),0.0)
				INTO #tmpStage2
				FROM #tmpStage1 A
				INNER JOIN tblTMBudgetCalculationItemPricing B
					ON A.intSiteItemId = B.intItemId


				IF OBJECT_ID(''tempdb..#tmpStage3'') IS NOT NULL 
				BEGIN DROP TABLE #tmpStage3 END		
				SELECT 
					*
					,dblTempEstimatedBudget = (CASE WHEN @ysnIncludeCredits = 0 AND @ysnIncludeInvoices = 0
													THEN ROUND((dblRequiredQuantity * dblPrice / @intNumberOfMonthsInBudget),0)
												WHEN @ysnIncludeCredits = 1 AND @ysnIncludeInvoices = 0
													THEN ROUND((((dblRequiredQuantity * dblPrice) - dblUnappliedCredits) / @intNumberOfMonthsInBudget),0) 
												WHEN @ysnIncludeCredits = 0 AND @ysnIncludeInvoices = 1
													THEN ROUND((((dblRequiredQuantity * dblPrice) + dblCurrentARBalance) / @intNumberOfMonthsInBudget),0) 
												WHEN @ysnIncludeCredits = 1 AND @ysnIncludeInvoices = 1
													THEN ROUND((((dblRequiredQuantity * dblPrice) + dblCurrentARBalance - dblUnappliedCredits) / @intNumberOfMonthsInBudget),0)
											END)
											+ (CASE WHEN @strCalculateBudgetFor = ''Next Year''
											THEN
												(365 * dblDailyUse)
											ELSE
												(30 * ISNULL(@intNumberOfMonthsInBudget,0) * dblDailyUse)
											END
								)
				INTO #tmpStage3
				FROM #tmpStage2
	
				SELECT 
					*
					,dblEstimatedBudget = (CASE WHEN dblTempEstimatedBudget < @dblMinimumBudgetAmount 
												THEN @dblMinimumBudgetAmount
												ELSE dblTempEstimatedBudget
											END)	
				FROM #tmpStage3	
			END

		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateBudgetCalculationSiteSP] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateBudgetCalculationSiteSP'
GO 
	EXEC ('uspTMRecreateBudgetCalculationSiteSP')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateBudgetCalculationSiteSP'
GO

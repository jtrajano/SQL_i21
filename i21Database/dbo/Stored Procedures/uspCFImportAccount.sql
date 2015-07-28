
CREATE PROCEDURE [dbo].[uspCFImportAccount]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--================================================
		--     ONE TIME ACCOUNT SYNCHRONIZATION	
		--================================================
		TRUNCATE TABLE tblCFAccountFailedImport
		TRUNCATE TABLE tblCFAccountSuccessImport
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time ACCOUNT Synchronization'

		DECLARE @originCustomer NVARCHAR(50)

		DECLARE @Counter						INT = 0
		DECLARE @intAccountId					INT
		DECLARE @intCustomerId					INT
		DECLARE @intDiscountDays				INT
		DECLARE @intDiscountScheduleId			INT
		DECLARE @intInvoiceCycle				INT
		DECLARE @intSalesPersonId				INT
		DECLARE @dtmBonusCommissionDate			DATETIME
		DECLARE @dblBonusCommissionRate			NUMERIC(18, 6)
		DECLARE @dblRegularCommissionRate		NUMERIC(18, 6)
		DECLARE @ysnPrintTimeOnInvoices			BIT
		DECLARE @ysnPrintTimeOnReports			BIT
		DECLARE @intTermsCode					INT
		DECLARE @strBillingSite					NVARCHAR(250)
		DECLARE @strPrimarySortOptions			NVARCHAR(250)
		DECLARE @strSecondarySortOptions		NVARCHAR(250)
		DECLARE @ysnSummaryByCard				BIT
		DECLARE @ysnSummaryByVehicle			BIT
		DECLARE @ysnSummaryByMiscellaneous		BIT
		DECLARE @ysnSummaryByProduct			BIT
		DECLARE @ysnSummaryByDepartment			BIT
		DECLARE @ysnVehicleRequire				BIT
		DECLARE @intAccountStatusCodeId			INT
		DECLARE @strPrintRemittancePage			NVARCHAR(250)
		DECLARE @strInvoiceProgramName			NVARCHAR(250)
		DECLARE @intPriceRuleGroup				INT
		DECLARE @strPrintPricePerGallon			NVARCHAR(250)
		DECLARE @ysnPPTransferCostForRemote		BIT
		DECLARE @ysnPPTransferCostForNetwork	BIT
		DECLARE @ysnPrintMiscellaneous			BIT
		DECLARE @intFeeProfileId				INT
		DECLARE @strPrintSiteAddress			NVARCHAR(250)
		DECLARE @dtmLastBillingCycleDate		DATETIME
		DECLARE @intRemotePriceProfileId		INT
		DECLARE @intExtRemotePriceProfileId		INT
		DECLARE @intLocalPriceProfileId			INT
		DECLARE @intCreatedUserId				INT
		DECLARE @dtmCreated						DATETIME
		DECLARE @intLastModifiedUserId			int
		DECLARE @dtmLastModified				DATETIME
    
		--Import only those are not yet imported
		SELECT cfact_cus_no INTO #tmpcfactmst 
			FROM cfactmst
				WHERE cfact_cus_no COLLATE Latin1_General_CI_AS IN ( select strCustomerNumber from tblARCustomer) 
				AND cfact_cus_no COLLATE Latin1_General_CI_AS NOT IN (  select strCustomerNumber 
																	from tblCFAccount cfAcct
																	INNER JOIN tblARCustomer arAcct
																	on cfAcct.intCustomerId = arAcct.intEntityCustomerId) 

		WHILE (EXISTS(SELECT 1 FROM #tmpcfactmst))
		BEGIN
				
			--=============================--
			--       REQUIRED FIELDS	   --
			--							   --
			-- 1. intCustomerId            --
			-- 2. intInvoiceCycle          --
			-- 3. intDiscountScheduleId    --
			-- 4. intSalesPersonId         --
			-- 5. intTermsCode             --
			-- 6. intAccountStatusCodeId   --
			--=============================--

			SELECT @originCustomer = cfact_cus_no FROM #tmpcfactmst
			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1

					--Tracking Fields--
					@intCreatedUserId = 0,		
					@dtmCreated = CONVERT(VARCHAR(10), GETDATE(), 120),				
					@intLastModifiedUserId = 0,
					@dtmLastModified = CONVERT(VARCHAR(10), GETDATE(), 120),
					--Tracking Fields--

					@intCustomerId = (SELECT intEntityCustomerId 
									  FROM tblARCustomer 
									  WHERE strCustomerNumber = RTRIM(LTRIM(cfact_cus_no)) COLLATE Latin1_General_CI_AS),

					@intInvoiceCycle = (SELECT intInvoiceCycleId 
										FROM tblCFInvoiceCycle 
										WHERE strInvoiceCycle = RTRIM(LTRIM(cfact_ivc_cyc)) COLLATE Latin1_General_CI_AS),

					@intDiscountScheduleId = (SELECT intDiscountScheduleId 
											  FROM tblCFDiscountSchedule 
											  WHERE strDiscountSchedule = RTRIM(LTRIM(cfact_dsc_schd)) COLLATE Latin1_General_CI_AS),

					@intSalesPersonId = (SELECT intEntitySalespersonId 
										 FROM tblARSalesperson 
										 WHERE strSalespersonId = RTRIM(LTRIM(cfact_sls_id)) COLLATE Latin1_General_CI_AS),

					@intTermsCode = (SELECT intTermID 
									 FROM tblSMTerm 
									 WHERE strTerm = RTRIM(LTRIM(cfact_terms)) COLLATE Latin1_General_CI_AS),

					@intAccountStatusCodeId = (SELECT intAccountStatusId 
											FROM tblARAccountStatus 
											WHERE strAccountStatusCode = RTRIM(LTRIM(cfact_acct_stat)) COLLATE Latin1_General_CI_AS),

					@intRemotePriceProfileId = ISNULL((SELECT intPriceProfileHeaderId 
												FROM tblCFPriceProfileHeader 
												WHERE strPriceProfile = RTRIM(LTRIM(cfact_rmt_prc_prf_id)) COLLATE Latin1_General_CI_AS
												AND strType = 'Remote'),0),

					@intExtRemotePriceProfileId = ISNULL((SELECT intPriceProfileHeaderId 
												   FROM tblCFPriceProfileHeader 
												   WHERE strPriceProfile = RTRIM(LTRIM(cfact_ext_rmt_prc_prf_id)) COLLATE Latin1_General_CI_AS
												   AND strType = 'Extended Remote'),0),

					@intLocalPriceProfileId = ISNULL((SELECT intPriceProfileHeaderId 
												FROM tblCFPriceProfileHeader 
												WHERE strPriceProfile = RTRIM(LTRIM(cfact_local_prc_prf_id)) COLLATE Latin1_General_CI_AS
												AND strType = 'Local/Network'),0),

					@intDiscountDays = ISNULL(cfact_dsc_days,0),
					@dblBonusCommissionRate = ISNULL(cfact_bonus_comm_rt,0),
					@dblRegularCommissionRate = ISNULL(cfact_reg_comm_rt,0),
					@dtmBonusCommissionDate = (case
												when LEN(RTRIM(LTRIM(ISNULL(cfact_bonus_comm_dt,0)))) = 8 
												then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfact_bonus_comm_dt)),1,4) 
													+ '/' + SUBSTRING (RTRIM(LTRIM(cfact_bonus_comm_dt)),5,2) + '/' 
													+ SUBSTRING (RTRIM(LTRIM(cfact_bonus_comm_dt)),7,2), 120)
												else NULL
											  end),
					@strBillingSite = RTRIM(LTRIM(cfact_billing_site)),
					@ysnPrintTimeOnInvoices = (case
												when RTRIM(LTRIM(cfact_prt_time_invoices_yn)) = 'N' then 'FALSE'
												when RTRIM(LTRIM(cfact_prt_time_invoices_yn)) = 'Y' then 'TRUE'
												else 'FALSE'
											  end),
					@ysnPrintTimeOnReports = (case
												when RTRIM(LTRIM(cfact_prt_time_reports_yn)) = 'N' then 'FALSE'
												when RTRIM(LTRIM(cfact_prt_time_reports_yn)) = 'Y' then 'TRUE'
												else 'FALSE'
												end),
					@strPrimarySortOptions = (case
												when RTRIM(LTRIM(cfact_prmry_sort_opt)) = 'C' then 'Card'
												when RTRIM(LTRIM(cfact_prmry_sort_opt)) = 'V' then 'Vehicle'
												when RTRIM(LTRIM(cfact_prmry_sort_opt)) = 'M' then 'Miscellaneous'
												when RTRIM(LTRIM(cfact_prmry_sort_opt)) = 'D' then 'Department'
												else NULL
											  end),
					@strSecondarySortOptions = (case
												when RTRIM(LTRIM(cfact_scndry_sort_opt)) = 'C' then 'Card'
												when RTRIM(LTRIM(cfact_scndry_sort_opt)) = 'V' then 'Vehicle'
												when RTRIM(LTRIM(cfact_scndry_sort_opt)) = 'M' then 'Miscellaneous'
												when RTRIM(LTRIM(cfact_scndry_sort_opt)) = 'D' then 'Department'
												else NULL
											  end),
					@ysnSummaryByCard = (case
											when RTRIM(LTRIM(cfact_summary_card_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_summary_card_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@ysnSummaryByVehicle = (case
											when RTRIM(LTRIM(cfact_summary_vehl_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_summary_vehl_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@ysnSummaryByDepartment = (case
											when RTRIM(LTRIM(cfact_summary_dept_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_summary_dept_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@ysnSummaryByMiscellaneous = (case
											when RTRIM(LTRIM(cfact_summary_misc_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_summary_misc_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@ysnSummaryByProduct = (case
											when RTRIM(LTRIM(cfact_summary_prod_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_summary_prod_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@ysnVehicleRequire = (case
											when RTRIM(LTRIM(cfact_require_vehl_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_require_vehl_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
										end),
					@strPrintRemittancePage = (case
											when RTRIM(LTRIM(cfact_pr_remit_pg)) = 'N' then 'NO'
											when RTRIM(LTRIM(cfact_pr_remit_pg)) = 'C' then 'Yes with company address'
											when RTRIM(LTRIM(cfact_pr_remit_pg)) = 'X' then 'Yes with no address'
											when RTRIM(LTRIM(cfact_pr_remit_pg)) = 'L' then 'Yes with location address'
											else NULL
										end),
					@strInvoiceProgramName = RTRIM(LTRIM(cfact_ivc_pgm_name)),
					@intPriceRuleGroup = (SELECT intPriceRuleGroupId 
									 FROM tblCFPriceRuleGroup 
									 WHERE strPriceGroup = RTRIM(LTRIM(cfact_price_rule_set)) COLLATE Latin1_General_CI_AS),
					@strPrintPricePerGallon = (case
											when RTRIM(LTRIM(cfact_ivc_prt_prc_wtax_yn)) = 'Y' then 'Including Taxes'
											when RTRIM(LTRIM(cfact_ivc_prt_prc_wtax_yn)) = 'S' then 'Excluding SST Tax'
											when RTRIM(LTRIM(cfact_ivc_prt_prc_wtax_yn)) = 'N' then 'Excluding Taxes'
											else NULL
										end),
					@ysnPrintMiscellaneous = (case
											when RTRIM(LTRIM(cfact_print_misc_auth_yn)) = 'N' then 'FALSE'
											when RTRIM(LTRIM(cfact_print_misc_auth_yn)) = 'Y' then 'TRUE'
											else 'FALSE'
											end),
					@intFeeProfileId = ISNULL((SELECT intFeeProfileId 
												FROM tblCFFeeProfile 
												WHERE strFeeProfileId = RTRIM(LTRIM(cfact_fee_prf_id)) COLLATE Latin1_General_CI_AS),0),
					@strPrintSiteAddress = (case
											when RTRIM(LTRIM(cfact_print_site_addr)) = 'N' then 'None'
											when RTRIM(LTRIM(cfact_print_site_addr)) = 'R' then 'Remote'
											when RTRIM(LTRIM(cfact_print_site_addr)) = 'A' then 'All'
											else NULL
										end),
					@dtmLastBillingCycleDate = (case
											when LEN(RTRIM(LTRIM(ISNULL(cfact_last_bill_cyc_dt,0)))) = 8 
											then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfact_last_bill_cyc_dt)),1,4) 
												+ '/' + SUBSTRING (RTRIM(LTRIM(cfact_last_bill_cyc_dt)),5,2) + '/' 
												+ SUBSTRING (RTRIM(LTRIM(cfact_last_bill_cyc_dt)),7,2), 120)
											else NULL
										end)
										

				FROM cfactmst
				WHERE cfact_cus_no = @originCustomer
					
		--INSERT into Customer
				INSERT [dbo].[tblCFAccount](		
					[intCustomerId]					
					,[intDiscountDays]				
					,[intDiscountScheduleId]			
					,[intInvoiceCycle]				
					,[intSalesPersonId]				
					,[dtmBonusCommissionDate]			
					,[dblBonusCommissionRate]			
					,[dblRegularCommissionRate]		
					,[ysnPrintTimeOnInvoices]			
					,[ysnPrintTimeOnReports]			
					,[intTermsCode]					
					,[strBillingSite]					
					,[strPrimarySortOptions]			
					,[strSecondarySortOptions]		
					,[ysnSummaryByCard]				
					,[ysnSummaryByVehicle]			
					,[ysnSummaryByMiscellaneous]		
					,[ysnSummaryByProduct]
					,[ysnSummaryByDepartment]	
					,[ysnVehicleRequire]
					,[intAccountStatusCodeId]
					,[strPrintRemittancePage]	
					,[strInvoiceProgramName]
					,[intPriceRuleGroup]
					,[strPrintPricePerGallon]	
					,[ysnPPTransferCostForRemote]	
					,[ysnPPTransferCostForNetwork]
					,[ysnPrintMiscellaneous]
					,[intFeeProfileId]
					,[strPrintSiteAddress]
					,[dtmLastBillingCycleDate]
					,[intRemotePriceProfileId]
					,[intExtRemotePriceProfileId]	
					,[intLocalPriceProfileId]	
					,[intCreatedUserId]
					,[dtmCreated]	
					,[intLastModifiedUserId]
					,[dtmLastModified])
				VALUES						
					(@intCustomerId				
					,@intDiscountDays			
					,@intDiscountScheduleId		
					,@intInvoiceCycle			
					,@intSalesPersonId			
					,@dtmBonusCommissionDate		
					,@dblBonusCommissionRate		
					,@dblRegularCommissionRate	
					,@ysnPrintTimeOnInvoices		
					,@ysnPrintTimeOnReports		
					,@intTermsCode				
					,@strBillingSite				
					,@strPrimarySortOptions		
					,@strSecondarySortOptions	
					,@ysnSummaryByCard			
					,@ysnSummaryByVehicle		
					,@ysnSummaryByMiscellaneous	
					,@ysnSummaryByProduct		
					,@ysnSummaryByDepartment		
					,@ysnVehicleRequire			
					,@intAccountStatusCodeId		
					,@strPrintRemittancePage		
					,@strInvoiceProgramName		
					,@intPriceRuleGroup			
					,@strPrintPricePerGallon		
					,@ysnPPTransferCostForRemote	
					,@ysnPPTransferCostForNetwork
					,@ysnPrintMiscellaneous		
					,@intFeeProfileId			
					,@strPrintSiteAddress		
					,@dtmLastBillingCycleDate	
					,@intRemotePriceProfileId	
					,@intExtRemotePriceProfileId	
					,@intLocalPriceProfileId		
					,@intCreatedUserId			
					,@dtmCreated					
					,@intLastModifiedUserId		
					,@dtmLastModified)
				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				INSERT INTO tblCFAccountSuccessImport(strAccountNumber)					
				VALUES(@originCustomer)			
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				INSERT INTO tblCFAccountFailedImport(strAccountNumber,strReason)					
				VALUES(@originCustomer,ERROR_MESSAGE())					
				--PRINT 'Failed to imports' + @originCustomer; --@@ERROR;
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originCustomer
			DELETE FROM #tmpcfactmst WHERE cfact_cus_no = @originCustomer
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END
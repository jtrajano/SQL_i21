
CREATE PROCEDURE [dbo].[uspCFImportAccount]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--================================================
		--     ONE TIME ACCOUNT SYNCHRONIZATION	
		--================================================

		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time ACCOUNT Synchronization'

		DECLARE @originCustomer					NVARCHAR(50)
		DECLARE @Counter						INT = 0
		DECLARE @MasterPk						INT

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


		--========================--
		--    DETAIL DEPARTMENT   --
		--========================--
		--DECLARE @originDepartment				NVARCHAR(50)
		--DECLARE @strDepartment					NVARCHAR(500)
		--DECLARE @strDepartmentDescription		NVARCHAR(500)


		--========================--
		--    DETAIL VEHICLE      --
		--========================--
		DECLARE @originVehicle							NVARCHAR(500)
		DECLARE @strVehicleVehicleNumber				NVARCHAR(500)
		DECLARE @strVehicleCustomerUnitNumber			NVARCHAR(500)
		DECLARE @strVehicleVehicleDescription			NVARCHAR(500)
		DECLARE @intVehicleDaysBetweenService			INT
		DECLARE @intVehicleMilesBetweenService			INT
		DECLARE @intVehicleLastReminderOdometer			INT
		DECLARE @dtmVehicleLastReminderDate				DATETIME
		DECLARE @dtmVehicleLastServiceDate				DATETIME
		DECLARE @intVehicleLastServiceOdometer			INT
		DECLARE @strVehicleNoticeMessageLine1			NVARCHAR(500)
		DECLARE @strVehicleNoticeMessageLine2			NVARCHAR(500)
		DECLARE @strVehicleVehicleForOwnUse				NVARCHAR(500)
		DECLARE @intVehicleExpenseItemId				INT
		DECLARE @strVehicleLicencePlateNumber			NVARCHAR(500)
		DECLARE @strVehicleDepartment					NVARCHAR(500)
		DECLARE @intVehicleCreatedUserId				INT
		DECLARE @dtmVehicleCreated						DATETIME
		DECLARE @intVehicleLastModifiedUserId			INT
		DECLARE @dtmVehicleLastModified					DATETIME
		DECLARE @ysnVehicleCardForOwnUse				BIT


		--============================--
		--    DETAIL MISCELLANEOUS    --
		--============================--
		--DECLARE @originMiscellaneous					NVARCHAR(500)
		--DECLARE @strMiscellaneous					    NVARCHAR(500)
		--DECLARE @strMiscellaneousDescription		    NVARCHAR(500)


		--============================--
		--    DETAIL PURCHASE ORDER   --
		--============================--
		--DECLARE @dtmPurchaseOrderExpirationDate			DATETIME
		--DECLARE @strPurchaseOrderNo						NVARCHAR(500)


		--===================--
		--    DETAIL CARDS   --
		--===================--
		--DECLARE @intCardNetworkId							INT
		--DECLARE @strCardCardNumber							NVARCHAR(500)
		--DECLARE @strCardCardDescription						NVARCHAR(500)
		--DECLARE @strCardCardForOwnUse						NVARCHAR(500)
		--DECLARE @intCardExpenseItemId						INT
		--DECLARE @intCardDefaultFixVehicleNumber				INT
		--DECLARE @intCardDepartmentId						INT
		--DECLARE @dtmCardLastUsedDated						DATETIME
		--DECLARE @intCardCardTypeId							INT
		--DECLARE @dtmCardIssueDate							DATETIME
		--DECLARE @ysnCardActive								BIT
		--DECLARE @ysnCardCardLocked							BIT
		--DECLARE @strCardCardPinNumber						NVARCHAR(500)
		--DECLARE @dtmCardCardExpiratioYearMonth				DATETIME
		--DECLARE @strCardCardValidationCode					NVARCHAR(500)
		--DECLARE @intCardNumberOfCardsIssued					INT
		--DECLARE @intCardCardLimitedCode						INT
		--DECLARE @intCardCardFuelCode						INT
		--DECLARE @strCardCardTierCode						NVARCHAR(500)
		--DECLARE @strCardCardOdometerCode					NVARCHAR(500)
		--DECLARE @strCardCardWCCode							NVARCHAR(500)
		--DECLARE @strCardSplitNumber							NVARCHAR(500)
		--DECLARE @intCardCardManCode							INT
		--DECLARE @intCardCardShipCat							INT
		--DECLARE @intCardCardProfileNumber					INT
		--DECLARE @intCardCardPositionSite					INT
		--DECLARE @intCardCardvehicleControl					INT
		--DECLARE @intCardCardCustomPin						INT
		--DECLARE @intCardCreatedUserId						INT
		--DECLARE @dtmCardCreated								DATETIME
		--DECLARE @intCardLastModifiedUserId					INT
		--DECLARE @dtmCardLastModified						DATETIME
		--DECLARE @ysnCardCardForOwnUse						BIT
		--DECLARE @ysnCardIgnoreCardTransaction				BIT
    

		--=============================--
				--		INSERT INTO ACCOUNT    --
				--        REQUIRED FIELDS	   --
				--							   --
				-- 1. intCustomerId            --
				-- 2. intInvoiceCycle          --
				-- 3. intDiscountScheduleId    --
				-- 4. intSalesPersonId         --
				-- 5. intTermsCode             --
				-- 6. intAccountStatusCodeId   --
				--							   --
		--Import only those are not yet imported
		SELECT cfact_cus_no INTO #tmpcfactmst 
			FROM cfactmst
				WHERE cfact_cus_no COLLATE Latin1_General_CI_AS IN ( select strCustomerNumber from tblARCustomer) 
				AND cfact_cus_no COLLATE Latin1_General_CI_AS NOT IN (  select strCustomerNumber 
																	from tblCFAccount cfAcct
																	INNER JOIN tblARCustomer arAcct
																	on cfAcct.intCustomerId = arAcct.[intEntityId]) 

		-- DUPLICATE OR NOT IN CUSTOMERS LIST--
		INSERT INTO tblCFImportResult(
							 dtmImportDate
							,strSetupName
							,ysnSuccessful
							,strFailedReason
							,strOriginTable
							,strOriginIdentityId
							,strI21Table
							,intI21IdentityId
							,strUserId
						)
		SELECT 
		 dtmImportDate = GETDATE()
		,strSetupName = 'Account'
		,ysnSuccessful = 0
		,strFailedReason = 'Unable to find customer number on i21 Customers List'
		,strOriginTable = 'cfactmst'
		,strOriginIdentityId = cfact_cus_no
		,strI21Table = 'tblCFAccount'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfactmst
		WHERE cfact_cus_no COLLATE Latin1_General_CI_AS NOT IN ( select strCustomerNumber from tblARCustomer) 
		INSERT INTO tblCFImportResult(
							 dtmImportDate
							,strSetupName
							,ysnSuccessful
							,strFailedReason
							,strOriginTable
							,strOriginIdentityId
							,strI21Table
							,intI21IdentityId
							,strUserId
						)
		SELECT 
		 dtmImportDate = GETDATE()
		,strSetupName = 'Account'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate customer number on i21 Card Fueling accounts list'
		,strOriginTable = 'cfactmst'
		,strOriginIdentityId = cfact_cus_no
		,strI21Table = 'tblCFAccount'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cfactmst
		WHERE cfact_cus_no COLLATE Latin1_General_CI_AS IN (  select strCustomerNumber 
		from tblCFAccount cfAcct
		INNER JOIN tblARCustomer arAcct
		on cfAcct.intCustomerId = arAcct.[intEntityId]) 
		-- DUPLICATE OR NOT IN CUSTOMERS LIST--

		WHILE (EXISTS(SELECT 1 FROM #tmpcfactmst))
		BEGIN

			SELECT @originCustomer = cfact_cus_no FROM #tmpcfactmst
			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1

					--================================--
					--       INSERT MASTER RECORD     --
					--================================--

					@intCreatedUserId = 0,		
					@dtmCreated = CONVERT(VARCHAR(10), GETDATE(), 120),				
					@intLastModifiedUserId = 0,
					@dtmLastModified = CONVERT(VARCHAR(10), GETDATE(), 120),

					@intCustomerId = (SELECT TOP 1 [intEntityId] 
									  FROM tblARCustomer 
									  WHERE strCustomerNumber = RTRIM(LTRIM(cfact_cus_no)) COLLATE Latin1_General_CI_AS),

					@intInvoiceCycle = (SELECT TOP 1 intInvoiceCycleId 
										FROM tblCFInvoiceCycle 
										WHERE strInvoiceCycle = RTRIM(LTRIM(cfact_ivc_cyc)) COLLATE Latin1_General_CI_AS),

					@intDiscountScheduleId = (SELECT TOP 1 intDiscountScheduleId 
											  FROM tblCFDiscountSchedule 
											  WHERE strDiscountSchedule = RTRIM(LTRIM(cfact_dsc_schd)) COLLATE Latin1_General_CI_AS),

					@intSalesPersonId = (SELECT TOP 1 intEntitySalespersonId 
										 FROM tblARSalesperson 
										 WHERE strSalespersonId = RTRIM(LTRIM(cfact_sls_id)) COLLATE Latin1_General_CI_AS),

					@intTermsCode = (SELECT TOP 1 intTermID 
                                     FROM tblSMTerm 
                                     WHERE strTermCode = RTRIM(LTRIM(cfact_terms)) COLLATE Latin1_General_CI_AS),

					@intAccountStatusCodeId = (SELECT TOP 1 intAccountStatusId 
											FROM tblARAccountStatus 
											WHERE strAccountStatusCode = RTRIM(LTRIM(cfact_acct_stat)) COLLATE Latin1_General_CI_AS),

					@intRemotePriceProfileId = ISNULL((SELECT TOP 1 intPriceProfileHeaderId 
												FROM tblCFPriceProfileHeader 
												WHERE strPriceProfile = RTRIM(LTRIM(cfact_rmt_prc_prf_id)) COLLATE Latin1_General_CI_AS
												AND strType = 'Remote'),0),

					@intExtRemotePriceProfileId = ISNULL((SELECT TOP 1 intPriceProfileHeaderId 
												   FROM tblCFPriceProfileHeader 
												   WHERE strPriceProfile = RTRIM(LTRIM(cfact_ext_rmt_prc_prf_id)) COLLATE Latin1_General_CI_AS
												   AND strType = 'Extended Remote'),0),

					@intLocalPriceProfileId = ISNULL((SELECT TOP 1 intPriceProfileHeaderId 
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
					@intPriceRuleGroup = (SELECT TOP 1 intPriceRuleGroupId 
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
					@intFeeProfileId = (SELECT TOP 1 intFeeProfileId 
                                                FROM tblCFFeeProfile 
                                                WHERE strFeeProfileId = RTRIM(LTRIM(cfact_fee_prf_id)) COLLATE Latin1_General_CI_AS),
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
				--=============================--

				SELECT @MasterPk  = SCOPE_IDENTITY();

				----====================================--
				----		INSERT DETAIL DEPARTMENT	  --
				----			 REQUIRED FIELDS		  --
				----									  --
				----	1. intAccountId					  --
				----									  --
				--SELECT cfdpt_dept INTO #tmpcfdptmst
				--FROM cfdptmst
				--WHERE cfdpt_cus_no COLLATE Latin1_General_CI_AS = @originCustomer				
				--WHILE (EXISTS(SELECT 1 FROM #tmpcfdptmst))
				--BEGIN

				--	SELECT @originDepartment = cfdpt_dept FROM #tmpcfdptmst

				--	SELECT TOP 1
				--	 @strDepartment							= LTRIM(RTRIM(cfdpt_dept))
				--	,@strDepartmentDescription				= LTRIM(RTRIM(cfdpt_dept_desc))

				--	FROM cfdptmst
				--	WHERE cfdpt_dept = @originDepartment
					
				--	INSERT [dbo].[tblCFDepartment](
				--		[intAccountId]
				--		,[strDepartment]				
				--		,[strDepartmentDescription]
				--	)
				--	VALUES(
				--		@MasterPk
				--		,@strDepartment				
				--		,@strDepartmentDescription
				--	)
				--	DEPARTMENTLOOP:
				--	--PRINT @originDepartment
				--	DELETE FROM #tmpcfdptmst WHERE cfdpt_dept = @originDepartment
				--END
				--DROP TABLE #tmpcfdptmst
				----====================================--


				----====================================--
				----	  INSERT DETAIL MISCELLANEOUS     --
				----			 REQUIRED FIELDS		  --
				----									  --
				----	1. intAccountId					  --
				----									  --
				--SELECT cfmsc_misc INTO #tmpcfmscmst
				--FROM cfmscmst
				--WHERE cfmsc_cus_no COLLATE Latin1_General_CI_AS = @originCustomer				
				--WHILE (EXISTS(SELECT 1 FROM #tmpcfmscmst))
				--BEGIN

				--	SELECT @originMiscellaneous = cfmsc_misc FROM #tmpcfmscmst

				--	SELECT TOP 1
				--	 @strMiscellaneous							= LTRIM(RTRIM(cfmsc_misc))
				--	,@strMiscellaneousDescription				= LTRIM(RTRIM(cfmsc_misc_desc))

				--	FROM cfmscmst
				--	WHERE cfmsc_misc = @originMiscellaneous
					
				--	INSERT [dbo].[tblCFMiscellaneous](
				--		[intAccountId]
				--		,[strMiscellaneous]				
				--		,[strMiscellaneousDescription]
				--	)
				--	VALUES(
				--		@MasterPk
				--		,@strMiscellaneous				
				--		,@strMiscellaneousDescription
				--	)
				--	MISCELLANEOUSLOOP:
				--	--PRINT @originMiscellaneous
				--	DELETE FROM #tmpcfmscmst WHERE cfmsc_misc = @originMiscellaneous
				--END
				--DROP TABLE #tmpcfmscmst
				----====================================--

				--====================================--
				--		  INSERT DETAIL VEHICLE       --
				--			 REQUIRED FIELDS		  --
				--									  --
				--	1. intAccountId					  --
				--  2. intItemId					  --
				--									  --
				SELECT cfveh_vehl_no INTO #tmpcfvehmst
				FROM cfvehmst
				WHERE cfveh_ar_cus_no COLLATE Latin1_General_CI_AS = @originCustomer				
				WHILE (EXISTS(SELECT 1 FROM #tmpcfvehmst))
				BEGIN

					SELECT @originVehicle = cfveh_vehl_no FROM #tmpcfvehmst

					SELECT TOP 1
					

					@strVehicleVehicleNumber					= LTRIM(RTRIM(cfveh_vehl_no))
					,@strVehicleCustomerUnitNumber				= LTRIM(RTRIM(cfveh_cus_unit_no))
					,@strVehicleVehicleDescription				= LTRIM(RTRIM(cfveh_vehicle_desc))
					,@intVehicleDaysBetweenService				= cfveh_days_between_serv
					,@intVehicleMilesBetweenService				= cfveh_mile_between_serv
					,@intVehicleLastReminderOdometer			= cfveh_last_serv_odom
					,@dtmVehicleLastReminderDate				= (case
																	when LEN(RTRIM(LTRIM(ISNULL(cfveh_last_rmndr_date,0)))) = 8 
																	then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfveh_last_rmndr_date)),1,4) 
																		+ '/' + SUBSTRING (RTRIM(LTRIM(cfveh_last_rmndr_date)),5,2) + '/' 
																		+ SUBSTRING (RTRIM(LTRIM(cfveh_last_rmndr_date)),7,2), 120)
																	else NULL
																end) 
					,@dtmVehicleLastServiceDate					= cfveh_last_serv_rev_dt
					,@intVehicleLastServiceOdometer				= cfveh_last_serv_odom
					,@strVehicleNoticeMessageLine1				= LTRIM(RTRIM(cfveh_notice_msg1))
					,@strVehicleNoticeMessageLine2				= LTRIM(RTRIM(cfveh_notice_msg2))
					--,@strVehicleVehicleForOwnUse				= LTRIM(RTRIM(cfveh_vehl_no))

					,@intVehicleExpenseItemId					= (SELECT TOP 1 intItemId 
																   FROM tblICItem 
																   WHERE strItemNo = LTRIM(RTRIM(cfveh_exp_itm_no)) 
																   COLLATE Latin1_General_CI_AS)

					,@strVehicleLicencePlateNumber				= LTRIM(RTRIM(cfveh_lic_plate_no))
					--,@strVehicleDepartment					= LTRIM(RTRIM(cfveh_vehl_no))
					,@intVehicleCreatedUserId					= 0		
					,@dtmVehicleCreated							= CONVERT(VARCHAR(10), GETDATE(), 120)				
					,@intVehicleLastModifiedUserId				= 0
					,@dtmVehicleLastModified					= CONVERT(VARCHAR(10), GETDATE(), 120)
					,@ysnVehicleCardForOwnUse					= (case
																   when RTRIM(LTRIM(cfveh_own_use_yn)) = 'N' then 'FALSE'
																   when RTRIM(LTRIM(cfveh_own_use_yn)) = 'Y' then 'TRUE'
																   else 'FALSE'
																   end)
					FROM cfvehmst
					WHERE cfveh_vehl_no = @originVehicle

					INSERT [dbo].[tblCFVehicle](
						[intAccountId]
						,[strVehicleNumber]		
						,[strCustomerUnitNumber]	
						,[strVehicleDescription]	
						,[intDaysBetweenService]	
						,[intMilesBetweenService]	
						,[intLastReminderOdometer]	
						,[dtmLastReminderDate]		
						,[dtmLastServiceDate]		
						,[intLastServiceOdometer]	
						,[strNoticeMessageLine1]	
						,[strNoticeMessageLine2]	
						,[strVehicleForOwnUse]		
						,[intExpenseItemId]		
						,[strLicencePlateNumber]	
						,[strDepartment]			
						,[intCreatedUserId]		
						,[dtmCreated]			
						,[intLastModifiedUserId]	
						,[dtmLastModified]		
						,[ysnCardForOwnUse]		
					)
					VALUES(
						@MasterPk
						,@strVehicleVehicleNumber		
						,@strVehicleCustomerUnitNumber	
						,@strVehicleVehicleDescription	
						,@intVehicleDaysBetweenService	
						,@intVehicleMilesBetweenService	
						,@intVehicleLastReminderOdometer	
						,@dtmVehicleLastReminderDate		
						,@dtmVehicleLastServiceDate		
						,@intVehicleLastServiceOdometer	
						,@strVehicleNoticeMessageLine1	
						,@strVehicleNoticeMessageLine2	
						,@strVehicleVehicleForOwnUse		
						,@intVehicleExpenseItemId		
						,@strVehicleLicencePlateNumber	
						,@strVehicleDepartment			
						,@intVehicleCreatedUserId		
						,@dtmVehicleCreated				
						,@intVehicleLastModifiedUserId	
						,@dtmVehicleLastModified			
						,@ysnVehicleCardForOwnUse		
					)
					VEHICLELOOP:
					--PRINT @originVehicle
					DELETE FROM #tmpcfvehmst WHERE cfveh_vehl_no = @originVehicle
				END
				DROP TABLE #tmpcfvehmst
				----====================================--

				COMMIT TRANSACTION
				SET @TotalSuccess += 1;	

				INSERT INTO tblCFImportResult(
					 dtmImportDate
					,strSetupName
					,ysnSuccessful
					,strFailedReason
					,strOriginTable
					,strOriginIdentityId
					,strI21Table
					,intI21IdentityId
					,strUserId
				)
				VALUES(
					GETDATE()
				   ,'Account'
				   ,1
				   ,''
				   ,'cfactmst'
				   ,@originCustomer
				   ,'tblCFAccount'
				   ,@MasterPk
				   ,''
				)

			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION

				INSERT INTO tblCFImportResult(
					 dtmImportDate
					,strSetupName
					,ysnSuccessful
					,strFailedReason
					,strOriginTable
					,strOriginIdentityId
					,strI21Table
					,intI21IdentityId
					,strUserId
				)
				VALUES(
					GETDATE()
				   ,'Account'
				   ,0
				   ,ERROR_MESSAGE()
				   ,'cfactmst'
				   ,@originCustomer
				   ,'tblCFAccount'
				   ,null
				   ,''
				)
									
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				--PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			--PRINT @originCustomer
			DELETE FROM #tmpcfactmst WHERE cfact_cus_no = @originCustomer
		
			SET @Counter += 1;

		END

		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cfactmst
		PRINT @TotalFailed

		

	
		--SET @Total = @Counter

	END
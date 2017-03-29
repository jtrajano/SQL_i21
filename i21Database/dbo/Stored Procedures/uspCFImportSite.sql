
	CREATE PROCEDURE [dbo].[uspCFImportSite]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--============================================--
		--     ONE TIME SITE SYNCHRONIZATION	  --
		--============================================--
		
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time SITE Synchronization'

		DECLARE @originSite								NVARCHAR(50)

		DECLARE @Counter								INT = 0

		DECLARE @strSite								NVARCHAR(MAX)	
		DECLARE @intNetworkId							INT
		DECLARE @strSiteNumber							NVARCHAR(MAX)	
		DECLARE @intARLocationId						INT
		DECLARE @intCardId								INT
		DECLARE @strTaxState							NVARCHAR(MAX)						
		DECLARE @strAuthorityId1						NVARCHAR(MAX)				
		DECLARE @strAuthorityId2						NVARCHAR(MAX)			
		DECLARE @ysnFederalExciseTax					BIT		
		DECLARE @ysnStateExciseTax						BIT		
		DECLARE @ysnStateSalesTax						BIT		
		DECLARE @ysnLocalTax1							BIT		
		DECLARE @ysnLocalTax2							BIT		
		DECLARE @ysnLocalTax3							BIT		
		DECLARE @ysnLocalTax4							BIT		
		DECLARE @ysnLocalTax5							BIT		
		DECLARE @ysnLocalTax6							BIT		
		DECLARE @ysnLocalTax7							BIT		
		DECLARE @ysnLocalTax8							BIT		
		DECLARE @ysnLocalTax9							BIT		
		DECLARE @ysnLocalTax10							BIT		
		DECLARE @ysnLocalTax11							BIT		
		DECLARE @ysnLocalTax12							BIT		
		DECLARE @intNumberOfLinesPerTransaction			INT
		DECLARE @intIgnoreCardID						INT
		DECLARE @strImportFileName						NVARCHAR(MAX)
		DECLARE @strImportPath							NVARCHAR(MAX)
		DECLARE @intNumberOfDecimalInPrice				INT
		DECLARE @intNumberOfDecimalInQuantity			INT
		DECLARE @intNumberOfDecimalInTotal				INT
		DECLARE @strImportType							NVARCHAR(MAX)
		DECLARE @strControllerType						NVARCHAR(MAX)
		DECLARE @ysnPumpCalculatesTaxes					BIT
		DECLARE @ysnSiteAcceptsMajorCreditCards			BIT
		DECLARE @ysnCenexSite							BIT
		DECLARE @ysnUseControllerCard					BIT
		DECLARE @intCashCustomerID						INT
		DECLARE @ysnProcessCashSales					BIT
		DECLARE @ysnAssignBatchByDate					BIT
		DECLARE @ysnMultipleSiteImport					BIT
		DECLARE @strSiteName							NVARCHAR(MAX)
		DECLARE @strDeliveryPickup						NVARCHAR(MAX)
		DECLARE @strSiteAddress							NVARCHAR(MAX)
		DECLARE @strSiteCity							NVARCHAR(MAX)
		DECLARE @intPPHostId							INT
		DECLARE @strPPSiteType							NVARCHAR(MAX)
		DECLARE @ysnPPLocalPrice						BIT
		DECLARE @intPPLocalHostId						INT
		DECLARE @strPPLocalSiteType						NVARCHAR(MAX)
		DECLARE @intPPLocalSiteId						INT
		DECLARE @intRebateSiteGroupId					INT
		DECLARE @intAdjustmentSiteGroupId				INT
		DECLARE @dtmLastTransactionDate					DATETIME
		DECLARE @ysnEEEStockItemDetail					BIT
		DECLARE @ysnRecalculateTaxesOnRemote			BIT
		DECLARE @strSiteType							NVARCHAR(MAX)
		DECLARE @intCreatedUserId						INT
		DECLARE @dtmCreated								DATETIME
		DECLARE @intLastModifiedUserId					INT
		DECLARE @dtmLastModified						DATETIME

		----================================--
		----     DETAIL FIELDS SITE ITEM	  --
		----================================--
		--DECLARE @originSiteItem								NVARCHAR(MAX)
		--DECLARE @MasterPk									INT
		--DECLARE @intSiteItemTaxGroupMaster					INT
		--DECLARE @intSiteItemNetworkId						INT
		--DECLARE @strSiteItemProductNumber					NVARCHAR(MAX)
		--DECLARE @intSiteItemARItemId						INT
		--DECLARE @strSiteItemProductDescription				NVARCHAR(MAX)
		--DECLARE @dblSiteItemOPISAverageCost1				NUMERIC(18,6)
		--DECLARE @dtmSiteItemOPISEffectiveDate1				DATETIME
		--DECLARE @dblSiteItemOPISAverageCost2				NUMERIC(18,6)
		--DECLARE @dtmSiteItemOPISEffectiveDate2				DATETIME
		--DECLARE @dblSiteItemOPISAverageCost3				NUMERIC(18,6)
		--DECLARE @dtmSiteItemOPISEffectiveDate3				DATETIME
		--DECLARE @dblSiteItemSellingPrice					NUMERIC(18,6)
		--DECLARE @dblSiteItemPumpPrice						NUMERIC(18,6)
		--DECLARE @ysnSiteItemCarryNegligibleBalance			BIT
		--DECLARE @ysnSiteItemIncludeInQuantityDiscount		BIT
		--DECLARE @strSiteItemDepartmentType					NVARCHAR(MAX)
		--DECLARE @ysnSiteItemOverrideLocationSalesTax		BIT
		--DECLARE @dblSiteItemRemoteFeePerTransaction			NUMERIC(18,6)
		--DECLARE @dblSiteItemExtRemoteFeePerTransaction		NUMERIC(18,6)
		--DECLARE @ysnSiteItemMPGCalculation					BIT
		--DECLARE @ysnSiteItemChargeOregonP					BIT
		--DECLARE @intSiteItemCreatedUserId					INT
		--DECLARE @dtmSiteItemCreated							DATETIME
		--DECLARE @intSiteItemLastModifiedUserId				INT
		--DECLARE @dtmSiteItemLastModified					DATETIME

		----================================--
		----     DETAIL FIELDS CREDIT CARD  --
		----================================--
		--DECLARE @originCreditCard							NVARCHAR(MAX)
		--DECLARE @intCreditCardCreditCardId					INT		
		--DECLARE @intCreditCardNetworkId						INT		
		--DECLARE @intCreditCardSiteId						INT		
		--DECLARE @strCreditCardPrefix						NVARCHAR(MAX)		
		--DECLARE @intCreditCardCardId						INT		
		--DECLARE @strCreditCardCardDescription				NVARCHAR(MAX)		
		--DECLARE @intCreditCardCustomerId					INT		
		--DECLARE @ysnCreditCardLocalPrefix					BIT		
		--DECLARE @intCreditCardCreatedUserId					INT		
		--DECLARE @dtmCreditCardCreated						DATETIME		
		--DECLARE @intCreditCardLastModifiedUserId			INT		
		--DECLARE @dtmCreditCardLastModified					DATETIME		
		

		--Import only those are not yet imported
		SELECT cfloc_site_no INTO #tmpcflocmst
			FROM cflocmst
				WHERE cfloc_site_no COLLATE Latin1_General_CI_AS NOT IN (select strSiteNumber from tblCFSite) 


		--DUPLICATE SITE ON i21--

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
		,strSetupName = 'Site'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate site on i21 Card Fueling sites list'
		,strOriginTable = 'cflocmst'
		,strOriginIdentityId = cfloc_site_no
		,strI21Table = 'tblCFSite'
		,intI21IdentityId = null
		,strUserId = ''
		FROM cflocmst
		WHERE cfloc_site_no COLLATE Latin1_General_CI_AS IN (select strSiteNumber from tblCFSite) 
		
		--DUPLICATE SITE ON i21--

		WHILE (EXISTS(SELECT 1 FROM #tmpcflocmst))
		BEGIN
			
			SELECT @originSite = cfloc_site_no FROM #tmpcflocmst
			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					 @intNetworkId								= (SELECT intNetworkId 
																   FROM tblCFNetwork 
																   WHERE strNetwork = RTRIM(LTRIM(cfloc_network_id)) 
																   COLLATE Latin1_General_CI_AS)

					,@strSiteNumber								= RTRIM(LTRIM(cfloc_site_no))

					,@strSiteName								= RTRIM(LTRIM(cfloc_site_name))

					,@intARLocationId							= (SELECT intCompanyLocationId 
																	FROM tblSMCompanyLocation 
																	WHERE strLocationNumber = RTRIM(LTRIM(cfloc_ar_itm_loc_no)) 
																	COLLATE Latin1_General_CI_AS)

					,@strDeliveryPickup							= (case
																	when RTRIM(LTRIM(cfloc_dlvry_pickup_ind)) = 'P' then 'Pickup'
																	when RTRIM(LTRIM(cfloc_dlvry_pickup_ind)) = 'D' then 'Deliver'
																	else ''
																  end) 

					,@strSiteType								= (case
																	when RTRIM(LTRIM(cfloc_site_type)) = 'N' then 'Local/Network'
																	when RTRIM(LTRIM(cfloc_site_type)) = 'R' then 'Remote'
																	when RTRIM(LTRIM(cfloc_site_type)) = 'E' then 'Extended'
																	else ''
																  end)

					,@strControllerType							= (case
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'G' then 'Gasboy'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'A' then 'AutoGas'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'P' then 'PetroVend'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'T' then 'Tech-21'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'C' then 'CCIS'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'M' then 'Mannatec'
																	when RTRIM(LTRIM(cfloc_controller_type)) = 'W' then 'WetHosing'
																	--when RTRIM(LTRIM(cfloc_controller_type)) = 'E' then 'Triple E'
																	else ''
																  end)

					,@intAdjustmentSiteGroupId					= (SELECT intSiteGroupPriceAdjustmentId 
																   FROM tblCFSiteGroup sg INNER JOIN tblCFSiteGroupPriceAdjustment sgpa 
																   ON sg.intSiteGroupId = sgpa.intSiteGroupId 
																   WHERE sg.strSiteGroup = RTRIM(LTRIM(cfloc_adj_site_grp_id)) 
																   COLLATE Latin1_General_CI_AS) 

					,@ysnSiteAcceptsMajorCreditCards			= (case
																	when RTRIM(LTRIM(cfloc_major_ccd_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_major_ccd_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@dtmLastTransactionDate					= (case
																	when LEN(RTRIM(LTRIM(ISNULL(cfloc_last_trans_rev_dt,0)))) = 8 
																	then CONVERT(datetime, SUBSTRING (RTRIM(LTRIM(cfloc_last_trans_rev_dt)),1,4) 
																		+ '/' + SUBSTRING (RTRIM(LTRIM(cfloc_last_trans_rev_dt)),5,2) + '/' 
																		+ SUBSTRING (RTRIM(LTRIM(cfloc_last_trans_rev_dt)),7,2), 120)
																	else NULL
																  end)

					,@strSiteAddress							= RTRIM(LTRIM(cfloc_site_addr))

					,@strSiteCity								= RTRIM(LTRIM(cfloc_site_city))

					,@strTaxState								= RTRIM(LTRIM(cfloc_state))

					,@intPPHostId								= RTRIM(LTRIM(cfloc_pp_host_no))

					,@strPPSiteType								= (case
																	when RTRIM(LTRIM(cfloc_major_ccd_yn)) = 'N' then 'Network'
																	when RTRIM(LTRIM(cfloc_major_ccd_yn)) = 'E' then 'Exclusive'
																	when RTRIM(LTRIM(cfloc_major_ccd_yn)) = 'R' then 'Retail'
																	else ''
																  end)

					,@ysnProcessCashSales						= (case
																	when RTRIM(LTRIM(cfloc_process_cash_sales_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_process_cash_sales_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@intCashCustomerID							= (SELECT [intEntityId] 
																   FROM tblARCustomer 
																   WHERE strCustomerNumber = RTRIM(LTRIM(cfloc_ar_cash_cus_no))
																   COLLATE Latin1_General_CI_AS)

					,@ysnEEEStockItemDetail						= (case
																	when RTRIM(LTRIM(cfloc_eee_item_det_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_eee_item_det_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@ysnPumpCalculatesTaxes					= (case
																	when RTRIM(LTRIM(cfloc_pump_calc_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_pump_calc_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@ysnRecalculateTaxesOnRemote				= (case
																	when RTRIM(LTRIM(cfloc_rcalc_tax_rmt_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_rcalc_tax_rmt_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)
																  
					,@ysnAssignBatchByDate						= (case
																	when RTRIM(LTRIM(cfloc_assign_batch_by_date_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_assign_batch_by_date_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@strImportType								= RTRIM(LTRIM(cfloc_import_type))

					,@ysnMultipleSiteImport						= (case
																	when RTRIM(LTRIM(cfloc_multi_site_import_yn)) = 'N' then 'FALSE'
																	when RTRIM(LTRIM(cfloc_multi_site_import_yn)) = 'Y' then 'TRUE'
																	else 'FALSE'
																  end)

					,@strImportPath								= RTRIM(LTRIM(cfloc_import_path))
					,@strImportFileName							= RTRIM(LTRIM(cfloc_import_file))
	

				FROM cflocmst
				WHERE cfloc_site_no = @originSite
					
				--*********************COMMIT TRANSACTION*****************--
				INSERT [dbo].[tblCFSite](
				  [intNetworkId]						
				 ,[strSiteNumber]						
				 ,[strSiteName]						
				 ,[intARLocationId]					
				 ,[strDeliveryPickup]					
				 ,[strSiteType]						
				 ,[strControllerType]					
				 ,[intAdjustmentSiteGroupId]			
				 ,[ysnSiteAcceptsMajorCreditCards]	
				 ,[dtmLastTransactionDate]			
				 ,[strSiteAddress]					
				 ,[strSiteCity]						
				 ,[strTaxState]						
				 ,[intPPHostId]						
				 ,[strPPSiteType]						
				 ,[ysnProcessCashSales]				
				 ,[intCashCustomerID]					
				 ,[ysnEEEStockItemDetail]				
				 ,[ysnPumpCalculatesTaxes]			
				 ,[ysnRecalculateTaxesOnRemote]		
				 ,[ysnAssignBatchByDate]			
				 ,[strImportType]						
				 ,[ysnMultipleSiteImport]				
				 ,[strImportPath]						
				 ,[strImportFileName]							
				)
				VALUES(
				 @intNetworkId						
				,@strSiteNumber						
				,@strSiteName						
				,@intARLocationId					
				,@strDeliveryPickup					
				,@strSiteType						
				,@strControllerType					
				,@intAdjustmentSiteGroupId			
				,@ysnSiteAcceptsMajorCreditCards	
				,@dtmLastTransactionDate			
				,@strSiteAddress					
				,@strSiteCity						
				,@strTaxState						
				,@intPPHostId						
				,@strPPSiteType						
				,@ysnProcessCashSales				
				,@intCashCustomerID					
				,@ysnEEEStockItemDetail				
				,@ysnPumpCalculatesTaxes			
				,@ysnRecalculateTaxesOnRemote		
				,@ysnAssignBatchByDate				
				,@strImportType						
				,@ysnMultipleSiteImport				
				,@strImportPath						
				,@strImportFileName)


				----========================================--
				----		INSERT DETAIL SITE ITEM RECORDS	  --
				----========================================--
				--SELECT cfitm_prod_no INTO #tmpcfitmmst
				--FROM cfitmmst
				--WHERE cfitm_site_no COLLATE Latin1_General_CI_AS = @originSite
				
				--WHILE (EXISTS(SELECT 1 FROM #tmpcfitmmst))
				--BEGIN

				--	SELECT @originSiteItem = cfitm_prod_no FROM #tmpcfitmmst

				--	SELECT TOP 1
				--	 @intSiteItemCreatedUserId							  = 0		
				--	,@dtmSiteItemCreated								  = CONVERT(VARCHAR(10), GETDATE(), 120)				
				--	,@intSiteItemLastModifiedUserId						  = 0
				--	,@dtmSiteItemLastModified							  = CONVERT(VARCHAR(10), GETDATE(), 120)
				--	,@strSiteItemProductNumber							  = RTRIM(LTRIM(cfitm_prod_no))

				--	,@intSiteItemARItemId								  = (SELECT intItemId 
				--															 FROM tblICItem 
				--															 WHERE strItemNo = RTRIM(LTRIM(cfitm_ar_itm_no)) 
				--															 COLLATE Latin1_General_CI_AS)

				--	,@strSiteItemProductDescription						  = RTRIM(LTRIM(cfitm_prod_desc))
				--	,@ysnSiteItemCarryNegligibleBalance					  = (case
				--															when RTRIM(LTRIM(cfitm_carry_neg_bal_yn)) = 'N' then 'FALSE'
				--															when RTRIM(LTRIM(cfitm_carry_neg_bal_yn)) = 'Y' then 'TRUE'
				--															else 'FALSE'
				--															end)
				--	,@ysnSiteItemIncludeInQuantityDiscount				  = (case
				--															when RTRIM(LTRIM(cfitm_include_in_qty_disc_yn)) = 'N' then 'FALSE'
				--															when RTRIM(LTRIM(cfitm_include_in_qty_disc_yn)) = 'Y' then 'TRUE'
				--															else 'FALSE'
				--															end)
				--	,@strSiteItemDepartmentType							  =  RTRIM(LTRIM(cfitm_dept_type))
				--	,@ysnSiteItemMPGCalculation							  = (case
				--															when RTRIM(LTRIM(cfitm_mpg_calc_yn)) = 'N' then 'FALSE'
				--															when RTRIM(LTRIM(cfitm_mpg_calc_yn)) = 'Y' then 'TRUE'
				--															else 'FALSE'
				--															end)
				--	,@ysnSiteItemChargeOregonP							  = (case
				--															when RTRIM(LTRIM(cfitm_remote_oregon_puc)) = 'N' then 'FALSE'
				--															when RTRIM(LTRIM(cfitm_remote_oregon_puc)) = 'Y' then 'TRUE'
				--															else 'FALSE'
				--															end)
				--	FROM cfitmmst
				--	WHERE cfitm_prod_no = @originSiteItem
					
				--	INSERT [dbo].[tblCFItem](
				--	 [intSiteId]
				--	,[intTaxGroupMaster]				
				--	,[intNetworkId]					
				--	,[strProductNumber]				
				--	,[intARItemId]					
				--	,[strProductDescription]		
				--	,[dblOPISAverageCost1]			
				--	,[dtmOPISEffectiveDate1]			
				--	,[dblOPISAverageCost2]			
				--	,[dtmOPISEffectiveDate2]			
				--	,[dblOPISAverageCost3]			
				--	,[dtmOPISEffectiveDate3]		
				--	,[dblSellingPrice]				
				--	,[dblPumpPrice]					
				--	,[ysnCarryNegligibleBalance]		
				--	,[ysnIncludeInQuantityDiscount]	
				--	,[strDepartmentType]				
				--	,[ysnOverrideLocationSalesTax]	
				--	,[dblRemoteFeePerTransaction]	
				--	,[dblExtRemoteFeePerTransaction]
				--	,[ysnMPGCalculation]				
				--	,[ysnChargeOregonP]				
				--	,[intCreatedUserId]				
				--	,[dtmCreated]					
				--	,[intLastModifiedUserId]			
				--	,[dtmLastModified]				
				--	)
				--	VALUES(
				--	 @MasterPk
				--	 ,@intSiteItemTaxGroupMaster				
				--	 ,@intSiteItemNetworkId					
				--	 ,@strSiteItemProductNumber				
				--	 ,@intSiteItemARItemId					
				--	 ,@strSiteItemProductDescription			
				--	 ,@dblSiteItemOPISAverageCost1			
				--	 ,@dtmSiteItemOPISEffectiveDate1			
				--	 ,@dblSiteItemOPISAverageCost2			
				--	 ,@dtmSiteItemOPISEffectiveDate2			
				--	 ,@dblSiteItemOPISAverageCost3			
				--	 ,@dtmSiteItemOPISEffectiveDate3			
				--	 ,@dblSiteItemSellingPrice				
				--	 ,@dblSiteItemPumpPrice					
				--	 ,@ysnSiteItemCarryNegligibleBalance		
				--	 ,@ysnSiteItemIncludeInQuantityDiscount	
				--	 ,@strSiteItemDepartmentType				
				--	 ,@ysnSiteItemOverrideLocationSalesTax	
				--	 ,@dblSiteItemRemoteFeePerTransaction		
				--	 ,@dblSiteItemExtRemoteFeePerTransaction	
				--	 ,@ysnSiteItemMPGCalculation				
				--	 ,@ysnSiteItemChargeOregonP				
				--	 ,@intSiteItemCreatedUserId				
				--	 ,@dtmSiteItemCreated						
				--	 ,@intSiteItemLastModifiedUserId			
				--	 ,@dtmSiteItemLastModified				
				--	)
				--	CONTINUEDETAILLOOP:
				--	PRINT @originSiteItem
				--	DELETE FROM #tmpcfitmmst WHERE cfitm_prod_no = @originSiteItem
				--END

				--DROP TABLE #tmpcfitmmst


				----============================================--
				----		INSERT DETAIL CREDIT CARD RECORDS	  --
				----============================================--
				--SELECT cfccd_card_prefix INTO #tmpcfccdmst
				--FROM cfccdmst
				--WHERE cfccd_site_no COLLATE Latin1_General_CI_AS = @originSite
				
				--WHILE (EXISTS(SELECT 1 FROM #tmpcfccdmst))
				--BEGIN

				--	SELECT @originCreditCard = cfccd_card_prefix FROM #tmpcfccdmst

				--	SELECT TOP 1
				--	 @intCreditCardNetworkId								= ISNULL((SELECT intNetworkId 
				--															   FROM tblCFNetwork 
				--															   WHERE strNetwork = LTRIM(RTRIM(cfccd_network_id)) 
				--															   COLLATE Latin1_General_CI_AS),0)
				--	,@strCreditCardPrefix									= LTRIM(RTRIM(cfccd_card_prefix))
				--	,@intCreditCardCardId									= LTRIM(RTRIM(cfccd_card_no))
				--	,@strCreditCardCardDescription							= LTRIM(RTRIM(cfccd_card_desc)) 
				--	,@intCreditCardCustomerId								= ISNULL((SELECT intEntityCustomerId 
				--																FROM tblARCustomer 
				--																WHERE strCustomerNumber = LTRIM(RTRIM(cfccd_ar_cus_no))
				--																COLLATE Latin1_General_CI_AS),0)
				--	,@ysnCreditCardLocalPrefix								= (case
				--															   when RTRIM(LTRIM(cfccd_local_prefix)) = 'N' then 'FALSE'
				--															   when RTRIM(LTRIM(cfccd_local_prefix)) = 'Y' then 'TRUE'
				--															   else 'FALSE'
				--															   end)
				--	,@intCreditCardCreatedUserId							= 0		
				--	,@dtmCreditCardCreated									= CONVERT(VARCHAR(10), GETDATE(), 120)
				--	,@intCreditCardLastModifiedUserId						= 0
				--	,@dtmCreditCardLastModified								= CONVERT(VARCHAR(10), GETDATE(), 120)
				--	FROM cfccdmst											  
				--	WHERE cfccd_card_prefix = @originCreditCard
					
				--	INSERT [dbo].[tblCFCreditCard](
				--	 [intSiteId]		
				--	,[intNetworkId]			
				--	,[strPrefix]				
				--	,[intCardId]				
				--	,[strCardDescription]		
				--	,[intCustomerId]			
				--	,[ysnLocalPrefix]			
				--	,[intCreatedUserId]	
				--	,[dtmCreated]				
				--	,[intLastModifiedUserId]	
				--	,[dtmLastModified]			
				--	)
				--	VALUES(
				--	  @MasterPk
				--	 ,@intCreditCardNetworkId			
				--	 ,@strCreditCardPrefix				
				--	 ,@intCreditCardCardId				
				--	 ,@strCreditCardCardDescription		
				--	 ,@intCreditCardCustomerId			
				--	 ,@ysnCreditCardLocalPrefix			
				--	 ,@intCreditCardCreatedUserId		
				--	 ,@dtmCreditCardCreated				
				--	 ,@intCreditCardLastModifiedUserId	
				--	 ,@dtmCreditCardLastModified			
				--	)
				--	CONTINUEDETAILCCLOOP:
				--	PRINT @originCreditCard
				--	DELETE FROM #tmpcfccdmst WHERE cfccd_card_prefix = @originCreditCard
				--END

				--DROP TABLE #tmpcfccdmst


				--COMMIT TRANSACTION

									   COMMIT TRANSACTION
				--*********************COMMIT TRANSACTION*****************--
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
						,'Site'
						,1
						,''
						,'cflocmst'
						,@originSite
						,'tblCFSite'
						,SCOPE_IDENTITY()
						,''
					)
				
			END TRY
			BEGIN CATCH
				--*********************ROLLBACK TRANSACTION*****************--
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				
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
					,'Site'
					,0
					,ERROR_MESSAGE()
					,'cflocmst'
					,@originSite
					,'tblCFSite'
					,null
					,''
				)
				GOTO CONTINUELOOP;
				--*********************ROLLBACK TRANSACTION*****************--
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			DELETE FROM #tmpcflocmst WHERE cfloc_site_no = @originSite
		
			SET @Counter += 1;

		END
	
		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(*) - @TotalSuccess from cflocmst
		PRINT @TotalFailed

	END
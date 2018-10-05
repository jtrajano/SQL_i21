CREATE PROCEDURE [dbo].[uspCFImportOriginItem]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME Item SYNCHRONIZATION	  --
		--====================================================--

		----------------------------------------------------
		---------Duplicate Item Check
		-------------------------------------------------------
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
		,strSetupName = 'Item'
		,ysnSuccessful = 0
		,strFailedReason = 'Duplicate product number on i21 Card Fueling item'
		,strOriginTable = 'cfitmmst'
		,strOriginIdentityId = A.cfitm_prod_no
		,strI21Table = 'tblCFItem'
		,intI21IdentityId = (SELECT TOP 1 intItemId 
								FROM tblCFItem 
								WHERE strProductNumber = A.cfitm_prod_no COLLATE Latin1_General_CI_AS
									AND ISNULL(intSiteId,0) = ISNULL(C.intSiteId,0)
									AND ISNULL(intNetworkId,0) = ISNULL(B.intNetworkId,0) 
							)
		,strUserId = ''
		FROM cfitmmst A
		OUTER APPLY (
			SELECT TOP 1 intNetworkId FROM tblCFNetwork WHERE strNetwork = A.cfitm_network_id COLLATE Latin1_General_CI_AS
				
		)B
		OUTER APPLY (
			SELECT TOP 1 
				intSiteId = CASE WHEN cfitm_site_no = 'NETWRK' THEN NULL ELSE intSiteId END
			FROM tblCFSite 
			WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS  
				
		)C
		WHERE EXISTS	(SELECT TOP 1 intItemId 
								FROM tblCFItem 
								WHERE strProductNumber = A.cfitm_prod_no COLLATE Latin1_General_CI_AS
									AND ISNULL(intSiteId,0) = ISNULL(C.intSiteId,0)
									AND ISNULL(intNetworkId,0) = ISNULL(B.intNetworkId,0) 
						)
		--------------------------------------------------------------------
		--------------------------------------------------------------------------





		
		------------------------------------------------------
		-----------Check AR Item.
		---------------------------------------------------------
		--INSERT INTO tblCFImportResult(
		--				dtmImportDate
		--				,strSetupName
		--				,ysnSuccessful
		--				,strFailedReason
		--				,strOriginTable
		--				,strOriginIdentityId
		--				,strI21Table
		--				,intI21IdentityId
		--				,strUserId
		--			)
		--SELECT 
		-- dtmImportDate = GETDATE()
		--,strSetupName = 'Item'
		--,ysnSuccessful = 0
		--,strFailedReason = 'AR product does not exists in i21'
		--,strOriginTable = 'cfitmmst'
		--,strOriginIdentityId = cfitm_prod_no
		--,strI21Table = 'tblICItem'
		--,intI21IdentityId = (SELECT TOP 1 intItemId FROM tblICItem WHERE cfitm_ar_itm_no = cfitm_ar_itm_no COLLATE Latin1_General_CI_AS)
		--,strUserId = ''
		--FROM cfitmmst 
		--WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblCFItem WHERE strProductNumber = cfitm_prod_no COLLATE Latin1_General_CI_AS)
		--	AND NOT EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = cfitm_ar_itm_no  COLLATE Latin1_General_CI_AS )
		
		----------------------------------------------------------------------
		----------------------------------------------------------------------------



		------------------------------------------------------
		-----------Check Site .
		---------------------------------------------------------
		--INSERT INTO tblCFImportResult(
		--				dtmImportDate
		--				,strSetupName
		--				,ysnSuccessful
		--				,strFailedReason
		--				,strOriginTable
		--				,strOriginIdentityId
		--				,strI21Table
		--				,intI21IdentityId
		--				,strUserId
		--			)
		--SELECT 
		-- dtmImportDate = GETDATE()
		--,strSetupName = 'Item'
		--,ysnSuccessful = 0
		--,strFailedReason = 'Site does not exists in i21 Card fueling'
		--,strOriginTable = 'cfitmmst'
		--,strOriginIdentityId = cfitm_site_no
		--,strI21Table = 'tblCFSite'
		--,intI21IdentityId = (SELECT TOP 1 intSiteId FROM tblCFSite WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS)
		--,strUserId = ''
		--FROM cfitmmst 
		--WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblCFItem WHERE strProductNumber = cfitm_prod_no COLLATE Latin1_General_CI_AS)
		--	AND EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = cfitm_ar_itm_no  COLLATE Latin1_General_CI_AS )
		--	AND NOT EXISTS (SELECT TOP 1 1 FROM tblCFSite WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS AND cfitm_site_no <> 'NETWRK' )

		----------------------------------------------------------------------
		----------------------------------------------------------------------------



		------------------------------------------------------
		-----------Check Network .
		---------------------------------------------------------
		--INSERT INTO tblCFImportResult(
		--				dtmImportDate
		--				,strSetupName
		--				,ysnSuccessful
		--				,strFailedReason
		--				,strOriginTable
		--				,strOriginIdentityId
		--				,strI21Table
		--				,intI21IdentityId
		--				,strUserId
		--			)
		--SELECT 
		-- dtmImportDate = GETDATE()
		--,strSetupName = 'Item'
		--,ysnSuccessful = 0
		--,strFailedReason = 'Network does not exists in i21 Card fueling'
		--,strOriginTable = 'cfitmmst'
		--,strOriginIdentityId = cfitm_network_id
		--,strI21Table = 'tblCFNetwork'
		--,intI21IdentityId = (SELECT TOP 1 intNetworkId FROM tblCFNetwork WHERE strNetwork = cfitm_network_id  COLLATE Latin1_General_CI_AS)
		--,strUserId = ''
		--FROM cfitmmst 
		--WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblCFItem WHERE strProductNumber = cfitm_prod_no COLLATE Latin1_General_CI_AS)
		--	AND EXISTS (SELECT TOP 1 1 FROM tblICItem WHERE strItemNo = cfitm_ar_itm_no  COLLATE Latin1_General_CI_AS )
		--	AND EXISTS (SELECT TOP 1 1 FROM tblCFSite WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS AND cfitm_site_no <> 'NETWRK' )
		--	AND NOT EXISTS(SELECT TOP 1 1 FROM tblCFNetwork WHERE strNetwork = cfitm_network_id COLLATE Latin1_General_CI_AS )
		----------------------------------------------------------------------
		----------------------------------------------------------------------------
		

		IF(OBJECT_ID('tempdb..#tblOriginItem') IS NOT NULL) DROP TABLE #tblOriginItem
		
		SELECT A.*
		INTO #tblOriginItem
		FROM cfitmmst A
		OUTER APPLY (
			SELECT TOP 1 intNetworkId FROM tblCFNetwork WHERE strNetwork = A.cfitm_network_id COLLATE Latin1_General_CI_AS
				
		)B
		OUTER APPLY (
			SELECT TOP 1 
				intSiteId = CASE WHEN cfitm_site_no = 'NETWRK' THEN NULL ELSE intSiteId END
			FROM tblCFSite 
			WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS  
				
		)C
		WHERE NOT EXISTS (SELECT TOP 1 intItemId 
								FROM tblCFItem 
								WHERE strProductNumber = A.cfitm_prod_no COLLATE Latin1_General_CI_AS
									AND ISNULL(intSiteId,0) = ISNULL(C.intSiteId,0)
									AND ISNULL(intNetworkId,0) = ISNULL(B.intNetworkId,0) 
						)


		INSERT INTO [dbo].[tblCFItem]
			   ([intNetworkId]
			   ,[intSiteId]
			   ,[strProductNumber]
			   ,[intARItemId]
			   ,[strProductDescription]
			   ,[dblOPISAverageCost1]
			   ,[dtmOPISEffectiveDate1]
			   ,[dblOPISAverageCost2]
			   ,[dtmOPISEffectiveDate2]
			   ,[dblOPISAverageCost3]
			   ,[dtmOPISEffectiveDate3]
			   ,[dblSellingPrice]
			   ,[dblPumpPrice]
			   ,[ysnCarryNegligibleBalance]
			   ,[ysnIncludeInQuantityDiscount]
			   ,[strDepartmentType]
			   ,[ysnOverrideLocationSalesTax]
			   ,[dblRemoteFeePerTransaction]
			   ,[dblExtRemoteFeePerTransaction]
			   ,[ysnMPGCalculation]
			   ,[ysnChargeOregonP]
				)           
		SELECT
			[intNetworkId] = (SELECT TOP 1 intNetworkId FROM tblCFNetwork WHERE strNetwork = cfitm_network_id COLLATE Latin1_General_CI_AS)
			,[intSiteId] =	CASE WHEN cfitm_site_no = 'NETWRK'
							THEN NULL
							ELSE 
								(SELECT TOP 1 intSiteId FROM tblCFSite WHERE strSiteNumber = cfitm_site_no  COLLATE Latin1_General_CI_AS)
							END
			,[strProductNumber] = cfitm_prod_no
			,[intARItemId] = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = cfitm_ar_itm_no  COLLATE Latin1_General_CI_AS )
			,[strProductDescription] = cfitm_prod_desc
			,[dblOPISAverageCost1] = cfitm_opis1_average
			,[dtmOPISEffectiveDate1] = (	CASE WHEN LEN(RTRIM(LTRIM(ISNULL(cfitm_opis1_rev_dt,0)))) = 8 
										THEN CONVERT(DATETIME, SUBSTRING (RTRIM(LTRIM(cfitm_opis1_rev_dt)),1,4) 
											+ '/' + SUBSTRING (RTRIM(LTRIM(cfitm_opis1_rev_dt)),5,2) + '/' 
											+ SUBSTRING (RTRIM(LTRIM(cfitm_opis1_rev_dt)),7,2), 120)
										ELSE NULL
										END)
			,[dblOPISAverageCost2] = cfitm_opis2_average
			,[dtmOPISEffectiveDate2] = (	CASE WHEN LEN(RTRIM(LTRIM(ISNULL(cfitm_opis2_rev_dt,0)))) = 8 
										THEN CONVERT(DATETIME, SUBSTRING (RTRIM(LTRIM(cfitm_opis2_rev_dt)),1,4) 
											+ '/' + SUBSTRING (RTRIM(LTRIM(cfitm_opis2_rev_dt)),5,2) + '/' 
											+ SUBSTRING (RTRIM(LTRIM(cfitm_opis2_rev_dt)),7,2), 120)
										ELSE NULL
										END)
			,[dblOPISAverageCost3] = cfitm_opis3_average
			,[dtmOPISEffectiveDate3] = (	CASE WHEN LEN(RTRIM(LTRIM(ISNULL(cfitm_opis3_rev_dt,0)))) = 8 
										THEN CONVERT(DATETIME, SUBSTRING (RTRIM(LTRIM(cfitm_opis3_rev_dt)),1,4) 
											+ '/' + SUBSTRING (RTRIM(LTRIM(cfitm_opis3_rev_dt)),5,2) + '/' 
											+ SUBSTRING (RTRIM(LTRIM(cfitm_opis3_rev_dt)),7,2), 120)
										ELSE NULL
										END)
			,[dblSellingPrice] = cfitm_local_price
			,[dblPumpPrice] = cfitm_pump_price
			,[ysnCarryNegligibleBalance] = CASE WHEN cfitm_carry_neg_bal_yn = 'Y' THEN 1 ELSE 0 END
			,[ysnIncludeInQuantityDiscount] = CASE WHEN cfitm_include_in_qty_disc_yn = 'Y' THEN 1 ELSE 0 END
			,[strDepartmentType] = cfitm_dept_type
			,[ysnOverrideLocationSalesTax] = CASE WHEN cfitm_override_loc_sst_yn = 'Y' THEN 1 ELSE 0 END 
			,[dblRemoteFeePerTransaction] = cfitm_remote_fee_per_tran
			,[dblExtRemoteFeePerTransaction] = cfitm_ext_remote_fee_per_tran
			,[ysnMPGCalculation] = CASE WHEN cfitm_mpg_calc_yn = 'Y' THEN 1 ELSE 0 END 
			,[ysnChargeOregonP] = CASE WHEN cfitm_remote_oregon_puc = 'Y' THEN 1 ELSE 0 END 
		FROM #tblOriginItem

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
						GETDATE()
						,'Item'
						,1
						,''
						,'cfitmmst'
						,cfitm_prod_no
						,'tblCFItem'
						,(SELECT TOP 1 1 FROM tblCFItem WHERE strProductNumber = cfitm_prod_no COLLATE Latin1_General_CI_AS)
						,''
		FROM #tblOriginItem
		
		SELECT @TotalSuccess = COUNT(1) FROM #tblOriginItem

		PRINT @TotalSuccess
		SELECT @TotalFailed = COUNT(1) - @TotalSuccess from cfitmmst
		PRINT @TotalFailed


END
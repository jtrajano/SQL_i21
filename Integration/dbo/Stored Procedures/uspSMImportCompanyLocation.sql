﻿GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportCompanyLocation')
	DROP PROCEDURE uspSMImportCompanyLocation
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 
OR (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'GR' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspSMImportCompanyLocation
			@Checking BIT = 0,
			@UserId INT = 0,
			@Total INT = 0 OUTPUT

			AS
		BEGIN
			
			--================================================
			--     GET TO BE IMPORTED RECORDS
			--	This is checking if there are still records need to be import	
			--================================================
			IF(@Checking = 1) 
			BEGIN
				--Check first on aglocmst	
				SELECT
					@Total = COUNT(AG.[agloc_loc_no])
				FROM
					aglocmst AG
				LEFT OUTER JOIN
					tblSMCompanyLocation CL
						ON RTRIM(LTRIM(AG.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))										
				WHERE
					CL.[strLocationNumber] IS NULL
					
				SELECT
					@Total = @Total + COUNT(GA.[galoc_loc_no])
				FROM
					galocmst GA
				LEFT OUTER JOIN
					tblSMCompanyLocation CL
						ON RTRIM(LTRIM(GA.[galoc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))
				WHERE 	CL.[strLocationNumber] IS NULL AND NOT exists (SELECT * FROM aglocmst AG WHERE AG.agloc_loc_no = GA.galoc_loc_no)									
				
				RETURN @Total
			END	
				
			INSERT INTO [tblSMCompanyLocation]
				([strLocationNumber]
				,[strLocationName]	
				,[strLocationType]
				,[strAddress]
				,[strZipPostalCode]
				,[strCity]
				,[strStateProvince]
				,[strCountry]
				,[strPhone]
				,[strFax]
				,[strEmail]
				,[strWebsite]
				,[strInternalNotes]
				,[strUseLocationAddress]
				,[strSkipSalesmanDefault]
				,[ysnSkipTermsDefault]
				,[strOrderTypeDefault]
				,[strPrintCashReceipts]
				,[ysnPrintCashTendered]
				,[strSalesTaxByLocation]
				,[strDeliverPickupDefault]
				,[strTaxState]
				,[strTaxAuthorityId1]
				,[strTaxAuthorityId2]
				,[ysnOverridePatronage]
				,[strOutOfStockWarning]
				,[strLotOverdrawnWarning]
				,[strDefaultCarrier]
				,[ysnOrderSection2Required]
				,[strPrintonPO]
				,[dblMixerSize]
				,[ysnOverrideMixerSize]
				,[ysnEvenBatches]
				,[ysnDefaultCustomBlend]
				,[ysnAgroguideInterface]
				,[ysnLocationActive]
				,[intProfitCenter]
				--,[intCashAccount]
				,[intDepositAccount]
				,[intARAccount]
				,[intAPAccount]
				,[intSalesAdvAcct]
				,[intPurchaseAdvAccount]
				,[intFreightAPAccount]
				,[intFreightExpenses]
				,[intFreightIncome]
				,[intServiceCharges]
				,[intSalesDiscounts]
				,[intCashOverShort]
				,[intWriteOff]
				,[intCreditCardFee]
				,[intSalesAccount]
				,[intCostofGoodsSold]
				,[intInventory]
				,[intUndepositedFundsId]
				,[strInvoiceType]
				,[strDefaultInvoicePrinter]
				,[strPickTicketType]
				,[strDefaultTicketPrinter]
				--,[strLastOrderNumber]
				--,[strLastInvoiceNumber]
				,[strPrintonInvoice]
				,[ysnPrintContractBalance]
				,[strJohnDeereMerchant]
				,[strInvoiceComments]
				,[ysnUseOrderNumberforInvoiceNumber]
				,[ysnOverrideOrderInvoiceNumber]
				,[ysnPrintInvoiceMedTags]
				,[ysnPrintPickTicketMedTags]
				,[ysnSendtoEnergyTrac]
				,[strDiscountScheduleType]
				,[strLocationDiscount]
				,[strLocationStorage]
				,[strMarketZone]
				,[strLastTicket]
				,[ysnDirectShipLocation]
				,[ysnScaleInstalled]
				,[strDefaultScaleId]
				,[ysnActive]
				,[ysnUsingCashDrawer]
				,[strCashDrawerDeviceId]
				,[ysnPrintRegisterTape]
				,[ysnUseUPConOrders]
				,[ysnUseUPConPhysical]
				,[ysnUseUPConPurchaseOrders]
				,[strUPCSearchSequence]
				,[strBarCodePrinterName]
				,[strPriceLevel1]
				,[strPriceLevel2]
				,[strPriceLevel3]
				,[strPriceLevel4]
				,[strPriceLevel5]
				,[ysnOverShortEntries]
				,[strOverShortCustomer]
				,[strOverShortAccount]
				,[ysnAutomaticCashDepositEntries]
				,[intConcurrencyId])
			SELECT
				AG.[agloc_loc_no]
				,(CASE WHEN EXISTS(SELECT [agloc_loc_no], [agloc_name] FROM aglocmst WHERE RTRIM(LTRIM([agloc_loc_no])) <> RTRIM(LTRIM(AG.[agloc_loc_no])) AND RTRIM(LTRIM([agloc_name])) = RTRIM(LTRIM(AG.[agloc_name])))
					THEN 
						RTRIM(LTRIM(AG.[agloc_name])) + '' - '' + RTRIM(LTRIM(AG.[agloc_loc_no]))
					ELSE
						RTRIM(LTRIM(AG.[agloc_name]))
				  END)								--<strLocationName, nvarchar(50),>
				,''Office''							--<strLocationType, nvarchar(50),>
				,(CASE 
					WHEN RTRIM(LTRIM(ISNULL(AG.[agloc_addr],''''))) = '''' 
						THEN AG.[agloc_addr2]
					ELSE
						RTRIM(LTRIM(ISNULL(AG.[agloc_addr],''''))) + (CHAR(13) + CHAR(10)) + RTRIM(LTRIM(ISNULL(AG.[agloc_addr2],'''')))
				  END)								--<strAddress, nvarchar(max),>
				,[agloc_zip]						--<strZipPostalCode, nvarchar(50),>
				,[agloc_city]						--<strCity, nvarchar(50),>
				,[agloc_state]						--<strStateProvince, nvarchar(50),>
				,[agloc_country]					--<strCountry, nvarchar(50),>
				,(CASE 
					WHEN CHARINDEX(''x'', AG.[agloc_phone]) > 0 
						THEN SUBSTRING(SUBSTRING(AG.[agloc_phone],1,15), 0, CHARINDEX(''x'',AG.[agloc_phone])) 
					ELSE 
						SUBSTRING(AG.[agloc_phone],1,15)
				  END)								--<strPhone, nvarchar(50),>
				,''''									---<strFax, nvarchar(50),>
				,''''									--<strEmail, nvarchar(50),>
				,''''									--<strWebsite, nvarchar(50),>
				,''''									--<strInternalNotes, nvarchar(max),>
				,(CASE UPPER(AG.[agloc_use_addr_ynal])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					WHEN ''A''	THEN	''Always''				
					WHEN ''L''	THEN	''Letterhead''
					ELSE ''''
				  END)								--<strUseLocationAddress, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_skip_slsmn_dflt_ynrs])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					WHEN ''R''	THEN	''Required''				
					WHEN ''S''	THEN	''Use Order Taker''
					ELSE ''''
				  END)								--<strSkipSalesmanDefault, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_skip_terms_dflt_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnSkipTermsDefault, bit,>
				,(CASE UPPER(AG.[agloc_dflt_tic_type_ois])
					WHEN ''O''	THEN	''Order''
					WHEN ''I''	THEN	''Invoice''
					WHEN ''S''	THEN	''Cash Sale''				
					ELSE ''''
				  END)								--<strOrderTypeDefault, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_cash_rcts_ynr])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					WHEN ''R''	THEN	''Register Tape''				
					ELSE ''''
				  END)								--<strPrintCashReceipts, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_cash_tender_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnPrintCashTendered, bit,>
				,(CASE UPPER(AG.[agloc_tax_by_loc_only_ynv])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					WHEN ''V''	THEN	''Varies''				
					ELSE ''''
				  END)								--<strSalesTaxByLocation, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_dflt_dlvr_pkup_ind])
					WHEN ''P''	THEN	''Pickup''
					WHEN ''D''	THEN	''Deliver''
					ELSE ''''
				  END)								--<strDeliverPickupDefault, nvarchar(50),>
				,AG.[agloc_tax_state]				--<strTaxState, nvarchar(50),>
				,AG.[agloc_tax_auth_id1]			--<strTaxAuthorityId1, nvarchar(50),>
				,AG.[agloc_tax_auth_id2]			--<strTaxAuthorityId2, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_override_pat_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnOverridePatronage, bit,>
				,(CASE UPPER(AG.[agloc_item_warning_yn])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					ELSE ''Not Allowed''
				  END)								--<strOutOfStockWarning, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_lot_warning_yns])
					WHEN ''Y''	THEN	''Yes''
					WHEN ''N''	THEN	''No''
					WHEN ''S''	THEN	''Not Allowed''
					ELSE ''''
				  END)								--<strLotOverdrawnWarning, nvarchar(50),>
				,AG.[agloc_default_carrier]			--<strDefaultCarrier, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_ord_sec2_req_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnOrderSection2Required, bit,>
				,(CASE UPPER(AG.[agloc_po_prt_pu])
					WHEN ''P''	THEN	''Packages''
					WHEN ''U''	THEN	''Units''
					ELSE ''''
				  END)								--<strPrintonPO, nvarchar(50),>
				,[agloc_mixer_size]					--<dblMixerSize, numeric(18,6),>
				,(CASE UPPER(AG.[agloc_override_mixer_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnOverrideMixerSize, bit,>
				,(CASE UPPER(AG.[agloc_even_batch_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnEvenBatches, bit,>
				,(CASE UPPER(AG.[agloc_custom_blend_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnDefaultCustomBlend, bit,>
				,(CASE UPPER(AG.[agloc_agroguide_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnAgroguideInterface, bit,>
				,(CASE UPPER(AG.[agloc_active_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnLocationActive, bit,>
				,CASE 
					WHEN (SELECT COUNT(*) FROM galocmst where galoc_loc_no = AG.agloc_loc_no) > 0
					THEN (SELECT GL.intAccountSegmentId FROM galocmst LEFT OUTER JOIN	tblGLAccountSegment GL 
						  ON galoc_gl_profit_center = CAST(GL.strCode AS INT) WHERE galoc_loc_no = AG.agloc_loc_no)
					ELSE 
						GL.intAccountSegmentId 
					END --AG.[agloc_gl_profit_center]		--<intProfitCenter, int,>				--TODO
				--,CA.[inti21Id]						--<agloc_cash, int,>
				,0									--<intDepositAccount, int,>
				,0									--<intARAccount, int,>
				,0									--<intAPAccount, int,>
				,0									--<intSalesAdvAcct, int,>
				,0									--<intPurchaseAdvAccount, int,>
				,0									--<intFreightAPAccount, int,>
				,FE.[inti21Id]						--<intFreightExpenses, int,>
				,FI.[inti21Id]						--<intFreightIncome, int,>
				,SC.[inti21Id]						--<intServiceCharges, int,>
				,SD.[inti21Id]						--<intSalesDiscounts, int,>
				,OS.[inti21Id]						--<intCashOverShort, int,>
				,WO.[inti21Id]						--<intWriteOff, int,>
				,CF.[inti21Id]						--<intCreditCardFee, int,>
				,0									--<intSalesAccount, int,>
				,0									--<intCostofGoodsSold, int,>
				,0									--<intInventory, int,>
				,CA.[inti21Id]						--[intUndepositedFundsId] <agloc_cash, int,> 
				,(CASE UPPER(AG.[agloc_ivc_type_phs7])
					WHEN ''P''	THEN	''Plain full page''
					WHEN ''H''	THEN	''Plain half page''
					WHEN ''S''	THEN	''Special 7 inch''
					WHEN ''7''	THEN	''Plain 7 inch''
					ELSE ''''
				  END)								--<strInvoiceType, nvarchar(50),>
				,AG.[agloc_ivc_prtr_name]			--<strDefaultInvoicePrinter, nvarchar(50),>
				,(CASE 
					WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''P''
						THEN	''Pick Ticket''
					WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''M''
						THEN	''Mix Sheet''
					WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''S''
						THEN	''Scale Tops''
					WHEN AG.[agloc_dflt_pic_tkt_type_pms] IS NOT NULL AND UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) NOT IN (''P'',''M'',''S'')
						THEN	''Plain 7 inch''
					ELSE ''''
				  END)								--<strPickTicketType, nvarchar(50),>
				,AG.[agloc_pic_prtr_name]			--<strDefaultTicketPrinter, nvarchar(50),>
				--,AG.[agloc_last_ord_no]				--<strLastOrderNumber, nvarchar(50),>
				--,AG.[agloc_last_ivc_no]				--<strLastInvoiceNumber, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_ivc_prt_ipo])
					WHEN ''I''	THEN	''Item''
					WHEN ''P''	THEN	''Package''
					WHEN ''O''	THEN	''Ordered''
					ELSE ''''
				  END)								--<strPrintonInvoice, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_prt_cnt_bal_ynu])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnPrintContractBalance, bit,>
				,[agloc_merchant]					--<strJohnDeereMerchant, nvarchar(50),>
				,(CASE 
					WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment1])) <> ''''
						THEN	SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment1])), 0, 49)
					WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment2])) <> ''''
						THEN	SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment2])), 0, 49)
					WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment3])) <> ''''
						THEN	SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment3])), 0, 49)
					WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment4])) <> ''''
						THEN	SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment4])), 0, 49)
					WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment5])) <> ''''
						THEN	SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment5])), 0, 49)			
					ELSE ''''
				  END)								--<strInvoiceComments, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_ord_for_ivc_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnUseOrderNumberforInvoiceNumber, bit,>
				,(CASE UPPER(AG.[agloc_override_ord_ivc_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnOverrideOrderInvoiceNumber, bit,>
				,(CASE UPPER(AG.[agloc_prt_ivc_med_tags_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnPrintInvoiceMedTags, bit,>
				,(CASE UPPER(AG.[agloc_prt_pic_med_tags_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnPrintPickTicketMedTags, bit,>
				,(CASE UPPER(AG.[agloc_send_to_et_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnSendtoEnergyTrac, bit,>
				,''''									--<strDiscountScheduleType, nvarchar(50),>
				,''''									--<strLocationDiscount, nvarchar(50),>
				,''''									--<strLocationStorage, nvarchar(50),>
				,''''									--<strMarketZone, nvarchar(50),>
				,''''									--<strLastTicket, nvarchar(50),>
				,0									--<ysnDirectShipLocation, bit,>
				,0									--<ysnScaleInstalled, bit,>
				,''''									--<strDefaultScaleId, nvarchar(50),>
				,0									--<ysnActive, bit,>
				,(CASE UPPER(AG.[agloc_csh_drwr_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnUsingCashDrawer, bit,>
				,[agloc_csh_drwr_dev_id]			--<strCashDrawerDeviceId, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_reg_tape_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnPrintRegisterTape, bit,>
				,(CASE UPPER(AG.[agloc_upc_ord_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnUseUPConOrders, bit,>
				,(CASE UPPER(AG.[agloc_upc_phy_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnUseUPConPhysical, bit,>
				,(CASE UPPER(AG.[agloc_upc_pur_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnUseUPConPurchaseOrders, bit,>
				,(CASE UPPER(AG.[agloc_upc_search_ui])
					WHEN ''U''	THEN	''UPC Code''
					WHEN ''I''	THEN	''Item Code''
					ELSE ''''
				  END)								--<strUPCSearchSequence, nvarchar(50),>
				,[agloc_bar_code_prtr]				--<strBarCodePrinterName, nvarchar(50),>
				,[agloc_prc1_desc]					--<strPriceLevel1, nvarchar(50),>
				,[agloc_prc2_desc]					--<strPriceLevel2, nvarchar(50),>
				,[agloc_prc3_desc]					--<strPriceLevel3, nvarchar(50),>
				,[agloc_prc4_desc]					--<strPriceLevel4, nvarchar(50),>
				,[agloc_prc5_desc]					--<strPriceLevel5, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_gen_ovr_short_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnOverShortEntries, bit,>
				,''''									--<strOverShortCustomer, nvarchar(50),>
				,''''									--<strOverShortAccount, nvarchar(50),>
				,(CASE UPPER(AG.[agloc_auto_dep_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnAutomaticCashDepositEntries, bit,>
				,0
			FROM
				aglocmst AG	
			LEFT JOIN
				tblGLCOACrossReference CA
					ON AG.[agloc_cash] = CA.strExternalId
			LEFT JOIN
				tblGLCOACrossReference FE
					ON AG.[agloc_frt_exp_acct_no] = FE.strExternalId
			LEFT JOIN
				tblGLCOACrossReference FI
					ON AG.[agloc_frt_inc_acct_no] = FI.strExternalId
			LEFT JOIN
				tblGLCOACrossReference SC
					ON AG.[agloc_srvchr] = SC.strExternalId	
			LEFT JOIN
				tblGLCOACrossReference SD
					ON AG.[agloc_disc_taken] = SD.strExternalId	
			LEFT JOIN
				tblGLCOACrossReference OS
					ON AG.[agloc_over_short] = OS.strExternalId
			LEFT JOIN
				tblGLCOACrossReference WO
					ON AG.[agloc_write_off] = WO.strExternalId	
			LEFT JOIN
				tblGLCOACrossReference CF
					ON AG.[agloc_ccfee_percent] = CF.strExternalId
			LEFT OUTER JOIN
				tblSMCompanyLocation CL
					ON RTRIM(LTRIM(AG.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))	
			LEFT JOIN
				tblGLAccountSegment GL
					ON AG.agloc_gl_profit_center = CAST(GL.strCode AS INT)									
			WHERE
				CL.[strLocationNumber] IS NULL
				
			ORDER BY
				AG.[agloc_loc_no]
				,AG.[agloc_name]
				
			--IMPORT GRAIN LOCATIONS
			INSERT INTO [tblSMCompanyLocation]
				([strLocationNumber]
				,[strLocationName]	
				,[strLocationType]
				,[strStateProvince]
				,[strPhone]
				,[strFax]
				,[strEmail]
				,[strWebsite]
				,[strInternalNotes]
				,[strUseLocationAddress]
				,[strSkipSalesmanDefault]
				,[ysnSkipTermsDefault]
				,[strOrderTypeDefault]
				,[strPrintCashReceipts]
				,[ysnPrintCashTendered]
				,[strSalesTaxByLocation]
				,[strDeliverPickupDefault]
				,[ysnOverridePatronage]
				,[strOutOfStockWarning]
				,[strLotOverdrawnWarning]
				,[ysnOrderSection2Required]
				,[strPrintonPO]
				,[dblMixerSize]
				,[ysnOverrideMixerSize]
				,[ysnEvenBatches]
				,[ysnDefaultCustomBlend]
				,[ysnAgroguideInterface]
				,[ysnLocationActive]
				,[intProfitCenter]
				--,[intCashAccount]
				,[intDepositAccount]
				,[intARAccount]
				,[intAPAccount]
				,[intSalesAdvAcct]
				,[intPurchaseAdvAccount]
				,[intFreightAPAccount]
				,[intFreightExpenses]
				,[intFreightIncome]
				,[intServiceCharges]
				,[intSalesDiscounts]
				,[intCashOverShort]
				,[intWriteOff]
				,[intCreditCardFee]
				,[intSalesAccount]
				,[intCostofGoodsSold]
				,[intInventory]
				,[intUndepositedFundsId]
				,[strInvoiceType]
				,[strPickTicketType]
				,[strPrintonInvoice]
				,[ysnPrintContractBalance]
				,[strInvoiceComments]
				,[ysnUseOrderNumberforInvoiceNumber]
				,[ysnOverrideOrderInvoiceNumber]
				,[ysnPrintInvoiceMedTags]
				,[ysnPrintPickTicketMedTags]
				,[ysnSendtoEnergyTrac]
				,[strDiscountScheduleType]
				,[strLocationDiscount]
				,[strLocationStorage]
				,[strMarketZone]
				,[strLastTicket]
				,[ysnDirectShipLocation]
				,[ysnScaleInstalled]
				,[strDefaultScaleId]
				,[ysnActive]
				,[ysnUsingCashDrawer]
				,[ysnPrintRegisterTape]
				,[ysnUseUPConOrders]
				,[ysnUseUPConPhysical]
				,[ysnUseUPConPurchaseOrders]
				,[strUPCSearchSequence]
				,[ysnOverShortEntries]
				,[strOverShortCustomer]
				,[strOverShortAccount]
				,[ysnAutomaticCashDepositEntries]
				,[intConcurrencyId])

			SELECT
				GA.[galoc_loc_no]
				,RTRIM(LTRIM(GA.[galoc_desc])) + '' - '' + RTRIM(LTRIM(GA.[galoc_loc_no])) --<strLocationName, nvarchar(50),>
				,''Office''							--<strLocationType, nvarchar(50),>
				,[galoc_state]						--<strStateProvince, nvarchar(50),>
				,''''									--<strPhone, nvarchar(50),>
				,''''									---<strFax, nvarchar(50),>
				,''''									--<strEmail, nvarchar(50),>
				,''''									--<strWebsite, nvarchar(50),>
				,''''									--<strInternalNotes, nvarchar(max),>
				,''''								--<strUseLocationAddress, nvarchar(50),>
				,''''								--<strSkipSalesmanDefault, nvarchar(50),>
				,''''								--<ysnSkipTermsDefault, bit,>
				,''''								--<strOrderTypeDefault, nvarchar(50),>
				,''''								--<strPrintCashReceipts, nvarchar(50),>
				,0								--<ysnPrintCashTendered, bit,>
				,''''								--<strSalesTaxByLocation, nvarchar(50),>
				,''''								--<strDeliverPickupDefault, nvarchar(50),>
				,0								--<ysnOverridePatronage, bit,>
				,''Not Allowed''					--<strOutOfStockWarning, nvarchar(50),>
				,''''								--<strLotOverdrawnWarning, nvarchar(50),>			
				,0								--<ysnOrderSection2Required, bit,>
				,''''								--<strPrintonPO, nvarchar(50),>
				,0								--<dblMixerSize, numeric(18,6),>
				,0								--<ysnOverrideMixerSize, bit,>
				,0								--<ysnEvenBatches, bit,>
				,0								--<ysnDefaultCustomBlend, bit,>
				,0								--<ysnAgroguideInterface, bit,>
				,(CASE UPPER(GA.[galoc_active_yn])
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnLocationActive, bit,>
				,GL.intAccountSegmentId AS intProfitCenter --GA.[galoc_gl_profit_center]		--<intProfitCenter, int,>				--TODO
				--,CA.[inti21Id]						--<[galoc_gl_cash], int,>
				,DA.[inti21Id]						--<intDepositAccount, int,>
				,ARA.[inti21Id]						--<intARAccount, int,>
				,APA.[inti21Id]						--<intAPAccount, int,>
				,SAA.[inti21Id]						--<intSalesAdvAcct, int,>
				,PAA.[inti21Id]						--<intPurchaseAdvAccount, int,>
				,FAP.[inti21Id]						--<intFreightAPAccount, int,>
				,0									--<intFreightExpenses, int,>
				,0									--<intFreightIncome, int,>
				,0									--<intServiceCharges, int,>
				,0									--<intSalesDiscounts, int,>
				,0									--<intCashOverShort, int,>
				,0									--<intWriteOff, int,>
				,0									--<intCreditCardFee, int,>
				,0									--<intSalesAccount, int,>
				,0									--<intCostofGoodsSold, int,>
				,0									--<intInventory, int,>
				,CA.[inti21Id]						--[intUndepositedFundsId] <[galoc_gl_cash], int,>
				,''''									--<strInvoiceType, nvarchar(50),>
				,''''									--<strPickTicketType, nvarchar(50),>
				,''''									--<strPrintonInvoice, nvarchar(50),>
				,0									--<ysnPrintContractBalance, bit,>
				,''''									--<strInvoiceComments, nvarchar(50),>
				,0									--<ysnUseOrderNumberforInvoiceNumber, bit,>
				,0									--<ysnOverrideOrderInvoiceNumber, bit,>
				,0									--<ysnPrintInvoiceMedTags, bit,>
				,0									--<ysnPrintPickTicketMedTags, bit,>
				,0									--<ysnSendtoEnergyTrac, bit,>
				,''''									--<strDiscountScheduleType, nvarchar(50),>
				,GA.galoc_disc_schd_loc				--<strLocationDiscount, nvarchar(50),>
				,GA.galoc_stor_schd_loc				--<strLocationStorage, nvarchar(50),>
				,GA.galoc_dflt_mkt_zone				--<strMarketZone, nvarchar(50),>
				,GA.galoc_last_tic_no				--<strLastTicket, nvarchar(50),>
				,(CASE UPPER(GA.galoc_direct_ship_yn)
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnDirectShipLocation, bit,>
				,(CASE UPPER(GA.galoc_scale_interfaced_yn)
					WHEN ''Y''	THEN	1
					WHEN ''N''	THEN	0
					ELSE 0
				  END)								--<ysnScaleInstalled, bit,>
				,''''									--<strDefaultScaleId, nvarchar(50),>
				,0									--<ysnActive, bit,>
				,0									--<ysnUsingCashDrawer, bit,>		
				,0									--<ysnPrintRegisterTape, bit,>
				,0									--<ysnUseUPConOrders, bit,>
				,0									--<ysnUseUPConPhysical, bit,>
				,0									--<ysnUseUPConPurchaseOrders, bit,>
				,''''									--<strUPCSearchSequence, nvarchar(50),>
				,0									--<ysnOverShortEntries, bit,>
				,''''									--<strOverShortCustomer, nvarchar(50),>
				,''''									--<strOverShortAccount, nvarchar(50),>
				,0									--<ysnAutomaticCashDepositEntries, bit,>
				,0
			FROM
				galocmst GA	
			LEFT JOIN
				tblGLCOACrossReference CA
					ON GA.[galoc_gl_cash] = CA.strExternalId
			LEFT JOIN
				tblGLCOACrossReference DA
					ON GA.[galoc_gl_dep]    = DA.strExternalId
			LEFT JOIN
				tblGLCOACrossReference ARA
					ON GA.[galoc_gl_ar]     = ARA.strExternalId
			LEFT JOIN
				tblGLCOACrossReference APA
					ON GA.[galoc_gl_ap]     = APA.strExternalId	
			LEFT JOIN
				tblGLCOACrossReference SAA
					ON GA.galoc_gl_sls_adv  = SAA.strExternalId	
			LEFT JOIN
				tblGLCOACrossReference PAA
					ON GA.galoc_gl_pur_adv  = PAA.strExternalId
			LEFT JOIN
				tblGLCOACrossReference FAP
					ON GA.galoc_gl_frt_ap   = FAP.strExternalId	
			LEFT OUTER JOIN
				tblSMCompanyLocation CL
					ON RTRIM(LTRIM(GA.[galoc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))	
			LEFT JOIN
				tblGLAccountSegment GL
					ON GA.galoc_gl_profit_center = CAST(GL.strCode AS INT)									
			WHERE 	CL.[strLocationNumber] IS NULL AND NOT exists (SELECT * FROM aglocmst AG WHERE AG.agloc_loc_no = GA.galoc_loc_no)									
				
			ORDER BY
				GA.[galoc_loc_no]
				,GA.[galoc_desc]

			--IMPORTS AG PRICE LEVELS FOR EACH LOCATION
			-- AG PRICE LEVEL 1--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc1_desc,
					1,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc1_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc1_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 2--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc2_desc,
					2,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc2_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc2_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 3--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc3_desc,
					3,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc3_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc3_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 4--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc4_desc,
					4,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc4_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc4_desc COLLATE Latin1_General_CI_AS)
			-- AG PRICE LEVEL 5--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc5_desc,
					5,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc5_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc5_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 6--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc6_desc,
					6,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc6_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc6_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 7--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc7_desc,
					7,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc7_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc7_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 8--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc8_desc,
					8,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc8_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc8_desc COLLATE Latin1_General_CI_AS) 
			-- AG PRICE LEVEL 9--
			INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
					   ([intCompanyLocationId]
					   ,[strPricingLevelName]
					   ,[intSort]
					   ,[intConcurrencyId])
			SELECT  CL.[intCompanyLocationId], 
					AL.agloc_prc9_desc,
					9,
					1
			FROM  
				tblSMCompanyLocation CL 
			   INNER JOIN  
				  aglocmst AL 
				  ON RTRIM(LTRIM(AL.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
				WHERE AL.agloc_prc9_desc IS NOT NULL AND [intCompanyLocationId] NOT IN (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
				WHERE [strPricingLevelName] COLLATE Latin1_General_CI_AS = AL.agloc_prc9_desc COLLATE Latin1_General_CI_AS)
		END
		')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspSMImportCompanyLocation  
   @Checking BIT = 0,  
   @UserId INT = 0,  
   @Total INT = 0 OUTPUT  
  
   AS  
  BEGIN  
     
   --================================================  
   --     GET TO BE IMPORTED RECORDS  
   -- This is checking if there are still records need to be import   
   --================================================  
   IF(@Checking = 1)   
   BEGIN  
    --Check first on ptlocmst   
    SELECT  
     @Total = COUNT(PT.[ptloc_loc_no])  
    FROM  
     ptlocmst PT  
    LEFT OUTER JOIN  
     tblSMCompanyLocation CL  
      ON RTRIM(LTRIM(PT.[ptloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))            
    WHERE  
     CL.[strLocationNumber] IS NULL  
        
    RETURN @Total  
   END   
      
   INSERT INTO [tblSMCompanyLocation]  
    ([strLocationNumber]  
    ,[strLocationName]   
    ,[strLocationType]  
    ,[strAddress]  
    ,[strZipPostalCode]  
    ,[strCity]  
    ,[strStateProvince]  
    ,[strCountry]  
    ,[strPhone]  
    ,[strFax]  
    ,[strEmail]  
    ,[strWebsite]  
    ,[strInternalNotes]  
    ,[strUseLocationAddress]  
    ,[strSkipSalesmanDefault]  
    ,[ysnSkipTermsDefault]  
    ,[strOrderTypeDefault]  
    ,[strPrintCashReceipts]  
    ,[ysnPrintCashTendered]  
    ,[strSalesTaxByLocation]  
    ,[strDeliverPickupDefault]  
    ,[strTaxState]  
    ,[strTaxAuthorityId1]  
    ,[strTaxAuthorityId2]  
    ,[ysnOverridePatronage]  
    ,[strOutOfStockWarning]  
    ,[strLotOverdrawnWarning]  
    ,[strDefaultCarrier]  
    ,[ysnOrderSection2Required]  
    ,[strPrintonPO]  
    ,[dblMixerSize]  
    ,[ysnOverrideMixerSize]  
    ,[ysnEvenBatches]  
    ,[ysnDefaultCustomBlend]  
    ,[ysnAgroguideInterface]  
    ,[ysnLocationActive]  
    ,[intProfitCenter]  
    --,[intCashAccount]  
    ,[intDepositAccount]  
    ,[intARAccount]  
    ,[intAPAccount]  
    ,[intSalesAdvAcct]  
    ,[intPurchaseAdvAccount]  
    ,[intFreightAPAccount]  
    ,[intFreightExpenses]  
    ,[intFreightIncome]  
    ,[intServiceCharges]  
    ,[intSalesDiscounts]  
    ,[intCashOverShort]  
    ,[intWriteOff]  
    ,[intCreditCardFee]  
    ,[intSalesAccount]  
    ,[intCostofGoodsSold]  
    ,[intInventory]  
	,[intUndepositedFundsId]
    ,[strInvoiceType]  
    ,[strDefaultInvoicePrinter]  
    ,[strPickTicketType]  
    ,[strDefaultTicketPrinter]  
    --,[strLastOrderNumber]  
    --,[strLastInvoiceNumber]  
    ,[strPrintonInvoice]  
    ,[ysnPrintContractBalance]  
    ,[strJohnDeereMerchant]  
    ,[strInvoiceComments]  
    ,[ysnUseOrderNumberforInvoiceNumber]  
    ,[ysnOverrideOrderInvoiceNumber]  
    ,[ysnPrintInvoiceMedTags]  
    ,[ysnPrintPickTicketMedTags]  
    ,[ysnSendtoEnergyTrac]  
    ,[strDiscountScheduleType]  
    ,[strLocationDiscount]  
    ,[strLocationStorage]  
    ,[strMarketZone]  
    ,[strLastTicket]  
    ,[ysnDirectShipLocation]  
    ,[ysnScaleInstalled]  
    ,[strDefaultScaleId]  
    ,[ysnActive]  
    ,[ysnUsingCashDrawer]  
    ,[strCashDrawerDeviceId]  
    ,[ysnPrintRegisterTape]  
    ,[ysnUseUPConOrders]  
    ,[ysnUseUPConPhysical]  
    ,[ysnUseUPConPurchaseOrders]  
    ,[strUPCSearchSequence]  
    ,[strBarCodePrinterName]  
    ,[strPriceLevel1]  
    ,[strPriceLevel2]  
    ,[strPriceLevel3]  
    ,[strPriceLevel4]  
    ,[strPriceLevel5]  
    ,[ysnOverShortEntries]  
    ,[strOverShortCustomer]  
    ,[strOverShortAccount]  
    ,[ysnAutomaticCashDepositEntries]  
    ,[intConcurrencyId])  
   SELECT  
    PT.[ptloc_loc_no]  
    ,(CASE WHEN EXISTS(SELECT [ptloc_loc_no], [ptloc_name] FROM ptlocmst WHERE RTRIM(LTRIM([ptloc_loc_no])) <> RTRIM(LTRIM(PT.[ptloc_loc_no])) AND RTRIM(LTRIM([ptloc_name])) = RTRIM(LTRIM(PT.[ptloc_name])))  
     THEN   
      RTRIM(LTRIM(PT.[ptloc_name])) + '' - '' + RTRIM(LTRIM(PT.[ptloc_loc_no]))  
     ELSE  
      RTRIM(LTRIM(PT.[ptloc_name]))  
      END)        --<strLocationName, nvarchar(50),>  
    ,''Office''       --<strLocationType, nvarchar(50),>  
    ,RTRIM(LTRIM(ISNULL(PT.[ptloc_addr],'''')))        --<strAddress, nvarchar(max),>  
    ,[ptloc_zip]      --<strZipPostalCode, nvarchar(50),>  
    ,[ptloc_city]      --<strCity, nvarchar(50),>  
    ,[ptloc_state]      --<strStateProvince, nvarchar(50),>  
    ,''''				     --<strCountry, nvarchar(50),>  
    ,(CASE   
     WHEN CHARINDEX(''x'', PT.[ptloc_phone]) > 0   
      THEN SUBSTRING(SUBSTRING(PT.[ptloc_phone],1,15), 0, CHARINDEX(''x'',PT.[ptloc_phone]))   
     ELSE   
      SUBSTRING(PT.[ptloc_phone],1,15)  
      END)        --<strPhone, nvarchar(50),>  
    ,''''         ---<strFax, nvarchar(50),>  
    ,''''         --<strEmail, nvarchar(50),>  
    ,''''         --<strWebsite, nvarchar(50),>  
    ,''''         --<strInternalNotes, nvarchar(max),>  
    ,(CASE UPPER(PT.[ptloc_use_loc_addr_yn])  
     WHEN ''Y'' THEN ''Yes''  
     WHEN ''N'' THEN ''No''   
     ELSE ''''  
      END)        --<strUseLocationAddress, nvarchar(50),>  
    ,''Yes''        --<strSkipSalesmanDefault, nvarchar(50),>  
    ,0            --<ysnSkipTermsDefault, bit,>  
    ,(CASE UPPER(PT.[ptloc_dflt_tic_type_oi])  
     WHEN ''O'' THEN ''Order''  
     WHEN ''I'' THEN ''Invoice''      
     ELSE ''''  
      END)        --<strOrderTypeDefault, nvarchar(50),>  
    ,(CASE UPPER(PT.[ptloc_cash_rcts_ynr])  
     WHEN ''Y'' THEN ''Yes''  
     WHEN ''N'' THEN ''No''  
     WHEN ''R'' THEN ''Cash Receipts Printer''      
     ELSE ''''  
      END)        --<strPrintCashReceipts, nvarchar(50),>  
    ,(CASE UPPER(PT.[ptloc_cash_tender_yn])  
     WHEN ''Y'' THEN 1  
     WHEN ''N'' THEN 0  
     ELSE 0  
      END)        --<ysnPrintCashTendered, bit,>  
    ,''No''        --<strSalesTaxByLocation, nvarchar(50),>  
    ,(CASE UPPER(PT.[ptloc_dlvry_pickup_ind])  
     WHEN ''P'' THEN ''Pickup''  
     WHEN ''D'' THEN ''Deliver''  
     ELSE ''''  
      END)        --<strDeliverPickupDefault, nvarchar(50),>  
    ,''''    --<strTaxState, nvarchar(50),>  
    ,''''   --<strTaxAuthorityId1, nvarchar(50),>  
    ,''''   --<strTaxAuthorityId2, nvarchar(50),>  
    ,0        --<ysnOverridePatronage, bit,>  
    ,''No''        --<strOutOfStockWarning, nvarchar(50),>  
    ,''No''        --<strLotOverdrawnWarning, nvarchar(50),>  
    ,PT.[ptloc_default_carrier]   --<strDefaultCarrier, nvarchar(50),>  
    ,0        --<ysnOrderSection2Required, bit,>  
    ,''''        --<strPrintonPO, nvarchar(50),>  
    ,0     --<dblMixerSize, numeric(18,6),>  
    ,0        --<ysnOverrideMixerSize, bit,>  
    ,0        --<ysnEvenBatches, bit,>  
    ,0        --<ysnDefaultCustomBlend, bit,>  
    ,0        --<ysnAgroguideInterface, bit,>  
    ,1        --<ysnLocationActive, bit,>  
    ,GL.intAccountSegmentId AS intProfitCenter --PT.[ptloc_gl_profit_center]  --<intProfitCenter, int,>    --TODO      
    --,0      --<ptloc_cash, int,>  
    ,0         --<intDepositAccount, int,>  
    ,0         --<intARAccount, int,>  
    ,0         --<intAPAccount, int,>  
    ,0         --<intSalesAdvAcct, int,>  
    ,0         --<intPurchaseAdvAccount, int,>  
    ,0         --<intFreightAPAccount, int,>  
    ,FE.[inti21Id]      --<intFreightExpenses, int,>  
    ,FI.[inti21Id]      --<intFreightIncome, int,>  
    ,0      --<intServiceCharges, int,>  
    ,0      --<intSalesDiscounts, int,>  
    ,0      --<intCashOverShort, int,>  
    ,0      --<intWriteOff, int,>  
    ,0      --<intCreditCardFee, int,>  
    ,0         --<intSalesAccount, int,>  
    ,0         --<intCostofGoodsSold, int,>  
    ,0         --<intInventory, int,>  
	,0		-- [intUndepositedFundsId] <ptloc_cash, int,>  
    ,(CASE UPPER(PT.[ptloc_ivc_type_fpl])  
     WHEN ''F'' THEN ''Forms''  
     WHEN ''L'' THEN ''Laser''  
     WHEN ''P'' THEN ''Plain Paper''  
     ELSE ''''  
      END)        --<strInvoiceType, nvarchar(50),>  
    ,PT.[ptloc_ivc_prtr_name]   --<strDefaultInvoicePrinter, nvarchar(50),>  
    ,''''        --<strPickTicketType, nvarchar(50),>  
    ,PT.[ptloc_pik_prtr_name]   --<strDefaultTicketPrinter, nvarchar(50),>  
    --,PT.[ptloc_last_ord_no]    --<strLastOrderNumber, nvarchar(50),>  
    --,PT.[ptloc_last_ivc_no]    --<strLastInvoiceNumber, nvarchar(50),>  
    ,''''        --<strPrintonInvoice, nvarchar(50),>  
    ,0        --<ysnPrintContractBalance, bit,>  
    ,PT.[ptloc_merchant]     --<strJohnDeereMerchant, nvarchar(50),>  
    ,''''        --<strInvoiceComments, nvarchar(50),>  
    ,0        --<ysnUseOrderNumberforInvoiceNumber, bitint  
    ,0       --<ysnOverrideOrderInvoiceNumber, bit,>  
    ,0        --<ysnPrintInvoiceMedTags, bit,>  
    ,0        --<ysnPrintPickTicketMedTags, bit,>  
    ,(CASE UPPER(PT.[ptloc_send_to_et_yn])  
     WHEN ''Y'' THEN 1  
     WHEN ''N'' THEN 0  
     ELSE 0  
      END)        --<ysnSendtoEnergyTrac, bit,>  
    ,''''         --<strDiscountScheduleType, nvarchar(50),>  
    ,''''         --<strLocationDiscount, nvarchar(50),>  
    ,''''         --<strLocationStorage, nvarchar(50),>  
    ,''''         --<strMarketZone, nvarchar(50),>  
    ,''''         --<strLastTicket, nvarchar(50),>  
    ,0         --<ysnDirectShipLocation, bit,>  
    ,0         --<ysnScaleInstalled, bit,>  
    ,''''         --<strDefaultScaleId, nvarchar(50),>  
    ,0         --<ysnActive, bit,>  
    ,(CASE UPPER(PT.[ptloc_csh_drwr_yn])  
     WHEN ''Y'' THEN 1  
     WHEN ''N'' THEN 0  
     ELSE 0  
      END)        --<ysnUsingCashDrawer, bit,>  
    ,[ptloc_csh_drwr_dev_id]   --<strCashDrawerDeviceId, nvarchar(50),>  
    ,(CASE UPPER(PT.[ptloc_reg_tape_yn])  
     WHEN ''Y'' THEN 1  
     WHEN ''N'' THEN 0  
     ELSE 0  
      END)        --<ysnPrintRegisterTape, bit,>  
    ,(CASE UPPER(PT.[ptloc_upc_for_inv_yn])  
     WHEN ''Y'' THEN 1  
     WHEN ''N'' THEN 0  
     ELSE 0  
      END)        --<ysnUseUPConOrders, bit,>  
    ,0        --<ysnUseUPConPhysical, bit,>  
    ,0        --<ysnUseUPConPurchaseOrders, bit,>  
    ,(CASE UPPER(PT.[ptloc_upc_search_ui])  
     WHEN ''U'' THEN ''UPC''  
     WHEN ''I'' THEN ''Item''  
     ELSE ''''  
      END)        --<strUPCSearchSequence, nvarchar(50),>  
    ,[ptloc_bar_code_prtr]    --<strBarCodePrinterName, nvarchar(50),>  
    ,''''     --<strPriceLevel1, nvarchar(50),>  
    ,''''     --<strPriceLevel2, nvarchar(50),>  
    ,''''     --<strPriceLevel3, nvarchar(50),>  
    ,''''     --<strPriceLevel4, nvarchar(50),>  
    ,''''     --<strPriceLevel5, nvarchar(50),>  
    ,0        --<ysnOverShortEntries, bit,>  
    ,''''         --<strOverShortCustomer, nvarchar(50),>  
    ,''''         --<strOverShortAccount, nvarchar(50),>  
    ,0        --<ysnAutomaticCashDepositEntries, bit,>  
    ,0  
   FROM  
    ptlocmst PT   
   LEFT JOIN  
    tblGLCOACrossReference FE  
     ON PT.[ptloc_frt_exp_acct_no] = FE.strExternalId  
   LEFT JOIN  
    tblGLCOACrossReference FI  
     ON PT.[ptloc_frt_inc_acct_no] = FI.strExternalId        
   LEFT OUTER JOIN  
    tblSMCompanyLocation CL  
     ON RTRIM(LTRIM(PT.[ptloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))            
   LEFT JOIN
	tblGLAccountSegment GL 
	 ON PT.[ptloc_gl_profit_center] = CAST(GL.[strCode] AS INT)
   WHERE  
    CL.[strLocationNumber] IS NULL  
      
   ORDER BY  
    PT.[ptloc_loc_no]  
    ,PT.[ptloc_name]  
  
    --IMPORT PRICE LEVEL FOR EACH LOCATION

	--PRICE LEVEL 1
	INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
           ([intCompanyLocationId]
           ,[strPricingLevelName]
           ,[intSort]
           ,[intConcurrencyId])
	SELECT  CL.[intCompanyLocationId], 
	        PT.pt3cf_prc1,
			1,
			1
	FROM  tblSMCompanyLocation CL 
	INNER JOIN ptlocmst PL 
		ON RTRIM(LTRIM(PL.[ptloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
	LEFT OUTER JOIN ptctlmst PT 
		ON  PT.ptctl_key = 3
	where [intCompanyLocationId] not in (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
										 where [strPricingLevelName] COLLATE Latin1_General_CI_AS = PT.pt3cf_prc1 COLLATE Latin1_General_CI_AS) 
	--PRICE LEVEL 2
	INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
           ([intCompanyLocationId]
           ,[strPricingLevelName]
           ,[intSort]
           ,[intConcurrencyId])
	SELECT  CL.[intCompanyLocationId], 
	        PT.pt3cf_prc2,
			2,
			1
	FROM  tblSMCompanyLocation CL 
	INNER JOIN ptlocmst PL 
		ON RTRIM(LTRIM(PL.[ptloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
	LEFT OUTER JOIN ptctlmst PT 
		ON  PT.ptctl_key = 3
	where [intCompanyLocationId] not in (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
										 where [strPricingLevelName] COLLATE Latin1_General_CI_AS = PT.pt3cf_prc2 COLLATE Latin1_General_CI_AS) 

	--PRICE LEVEL 3
	INSERT INTO [dbo].[tblSMCompanyLocationPricingLevel]
           ([intCompanyLocationId]
           ,[strPricingLevelName]
           ,[intSort]
           ,[intConcurrencyId])
	SELECT  CL.[intCompanyLocationId], 
	        PT.pt3cf_prc3,
			3,
			1
	FROM  tblSMCompanyLocation CL 
	INNER JOIN ptlocmst PL 
		ON RTRIM(LTRIM(PL.[ptloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS) )        
	LEFT OUTER JOIN ptctlmst PT 
		ON  PT.ptctl_key = 3
	where [intCompanyLocationId] not in (select [intCompanyLocationId] from tblSMCompanyLocationPricingLevel
										 where [strPricingLevelName] COLLATE Latin1_General_CI_AS = PT.pt3cf_prc3 COLLATE Latin1_General_CI_AS)   
  END'
  )
END
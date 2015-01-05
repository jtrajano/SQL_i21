GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMSyncCompanyLocation')
	DROP PROCEDURE uspSMSyncCompanyLocation
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspSMSyncCompanyLocation  
	@ToOrigin   bit    = 0  
	,@LocationNumbers nvarchar(MAX) = ''all''  
	,@AddedCount  int    = 0 OUTPUT  
	,@UpdatedCount  int    = 0 OUTPUT  
AS  
BEGIN  
  
   IF (@ToOrigin = 1)  
    BEGIN  
     SELECT intCompanyLocationId   
     INTO #Temp  
     FROM dbo.[tblSMCompanyLocation]   
     WHERE strLocationNumber IS NULL OR RTRIM(LTRIM(strLocationNumber)) = ''''
     ORDER BY intCompanyLocationId  
       
     WHILE(EXISTS(SELECT TOP 1 1 FROM #Temp))  
      BEGIN  
       DECLARE @MaxNumber int  
       DECLARE @TopLocId int  
       SELECT @TopLocId = intCompanyLocationId FROM #Temp ORDER BY intCompanyLocationId  
       SELECT @MaxNumber = MAX([agloc_loc_no]) FROM aglocmst  
         
       --IF(EXISTS(SELECT NULL FROM aglocmst WHERE ISNUMERIC([agloc_loc_no]) = 0) OR @MaxNumber > 998)  
       -- BEGIN  
  
       -- END  
       --ELSE  
       -- BEGIN  
  
         --UPDATE tblSMCompanyLocation -- Uncomment Once strLocationNumberhas been adde to strLocationNumber  
         --SET strLocationNumber = @MaxNumber + 1  
         --WHERE intCompanyLocationId = @TopLocId  
        --END  
          
       DELETE FROM #Temp WHERE intCompanyLocationId = @TopLocId  
      END   
        
     DROP TABLE #Temp         
    END  
      
   DECLARE @RecordsToProcess table(strNumber varchar(3), strName varchar(30))  
   DECLARE @RecordsToAdd table(strNumber varchar(3), strName varchar(30))  
   DECLARE @RecordsToUpdate table(strNumber varchar(3), strName varchar(30))  
  
   DELETE FROM @RecordsToProcess  
   DELETE FROM @RecordsToAdd  
   DELETE FROM @RecordsToUpdate  
  
  
  
   IF(LOWER(@LocationNumbers) = ''all'')  
    BEGIN  
     IF (@ToOrigin = 1)  
      INSERT INTO @RecordsToProcess(strName, strNumber)
      SELECT [strLocationName], [strLocationNumber]  
      FROM tblSMCompanyLocation           
     ELSE  
      INSERT INTO @RecordsToProcess(strName, strNumber)
      SELECT [agloc_name], [agloc_loc_no]  
      FROM aglocmst    
    END  
   ELSE  
    BEGIN  
     IF (@ToOrigin = 1)     
      INSERT INTO @RecordsToProcess(strName, strNumber)
      SELECT CL.[strLocationName], CL.[strLocationNumber]  
      FROM fnGetRowsFromDelimitedValues(@LocationNumbers) T  
      INNER JOIN tblSMCompanyLocation CL ON T.[intID] = CL.[intCompanyLocationId]  
     ELSE  
      INSERT INTO @RecordsToProcess(strName, strNumber)   
      SELECT AG.[agloc_name], AG.[agloc_loc_no]  
      FROM fnGetRowsFromDelimitedValues(@LocationNumbers) T  
      INNER JOIN aglocmst AG ON T.[intID] = AG.[agloc_loc_no]          
    END    
      
   IF (@ToOrigin = 1)  
    INSERT INTO @RecordsToAdd  
    SELECT P.*  
    FROM @RecordsToProcess P  
    LEFT OUTER JOIN aglocmst AG ON P.[strNumber] = AG.[agloc_loc_no]  
    WHERE AG.[agloc_loc_no] IS NULL  
   ELSE  
    INSERT INTO @RecordsToAdd  
    SELECT P.*  
    FROM @RecordsToProcess P  
    LEFT OUTER JOIN tblSMCompanyLocation CL ON P.[strNumber] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
    WHERE CL.[strLocationNumber] IS NULL           
      
   INSERT INTO @RecordsToUpdate  
   SELECT P.*  
   FROM @RecordsToProcess P  
   LEFT JOIN @RecordsToAdd A ON P.[strNumber] = A.[strNumber]  
   WHERE A.strNumber IS NULL   
  
   IF(@ToOrigin = 1)   
    BEGIN  
       
     INSERT INTO [aglocmst]  
      ([agloc_loc_no]
      ,[agloc_name]  
      ,[agloc_addr]  
      ,[agloc_addr2]  
      ,[agloc_city]  
      ,[agloc_state]  
      ,[agloc_zip]  
      ,[agloc_country]  
      ,[agloc_phone]  
      ,[agloc_inv_by_loc_ynd]  
      ,[agloc_tax_by_loc_only_ynv]  
      ,[agloc_tax_state]  
      ,[agloc_tax_auth_id1]  
      ,[agloc_tax_auth_id2]  
      ,[agloc_csh_drwr_yn]  
      ,[agloc_csh_drwr_dev_id]  
      ,[agloc_reg_tape_yn]  
      ,[agloc_reg_tape_prtr]  
      ,[agloc_bar_code_prtr]  
      ,[agloc_pic_prtr_name]  
      ,[agloc_ivc_prtr_name]  
      ,[agloc_cnt_prtr_name]  
      ,[agloc_last_ivc_no]  
      ,[agloc_last_ord_no]  
      ,[agloc_ord_for_ivc_yn]  
      ,[agloc_override_ord_ivc_yn]  
      ,[agloc_ivc_type_phs7]  
      ,[agloc_upc_ord_yn]  
      ,[agloc_upc_rct_yn]  
      ,[agloc_upc_search_ui]  
      ,[agloc_upc_phy_yn]  
      ,[agloc_upc_pur_yn]  
      ,[agloc_mixer_size]  
      ,[agloc_override_mixer_yn]  
      ,[agloc_even_batch_yn]  
      ,[agloc_cash_rcts_ynr]  
      ,[agloc_cash_tender_yn]  
      ,[agloc_dd_clock_loc]  
      ,[agloc_season_ind_sw]  
      ,[agloc_summer_chng_rev_dt]  
      ,[agloc_dlv_tic_prtr]  
      ,[agloc_dlv_tic_no]  
      ,[agloc_dflt_lp_pct_full]  
      ,[agloc_dlv_tic_fmt]  
      ,[agloc_rdg_entry_meth_ad]  
      ,[agloc_fill_by_class_yn]  
      ,[agloc_fill_class]  
      ,[agloc_base_temp]  
      ,[agloc_winter_chng_rev_dt]  
      ,[agloc_winter_accum_dd]  
      ,[agloc_custom_blend_yn]  
      ,[agloc_dflt_dlvr_pkup_ind]  
      ,[agloc_ord_sec2_req_yn]  
      ,[agloc_item_warning_yn]  
      ,[agloc_skip_slsmn_dflt_ynrs]  
      ,[agloc_skip_terms_dflt_yn]  
      ,[agloc_override_pat_yn]  
      ,[agloc_dflt_tic_type_ois]  
      ,[agloc_dflt_pic_tkt_type_pms]  
      ,[agloc_wn_retailer_ic_cd]  
      ,[agloc_prc1_desc]  
      ,[agloc_prc2_desc]  
      ,[agloc_prc3_desc]  
      ,[agloc_prc4_desc]  
      ,[agloc_prc5_desc]  
      ,[agloc_prc6_desc]  
      ,[agloc_prc7_desc]  
      ,[agloc_prc8_desc]  
      ,[agloc_prc9_desc]  
      ,[agloc_gl_profit_center]  
      ,[agloc_frt_exp_acct_no]  
      ,[agloc_frt_inc_acct_no]  
      ,[agloc_cash]  
      ,[agloc_srvchr]  
      ,[agloc_disc_taken]  
      ,[agloc_over_short]  
      ,[agloc_ccfee_percent]  
      ,[agloc_write_off]  
      ,[agloc_gl_div_col]  
      ,[agloc_disc_by_lob_yn]  
      ,[agloc_use_addr_ynal]  
      ,[agloc_prt_cnt_bal_ynu]  
      ,[agloc_prt_ivc_med_tags_yn]  
      ,[agloc_prt_pic_med_tags_yn]  
      ,[agloc_ivc_prt_ipo]  
      ,[agloc_ivc_comment1]  
      ,[agloc_ivc_comment2]  
      ,[agloc_ivc_comment3]  
      ,[agloc_ivc_comment4]  
      ,[agloc_ivc_comment5]  
      ,[agloc_pic_comment1]  
      ,[agloc_pic_comment2]  
      ,[agloc_pic_comment3]  
      ,[agloc_pic_comment4]  
      ,[agloc_pic_comment5]  
      ,[agloc_default_carrier]  
      ,[agloc_auto_dep_yn]  
      ,[agloc_gen_ovr_short_yn]  
      ,[agloc_oth_inc_cd]  
      ,[agloc_oth_inc_cus_no]  
      ,[agloc_upd_cost_yn]  
      ,[agloc_lot_warning_yns]  
      ,[agloc_var_pct]  
      ,[agloc_po_prt_pu]  
      ,[agloc_active_yn]  
      ,[agloc_agroguide_yn]  
      ,[agloc_merchant]  
      ,[agloc_send_to_et_yn]  
      --,[agloc_user_id]  
      --,[agloc_user_rev_dt]  
      )  
     SELECT   
      CL.[strLocationNumber]   --[agloc_loc_no] 
      ,CL.[strLocationName]   --[agloc_name]  
      ,(CASE WHEN LEN(RTRIM(LTRIM(CL.[strAddress]))) > 30  
        THEN SUBSTRING(RTRIM(LTRIM(CL.[strAddress])), 0, 29)  
        ELSE LEN(RTRIM(LTRIM(CL.[strAddress])))  
       END)      --[agloc_addr]  
      ,(CASE WHEN LEN(RTRIM(LTRIM(CL.[strAddress]))) > 30  
        THEN SUBSTRING(RTRIM(LTRIM(CL.[strAddress])), 29, LEN(RTRIM(LTRIM(CL.[strAddress]))) - 31)  
        ELSE ''''  
       END)      --[agloc_addr2]  
      ,CL.[strCity]     --[agloc_city]  
      ,CL.[strStateProvince]   --[agloc_state]  
      ,CL.[strZipPostalCode]   --[agloc_zip]  
      ,C.[strCountryCode]    --[agloc_country]  
      ,CL.[strPhone]     --[agloc_phone]  
      ,''N''       --[agloc_inv_by_loc_ynd]  
      ,(CASE CL.[strSalesTaxByLocation]  
           WHEN ''Yes''  THEN ''Y''  
           WHEN ''No''  THEN ''N''  
           WHEN ''Varies'' THEN ''V''      
           ELSE ''''  
       END)       --[agloc_tax_by_loc_only_ynv]  
      ,CL.[strTaxState]    --[agloc_tax_state]  
      ,CL.[strTaxAuthorityId1]  --[agloc_tax_auth_id1]  
      ,CL.[strTaxAuthorityId2]  --[agloc_tax_auth_id2]  
      ,(CASE CL.[ysnUsingCashDrawer]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_csh_drwr_yn]  
      ,CL.[strCashDrawerDeviceId]  --[agloc_csh_drwr_dev_id]  
      ,(CASE CL.[ysnPrintRegisterTape]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_reg_tape_yn]  
      ,NULL       --[agloc_reg_tape_prtr]  
      ,CL.[strBarCodePrinterName]  --[agloc_bar_code_prtr]  
      ,CL.[strDefaultTicketPrinter] --[agloc_pic_prtr_name]  
      ,CL.[strDefaultInvoicePrinter] --[agloc_ivc_prtr_name]  
      ,NULL       --[agloc_cnt_prtr_name]  
      ,CL.[strLastInvoiceNumber]  --[agloc_last_ivc_no]  
      ,CL.[strLastOrderNumber]  --[agloc_last_ord_no]  
      ,(CASE CL.[ysnUseOrderNumberforInvoiceNumber]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_ord_for_ivc_yn]  
      ,(CASE CL.[ysnOverrideOrderInvoiceNumber]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_override_ord_ivc_yn]  
      ,(CASE CL.[strInvoiceType]  
           WHEN ''Plain full page'' THEN ''P''  
           WHEN ''Plain half page'' THEN ''H''  
           WHEN ''Special 7 inch'' THEN ''S''  
           WHEN ''Plain 7 inch''  THEN ''7''  
           ELSE ''''  
       END)      --[agloc_ivc_type_phs7]  
      ,(CASE CL.[ysnUseUPConOrders]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_upc_ord_yn]  
      ,NULL       --[agloc_upc_rct_yn]  
      ,(CASE CL.[strUPCSearchSequence]  
           WHEN ''UPC Code''  THEN ''U''  
           WHEN ''Item Code'' THEN ''I''  
           ELSE ''''  
       END)      --[agloc_upc_search_ui]  
      ,(CASE CL.[ysnUseUPConPhysical]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_upc_phy_yn]  
      ,(CASE CL.[ysnUseUPConPurchaseOrders]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_upc_pur_yn]  
      ,CL.[dblMixerSize]    --[agloc_mixer_size]  
      ,(CASE CL.[ysnOverrideMixerSize]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_override_mixer_yn]  
      ,(CASE CL.[ysnEvenBatches]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_even_batch_yn]  
      ,(CASE CL.[strPrintCashReceipts]  
           WHEN ''Yes''    THEN ''Y''  
           WHEN ''No''    THEN ''N''  
           WHEN ''Register Tape'' THEN ''R''      
           ELSE ''''  
       END)      --[agloc_cash_rcts_ynr]  
      ,(CASE CL.[ysnPrintCashTendered]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_cash_tender_yn]  
      ,NULL       --[agloc_dd_clock_loc]  
      ,NULL       --[agloc_season_ind_sw]  
      ,NULL       --[agloc_summer_chng_rev_dt]  
      ,NULL       --[agloc_dlv_tic_prtr]  
      ,NULL       --[agloc_dlv_tic_no]  
      ,NULL       --[agloc_dflt_lp_pct_full]  
      ,NULL       --[agloc_dlv_tic_fmt]  
      ,NULL       --[agloc_rdg_entry_meth_ad]  
      ,NULL       --[agloc_fill_by_class_yn]  
      ,NULL       --[agloc_fill_class]  
      ,NULL       --[agloc_base_temp]  
      ,NULL       --[agloc_winter_chng_rev_dt]  
      ,NULL       --[agloc_winter_accum_dd]  
      ,(CASE CL.[ysnDefaultCustomBlend]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_custom_blend_yn]  
      ,(CASE CL.[strDeliverPickupDefault]  
           WHEN ''Pickup'' THEN ''P''  
           WHEN ''Deliver'' THEN ''D''  
           ELSE ''''  
       END)      --[agloc_dflt_dlvr_pkup_ind]  
      ,(CASE CL.[ysnOrderSection2Required]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_ord_sec2_req_yn]  
      ,(CASE CL.[strOutOfStockWarning]  
           WHEN ''Yes'' THEN ''Y''  
           WHEN ''No'' THEN ''N''  
           ELSE ''''  
       END)      --[agloc_item_warning_yn]  
      ,(CASE CL.[strSkipSalesmanDefault]  
           WHEN ''Yes''    THEN ''Y''  
           WHEN ''No''    THEN ''N''  
           WHEN ''Required''   THEN ''R''      
           WHEN ''Use Order Taker'' THEN ''S''  
           ELSE ''''  
       END)      --[agloc_skip_slsmn_dflt_ynrs]  
      ,(CASE CL.[ysnSkipTermsDefault]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_skip_terms_dflt_yn]  
      ,(CASE CL.[ysnOverridePatronage]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_override_pat_yn]  
      ,(CASE CL.[strOrderTypeDefault]  
           WHEN ''Order''  THEN ''O''  
           WHEN ''Invoice''  THEN ''I''  
           WHEN ''Cash Sale'' THEN ''S''      
           ELSE ''''  
       END)      --[agloc_dflt_tic_type_ois]  
      ,(CASE   
        WHEN CL.[strPickTicketType] = ''Pick Ticket''  
         THEN ''P''  
        WHEN CL.[strPickTicketType] = ''Mix Sheet''  
         THEN ''M''  
        WHEN CL.[strPickTicketType] = ''Scale Tops''  
         THEN ''S''  
        WHEN CL.[strPickTicketType] IS NOT NULL AND CL.[strPickTicketType] NOT IN (''Pick Ticket'',''Mix Sheet'',''Scale Tops'')  
         THEN ''''  
        ELSE ''''  
       END)      --[agloc_dflt_pic_tkt_type_pms]  
      ,NULL       --[agloc_wn_retailer_ic_cd]  
      ,CL.[strPriceLevel1]   --[agloc_prc1_desc]  
      ,CL.[strPriceLevel2]   --[agloc_prc2_desc]  
      ,CL.[strPriceLevel3]   --[agloc_prc3_desc]  
      ,CL.[strPriceLevel4]   --[agloc_prc4_desc]  
      ,CL.[strPriceLevel5]   --[agloc_prc5_desc]  
      ,NULL       --[agloc_prc6_desc]  
      ,NULL       --[agloc_prc7_desc]  
      ,NULL       --[agloc_prc8_desc]  
      ,NULL       --[agloc_prc9_desc]  
      ,CL.[intProfitCenter]   --[agloc_gl_profit_center]  
      ,FE.[strExternalId]    --[agloc_frt_exp_acct_no]  
      ,FI.[strExternalId]    --[agloc_frt_inc_acct_no]  
      ,CA.[strExternalId]    --[agloc_cash]  
      ,SC.[strExternalId]    --[agloc_srvchr]  
      ,SD.[strExternalId]    --[agloc_disc_taken]  
      ,OS.[strExternalId]    --[agloc_over_short]  
      ,CF.[strExternalId]    --[agloc_ccfee_percent]  
      ,WO.[strExternalId]    --[agloc_write_off]  
      ,NULL       --[agloc_gl_div_col]  
      ,''N''       --[agloc_disc_by_lob_yn]  
      ,(CASE CL.[strUseLocationAddress]  
           WHEN ''Yes''   THEN ''Y''  
           WHEN ''No''   THEN ''N''  
           WHEN ''Always''  THEN ''A''      
           WHEN ''Letterhead'' THEN ''L''  
           ELSE ''''  
       END)      --[agloc_use_addr_ynal]  
      ,(CASE CL.[ysnPrintContractBalance]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_prt_cnt_bal_ynu]  
      ,(CASE CL.[ysnPrintInvoiceMedTags]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_prt_ivc_med_tags_yn]  
      ,(CASE CL.[ysnPrintPickTicketMedTags]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_prt_pic_med_tags_yn]  
      ,(CASE CL.[strPrintonInvoice]  
           WHEN ''Item''  THEN ''I''  
           WHEN ''Package'' THEN ''P''  
           WHEN ''Ordered'' THEN ''O''  
           ELSE ''''  
       END)      --[agloc_ivc_prt_ipo]  
      ,NULL       --[agloc_ivc_comment1]  
      ,NULL       --[agloc_ivc_comment2]  
      ,NULL       --[agloc_ivc_comment3]  
      ,NULL       --[agloc_ivc_comment4]  
      ,NULL       --[agloc_ivc_comment5]  
      ,NULL       --[agloc_pic_comment1]  
      ,NULL       --[agloc_pic_comment2]  
      ,NULL       --[agloc_pic_comment3]  
      ,NULL       --[agloc_pic_comment4]  
      ,NULL       --[agloc_pic_comment5]  
      ,CL.[strDefaultCarrier]   --[agloc_default_carrier]  
      ,(CASE CL.[ysnAutomaticCashDepositEntries]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_auto_dep_yn]  
      ,(CASE CL.[ysnOverShortEntries]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_gen_ovr_short_yn]  
      ,NULL       --[agloc_oth_inc_cd]  
      ,NULL       --[agloc_oth_inc_cus_no]  
      ,NULL       --[agloc_upd_cost_yn]  
      ,(CASE CL.[strLotOverdrawnWarning]  
           WHEN ''Yes''   THEN ''Y''  
           WHEN ''No''   THEN ''N''  
           WHEN ''Not Allowed'' THEN ''S''  
           ELSE ''''  
       END)      --[agloc_lot_warning_yns]  
      ,NULL       --[agloc_var_pct]  
      ,(CASE CL.[strPrintonPO]  
           WHEN ''P'' THEN ''Packages''  
           WHEN ''U'' THEN ''Units''  
           ELSE ''''  
       END)      --[agloc_po_prt_pu]  
      ,(CASE CL.[ysnLocationActive]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_active_yn]  
      ,(CASE CL.[ysnAgroguideInterface]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_agroguide_yn]  
      ,CL.[strJohnDeereMerchant]  --[agloc_merchant]  
      ,(CASE CL.[ysnSendtoEnergyTrac]  
           WHEN 1 THEN ''Y''  
           WHEN 0 THEN ''N''  
           ELSE ''N''  
       END)      --[agloc_send_to_et_yn]  
      --,[agloc_user_id]  
      --,[agloc_user_rev_dt]  
      --,[A4GLIdentity]  
     FROM   
      tblSMCompanyLocation CL  
     INNER JOIN
      @RecordsToAdd A  
       ON CL.[strLocationNumber] = A.strNumber  COLLATE Latin1_General_CI_AS     
     LEFT JOIN  
      tblGLCOACrossReference CA  
       ON CL.[intCashAccount] = CA.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference FE  
       ON CL.[intFreightExpenses] = FE.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference FI  
       ON CL.intFreightIncome = FI.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference SC  
       ON CL.intServiceCharges = SC.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference SD  
       ON CL.intSalesDiscounts = SD.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference OS  
       ON CL.intCashOverShort = OS.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference WO  
       ON CL.intWriteOff = WO.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference CF  
       ON CL.intCreditCardFee = CF.[inti21Id]  
     LEFT OUTER JOIN  
      tblSMCountry C  
       ON CL.strCountry = C.strCountry       
        
     SET @AddedCount = @@ROWCOUNT  
       
     UPDATE [aglocmst]  
     SET   
      [agloc_name] = CL.[strLocationName]  
      ,[agloc_addr] =   
       (CASE WHEN LEN(RTRIM(LTRIM(CL.[strAddress]))) > 30  
        THEN SUBSTRING(RTRIM(LTRIM(CL.[strAddress])), 0, 29)  
        ELSE LEN(RTRIM(LTRIM(CL.[strAddress])))  
       END)      
      ,[agloc_addr2] =   
       (CASE WHEN LEN(RTRIM(LTRIM(CL.[strAddress]))) > 30  
        THEN SUBSTRING(RTRIM(LTRIM(CL.[strAddress])), 29, LEN(RTRIM(LTRIM(CL.[strAddress]))) - 31)  
        ELSE ''''  
       END)      
      ,[agloc_city] = CL.[strCity]   
      ,[agloc_state] = CL.[strStateProvince]  
      ,[agloc_zip] = CL.[strZipPostalCode]  
      ,[agloc_country] = C.[strCountryCode]  
      ,[agloc_phone] = CL.[strPhone]  
      ,[agloc_inv_by_loc_ynd] = [agloc_inv_by_loc_ynd]  
      ,[agloc_tax_by_loc_only_ynv] =   
        (CASE CL.[strSalesTaxByLocation]  
         WHEN ''Yes''  THEN ''Y''  
         WHEN ''No''  THEN ''N''  
         WHEN ''Varies'' THEN ''V''      
         ELSE ''''  
        END)  
      ,[agloc_tax_state] = CL.[strTaxState]  
      ,[agloc_tax_auth_id1] = CL.[strTaxAuthorityId1]  
      ,[agloc_tax_auth_id2] = CL.[strTaxAuthorityId2]  
      ,[agloc_csh_drwr_yn] =   
        (CASE CL.[ysnUsingCashDrawer]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_csh_drwr_dev_id] = CL.[strCashDrawerDeviceId]  
      ,[agloc_reg_tape_yn] =   
        (CASE CL.[ysnPrintRegisterTape]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_reg_tape_prtr] = [agloc_reg_tape_prtr]  
      ,[agloc_bar_code_prtr] = CL.[strBarCodePrinterName]  
      ,[agloc_pic_prtr_name] = CL.[strDefaultTicketPrinter]  
      ,[agloc_ivc_prtr_name] = CL.[strDefaultInvoicePrinter]  
      ,[agloc_cnt_prtr_name] = [agloc_cnt_prtr_name]  
      ,[agloc_last_ivc_no] = CL.[strLastInvoiceNumber]  
      ,[agloc_last_ord_no] = CL.[strLastOrderNumber]  
      ,[agloc_ord_for_ivc_yn] =   
        (CASE CL.[ysnUseOrderNumberforInvoiceNumber]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_override_ord_ivc_yn] =   
        (CASE CL.[ysnOverrideOrderInvoiceNumber]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_ivc_type_phs7] =  
        (CASE CL.[strInvoiceType]  
         WHEN ''Plain full page'' THEN ''P''  
         WHEN ''Plain half page'' THEN ''H''  
         WHEN ''Special 7 inch'' THEN ''S''  
         WHEN ''Plain 7 inch''  THEN ''7''  
         ELSE ''''  
        END)  
      ,[agloc_upc_ord_yn] =  
        (CASE CL.[ysnUseUPConOrders]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_upc_rct_yn] = [agloc_upc_rct_yn]  
      ,[agloc_upc_search_ui] =  
        (CASE CL.[strUPCSearchSequence]  
         WHEN ''UPC Code''  THEN ''U''  
         WHEN ''Item Code'' THEN ''I''  
         ELSE ''''  
          END)  
      ,[agloc_upc_phy_yn] =  
        (CASE CL.[ysnUseUPConPhysical]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_upc_pur_yn] =  
        (CASE CL.[ysnUseUPConPurchaseOrders]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_mixer_size] = CL.[dblMixerSize]  
      ,[agloc_override_mixer_yn] =  
        (CASE CL.[ysnOverrideMixerSize]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_even_batch_yn] =  
        (CASE CL.[ysnEvenBatches]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_cash_rcts_ynr] =  
        (CASE CL.[strPrintCashReceipts]  
         WHEN ''Yes''    THEN ''Y''  
         WHEN ''No''    THEN ''N''  
         WHEN ''Register Tape'' THEN ''R''      
         ELSE ''''  
        END)  
      ,[agloc_cash_tender_yn] =  
        (CASE CL.[ysnPrintCashTendered]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_dd_clock_loc] = [agloc_dd_clock_loc]  
      ,[agloc_season_ind_sw] = [agloc_season_ind_sw]  
      ,[agloc_summer_chng_rev_dt] = [agloc_summer_chng_rev_dt]  
      ,[agloc_dlv_tic_prtr] = [agloc_dlv_tic_prtr]  
      ,[agloc_dlv_tic_no] = [agloc_dlv_tic_no]  
      ,[agloc_dflt_lp_pct_full] = [agloc_dflt_lp_pct_full]  
      ,[agloc_dlv_tic_fmt] = [agloc_dlv_tic_fmt]  
      ,[agloc_rdg_entry_meth_ad] = [agloc_rdg_entry_meth_ad]  
      ,[agloc_fill_by_class_yn] = [agloc_fill_by_class_yn]  
      ,[agloc_fill_class] = [agloc_fill_class]  
      ,[agloc_base_temp] = [agloc_base_temp]  
      ,[agloc_winter_chng_rev_dt] = [agloc_winter_chng_rev_dt]  
      ,[agloc_winter_accum_dd] = [agloc_winter_accum_dd]  
      ,[agloc_custom_blend_yn] =  
        (CASE CL.[ysnDefaultCustomBlend]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_dflt_dlvr_pkup_ind] =  
        (CASE CL.[strDeliverPickupDefault]  
         WHEN ''Pickup'' THEN ''P''  
         WHEN ''Deliver'' THEN ''D''  
         ELSE ''''  
        END)  
      ,[agloc_ord_sec2_req_yn] =  
        (CASE CL.[ysnOrderSection2Required]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_item_warning_yn] =  
        (CASE CL.[strOutOfStockWarning]  
         WHEN ''Yes'' THEN ''Y''  
         WHEN ''No'' THEN ''N''  
         ELSE ''''  
        END)  
      ,[agloc_skip_slsmn_dflt_ynrs] =  
        (CASE CL.[strSkipSalesmanDefault]  
         WHEN ''Yes''    THEN ''Y''  
         WHEN ''No''    THEN ''N''  
         WHEN ''Required''   THEN ''R''      
         WHEN ''Use Order Taker'' THEN ''S''  
         ELSE ''''  
        END)  
      ,[agloc_skip_terms_dflt_yn] =  
        (CASE CL.[ysnSkipTermsDefault]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_override_pat_yn] =  
        (CASE CL.[ysnOverridePatronage]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_dflt_tic_type_ois] =  
        (CASE CL.[strOrderTypeDefault]  
         WHEN ''Order''  THEN ''O''  
         WHEN ''Invoice''  THEN ''I''  
         WHEN ''Cash Sale'' THEN ''S''      
         ELSE ''''  
        END)  
      ,[agloc_dflt_pic_tkt_type_pms] =  
        (CASE   
         WHEN CL.[strPickTicketType] = ''Pick Ticket''  
          THEN ''P''  
         WHEN CL.[strPickTicketType] = ''Mix Sheet''  
          THEN ''M''  
         WHEN CL.[strPickTicketType] = ''Scale Tops''  
          THEN ''S''  
         WHEN CL.[strPickTicketType] IS NOT NULL AND CL.[strPickTicketType] NOT IN (''Pick Ticket'',''Mix Sheet'',''Scale Tops'')  
          THEN ''''  
         ELSE ''''  
          END)  
      ,[agloc_wn_retailer_ic_cd] = [agloc_wn_retailer_ic_cd]  
      ,[agloc_prc1_desc] = CL.[strPriceLevel1]  
      ,[agloc_prc2_desc] = CL.[strPriceLevel2]  
      ,[agloc_prc3_desc] = CL.[strPriceLevel3]  
      ,[agloc_prc4_desc] = CL.[strPriceLevel4]  
      ,[agloc_prc5_desc] = CL.[strPriceLevel5]  
      ,[agloc_prc6_desc] = [agloc_prc6_desc]  
      ,[agloc_prc7_desc] = [agloc_prc7_desc]  
      ,[agloc_prc8_desc] = [agloc_prc8_desc]  
      ,[agloc_prc9_desc] = [agloc_prc9_desc]  
      ,[agloc_gl_profit_center] = CL.[intProfitCenter]  
      ,[agloc_frt_exp_acct_no] = FE.[strExternalId]  
      ,[agloc_frt_inc_acct_no] = FI.[strExternalId]  
      ,[agloc_cash] = CA.[strExternalId]  
      ,[agloc_srvchr] = SC.[strExternalId]  
      ,[agloc_disc_taken] = SD.[strExternalId]  
      ,[agloc_over_short] = OS.[strExternalId]  
      ,[agloc_ccfee_percent] = CF.[strExternalId]  
      ,[agloc_write_off] = WO.[strExternalId]  
      ,[agloc_gl_div_col] = [agloc_gl_div_col]  
      ,[agloc_disc_by_lob_yn] = [agloc_disc_by_lob_yn]  
      ,[agloc_use_addr_ynal] =  
        (CASE CL.[strUseLocationAddress]  
         WHEN ''Yes''   THEN ''Y''  
         WHEN ''No''   THEN ''N''  
         WHEN ''Always''  THEN ''A''      
         WHEN ''Letterhead'' THEN ''L''  
         ELSE ''''  
        END)  
      ,[agloc_prt_cnt_bal_ynu] =  
        (CASE CL.[ysnPrintContractBalance]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_prt_ivc_med_tags_yn] =  
        (CASE CL.[ysnPrintInvoiceMedTags]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_prt_pic_med_tags_yn] =  
        (CASE CL.[ysnPrintPickTicketMedTags]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_ivc_prt_ipo] =  
        (CASE CL.[strPrintonInvoice]  
         WHEN ''Item''  THEN ''I''  
         WHEN ''Package'' THEN ''P''  
         WHEN ''Ordered'' THEN ''O''  
         ELSE ''''  
        END)  
      ,[agloc_ivc_comment1] = [agloc_ivc_comment1]  
      ,[agloc_ivc_comment2] = [agloc_ivc_comment2]  
      ,[agloc_ivc_comment3] = [agloc_ivc_comment3]  
      ,[agloc_ivc_comment4] = [agloc_ivc_comment4]  
      ,[agloc_ivc_comment5] = [agloc_ivc_comment5]  
      ,[agloc_pic_comment1] = [agloc_pic_comment1]  
      ,[agloc_pic_comment2] = [agloc_pic_comment2]  
      ,[agloc_pic_comment3] = [agloc_pic_comment3]  
      ,[agloc_pic_comment4] = [agloc_pic_comment4]  
      ,[agloc_pic_comment5] = [agloc_pic_comment5]  
      ,[agloc_default_carrier] = CL.[strDefaultCarrier]  
      ,[agloc_auto_dep_yn] =  
        (CASE CL.[ysnAutomaticCashDepositEntries]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_gen_ovr_short_yn] =  
        (CASE CL.[ysnOverShortEntries]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_oth_inc_cd] = [agloc_oth_inc_cd]  
      ,[agloc_oth_inc_cus_no] = [agloc_oth_inc_cus_no]  
      ,[agloc_upd_cost_yn] = [agloc_upd_cost_yn]  
      ,[agloc_lot_warning_yns] =  
        (CASE CL.[strLotOverdrawnWarning]  
         WHEN ''Yes''   THEN ''Y''  
         WHEN ''No''   THEN ''N''  
         WHEN ''Not Allowed'' THEN ''S''  
         ELSE ''''  
        END)  
      ,[agloc_var_pct] = [agloc_var_pct]  
      ,[agloc_po_prt_pu] =  
        (CASE CL.[strPrintonPO]  
         WHEN ''P'' THEN ''Packages''  
         WHEN ''U'' THEN ''Units''  
         ELSE ''''  
          END)  
      ,[agloc_active_yn] =  
        (CASE CL.[ysnLocationActive]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_agroguide_yn] =  
        (CASE CL.[ysnAgroguideInterface]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_merchant] = CL.[strJohnDeereMerchant]  
      ,[agloc_send_to_et_yn] =  
        (CASE CL.[ysnSendtoEnergyTrac]  
         WHEN 1 THEN ''Y''  
         WHEN 0 THEN ''N''  
         ELSE ''N''  
        END)  
      ,[agloc_user_id] = [agloc_user_id]  
      ,[agloc_user_rev_dt] = [agloc_user_rev_dt]    
     FROM  
      tblSMCompanyLocation CL  
     INNER JOIN
      @RecordsToUpdate U  
       ON CL.[strLocationNumber] = U.strNumber COLLATE Latin1_General_CI_AS      
     LEFT JOIN  
      tblGLCOACrossReference CA  
       ON CL.[intCashAccount] = CA.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference FE  
       ON CL.[intFreightExpenses] = FE.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference FI  
       ON CL.intFreightIncome = FI.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference SC  
       ON CL.intServiceCharges = SC.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference SD  
       ON CL.intSalesDiscounts = SD.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference OS  
       ON CL.intCashOverShort = OS.[inti21Id]  
     LEFT JOIN  
      tblGLCOACrossReference WO  
       ON CL.intWriteOff = WO.[inti21Id]   
     LEFT JOIN  
      tblGLCOACrossReference CF  
       ON CL.intCreditCardFee = CF.[inti21Id]  
     LEFT OUTER JOIN  
      tblSMCountry C  
       ON CL.strCountry = C.strCountry       
     WHERE
      RTRIM(LTRIM([aglocmst].[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))  
         
     SET @UpdatedCount = @@ROWCOUNT  
  
    END  
      
   ELSE  
    BEGIN  
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
      ,[intCashAccount]  
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
      ,[strInvoiceType]  
      ,[strDefaultInvoicePrinter]  
      ,[strPickTicketType]  
      ,[strDefaultTicketPrinter]  
      ,[strLastOrderNumber]  
      ,[strLastInvoiceNumber]  
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
      AG.[agloc_loc_no]     --<strLocationNumber, nvarchar(3),> 
      ,(CASE WHEN EXISTS(SELECT [agloc_loc_no], [agloc_name] FROM aglocmst WHERE RTRIM(LTRIM([agloc_loc_no])) <> RTRIM(LTRIM(AG.[agloc_loc_no])) AND RTRIM(LTRIM([agloc_name])) = RTRIM(LTRIM(AG.[agloc_name])))  
       THEN   
        RTRIM(LTRIM(AG.[agloc_name])) + '' - '' + RTRIM(LTRIM(AG.[agloc_loc_no]))  
       ELSE  
        RTRIM(LTRIM(AG.[agloc_name]))  
        END)        --<strLocationName, nvarchar(50),>  
      ,''Office''       --<strLocationType, nvarchar(50),>  
      ,(CASE   
       WHEN RTRIM(LTRIM(AG.[agloc_addr])) = ''''   
        THEN AG.[agloc_addr2]  
       ELSE  
        RTRIM(LTRIM(AG.[agloc_addr])) + (CHAR(13) + CHAR(10)) + RTRIM(LTRIM(AG.[agloc_addr2]))  
        END)        --<strAddress, nvarchar(max),>  
      ,[agloc_zip]      --<strZipPostalCode, nvarchar(50),>  
      ,[agloc_city]      --<strCity, nvarchar(50),>  
      ,[agloc_state]      --<strStateProvince, nvarchar(50),>  
      ,[agloc_country]     --<strCountry, nvarchar(50),>  
      ,(CASE   
       WHEN CHARINDEX(''x'', AG.[agloc_phone]) > 0   
        THEN SUBSTRING(SUBSTRING(AG.[agloc_phone],1,15), 0, CHARINDEX(''x'',AG.[agloc_phone]))   
       ELSE   
        SUBSTRING(AG.[agloc_phone],1,15)  
        END)        --<strPhone, nvarchar(50),>  
      ,''''         ---<strFax, nvarchar(50),>  
      ,''''         --<strEmail, nvarchar(50),>  
      ,''''         --<strWebsite, nvarchar(50),>  
      ,''''         --<strInternalNotes, nvarchar(max),>  
      ,(CASE UPPER(AG.[agloc_use_addr_ynal])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       WHEN ''A'' THEN ''Always''      
       WHEN ''L'' THEN ''Letterhead''  
       ELSE ''''  
        END)        --<strUseLocationAddress, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_skip_slsmn_dflt_ynrs])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       WHEN ''R'' THEN ''Required''      
       WHEN ''S'' THEN ''Use Order Taker''  
       ELSE ''''  
        END)        --<strSkipSalesmanDefault, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_skip_terms_dflt_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnSkipTermsDefault, bit,>  
      ,(CASE UPPER(AG.[agloc_dflt_tic_type_ois])  
       WHEN ''O'' THEN ''Order''  
       WHEN ''I'' THEN ''Invoice''  
       WHEN ''S'' THEN ''Cash Sale''      
       ELSE ''''  
        END)        --<strOrderTypeDefault, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_cash_rcts_ynr])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       WHEN ''R'' THEN ''Register Tape''      
       ELSE ''''  
        END)        --<strPrintCashReceipts, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_cash_tender_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnPrintCashTendered, bit,>  
      ,(CASE UPPER(AG.[agloc_tax_by_loc_only_ynv])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       WHEN ''V'' THEN ''Varies''      
       ELSE ''''  
        END)        --<strSalesTaxByLocation, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_dflt_dlvr_pkup_ind])  
       WHEN ''P'' THEN ''Pickup''  
       WHEN ''D'' THEN ''Deliver''  
       ELSE ''''  
        END)        --<strDeliverPickupDefault, nvarchar(50),>  
      ,AG.[agloc_tax_state]    --<strTaxState, nvarchar(50),>  
      ,AG.[agloc_tax_auth_id1]   --<strTaxAuthorityId1, nvarchar(50),>  
      ,AG.[agloc_tax_auth_id2]   --<strTaxAuthorityId2, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_override_pat_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnOverridePatronage, bit,>  
      ,(CASE UPPER(AG.[agloc_item_warning_yn])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       ELSE ''Not Allowed''  
        END)        --<strOutOfStockWarning, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_lot_warning_yns])  
       WHEN ''Y'' THEN ''Yes''  
       WHEN ''N'' THEN ''No''  
       WHEN ''S'' THEN ''Not Allowed''  
       ELSE ''''  
        END)        --<strLotOverdrawnWarning, nvarchar(50),>  
      ,AG.[agloc_default_carrier]   --<strDefaultCarrier, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_ord_sec2_req_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnOrderSection2Required, bit,>  
      ,(CASE UPPER(AG.[agloc_po_prt_pu])  
       WHEN ''P'' THEN ''Packages''  
       WHEN ''U'' THEN ''Units''  
       ELSE ''''  
        END)        --<strPrintonPO, nvarchar(50),>  
      ,ISNULL(AG.[agloc_mixer_size],0) --<dblMixerSize, numeric(18,6),>  
      ,(CASE UPPER(AG.[agloc_override_mixer_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnOverrideMixerSize, bit,>  
      ,(CASE UPPER(AG.[agloc_even_batch_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnEvenBatches, bit,>  
      ,(CASE UPPER(AG.[agloc_custom_blend_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnDefaultCustomBlend, bit,>  
      ,(CASE UPPER(AG.[agloc_agroguide_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnAgroguideInterface, bit,>  
      ,(CASE UPPER(AG.[agloc_active_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnLocationActive, bit,>  
      ,ISNULL(AG.[agloc_gl_profit_center],0) --<intProfitCenter, int,>    --TODO  
      ,ISNULL(CA.[inti21Id],0)      --<agloc_cash, int,>  
      ,0         --<intDepositAccount, int,>  
      ,0         --<intARAccount, int,>  
      ,0         --<intAPAccount, int,>  
      ,0         --<intSalesAdvAcct, int,>  
      ,0         --<intPurchaseAdvAccount, int,>  
      ,0         --<intFreightAPAccount, int,>  
      ,ISNULL(FE.[inti21Id],0)      --<intFreightExpenses, int,>  
      ,ISNULL(FI.[inti21Id],0)      --<intFreightIncome, int,>  
      ,ISNULL(SC.[inti21Id],0)      --<intServiceCharges, int,>  
      ,ISNULL(SD.[inti21Id],0)      --<intSalesDiscounts, int,>  
      ,ISNULL(OS.[inti21Id],0)      --<intCashOverShort, int,>  
      ,ISNULL(WO.[inti21Id],0)      --<intWriteOff, int,>  
      ,ISNULL(CF.[inti21Id],0)      --<intCreditCardFee, int,>  
      ,0         --<intSalesAccount, int,>  
      ,0         --<intCostofGoodsSold, int,>  
      ,0         --<intInventory, int,>  
      ,(CASE UPPER(AG.[agloc_ivc_type_phs7])  
       WHEN ''P'' THEN ''Plain full page''  
       WHEN ''H'' THEN ''Plain half page''  
       WHEN ''S'' THEN ''Special 7 inch''  
       WHEN ''7'' THEN ''Plain 7 inch''  
       ELSE ''''  
        END)        --<strInvoiceType, nvarchar(50),>  
      ,AG.[agloc_ivc_prtr_name]   --<strDefaultInvoicePrinter, nvarchar(50),>  
      ,(CASE   
       WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''P''  
        THEN ''Pick Ticket''  
       WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''M''  
        THEN ''Mix Sheet''  
       WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''S''  
        THEN ''Scale Tops''  
       WHEN AG.[agloc_dflt_pic_tkt_type_pms] IS NOT NULL AND UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) NOT IN (''P'',''M'',''S'')  
        THEN ''Plain 7 inch''  
       ELSE ''''  
        END)        --<strPickTicketType, nvarchar(50),>  
      ,AG.[agloc_pic_prtr_name]   --<strDefaultTicketPrinter, nvarchar(50),>  
      ,AG.[agloc_last_ord_no]    --<strLastOrderNumber, nvarchar(50),>  
      ,AG.[agloc_last_ivc_no]    --<strLastInvoiceNumber, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_ivc_prt_ipo])  
       WHEN ''I'' THEN ''Item''  
       WHEN ''P'' THEN ''Package''  
       WHEN ''O'' THEN ''Ordered''  
       ELSE ''''  
        END)        --<strPrintonInvoice, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_prt_cnt_bal_ynu])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnPrintContractBalance, bit,>  
      ,AG.[agloc_merchant]    --<strJohnDeereMerchant, nvarchar(50),>  
      ,(CASE   
       WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment1])) <> ''''  
        THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment1])), 0, 49)  
       WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment2])) <> ''''  
        THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment2])), 0, 49)  
       WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment3])) <> ''''  
        THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment3])), 0, 49)  
       WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment4])) <> ''''  
        THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment4])), 0, 49)  
       WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment5])) <> ''''  
        THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment5])), 0, 49)     
       ELSE ''''  
        END)        --<strInvoiceComments, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_ord_for_ivc_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnUseOrderNumberforInvoiceNumber, bit,>  
      ,(CASE UPPER(AG.[agloc_override_ord_ivc_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnOverrideOrderInvoiceNumber, bit,>  
      ,(CASE UPPER(AG.[agloc_prt_ivc_med_tags_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnPrintInvoiceMedTags, bit,>  
      ,(CASE UPPER(AG.[agloc_prt_pic_med_tags_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnPrintPickTicketMedTags, bit,>  
      ,(CASE UPPER(AG.[agloc_send_to_et_yn])  
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
      ,(CASE UPPER(AG.[agloc_csh_drwr_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnUsingCashDrawer, bit,>  
      ,AG.[agloc_csh_drwr_dev_id]   --<strCashDrawerDeviceId, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_reg_tape_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnPrintRegisterTape, bit,>  
      ,(CASE UPPER(AG.[agloc_upc_ord_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnUseUPConOrders, bit,>  
      ,(CASE UPPER(AG.[agloc_upc_phy_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnUseUPConPhysical, bit,>  
      ,(CASE UPPER(AG.[agloc_upc_pur_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnUseUPConPurchaseOrders, bit,>  
      ,(CASE UPPER(AG.[agloc_upc_search_ui])  
       WHEN ''U'' THEN ''UPC Code''  
       WHEN ''I'' THEN ''Item Code''  
       ELSE ''''  
        END)        --<strUPCSearchSequence, nvarchar(50),>  
      ,AG.[agloc_bar_code_prtr]    --<strBarCodePrinterName, nvarchar(50),>  
      ,AG.[agloc_prc1_desc]     --<strPriceLevel1, nvarchar(50),>  
      ,AG.[agloc_prc2_desc]     --<strPriceLevel2, nvarchar(50),>  
      ,AG.[agloc_prc3_desc]     --<strPriceLevel3, nvarchar(50),>  
      ,AG.[agloc_prc4_desc]     --<strPriceLevel4, nvarchar(50),>  
      ,AG.[agloc_prc5_desc]     --<strPriceLevel5, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_gen_ovr_short_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnOverShortEntries, bit,>  
      ,''''         --<strOverShortCustomer, nvarchar(50),>  
      ,''''         --<strOverShortAccount, nvarchar(50),>  
      ,(CASE UPPER(AG.[agloc_auto_dep_yn])  
       WHEN ''Y'' THEN 1  
       WHEN ''N'' THEN 0  
       ELSE 0  
        END)        --<ysnAutomaticCashDepositEntries, bit,>  
      ,0  
     FROM  
      aglocmst AG  
     INNER JOIN  
      @RecordsToAdd A  
       ON AG.[agloc_loc_no] = A.[strNumber]     
     LEFT JOIN  
      tblGLCOACrossReference CA  
       ON AG.[agloc_cash] = CA.[strExternalId]  
     LEFT JOIN  
      tblGLCOACrossReference FE  
       ON AG.[agloc_frt_exp_acct_no] = FE.[strExternalId]  
     LEFT JOIN  
      tblGLCOACrossReference FI  
       ON AG.[agloc_frt_inc_acct_no] = FI.[strExternalId]  
     LEFT JOIN  
      tblGLCOACrossReference SC  
       ON AG.[agloc_srvchr] = SC.[strExternalId]   
     LEFT JOIN  
      tblGLCOACrossReference SD  
       ON AG.[agloc_disc_taken] = SD.[strExternalId]   
     LEFT JOIN  
      tblGLCOACrossReference OS  
       ON AG.[agloc_over_short] = OS.[strExternalId]  
     LEFT JOIN  
      tblGLCOACrossReference WO  
       ON AG.[agloc_write_off] = WO.[strExternalId]   
     LEFT JOIN  
      tblGLCOACrossReference CF  
       ON AG.[agloc_ccfee_percent] = CF.[strExternalId]  
     LEFT OUTER JOIN  
      tblSMCompanyLocation CL  
       ON RTRIM(LTRIM(AG.[agloc_name] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationName] COLLATE Latin1_General_CI_AS))   
        AND RTRIM(LTRIM(AG.[agloc_loc_no] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(CL.[strLocationNumber] COLLATE Latin1_General_CI_AS))
     WHERE  
      CL.[strLocationName] IS NULL  
        
     ORDER BY  
      AG.[agloc_loc_no]  
      ,AG.[agloc_name]  
        
       
     SET @AddedCount = @@ROWCOUNT  
        
        
     UPDATE [tblSMCompanyLocation]  
     SET   
      [strLocationName] =   
       (CASE WHEN EXISTS(SELECT [agloc_loc_no], [agloc_name] FROM aglocmst WHERE RTRIM(LTRIM([agloc_loc_no])) <> RTRIM(LTRIM(AG.[agloc_loc_no])) AND RTRIM(LTRIM([agloc_name])) = RTRIM(LTRIM(AG.[agloc_name])))  
        THEN   
         RTRIM(LTRIM(AG.[agloc_name])) + '' - '' + RTRIM(LTRIM(AG.[agloc_loc_no]))  
        ELSE  
         RTRIM(LTRIM(AG.[agloc_name]))  
       END)  
      ,[strLocationType] = [strLocationType]  
      ,[strAddress] =   
        (CASE   
         WHEN RTRIM(LTRIM(AG.[agloc_addr])) = ''''   
          THEN AG.[agloc_addr2]  
         ELSE  
          RTRIM(LTRIM(AG.[agloc_addr])) + (CHAR(13) + CHAR(10)) + RTRIM(LTRIM(AG.[agloc_addr2]))  
          END)  
      ,[strZipPostalCode] = AG.[agloc_zip]  
      ,[strCity] = AG.[agloc_city]  
      ,[strStateProvince] = AG.[agloc_state]  
      ,[strCountry] = AG.[agloc_country]  
      ,[strPhone] =   
        (CASE   
         WHEN CHARINDEX(''x'', AG.[agloc_phone]) > 0   
          THEN SUBSTRING(SUBSTRING(AG.[agloc_phone],1,15), 0, CHARINDEX(''x'',AG.[agloc_phone]))   
         ELSE   
          SUBSTRING(AG.[agloc_phone],1,15)  
          END)  
      ,[strFax] = [strFax]  
      ,[strEmail] = [strEmail]  
      ,[strWebsite] = [strWebsite]  
      ,[strInternalNotes] = [strInternalNotes]  
      ,[strUseLocationAddress] =   
        (CASE UPPER(AG.[agloc_use_addr_ynal])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         WHEN ''A'' THEN ''Always''      
         WHEN ''L'' THEN ''Letterhead''  
         ELSE ''''  
          END)  
      ,[strSkipSalesmanDefault] =   
        (CASE UPPER(AG.[agloc_skip_slsmn_dflt_ynrs])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         WHEN ''R'' THEN ''Required''      
         WHEN ''S'' THEN ''Use Order Taker''  
         ELSE ''''  
          END)  
      ,[ysnSkipTermsDefault] =   
        (CASE UPPER(AG.[agloc_skip_terms_dflt_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strOrderTypeDefault] =   
        (CASE UPPER(AG.[agloc_dflt_tic_type_ois])  
         WHEN ''O'' THEN ''Order''  
         WHEN ''I'' THEN ''Invoice''  
         WHEN ''S'' THEN ''Cash Sale''      
         ELSE ''''  
          END)  
      ,[strPrintCashReceipts] =   
        (CASE UPPER(AG.[agloc_cash_rcts_ynr])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         WHEN ''R'' THEN ''Register Tape''      
         ELSE ''''  
          END)  
      ,[ysnPrintCashTendered] =   
        (CASE UPPER(AG.[agloc_cash_tender_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strSalesTaxByLocation] =   
        (CASE UPPER(AG.[agloc_tax_by_loc_only_ynv])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         WHEN ''V'' THEN ''Varies''      
         ELSE ''''  
          END)  
      ,[strDeliverPickupDefault] =   
        (CASE UPPER(AG.[agloc_dflt_dlvr_pkup_ind])  
         WHEN ''P'' THEN ''Pickup''  
         WHEN ''D'' THEN ''Deliver''  
         ELSE ''''  
          END)  
      ,[strTaxState] = AG.[agloc_tax_state]  
      ,[strTaxAuthorityId1] = AG.[agloc_tax_auth_id1]  
      ,[strTaxAuthorityId2] = AG.[agloc_tax_auth_id2]  
      ,[ysnOverridePatronage] =   
        (CASE UPPER(AG.[agloc_override_pat_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strOutOfStockWarning] =   
        (CASE UPPER(AG.[agloc_item_warning_yn])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         ELSE ''Not Allowed''  
          END)  
      ,[strLotOverdrawnWarning] =   
        (CASE UPPER(AG.[agloc_lot_warning_yns])  
         WHEN ''Y'' THEN ''Yes''  
         WHEN ''N'' THEN ''No''  
         WHEN ''S'' THEN ''Not Allowed''  
         ELSE ''''  
          END)  
      ,[strDefaultCarrier] = AG.[agloc_default_carrier]  
      ,[ysnOrderSection2Required] =   
        (CASE UPPER(AG.[agloc_ord_sec2_req_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strPrintonPO] =   
        (CASE UPPER(AG.[agloc_po_prt_pu])  
         WHEN ''P'' THEN ''Packages''  
         WHEN ''U'' THEN ''Units''  
         ELSE ''''  
          END)  
      ,[dblMixerSize] = ISNULL(AG.[agloc_mixer_size],0)  
      ,[ysnOverrideMixerSize] =   
        (CASE UPPER(AG.[agloc_override_mixer_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnEvenBatches] =   
        (CASE UPPER(AG.[agloc_even_batch_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnDefaultCustomBlend] =   
        (CASE UPPER(AG.[agloc_custom_blend_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnAgroguideInterface] =   
        (CASE UPPER(AG.[agloc_agroguide_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnLocationActive] =   
        (CASE UPPER(AG.[agloc_active_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[intProfitCenter] = ISNULL(AG.[agloc_gl_profit_center],0)  
      ,[intCashAccount] = ISNULL(CA.[inti21Id],0)  
      ,[intDepositAccount] = ISNULL([intDepositAccount],0)  
      ,[intARAccount] = ISNULL([intARAccount],0)  
      ,[intAPAccount] = ISNULL([intAPAccount],0)  
      ,[intSalesAdvAcct] = ISNULL([intSalesAdvAcct],0)  
      ,[intPurchaseAdvAccount] = ISNULL([intPurchaseAdvAccount],0)  
      ,[intFreightAPAccount] = ISNULL([intFreightAPAccount],0)  
      ,[intFreightExpenses] = ISNULL(FE.[inti21Id],0)  
      ,[intFreightIncome] = ISNULL(FI.[inti21Id],0)  
      ,[intServiceCharges] = ISNULL(SC.[inti21Id],0)  
      ,[intSalesDiscounts] = ISNULL(SD.[inti21Id],0)  
      ,[intCashOverShort] = ISNULL(OS.[inti21Id],0)  
      ,[intWriteOff] = ISNULL(WO.[inti21Id],0)  
      ,[intCreditCardFee] = ISNULL(CF.[inti21Id],0)  
      ,[intSalesAccount] = ISNULL([intSalesAccount],0)  
      ,[intCostofGoodsSold] = ISNULL([intCostofGoodsSold],0)  
      ,[intInventory] = ISNULL([intInventory],0)  
      ,[strInvoiceType] =   
        (CASE UPPER(AG.[agloc_ivc_type_phs7])  
         WHEN ''P'' THEN ''Plain full page''  
         WHEN ''H'' THEN ''Plain half page''  
         WHEN ''S'' THEN ''Special 7 inch''  
         WHEN ''7'' THEN ''Plain 7 inch''  
         ELSE ''''  
          END)  
      ,[strDefaultInvoicePrinter] = AG.[agloc_ivc_prtr_name]  
      ,[strPickTicketType] =   
        (CASE   
         WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''P''  
          THEN ''Pick Ticket''  
         WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''M''  
          THEN ''Mix Sheet''  
         WHEN UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) = ''S''  
          THEN ''Scale Tops''  
         WHEN AG.[agloc_dflt_pic_tkt_type_pms] IS NOT NULL AND UPPER(AG.[agloc_dflt_pic_tkt_type_pms]) NOT IN (''P'',''M'',''S'')  
          THEN ''Plain 7 inch''  
         ELSE ''''  
          END)  
      ,[strDefaultTicketPrinter] = AG.[agloc_pic_prtr_name]  
      ,[strLastOrderNumber] = AG.[agloc_last_ord_no]  
      ,[strLastInvoiceNumber] = AG.[agloc_last_ivc_no]  
      ,[strPrintonInvoice] =   
        (CASE UPPER(AG.[agloc_ivc_prt_ipo])  
         WHEN ''I'' THEN ''Item''  
         WHEN ''P'' THEN ''Package''  
         WHEN ''O'' THEN ''Ordered''  
         ELSE ''''  
          END)  
      ,[ysnPrintContractBalance] =   
        (CASE UPPER(AG.[agloc_prt_cnt_bal_ynu])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strJohnDeereMerchant] = AG.[agloc_merchant]  
      ,[strInvoiceComments] =   
        (CASE   
         WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment1])) <> ''''  
          THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment1])), 0, 49)  
         WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment2])) <> ''''  
          THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment2])), 0, 49)  
         WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment3])) <> ''''  
          THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment3])), 0, 49)  
         WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment4])) <> ''''  
          THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment4])), 0, 49)  
         WHEN RTRIM(LTRIM(AG.[agloc_ivc_comment5])) <> ''''  
          THEN SUBSTRING(RTRIM(LTRIM(AG.[agloc_ivc_comment5])), 0, 49)     
         ELSE ''''  
          END)  
      ,[ysnUseOrderNumberforInvoiceNumber] =   
        (CASE UPPER(AG.[agloc_ord_for_ivc_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnOverrideOrderInvoiceNumber] =   
        (CASE UPPER(AG.[agloc_override_ord_ivc_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnPrintInvoiceMedTags] =   
        (CASE UPPER(AG.[agloc_prt_ivc_med_tags_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnPrintPickTicketMedTags] =   
        (CASE UPPER(AG.[agloc_prt_pic_med_tags_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnSendtoEnergyTrac] =   
        (CASE UPPER(AG.[agloc_send_to_et_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strDiscountScheduleType] = [strDiscountScheduleType]  
      ,[strLocationDiscount] = [strLocationDiscount]  
      ,[strLocationStorage] = [strLocationStorage]  
      ,[strMarketZone] = [strMarketZone]  
      ,[strLastTicket] = [strLastTicket]  
      ,[ysnDirectShipLocation] = [ysnDirectShipLocation]  
      ,[ysnScaleInstalled] = [ysnScaleInstalled]  
      ,[strDefaultScaleId] = [strDefaultScaleId]  
      ,[ysnActive] = [ysnActive]  
      ,[ysnUsingCashDrawer] =   
        (CASE UPPER(AG.[agloc_csh_drwr_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strCashDrawerDeviceId] = AG.[agloc_csh_drwr_dev_id]  
      ,[ysnPrintRegisterTape] =   
        (CASE UPPER(AG.[agloc_reg_tape_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnUseUPConOrders] =   
        (CASE UPPER(AG.[agloc_upc_ord_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnUseUPConPhysical] =   
        (CASE UPPER(AG.[agloc_upc_phy_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[ysnUseUPConPurchaseOrders] =   
        (CASE UPPER(AG.[agloc_upc_pur_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strUPCSearchSequence] =   
        (CASE UPPER(AG.[agloc_upc_search_ui])  
         WHEN ''U'' THEN ''UPC Code''  
         WHEN ''I'' THEN ''Item Code''  
         ELSE ''''  
          END)   
      ,[strBarCodePrinterName] = AG.[agloc_bar_code_prtr]  
      ,[strPriceLevel1] = AG.[agloc_prc1_desc]  
      ,[strPriceLevel2] = AG.[agloc_prc2_desc]  
      ,[strPriceLevel3] = AG.[agloc_prc3_desc]  
      ,[strPriceLevel4] = AG.[agloc_prc4_desc]  
      ,[strPriceLevel5] = AG.[agloc_prc5_desc]  
      ,[ysnOverShortEntries] =   
        (CASE UPPER(AG.[agloc_gen_ovr_short_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
      ,[strOverShortCustomer] = [strOverShortCustomer]  
      ,[strOverShortAccount] = [strOverShortAccount]  
      ,[ysnAutomaticCashDepositEntries] =   
        (CASE UPPER(AG.[agloc_auto_dep_yn])  
         WHEN ''Y'' THEN 1  
         WHEN ''N'' THEN 0  
         ELSE 0  
          END)  
     FROM  
      aglocmst AG  
      INNER JOIN  
       @RecordsToUpdate A  
        ON AG.[agloc_loc_no] = A.[strNumber]     
      LEFT JOIN  
       tblGLCOACrossReference CA  
        ON AG.[agloc_cash] = CA.[strExternalId]  
      LEFT JOIN  
       tblGLCOACrossReference FE  
        ON AG.[agloc_frt_exp_acct_no] = FE.[strExternalId]  
      LEFT JOIN  
       tblGLCOACrossReference FI  
        ON AG.[agloc_frt_inc_acct_no] = FI.[strExternalId]  
      LEFT JOIN  
       tblGLCOACrossReference SC  
        ON AG.[agloc_srvchr] = SC.[strExternalId]   
      LEFT JOIN  
       tblGLCOACrossReference SD  
        ON AG.[agloc_disc_taken] = SD.[strExternalId]   
      LEFT JOIN  
       tblGLCOACrossReference OS  
        ON AG.[agloc_over_short] = OS.[strExternalId]  
      LEFT JOIN  
       tblGLCOACrossReference WO  
        ON AG.[agloc_write_off] = WO.[strExternalId]   
      LEFT JOIN  
       tblGLCOACrossReference CF  
        ON AG.[agloc_ccfee_percent] = CF.[strExternalId]  
      WHERE          
      RTRIM(LTRIM([strLocationNumber])) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(AG.[agloc_loc_no])) COLLATE Latin1_General_CI_AS  
        
     SET @UpdatedCount = @@ROWCOUNT  
    END    
         
   END   	
			')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspSMSyncCompanyLocation
				@ToOrigin			bit				= 0
				,@LocationNumbers	nvarchar(MAX)	= ''all''
				,@AddedCount		int				= 0 OUTPUT
				,@UpdatedCount		int				= 0 OUTPUT
				AS
			BEGIN
				Return 0	
			END	')
END
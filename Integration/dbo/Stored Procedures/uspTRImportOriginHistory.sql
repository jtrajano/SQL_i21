
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportOriginHistory')
	DROP PROCEDURE uspTRImportOriginHistory
GO

CREATE PROCEDURE uspTRImportOriginHistory
	@defaultDriver AS int,
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblTRLoadHeader],[tblTRLoadReceipt][tblTRLoadDistributionHeader] - TR Origin History
	--========================================================== 
	IF NOT EXISTS (SELECT intEntityId FROM tblARSalesperson WHERE intEntityId = @defaultDriver)
	BEGIN
			RAISERROR('Default Company Driver is not valid',16,1)
			RETURN	
	END	

	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#tempvnd')
		DROP table #tempvnd

		 SELECT 		ssvnd_vnd_no,
					CASE WHEN ssvnd_pay_to IS NULL OR ssvnd_pay_to = ssvnd_vnd_no THEN ssvnd_vnd_no ELSE ssvnd_pay_to END as ssvnd_pay_to,
					CASE WHEN ssvnd_pay_to IS NULL OR ssvnd_pay_to = ssvnd_vnd_no THEN ssvnd_name 
						 ELSE  					
							RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
						    ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'')) + '_' + CAST(A4GLIdentity AS NVARCHAR) END as ssvnd_name,
					ssvnd_tax_st
		 INTO #tempvnd			
		 FROM ssvndmst 

		DECLARE @intLoadDistributionHeaderId int,
				@Disttotal int,
				@trhst_ord_no  nvarchar(10),
				@trhst_cus_no  nvarchar(10),
				@trhst_line_no int,
				@incDistval int = 1,
				@incval int;

		DECLARE @TempDist TABLE
			(
			intId INT IDENTITY PRIMARY KEY CLUSTERED,
			strloadNo nvarchar(10),
			strCusNo nvarchar(10)
			)

 	IF(@Checking = 0)
	BEGIN

		DECLARE @Freight_Item_id as  int

		SELECT @Freight_Item_id = intItemId FROM tblICItem I INNER JOIN trctlmst CTL 
		ON I.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = CTL.trctl_freight_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		AND trctl_key = 1

		--IMPORT LOAD HEADERS-- 
		 INSERT INTO [dbo].[tblTRLoadHeader]
			   ([intLoadId]
			   ,[strTransaction]
			   ,[dtmLoadDateTime]
			   ,[intShipViaId]
			   ,[intSellerId]
			   ,[intDriverId]
			   ,[strTractor]
			   ,[strTrailer]
			   ,[ysnPosted]
			   ,[intConcurrencyId])     
		 SELECT
			 NULL,-- intLoadId
			 trhst_ord_no,-- strTransaction
			 CAST((LEFT(CONVERT(VARCHAR,MAX(trhst_rev_dt)),4) + '-' + SUBSTRING(CONVERT(VARCHAR,MAX(trhst_rev_dt)),5,2) +  '-' + RIGHT(CONVERT(VARCHAR,MAX(trhst_rev_dt)),2)) + ' ' +
			   CAST((RTRIM(CONVERT(CHAR,LEFT(CAST((RIGHT('0000'+CAST(MAX(trhst_pur_rack_ent_time) AS VARCHAR(4)),4) ) AS CHAR(4)),2)+':'
				+RIGHT(CAST((RIGHT('0000'+CAST(MAX(trhst_pur_rack_ent_time) AS VARCHAR(4)),4) ) AS CHAR(4)),2),108))+':00') AS CHAR(10)) AS DATETIME),-- dtmLoadDateTime
			 (SELECT TOP 1 intEntityId FROM tblSMShipVia 
				WHERE strShipViaOriginKey COLLATE LATIN1_GENERAL_CI_AS = MAX(trhst_pur_carrier) COLLATE LATIN1_GENERAL_CI_AS),  -- intShipViaId
			 (select top 1 intEntityId from tblSMShipVia 
				WHERE strShipViaOriginKey COLLATE LATIN1_GENERAL_CI_AS = MAX(trhst_pur_seller) COLLATE LATIN1_GENERAL_CI_AS),    -- intSellerId
			 CASE WHEN (select COUNT(SLS.intEntityId) from tblEMEntity EM INNER JOIN trdrvmst DRV 
						on DRV.trdrv_driver COLLATE LATIN1_GENERAL_CI_AS = MAX(trhst_driver) COLLATE LATIN1_GENERAL_CI_AS
						AND DRV.trdrv_name COLLATE LATIN1_GENERAL_CI_AS = EM.strName COLLATE LATIN1_GENERAL_CI_AS 
						INNER JOIN tblARSalesperson SLS ON SLS.intEntityId = EM.intEntityId ) = 0 THEN  @defaultDriver
				  ELSE (select TOP 1 SLS.intEntityId from tblEMEntity EM INNER JOIN trdrvmst DRV 
						on DRV.trdrv_driver COLLATE LATIN1_GENERAL_CI_AS = MAX(trhst_driver) COLLATE LATIN1_GENERAL_CI_AS
						AND DRV.trdrv_name COLLATE LATIN1_GENERAL_CI_AS = EM.strName COLLATE LATIN1_GENERAL_CI_AS 
						INNER JOIN tblARSalesperson SLS ON SLS.intEntityId = EM.intEntityId) END,       -- intDriverId
			 min(trhst_tractor_trailor),-- strTractor
			 min(trhst_tractor_trailor),-- strTrailer
			 1,-- ysnPosted
			 1 -- intConcurrencyId
			 from trhstmst WHERE trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS NOT IN (SELECT strTransaction FROM tblTRLoadHeader 
							WHERE strTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS)
			 GROUP BY trhst_ord_no

			--IMPORT LOAD RECEIPTS-- 
			INSERT INTO [dbo].[tblTRLoadReceipt]
					 ([intLoadHeaderId]
					 ,[strOrigin]
					 ,[intTerminalId]
					 ,[intSupplyPointId]
					 ,[intCompanyLocationId]
					 ,[strBillOfLading]
					 ,[intItemId]
					 ,[intContractDetailId]
					 ,[dblGross]
					 ,[dblNet]
					 ,[dblUnitCost]
					 ,[dblFreightRate]
					 ,[dblPurSurcharge]
					 ,[intInventoryReceiptId]
					 ,[ysnFreightInPrice]
					 ,[intTaxGroupId]
					 ,[intInventoryTransferId]
					 ,[strReceiptLine]
					 ,[intConcurrencyId])
				SELECT 
					  intLoadHeaderId
					 ,strOrigin = CASE
								WHEN  trhst_pur_from_bulk_yn != 'Y'
								   THEN 'Terminal'
								else  
							    		'Location'
								END	   
					 ,VND.intEntityId               --[intTerminalId]
					 ,SP.intSupplyPointId           --[intSupplyPointId]
					 ,loc.intCompanyLocationId
					 ,ISNULL(trhst_pur_lading_no,trhst_ord_no)
					 ,ITM.intItemId
					 ,null                          --[intContractDetailId]
					 ,trhst_pur_gross_un
					 ,trhst_pur_net_un
					 ,trhst_pur_un_cost
					 ,trhst_pur_frt_un_cost         --[dblFreightRate]
					 ,0                             --[dblPurSurcharge]
					 ,null                          --[intInventoryReceiptId]
					 ,convert(bit,0)                --[ysnFreightInPrice]
					 ,SP.intTaxGroupId              --[intTaxGroupId]
					 ,null                          --[intInventoryTransferId]
	  				 ,'RL-'+CAST(TR.trhst_line_no AS char)
					 ,1                             --[intConcurrencyId]
				FROM dbo.trhstmst TR
					INNER JOIN tblTRLoadHeader HDR ON HDR.strTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = TR.trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS		  
					LEFT JOIN tblICItem AS ITM ON TR.trhst_pur_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS
					LEFT JOIN tblSMCompanyLocation AS loc ON TR.trhst_pur_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
					LEFT JOIN #tempvnd AS TMP ON trhst_pur_vnd_no = TMP.ssvnd_vnd_no
					LEFT JOIN tblAPVendor AS VND ON TMP.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS = VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS 
					LEFT JOIN tblEMEntity AS ENT ON ENT.intEntityId = VND.intEntityId
					LEFT JOIN tblEMEntityLocation AS VNDLOC ON VNDLOC.intEntityId = VND.intEntityId AND TMP.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS = VNDLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS
					left join vyuTRSupplyPointView as SP on SP.intEntityLocationId = VNDLOC.intEntityLocationId
				WHERE isNull(trhst_cus_no,'') = '' AND intLoadHeaderId NOT IN (SELECT intLoadHeaderId FROM tblTRLoadReceipt RCPT
				WHERE HDR.intLoadHeaderId = RCPT.intLoadHeaderId)

			--IMPORT LOAD DISTRIBUTIONS-- 
			  INSERT into @TempDist
			  SELECT  
					trhst_ord_no,
					trhst_cus_no
			  FROM [dbo].[trhstmst] TR
					left join ptitmmst as itm on TR.trhst_sls_itm_no = ptitm_itm_no and TR.trhst_sls_loc_no = ptitm_loc_no
					left join tblICItem as inv on TR.trhst_sls_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = inv.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS
					left join tblSMCompanyLocation as loc on itm.ptitm_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = loc.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
					left join tblARCustomer as cus on trhst_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = cus.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
					INNER JOIN tblTRLoadHeader HDR ON HDR.strTransaction  COLLATE SQL_Latin1_General_CP1_CS_AS = TR.trhst_ord_no  COLLATE SQL_Latin1_General_CP1_CS_AS
					where isNull(trhst_cus_no,'') != ''  AND HDR.intLoadHeaderId NOT IN (SELECT intLoadHeaderId FROM tblTRLoadDistributionHeader DIST WHERE HDR.intLoadHeaderId = DIST.intLoadHeaderId)
			        GROUP BY trhst_ord_no,trhst_cus_no
				
			 select @Disttotal = count(*) from @TempDist;
			 -- Loop for each Distribution Header
			 WHILE @incDistval <=@Disttotal 
			 BEGIN
				  SELECT @trhst_ord_no = strloadNo,@trhst_cus_no = strCusNo FROM @TempDist WHERE intId = @incDistval 				 

				  INSERT INTO [dbo].[tblTRLoadDistributionHeader]
						([intLoadHeaderId]
						,[strDestination]
						,[intEntityCustomerId]
						,[intShipToLocationId]
						,[intCompanyLocationId]
						,[intEntitySalespersonId]
						,[strPurchaseOrder]
						,[strComments]
						,[dtmInvoiceDateTime]
						,[intInvoiceId]
						,[intConcurrencyId])
				  SELECT  intLoadHeaderId
						,strDestination = CASE
									WHEN  TR.trhst_sls_own_loc_yn != 'Y'
									   THEN 'Customer'
									else  
							    			'Location'
									END	   
              
					   ,CUS.intEntityId		                                     --[intDefaultLocationId] 
					   ,CUS.intShipToId                                          --[intShipToLocationId]
					   ,LOC.intCompanyLocationId                                 --[intCompanyLocationId]
					   ,CUS.intSalespersonId                                     --[intSalespersonId]
					   ,trhst_sls_cus_po_no                                      --[strPurchaseOrder]
					   ,trhst_sls_comment                                        --[strComments]
					   ,CONVERT(DATETIME, CAST(trhst_rev_dt AS CHAR(12)), 112)   --[dtmInvoiceDateTime]
					   ,null                                                     --[intInvoiceId]
					   ,1                                                        --[intConcurrencyId]
				  FROM [dbo].[trhstmst] TR
						INNER JOIN tblTRLoadHeader HDR ON HDR.strTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = TR.trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS		  
						LEFT JOIN tblSMCompanyLocation AS LOC ON TR.trhst_sls_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
						LEFT JOIN tblARCustomer as CUS on trhst_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
						WHERE trhst_cus_no = @trhst_cus_no AND trhst_ord_no = @trhst_ord_no AND trhst_line_no = 1
						 

				  SET @intLoadDistributionHeaderId = @@IDENTITY;

				  INSERT INTO [dbo].[tblTRLoadDistributionDetail]
							 ([intLoadDistributionHeaderId]
							 ,[intItemId]
							 ,[intContractDetailId]
							 ,[dblUnits]
							 ,[dblPrice]
							 ,[dblFreightRate]
							 ,[dblDistSurcharge]
							 ,[ysnFreightInPrice]
							 ,[intTaxGroupId]
							 ,[strReceiptLink]
							 ,[intConcurrencyId])
					   SELECT @intLoadDistributionHeaderId
							  ,ITM.intItemId                     --[intItemId]
							  ,(SELECT TOP 1 intContractDetailId FROM tblCTContractDetail CDT 
								INNER JOIN tblCTContractHeader CNT ON CNT.intContractHeaderId = CDT.intContractHeaderId 
								AND CNT.intEntityId = CUS.intEntityId
								WHERE CNT.strContractNumber COLLATE SQL_Latin1_General_CP1_CS_AS = TR.trhst_cnt_no COLLATE SQL_Latin1_General_CP1_CS_AS 
								AND CDT.intItemId = ITM.intItemId) --[intContractDetailId]
							  ,trhst_sls_un                        --[dblUnits]
							  , trhst_sls_un_prc                   --[dblPrice]
							  , trhst_sls_frt_rt                   --[dblFreightRate]
							  ,null                                --[dblDistSurcharge]
							  ,convert(bit,0)                      --[ysnFreightInPrice]
							  ,null                                --[intTaxGroupId]
			      			  ,CASE WHEN (SELECT COUNT(strReceiptLine) FROM tblTRLoadDistributionHeader DHDR INNER JOIN tblTRLoadReceipt RCP ON RCP.intLoadHeaderId = DHDR.intLoadHeaderId
										  AND RCP.intItemId = ITM.intItemId WHERE DHDR.intLoadDistributionHeaderId = @intLoadDistributionHeaderId) = 1 
									THEN 
										(SELECT strReceiptLine FROM tblTRLoadDistributionHeader DHDR INNER JOIN tblTRLoadReceipt RCP ON RCP.intLoadHeaderId = DHDR.intLoadHeaderId
										AND RCP.intItemId = ITM.intItemId WHERE DHDR.intLoadDistributionHeaderId = @intLoadDistributionHeaderId)
									ELSE '' END
							  ,1                                   --[intConcurrencyId]
				  FROM [dbo].[trhstmst] TR
						LEFT JOIN tblICItem AS ITM ON TR.trhst_sls_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS = ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS
						LEFT JOIN tblSMCompanyLocation AS LOC ON TR.trhst_sls_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
						left join tblARCustomer as CUS on trhst_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
						where trhst_cus_no = @trhst_cus_no and trhst_ord_no = @trhst_ord_no 

                 -- ADD FRIEGHT ITEM DETAILS 
					INSERT INTO [dbo].[tblTRLoadDistributionDetail]
							 ([intLoadDistributionHeaderId]
							 ,[intItemId]
							 ,[dblUnits]
							 ,[dblPrice]
							 ,[dblFreightRate]
							 ,[dblDistSurcharge]
							 ,[ysnFreightInPrice]
							 ,[intTaxGroupId]
							 ,[strReceiptLink]
							 ,[intConcurrencyId])
					   SELECT @intLoadDistributionHeaderId
							  ,@Freight_Item_id                    --[intItemId]
							  ,1								   --[dblUnits]
							  ,trhst_sls_frt_amt                   --[dblPrice]
							  ,trhst_sls_frt_rt                    --[dblFreightRate]
							  ,null                                --[dblDistSurcharge]
							  ,convert(bit,0)                      --[ysnFreightInPrice]
							  ,null                                --[intTaxGroupId]
			      			  ,'RL-1'							   --[strReceiptLink]
							  ,1                                   --[intConcurrencyId]
					FROM [dbo].[trhstmst] TR
						LEFT JOIN tblSMCompanyLocation AS LOC ON TR.trhst_sls_loc_no COLLATE SQL_Latin1_General_CP1_CS_AS = LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS
						left join tblARCustomer as CUS on trhst_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
						where trhst_cus_no = @trhst_cus_no and trhst_ord_no = @trhst_ord_no and  trhst_line_no = 1 and  trhst_sls_frt_amt <> 0

				SET @incDistval = @incDistval + 1;
			END

			--CREATE i21 DISTRIBUTION for the receipt that do not have Distribution details in ORIGIN
			--****************************************************************************************
				SELECT RCP.intLoadReceiptId,RCP.intLoadHeaderId
				INTO #tmprcpt
				FROM tblTRLoadReceipt RCP
					INNER JOIN tblTRLoadHeader HDR ON RCP.intLoadHeaderId = HDR.intLoadHeaderId
					--INNER JOIN  dbo.trhstmst TR ON HDR.strTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = TR.trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS		  
				WHERE RCP.intLoadHeaderId NOT IN (SELECT intLoadHeaderId FROM tblTRLoadDistributionHeader DST
				WHERE DST.intLoadHeaderId = RCP.intLoadHeaderId)

				INSERT INTO [dbo].[tblTRLoadDistributionHeader]
						([intLoadHeaderId]
						,[strDestination]
						,[intCompanyLocationId]
						,[dtmInvoiceDateTime]
						,[intInvoiceId]
						,[intConcurrencyId])
				  SELECT RCP.intLoadHeaderId
						,'Location'      
					   ,RCP.intCompanyLocationId                                 --[intCompanyLocationId]
					   ,HDR.dtmLoadDateTime										 --[dtmInvoiceDateTime]
					   ,null                                                     --[intInvoiceId]
					   ,1                                                        --[intConcurrencyId]
				  FROM #tmprcpt RCPT
						INNER JOIN tblTRLoadReceipt RCP ON RCP.intLoadReceiptId = RCPT.intLoadReceiptId
						INNER JOIN tblTRLoadHeader HDR ON HDR.intLoadHeaderId = RCP.intLoadHeaderId
				  WHERE RCP.strReceiptLine = 'RL-1' 

				  INSERT INTO [dbo].[tblTRLoadDistributionDetail]
							 ([intLoadDistributionHeaderId]
							 ,[intItemId]
							 ,[dblUnits]
							 ,[dblPrice]
							 ,[ysnFreightInPrice]
							 ,[intTaxGroupId]
							 ,[strReceiptLink]
							 ,[intConcurrencyId])
					   SELECT DHDR.intLoadDistributionHeaderId
							  ,RCP.intItemId	                   --[intItemId]
							  ,RCP.dblNet		                   --[dblUnits]
							  ,0				                   --[dblPrice]
							  ,convert(bit,0)                      --[ysnFreightInPrice]
							  ,null                                --[intTaxGroupId]
			      			  ,RCP.strReceiptLine
							  ,1                                   --[intConcurrencyId]
				  FROM #tmprcpt RCPT
						INNER JOIN tblTRLoadReceipt RCP ON RCP.intLoadReceiptId = RCPT.intLoadReceiptId
						INNER JOIN tblTRLoadHeader HDR ON HDR.intLoadHeaderId = RCP.intLoadHeaderId
						INNER JOIN tblTRLoadDistributionHeader DHDR ON DHDR.intLoadHeaderId = HDR.intLoadHeaderId					 
		END

 	IF(@Checking = 1)
	BEGIN
		SELECT @Total =  COUNT(DISTINCT trhst_ord_no) FROM trhstmst 
		WHERE trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS NOT IN (SELECT strTransaction FROM tblTRLoadHeader 
		WHERE strTransaction COLLATE SQL_Latin1_General_CP1_CS_AS = trhst_ord_no COLLATE SQL_Latin1_General_CP1_CS_AS)
	END

END
GO
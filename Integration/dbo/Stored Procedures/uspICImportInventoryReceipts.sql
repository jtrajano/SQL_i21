/****** Object:  StoredProcedure [dbo].[uspICImportInventoryReceipts]    Script Date: 08/24/2016 06:24:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspICImportInventoryReceipts]
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL

	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================
	
	--================================================
	--CREATED TRIGGER TO GET THE RECEIPT NUMBER--
	--================================================
	EXEC ('CREATE TRIGGER [dbo].[trgReceiptNumber]
	ON [dbo].[tblICInventoryReceipt]
	FOR INSERT
	AS

	DECLARE @inserted TABLE(intInventoryReceiptId INT)
	DECLARE @count INT = 0
	DECLARE @intInventoryReceiptId INT
	DECLARE @ReceiptNumber NVARCHAR(50)
	DECLARE @intMaxCount INT = 0
	DECLARE @intStartingNumberId INT = 0

	INSERT INTO @inserted
	SELECT intInventoryReceiptId FROM INSERTED ORDER BY intInventoryReceiptId
	WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
	BEGIN
		SET @intStartingNumberId = 23	
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId  FROM @inserted
		SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM tblSMStartingNumber 
		WHERE strTransactionType = ''Inventory Receipt''
		
		EXEC uspSMGetStartingNumber @intStartingNumberId, @ReceiptNumber OUT	
	
		IF(@ReceiptNumber IS NOT NULL)
		BEGIN
			IF EXISTS (SELECT NULL FROM tblICInventoryReceipt WHERE strReceiptNumber = @ReceiptNumber)
				BEGIN
					SET @ReceiptNumber = NULL
					DECLARE @intStartIndex INT = 4
									
					SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strReceiptNumber, @intStartIndex, 10))) FROM tblICInventoryReceipt 

					UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
					EXEC uspSMGetStartingNumber @intStartingNumberId, @ReceiptNumber OUT				
				END
			UPDATE tblICInventoryReceipt
				SET tblICInventoryReceipt.strReceiptNumber = @ReceiptNumber
			FROM tblICInventoryReceipt A
			WHERE A.intInventoryReceiptId = @intInventoryReceiptId
		END
		DELETE FROM @inserted
		WHERE intInventoryReceiptId = @intInventoryReceiptId
	END')

-----------------------------------------------------------------------------------------------------		
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
		BEGIN
			SET @StartDate = NULL
			SET @EndDate = NULL
		END			
	
	DECLARE @EntityId int
	SET @EntityId = ISNULL((SELECT  intEntityUserSecurityId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @UserId),@UserId)
	

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	

	
	IF(@Checking = 0) 
	BEGIN
		
		--1 Time synchronization here
		PRINT '1 Time Invoice Synchronization'
		
		DECLARE @maxInvRcptId INT
		
		SELECT @maxInvRcptId = MAX([intInventoryReceiptId]) FROM tblICInventoryReceipt
		SET @maxInvRcptId = ISNULL(@maxInvRcptId, 0)
				
	  	--================================================
		-- Insert into tblICInventoryReceipt --AG Inventory Receipts--
		--================================================	
					
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agphsmst')
		 Begin
			INSERT INTO [dbo].[tblICInventoryReceipt]
			   ([strReceiptType]
			   ,[intSourceType]
			   ,[intEntityVendorId]
			   ,[intTransferorId]
			   ,[intLocationId]
			   ,[strReceiptNumber]
			   ,[dtmReceiptDate]
			   ,[intCurrencyId]
			   ,[intSubCurrencyCents]
			   ,[intBlanketRelease]
			   ,[strVendorRefNo]
			   ,[strBillOfLading]
			   ,[intShipViaId]
			   ,[intShipFromId]
			   ,[intReceiverId]
			   ,[strVessel]
			   ,[intFreightTermId]
			   ,[intShiftNumber]
			   ,[dblInvoiceAmount]
			   ,[ysnPrepaid]
			   ,[ysnInvoicePaid]
			   ,[intTaxGroupId]
			   ,[ysnPosted]
			   ,[intCreatedUserId]
			   ,[intEntityId]
			   ,[intConcurrencyId]
			   ,strReceiptOriginId
			   ,ysnOrigin)
			SELECT
					'Direct'--[strReceiptType]
					,0--[intSourceType]
					,(select intEntityVendorId from tblAPVendor where strVendorId = Vnd.strVendorPayToId)
					,NULL--[intTransferorId]
					,(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = PHS.agphs_hdr_loc_no COLLATE Latin1_General_CI_AS)--[intLocationId]
					,PHS.agphs_ord_no --[strReceiptNumber]
					,(CASE WHEN ISDATE(agphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(agphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmReceiptDate]
					,(select intDefaultCurrencyId from tblSMCompanyPreference)--intCurrencyId
					,1--[intSubCurrencyCents]
					,0--[intBlanketRelease]
					,PHS.agphs_vnd_ivc_no--[strVendorRefNo]
					,PHS.agphs_bill_lading--[strBillOfLading]
					,(SELECT intEntityShipViaId FROM tblSMShipVia WHERE strShipViaOriginKey  COLLATE Latin1_General_CI_AS = PHS.agphs_carrier COLLATE Latin1_General_CI_AS)--[intShipViaId]
					,Vnd.intDefaultLocationId--[intShipFromId]
					,@UserId--[intReceiverId]
					,''--[strVessel]
					,(select intFreightTermId from tblSMFreightTerms where strFreightTerm = 'Delivery')--[intFreightTermId]
					,0--[intShiftNumber]
					,PHS.agphs_calc_total--[dblInvoiceAmount]
					,0--[ysnPrepaid]
					,0--[ysnInvoicePaid]
					,(SELECT intTaxGroupId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = PHS.agphs_hdr_loc_no COLLATE Latin1_General_CI_AS)--[intTaxGroupId]
					,1--[ysnPosted]
					,@UserId--[intCreatedUserId]
					,@UserId--[intEntityId]
					,0--[intConcurrencyId]
					,PHS.agphs_ord_no--strReceiptOriginId
					,0
			FROM agphsmst PHS
			LEFT JOIN tblICInventoryReceipt Inv ON PHS.agphs_ord_no COLLATE Latin1_General_CI_AS = Inv.strReceiptOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblAPVendor Vnd ON  strVendorId COLLATE Latin1_General_CI_AS = PHS.agphs_vnd_no COLLATE Latin1_General_CI_AS
			WHERE Inv.strReceiptNumber IS NULL and PHS.agphs_line_no = 0			   
			AND (
					((CASE WHEN ISDATE(agphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(agphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
			
		 End
		
		--==========================================================
		--     Insert into tblICInventoryReceiptDetail - AG Inventory Receipt ITEMS
		--==========================================================
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agphsmst')
		 Begin
			INSERT INTO [dbo].[tblICInventoryReceiptItem]
				   ([intInventoryReceiptId]
				   ,[intLineNo]
				   ,[intItemId]
				   ,[intOwnershipType]
				   ,[dblOrderQty]
				   ,[dblBillQty]
				   ,[dblOpenReceive]
				   ,[dblReceived]
				   ,[intUnitMeasureId]
				   ,[intCostUOMId]
				   ,[dblUnitCost]
				   ,[dblUnitRetail]
				   ,[ysnSubCurrency]
				   ,[dblLineTotal]
				   ,[dblGross]
				   ,[dblNet]
				   ,[dblTax]
				   ,[intConcurrencyId]
				   ,[strComments])
			SELECT 
				INV.intInventoryReceiptId	--[intInventoryReceiptId]
				 ,agphs_line_no-- [intLineNo]
				 ,ITM.intItemId-- [intItemId]
				 ,1-- [intOwnershipType]
				 ,0-- [dblOrderQty]
				 ,0-- [dblBillQty]
				 ,CASE 
					WHEN (DTL.agphs_verified_yn = 'Y')
					THEN DTL.agphs_invc_un
					ELSE DTL.agphs_rcvd_un
				  END-- [dblOpenReceive]
				 ,0-- [dblReceived]
				 ,isNull((select intUnitMeasureId from tblICUnitMeasure where strSymbol COLLATE Latin1_General_CI_AS = DTL.agphs_un_desc COLLATE Latin1_General_CI_AS),intUnitMeasureId)-- [intUnitMeasureId] 
				 ,isNull((select intUnitMeasureId from tblICUnitMeasure where strSymbol COLLATE Latin1_General_CI_AS = DTL.agphs_un_desc COLLATE Latin1_General_CI_AS),intUnitMeasureId)-- [intCostUOMId]
				 ,CASE 
					WHEN (DTL.agphs_verified_yn = 'Y')
					THEN DTL.agphs_invc_un_cst
					ELSE DTL.agphs_rcvd_un_cst
				  END-- [dblUnitCost]
				 ,0-- [dblUnitRetail]
				 ,0-- [ysnSubCurrency]
				 ,(DTL.agphs_invc_un * DTL.agphs_invc_un_cst)-- [dblLineTotal]
				 ,agphs_rcvd_gross_un-- [dblGross]
				 ,agphs_rcvd_net_un-- [dblNet]
				 ,0-- [dblTax]
				 ,0-- [intConcurrencyId]
				 ,DTL.agphs_desc_override 		 			
			FROM agphsmst DTL
			INNER JOIN tblICInventoryReceipt INV ON INV.strReceiptOriginId COLLATE Latin1_General_CI_AS = DTL.agphs_ord_no COLLATE Latin1_General_CI_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(DTL.agphs_itm_no  COLLATE Latin1_General_CI_AS)
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId
			WHERE DTL.agphs_itm_no <> '*' and DTL.agphs_line_no <> 0 and INV.ysnOrigin = 0
			
			 EXEC [uspICImportInventoryReceiptsAGItemTax]	 
		 end
		 			 
	  	--================================================
		--     Insert into tblICInventoryReceipt --PT Inventory Receipts--
		--================================================	
					
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		 Begin
			INSERT INTO [dbo].[tblICInventoryReceipt]
			   ([strReceiptType]
			   ,[intSourceType]
			   ,(select intEntityVendorId from tblAPVendor where strVendorId = Vnd.strVendorPayToId)
			   ,[intTransferorId]
			   ,[intLocationId]
			   ,[strReceiptNumber]
			   ,[dtmReceiptDate]
			   ,[intCurrencyId]
			   ,[intSubCurrencyCents]
			   ,[intBlanketRelease]
			   ,[strVendorRefNo]
			   ,[strBillOfLading]
			   ,[intShipViaId]
			   ,[intShipFromId]
			   ,[intReceiverId]
			   ,[strVessel]
			   ,[intFreightTermId]
			   ,[intShiftNumber]
			   ,[dblInvoiceAmount]
			   ,[ysnPrepaid]
			   ,[ysnInvoicePaid]
			   ,[intTaxGroupId]
			   ,[ysnPosted]
			   ,[intCreatedUserId]
			   ,[intEntityId]
			   ,[intConcurrencyId]
			   ,strReceiptOriginId
			   ,ysnOrigin)
			SELECT
					'Direct'--[strReceiptType]
					,0--[intSourceType]
					,Vnd.intEntityVendorId
					,NULL--[intTransferorId]
					,(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = PHS.ptphs_hdr_loc_no COLLATE Latin1_General_CI_AS)--[intLocationId]
					,PHS.ptphs_ord_no --[strReceiptNumber]
					,(CASE WHEN ISDATE(ptphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmReceiptDate]
					,(select intDefaultCurrencyId from tblSMCompanyPreference)--intCurrencyId
					,1--[intSubCurrencyCents]
					,0--[intBlanketRelease]
					,PHS.ptphs_vnd_ivc_no--[strVendorRefNo]
					,PHS.ptphs_bill_lading--[strBillOfLading]
					,(SELECT intEntityShipViaId FROM tblSMShipVia WHERE strShipViaOriginKey  COLLATE Latin1_General_CI_AS = PHS.ptphs_carrier COLLATE Latin1_General_CI_AS)--[intShipViaId]
					,Vnd.intDefaultLocationId--[intShipFromId]
					,@UserId--[intReceiverId]
					,''--[strVessel]
					,(select intFreightTermId from tblSMFreightTerms where strFreightTerm = 'Delivery')--[intFreightTermId]
					,0--[intShiftNumber]
					,PHS.ptphs_calc_total--[dblInvoiceAmount]
					,0--[ysnPrepaid]
					,0--[ysnInvoicePaid]
					,(SELECT intTaxGroupId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = PHS.ptphs_hdr_loc_no COLLATE Latin1_General_CI_AS)--[intTaxGroupId]
					,1--[ysnPosted]
					,@UserId--[intCreatedUserId]
					,@UserId--[intEntityId]
					,0--[intConcurrencyId]
					,PHS.ptphs_ord_no--strReceiptOriginId
					,0
			FROM ptphsmst PHS
			LEFT JOIN tblICInventoryReceipt Inv ON PHS.ptphs_ord_no COLLATE Latin1_General_CI_AS = Inv.strReceiptOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblAPVendor Vnd ON  strVendorId COLLATE Latin1_General_CI_AS = PHS.ptphs_vnd_no COLLATE Latin1_General_CI_AS
			WHERE Inv.strReceiptNumber IS NULL and PHS.ptphs_line_no = 0			   
			AND (
					((CASE WHEN ISDATE(ptphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
			
		 End

		
			--==========================================================
			--     Insert into tblICInventoryReceiptDetail - PT INVOICE DETAILS
			--==========================================================
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		 Begin
			INSERT INTO [dbo].[tblICInventoryReceiptItem]
				   ([intInventoryReceiptId]
				   ,[intLineNo]
				   ,[intItemId]
				   ,[intOwnershipType]
				   ,[dblOrderQty]
				   ,[dblBillQty]
				   ,[dblOpenReceive]
				   ,[dblReceived]
				   ,[intUnitMeasureId]
				   ,[intCostUOMId]
				   ,[dblUnitCost]
				   ,[dblUnitRetail]
				   ,[ysnSubCurrency]
				   ,[dblLineTotal]
				   ,[dblGross]
				   ,[dblNet]
				   ,[dblTax]
				   ,[intConcurrencyId]
				   ,[strComments])
			SELECT 
				INV.intInventoryReceiptId	--[intInventoryReceiptId]
				 ,ptphs_line_no-- [intLineNo]
				 ,ITM.intItemId-- [intItemId]
				 ,1-- [intOwnershipType]
				 ,0-- [dblOrderQty]
				 ,0-- [dblBillQty]
				 ,CASE 
					WHEN (DTL.ptphs_verified_yn = 'Y')
					THEN DTL.ptphs_invc_un
					ELSE DTL.ptphs_rcvd_un
				  END-- [dblOpenReceive]
				 ,0-- [dblReceived]
				 ,isNull((select intUnitMeasureId from tblICUnitMeasure where strSymbol COLLATE Latin1_General_CI_AS = DTL.ptphs_un_desc COLLATE Latin1_General_CI_AS),intUnitMeasureId)-- [intUnitMeasureId] 
				 ,isNull((select intUnitMeasureId from tblICUnitMeasure where strSymbol COLLATE Latin1_General_CI_AS = DTL.ptphs_un_desc COLLATE Latin1_General_CI_AS),intUnitMeasureId)-- [intCostUOMId]
				 ,CASE 
					WHEN (DTL.ptphs_verified_yn = 'Y')
					THEN DTL.ptphs_invc_un_cost
					ELSE DTL.ptphs_rcvd_un_cost
				  END-- [dblUnitCost]
				 ,0-- [dblUnitRetail]
				 ,0-- [ysnSubCurrency]
				 ,(DTL.ptphs_invc_un * DTL.ptphs_invc_un_cost)-- [dblLineTotal]
				 ,ptphs_rcvd_gross_un-- [dblGross]
				 ,ptphs_rcvd_net_un-- [dblNet]
				 ,0-- [dblTax]
				 ,0-- [intConcurrencyId]
				 ,DTL.ptphs_desc_override 		 			
			FROM ptphsmst DTL
			INNER JOIN tblICInventoryReceipt INV ON INV.strReceiptOriginId COLLATE Latin1_General_CI_AS = DTL.ptphs_ord_no COLLATE Latin1_General_CI_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(DTL.ptphs_itm_no  COLLATE Latin1_General_CI_AS)
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId
			WHERE DTL.ptphs_itm_no <> '*' and DTL.ptphs_line_no <> 0 and INV.ysnOrigin = 0
			
			EXEC [uspICImportInventoryReceiptsPTItemTax]
		 end
	
		IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trgReceiptNumber]'))
		DROP TRIGGER [dbo].trgReceiptNumber		  
		 	 			
	END
				 			
		
	----================================================
	----     GET TO BE IMPORTED RECORDS
	----	This is checking if there are still records need to be import	
	----================================================
	IF(@Checking = 1) 
	BEGIN

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		 BEGIN
		--Check first on ptphsmst
			SELECT @Total = COUNT(ptphs_ord_no)  
				FROM ptphsmst
			LEFT JOIN tblICInventoryReceipt Inv ON ptphsmst.ptphs_ord_no COLLATE Latin1_General_CI_AS = Inv.strReceiptOriginId COLLATE Latin1_General_CI_AS
			WHERE Inv.strReceiptOriginId IS NULL and ptphs_line_no = 0			   
			AND (
					((CASE WHEN ISDATE(ptphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
		 END		 
		
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agphsmst')
		 BEGIN
		--Check first on ptphsmst
			SELECT @Total = COUNT(agphs_ord_no)  
				FROM agphsmst
			LEFT JOIN tblICInventoryReceipt Inv ON agphsmst.agphs_ord_no COLLATE Latin1_General_CI_AS = Inv.strReceiptOriginId COLLATE Latin1_General_CI_AS
			WHERE Inv.strReceiptOriginId IS NULL and agphs_line_no = 0			   
			AND (
					((CASE WHEN ISDATE(agphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(agphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
	END		 
END				
		END
		
	

GO



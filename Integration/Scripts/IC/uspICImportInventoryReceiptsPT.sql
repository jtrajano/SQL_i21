/****** Object:  StoredProcedure [dbo].[uspICImportInventoryReceipts]    Script Date: 08/24/2016 06:24:06 ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICImportInventoryReceiptsPT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICImportInventoryReceiptsPT]; 
GO 

CREATE PROCEDURE [dbo].[uspICImportInventoryReceiptsPT]
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================

	-----------------------------------------------------------------------------------------------------		
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
	BEGIN
		SET @StartDate = NULL
		SET @EndDate = NULL
	END			

	
	IF(@Checking = 0) 
	BEGIN
		
		--1 Time synchronization here
		PRINT '1 Time PT Invoice Synchronization'		
			
	  	--================================================
		-- Insert into tblICInventoryReceipt --AG Inventory Receipts--
		--================================================	
	 			 
	  	--================================================
		--     Insert into tblICInventoryReceipt --PT Inventory Receipts--
		--================================================	
					
		IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		BEGIN
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
					,(select intEntityId from tblAPVendor where strVendorId = Vnd.strVendorPayToId)
					,NULL--[intTransferorId]
					,(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = PHS.ptphs_hdr_loc_no COLLATE Latin1_General_CI_AS)--[intLocationId]
					,PHS.ptphs_ord_no+CAST(PHS.A4GLIdentity AS NVARCHAR) --[strReceiptNumber]
					,(CASE WHEN ISDATE(ptphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmReceiptDate]
					,(select intDefaultCurrencyId from tblSMCompanyPreference)--intCurrencyId
					,1--[intSubCurrencyCents]
					,0--[intBlanketRelease]
					,PHS.ptphs_vnd_ivc_no--[strVendorRefNo]
					,PHS.ptphs_bill_lading--[strBillOfLading]
					,(SELECT intEntityId FROM tblSMShipVia WHERE strShipViaOriginKey  COLLATE Latin1_General_CI_AS = PHS.ptphs_carrier COLLATE Latin1_General_CI_AS)--[intShipViaId]
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
			
		 END

		
			--==========================================================
			--     Insert into tblICInventoryReceiptDetail - PT INVOICE DETAILS
			--==========================================================
		IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		BEGIN
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
				 ,UOM.intItemUOMId-- [intUnitMeasureId] 
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
			INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = UOM.intUnitMeasureId
			AND UM.strSymbol COLLATE Latin1_General_CI_AS = DTL.ptphs_un_desc COLLATE Latin1_General_CI_AS			
			WHERE DTL.ptphs_itm_no <> '*' and DTL.ptphs_line_no <> 0 and INV.ysnOrigin = 0
			
			EXEC [uspICImportInventoryReceiptsPTItemTax]
		 END
	END
				 			
	----================================================
	----     GET TO BE IMPORTED RECORDS
	----	This is checking if there are still records need to be import	
	----================================================
	IF(@Checking = 1) 
	BEGIN
		IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		 BEGIN
			--Check first on ptphsmst
			SELECT @Total = COUNT(ptphs_ord_no)  
				FROM ptphsmst
			LEFT JOIN tblICInventoryReceipt Inv ON ptphsmst.ptphs_ord_no COLLATE Latin1_General_CI_AS = Inv.strReceiptOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblAPVendor Vnd ON  strVendorId COLLATE Latin1_General_CI_AS = ptphsmst.ptphs_vnd_no COLLATE Latin1_General_CI_AS
			WHERE Inv.strReceiptNumber IS NULL and ptphs_line_no = 0			   
			AND (
					((CASE WHEN ISDATE(ptphs_rct_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptphs_rct_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
		 END
	END
END
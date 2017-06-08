--/****** Object:  StoredProcedure [dbo].[uspICImportInventoryReceiptsAGItemTax]    Script Date: 08/24/2016 06:28:30 ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICImportInventoryReceiptsAGItemTax]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICImportInventoryReceiptsAGItemTax]; 
GO 

CREATE PROCEDURE [dbo].[uspICImportInventoryReceiptsAGItemTax]

AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

BEGIN
--************************************************************************************************************************************************
--******************************** TAX FOR ITEM DOESNOT HAVE TAX SETUP IN ORIGIN *****************************************************************
--************************************************************************************************************************************************

--drop table #purnotax
--drop table #purnotax1

SELECT INV.intInventoryReceiptId, INV.strReceiptOriginId,PHS.agphs_line_no, agphs_itm_no,INV.intEntityVendorId,agphs_vnd_no, ITM.intItemId,ITM.intCategoryId,
CAT.intTaxClassId,(select agphs_tax_st from agphsmst where agphs_rcpt_seq = PHS.agphs_rcpt_seq and agphs_vnd_no = PHS.agphs_vnd_no and agphs_ord_no = PHS.agphs_ord_no and agphs_line_no = 0) as agphs_tax_st, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_set_rt ELSE agphs_invc_set_rt END as agphs_set_rt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_set_amt ELSE agphs_invc_set_amt END as agphs_set_amt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_fet_rt ELSE agphs_invc_fet_rt END as agphs_rcvd_fet_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_fet_amt ELSE agphs_invc_fet_amt END as agphs_fet_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_sst_rt ELSE agphs_invc_sst_rt END as agphs_rcvd_sst_rt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_sst_amt ELSE agphs_invc_sst_amt END as agphs_sst_amt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc1_rt ELSE agphs_invc_lc1_rt END as agphs_lc1_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc1_amt ELSE agphs_invc_lc1_amt END as agphs_lc1_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc2_rt ELSE agphs_invc_lc2_rt END as agphs_lc2_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc2_amt ELSE agphs_invc_lc2_amt END as agphs_lc2_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc3_rt ELSE agphs_invc_lc3_rt END as agphs_lc3_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc3_amt ELSE agphs_invc_lc3_amt END as agphs_lc3_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc4_rt ELSE agphs_invc_lc4_rt END as agphs_lc4_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc4_amt ELSE agphs_invc_lc4_amt END as agphs_lc4_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc5_rt ELSE agphs_invc_lc5_rt END as agphs_lc5_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc5_amt ELSE agphs_invc_lc5_amt END as agphs_lc5_amt,
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc6_rt ELSE agphs_invc_lc6_rt END as agphs_lc6_rt, 
CASE WHEN (agphs_verified_yn = 'Y')THEN agphs_rcvd_lc6_amt ELSE agphs_invc_lc6_amt END as agphs_lc6_amt
 into #purnotax 
FROM tblICInventoryReceipt INV 
INNER JOIN tblEMEntity ENT on ENT.intEntityId = INV.intEntityVendorId
INNER JOIN agphsmst PHS ON PHS.agphs_ord_no COLLATE Latin1_General_CI_AS = INV.strReceiptOriginId  COLLATE Latin1_General_CI_AS
AND PHS.agphs_vnd_no COLLATE Latin1_General_CI_AS = ENT.strEntityNo
INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = PHS.agphs_itm_no  COLLATE Latin1_General_CI_AS
INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId 
WHERE agphs_line_no <> 0  AND INV.strReceiptOriginId <> '' and INV.ysnOrigin = 0

------------------------------------------------------------------------------------------------------------------------------------------
---** INSERT SET TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_set_rt,--dblRate					 
		PHS.agphs_set_amt,--dblTax					 
		PHS.agphs_set_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'SET' 

---** INSERT FET TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_rcvd_fet_rt,--dblRate					 
		PHS.agphs_fet_amt,--dblTax					 
		PHS.agphs_fet_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'FET' 

---** INSERT SST TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_rcvd_sst_rt,--dblRate					 
		PHS.agphs_sst_amt,--dblTax					 
		PHS.agphs_sst_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'SST' 

---** INSERT LC1 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc1_rt,--dblRate					 
		PHS.agphs_lc1_amt,--dblTax					 
		PHS.agphs_lc1_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC1' 

---** INSERT LC2 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc2_rt,--dblRate					 
		PHS.agphs_lc2_amt,--dblTax					 
		PHS.agphs_lc2_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC2' 

---** INSERT LC3 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc3_rt,--dblRate					 
		PHS.agphs_lc3_amt,--dblTax					 
		PHS.agphs_lc3_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC3' 

---** INSERT LC4 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc4_rt,--dblRate					 
		PHS.agphs_lc4_amt,--dblTax					 
		PHS.agphs_lc4_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC4' 

---** INSERT LC5 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc5_rt,--dblRate					 
		PHS.agphs_lc5_amt,--dblTax					 
		PHS.agphs_lc5_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC5' 

---** INSERT LC6 TAX DETAILS **---
INSERT INTO [tblICInventoryReceiptItemTax]
		([intInventoryReceiptItemId]
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[dblRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[ysnTaxAdjusted]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[intConcurrencyId])			   
select 
		INVD.intInventoryReceiptItemId,--[intInventoryReceiptItemId]
		TAXG.intTaxGroupId,	--[intTaxGroupId]
		TAXC.intTaxCodeId, --[intTaxCodeId]
		PHS.intTaxClassId,	--[intTaxClassId]
		0,--[strTaxableByOtherTaxes]
		TAXR.strCalculationMethod,--[strCalculationMethod]
		PHS.agphs_lc6_rt,--dblRate					 
		PHS.agphs_lc6_amt,--dblTax					 
		PHS.agphs_lc6_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.agphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.agphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC6' 

--***UPDATE IC INVENTORY RECEIPTS DETAILS**--

select dtl.intInventoryReceiptItemId,tax.intTaxGroupId,sum(tax.dblTax)as dblTax into #tempDTL 
from tblICInventoryReceiptItem dtl
inner join tblICInventoryReceipt inv on inv.intInventoryReceiptId = dtl.intInventoryReceiptId
inner join tblICInventoryReceiptItemTax tax on tax.intInventoryReceiptItemId = dtl.intInventoryReceiptItemId
where inv.strReceiptOriginId <> '' and inv.ysnOrigin = 0 group by dtl.intInventoryReceiptItemId, tax.intTaxGroupId

update dtl 
set dtl.dblTax = tmp.dblTax
from tblICInventoryReceiptItem dtl
inner join #tempDTL tmp on tmp.intInventoryReceiptItemId = dtl.intInventoryReceiptItemId

Update tblICInventoryReceipt set ysnOrigin = 1 where strReceiptOriginId <> ''  and ysnOrigin = 0

END	


GO



--/****** Object:  StoredProcedure [dbo].[uspICImportInventoryReceiptsPTItemTax]    Script Date: 08/24/2016 06:31:39 ******/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICImportInventoryReceiptsPTItemTax]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICImportInventoryReceiptsPTItemTax]; 
GO 

CREATE PROCEDURE [dbo].[uspICImportInventoryReceiptsPTItemTax]

AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

BEGIN
--************************************************************************************************************************************************
--******************************** TAX FOR ITEM DOESNOT HAVE TAX SETUP IN ORIGIN *****************************************************************
--************************************************************************************************************************************************

--drop table #purnotax
--drop table #purnotax1

SELECT INV.intInventoryReceiptId, INV.strReceiptOriginId,PHS.ptphs_line_no, ptphs_itm_no,INV.intEntityVendorId,ptphs_vnd_no, ITM.intItemId,ITM.intCategoryId,
CAT.intTaxClassId,(select ptphs_tax_st from ptphsmst where ptphs_rcpt_seq = PHS.ptphs_rcpt_seq and ptphs_vnd_no = PHS.ptphs_vnd_no AND ptphs_ord_no = PHS.ptphs_ord_no and ptphs_line_no = 0) as ptphs_tax_st, 
ptphs_rcvd_set_rt,ptphs_set_amt, ptphs_rcvd_fet_rt, ptphs_fet_amt,
ptphs_rcvd_sst_rt,ptphs_sst_amt, ptphs_rcvd_lc1_rt, ptphs_lc1_amt,
ptphs_rcvd_lc2_rt,ptphs_lc2_amt, ptphs_rcvd_lc3_rt, ptphs_lc3_amt,
ptphs_rcvd_lc4_rt,ptphs_lc4_amt, ptphs_rcvd_lc5_rt, ptphs_lc5_amt,
ptphs_rcvd_lc6_rt,ptphs_lc6_amt, ptphs_rcvd_lc7_rt, ptphs_lc7_amt,
ptphs_rcvd_lc8_rt,ptphs_lc8_amt, ptphs_rcvd_lc9_rt, ptphs_lc9_amt,
ptphs_rcvd_lc10_rt,ptphs_lc10_amt, ptphs_rcvd_lc11_rt, ptphs_lc11_amt,
ptphs_rcvd_lc12_rt,ptphs_lc12_amt into #purnotax 
FROM tblICInventoryReceipt INV 
INNER JOIN tblEMEntity ENT on ENT.intEntityId = INV.intEntityVendorId
INNER JOIN ptphsmst PHS ON PHS.ptphs_ord_no COLLATE Latin1_General_CI_AS = INV.strReceiptOriginId  COLLATE Latin1_General_CI_AS
AND PHS.ptphs_vnd_no COLLATE Latin1_General_CI_AS = ENT.strEntityNo
INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = PHS.ptphs_itm_no  COLLATE Latin1_General_CI_AS
INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId 
WHERE ptphs_line_no <> 0  AND INV.strReceiptOriginId <> '' and INV.ysnOrigin = 0

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
		PHS.ptphs_rcvd_set_rt,--dblRate					 
		PHS.ptphs_set_amt,--dblTax					 
		PHS.ptphs_set_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_fet_rt,--dblRate					 
		PHS.ptphs_fet_amt,--dblTax					 
		PHS.ptphs_fet_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_sst_rt,--dblRate					 
		PHS.ptphs_sst_amt,--dblTax					 
		PHS.ptphs_sst_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc1_rt,--dblRate					 
		PHS.ptphs_lc1_amt,--dblTax					 
		PHS.ptphs_lc1_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc2_rt,--dblRate					 
		PHS.ptphs_lc2_amt,--dblTax					 
		PHS.ptphs_lc2_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc3_rt,--dblRate					 
		PHS.ptphs_lc3_amt,--dblTax					 
		PHS.ptphs_lc3_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc4_rt,--dblRate					 
		PHS.ptphs_lc4_amt,--dblTax					 
		PHS.ptphs_lc4_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc5_rt,--dblRate					 
		PHS.ptphs_lc5_amt,--dblTax					 
		PHS.ptphs_lc5_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
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
		PHS.ptphs_rcvd_lc6_rt,--dblRate					 
		PHS.ptphs_lc6_amt,--dblTax					 
		PHS.ptphs_lc6_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC6' 

---** INSERT LC7 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc7_rt,--dblRate					 
		PHS.ptphs_lc7_amt,--dblTax					 
		PHS.ptphs_lc7_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC7' 

---** INSERT LC8 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc8_rt,--dblRate					 
		PHS.ptphs_lc8_amt,--dblTax					 
		PHS.ptphs_lc8_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC8' 

---** INSERT LC9 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc9_rt,--dblRate					 
		PHS.ptphs_lc9_amt,--dblTax					 
		PHS.ptphs_lc9_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC9' 

---** INSERT LC10 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc10_rt,--dblRate					 
		PHS.ptphs_lc10_amt,--dblTax					 
		PHS.ptphs_lc10_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC10' 

---** INSERT LC11 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc11_rt,--dblRate					 
		PHS.ptphs_lc11_amt,--dblTax					 
		PHS.ptphs_lc11_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC11' 

---** INSERT LC12 TAX DETAILS **---
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
		PHS.ptphs_rcvd_lc12_rt,--dblRate					 
		PHS.ptphs_lc12_amt,--dblTax					 
		PHS.ptphs_lc12_amt,--[dblAdjustedTax]
		0,--[ysnTaxAdjusted]
		0,--[ysnSeparateOnInvoice]
		0,--[ysnCheckoffTax]
		TAXC.strTaxCode,
		0--[intConcurrencyId]
 from #purnotax PHS
INNER JOIN  tblICInventoryReceiptItem INVD ON INVD.intInventoryReceiptId = PHS.intInventoryReceiptId and INVD.intItemId = PHS.intItemId
			AND INVD.intLineNo = PHS.ptphs_line_no
INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = PHS.intTaxClassId
INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = PHS.ptphs_tax_st COLLATE Latin1_General_CI_AS		   
INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
where XREF.strTaxClassType = 'LC12' 


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



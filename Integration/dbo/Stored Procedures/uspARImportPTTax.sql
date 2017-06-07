CREATE PROCEDURE [dbo].[uspARImportPTTax]
	AS
BEGIN

	--IMPORTS THE TAX XREF TABLE 
	EXEC [uspARImportPTTaxXref]
	--************************************************************************************************************************************************
	--******************************** TAX FOR ITEM DOESNOT HAVE TAX SETUP IN ORIGIN *****************************************************************
	--************************************************************************************************************************************************
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'temp_sst')
		DROP table temp_sst
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#itmnotax')
		DROP table #itmnotax
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#itmnotax1')
		DROP table #itmnotax1	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#temp_ptstm')
		DROP table #temp_ptstm	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#tempDTL')
		DROP table #tempDTL	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#IVCTAX')
		DROP table #IVCTAX	
	

	SELECT IVC.intInvoiceId, IVC.strInvoiceOriginId, ptstm_itm_no,IVC.intEntityCustomerId,ptstm_bill_to_cus, ITM.intItemId,ITM.intCategoryId,
	CAT.intTaxClassId, --TAXG.intTaxGroupId, 
	ptstm_tax_key, 
	ptstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_set_amt * -1 ELSE ptstm_set_amt END) as ptstm_set_amt, 
	ptstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_fet_amt * -1 ELSE ptstm_fet_amt END) as ptstm_fet_amt,
	ptstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_sst_amt * -1 ELSE ptstm_sst_amt END) as ptstm_sst_amt,
	ptstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc1_amt * -1 ELSE ptstm_lc1_amt END) as ptstm_lc1_amt,
	ptstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc2_amt * -1 ELSE ptstm_lc2_amt END) as ptstm_lc2_amt, 
	ptstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc3_amt * -1 ELSE ptstm_lc3_amt END) as ptstm_lc3_amt, 
	ptstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc4_amt * -1 ELSE ptstm_lc4_amt END) as ptstm_lc4_amt, 
	ptstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc5_amt * -1 ELSE ptstm_lc5_amt END) as ptstm_lc5_amt, 
	ptstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc6_amt * -1 ELSE ptstm_lc6_amt END) as ptstm_lc6_amt, 
	ptstm_lc7_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc7_amt * -1 ELSE ptstm_lc7_amt END) as ptstm_lc7_amt, 
	ptstm_lc8_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc8_amt * -1 ELSE ptstm_lc8_amt END) as ptstm_lc8_amt, 
	ptstm_lc9_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc9_amt * -1 ELSE ptstm_lc9_amt END) as ptstm_lc9_amt, 
	ptstm_lc10_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc10_amt * -1 ELSE ptstm_lc10_amt END) as ptstm_lc10_amt, 
	ptstm_lc11_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc11_amt * -1 ELSE ptstm_lc11_amt END) as ptstm_lc11_amt, 
	ptstm_lc12_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc12_amt * -1 ELSE ptstm_lc12_amt END) as ptstm_lc12_amt into #itmnotax 
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN ptstmmst STM ON STM.ptstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.ptstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.ptstm_itm_no  COLLATE Latin1_General_CI_AS
	INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId
	WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL 
				   AND IVC.strInvoiceOriginId COLLATE Latin1_General_CI_AS  <> ''	AND STM.ptstm_tax_key is not null
				   and ptstm_itm_no not in (select strOrgItemNo COLLATE Latin1_General_CI_AS from tblSMTaxXRef)

	------------------------------------------------------------------------------------------------------------------------------------------
	---** INSERT SET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_set_rt,--dblRate					 
			STM.ptstm_set_amt,--dblTax					 
			STM.ptstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_set_amt = 0 and STM.ptstm_set_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'SET' and IVCD.strDocumentNumber is NULL

	---** INSERT FET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_fet_rt,--dblRate					 
			STM.ptstm_fet_amt,--dblTax					 
			STM.ptstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_fet_amt = 0 and STM.ptstm_fet_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'FET' and IVCD.strDocumentNumber is NULL

	---** INSERT SST TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_sst_rt,--dblRate					 
			STM.ptstm_sst_amt,--dblTax					 
			STM.ptstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_sst_amt = 0 and STM.ptstm_sst_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'SST' and IVCD.strDocumentNumber is NULL

	---** INSERT LC1 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc1_rt,--dblRate					 
			STM.ptstm_lc1_amt,--dblTax					 
			STM.ptstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc1_amt = 0 and STM.ptstm_lc1_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC1' and IVCD.strDocumentNumber is NULL

	---** INSERT LC2 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc2_rt,--dblRate					 
			STM.ptstm_lc2_amt,--dblTax					 
			STM.ptstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc2_amt = 0 and STM.ptstm_lc2_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC2' and IVCD.strDocumentNumber is NULL

	---** INSERT LC3 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc3_rt,--dblRate					 
			STM.ptstm_lc3_amt,--dblTax					 
			STM.ptstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc3_amt = 0 and STM.ptstm_lc3_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC3' and IVCD.strDocumentNumber is NULL

	---** INSERT LC4 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc4_rt,--dblRate					 
			STM.ptstm_lc4_amt,--dblTax					 
			STM.ptstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc4_amt = 0 and STM.ptstm_lc4_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC4' and IVCD.strDocumentNumber is NULL

	---** INSERT LC5 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc5_rt,--dblRate					 
			STM.ptstm_lc5_amt,--dblTax					 
			STM.ptstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc5_amt = 0 and STM.ptstm_lc5_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC5' and IVCD.strDocumentNumber is NULL
	---** INSERT LC6 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc6_rt,--dblRate					 
			STM.ptstm_lc6_amt,--dblTax					 
			STM.ptstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc6_amt = 0 and STM.ptstm_lc6_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC6' and IVCD.strDocumentNumber is NULL

	---** INSERT LC7 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc7_rt,--dblRate					 
			STM.ptstm_lc7_amt,--dblTax					 
			STM.ptstm_lc7_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc7_amt = 0 and STM.ptstm_lc7_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC7' and IVCD.strDocumentNumber is NULL
	---** INSERT LC8 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc8_rt,--dblRate					 
			STM.ptstm_lc8_amt,--dblTax					 
			STM.ptstm_lc8_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc8_amt = 0 and STM.ptstm_lc8_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC8' and IVCD.strDocumentNumber is NULL

	---** INSERT LC9 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc9_rt,--dblRate					 
			STM.ptstm_lc9_amt,--dblTax					 
			STM.ptstm_lc9_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc9_amt = 0 and STM.ptstm_lc9_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC9' and IVCD.strDocumentNumber is NULL

	---** INSERT LC10 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc10_rt,--dblRate					 
			STM.ptstm_lc10_amt,--dblTax					 
			STM.ptstm_lc10_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc10_amt = 0 and STM.ptstm_lc10_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC10' and IVCD.strDocumentNumber is NULL

	---** INSERT LC11 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc11_rt,--dblRate					 
			STM.ptstm_lc11_amt,--dblTax					 
			STM.ptstm_lc11_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc11_amt = 0 and STM.ptstm_lc11_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC11' and IVCD.strDocumentNumber is NULL

	---** INSERT LC12 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc12_rt,--dblRate					 
			STM.ptstm_lc12_amt,--dblTax					 
			STM.ptstm_lc12_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc12_amt = 0 and STM.ptstm_lc12_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC12' and IVCD.strDocumentNumber is NULL
	--*************************************************************************************************************
	--************************************* TAX FOR ITEM THAT HAS NULL ON TAX KEY ********************************************************************
	--*************************************************************************************************************

	SELECT IVC.intInvoiceId, IVC.strInvoiceOriginId,ENT.strEntityNo, ptstm_itm_no, ITM.intItemId,ITM.intCategoryId,
	CAT.intTaxClassId, --TAXG.intTaxGroupId, 
	ptstm_tax_key, 
	ptstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_set_amt * -1 ELSE ptstm_set_amt END) as ptstm_set_amt, 
	ptstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_fet_amt * -1 ELSE ptstm_fet_amt END) as ptstm_fet_amt,
	ptstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_sst_amt * -1 ELSE ptstm_sst_amt END) as ptstm_sst_amt,
	ptstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc1_amt * -1 ELSE ptstm_lc1_amt END) as ptstm_lc1_amt,
	ptstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc2_amt * -1 ELSE ptstm_lc2_amt END) as ptstm_lc2_amt, 
	ptstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc3_amt * -1 ELSE ptstm_lc3_amt END) as ptstm_lc3_amt, 
	ptstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc4_amt * -1 ELSE ptstm_lc4_amt END) as ptstm_lc4_amt, 
	ptstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc5_amt * -1 ELSE ptstm_lc5_amt END) as ptstm_lc5_amt, 
	ptstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc6_amt * -1 ELSE ptstm_lc6_amt END) as ptstm_lc6_amt, 
	ptstm_lc7_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc7_amt * -1 ELSE ptstm_lc7_amt END) as ptstm_lc7_amt, 
	ptstm_lc8_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc8_amt * -1 ELSE ptstm_lc8_amt END) as ptstm_lc8_amt, 
	ptstm_lc9_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc9_amt * -1 ELSE ptstm_lc9_amt END) as ptstm_lc9_amt, 
	ptstm_lc10_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc10_amt * -1 ELSE ptstm_lc10_amt END) as ptstm_lc10_amt, 
	ptstm_lc11_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc11_amt * -1 ELSE ptstm_lc11_amt END) as ptstm_lc11_amt, 
	ptstm_lc12_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc12_amt * -1 ELSE ptstm_lc12_amt END) as ptstm_lc12_amt into #itmnotax1
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN ptstmmst STM ON STM.ptstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.ptstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.ptstm_itm_no  COLLATE Latin1_General_CI_AS
	INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId
	WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL 
				   AND IVC.strInvoiceOriginId COLLATE Latin1_General_CI_AS  <> '' AND STM.ptstm_tax_key is null
				   and ptstm_itm_no not in (select strOrgItemNo COLLATE Latin1_General_CI_AS from tblSMTaxXRef)			  
	-----------------------------------------------------------------------------------------------------------------------			   			   			  		   

	---** INSERT SET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_set_rt,--dblRate					 
			STM.ptstm_set_amt,--dblTax					 
			STM.ptstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_set_amt = 0 and STM.ptstm_set_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'SET' and IVCD.strDocumentNumber is NULL

	---** INSERT FET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_fet_rt,--dblRate					 
			STM.ptstm_fet_amt,--dblTax					 
			STM.ptstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_fet_amt = 0 and STM.ptstm_fet_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'FET' and IVCD.strDocumentNumber is NULL

	---** INSERT SST TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_sst_rt,--dblRate					 
			STM.ptstm_sst_amt,--dblTax					 
			STM.ptstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_sst_amt = 0 and STM.ptstm_sst_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'SST' and IVCD.strDocumentNumber is NULL

	---** INSERT LC1 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc1_rt,--dblRate					 
			STM.ptstm_lc1_amt,--dblTax					 
			STM.ptstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc1_amt = 0 and STM.ptstm_lc1_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC1' and IVCD.strDocumentNumber is NULL

	---** INSERT LC2 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc2_rt,--dblRate					 
			STM.ptstm_lc2_amt,--dblTax					 
			STM.ptstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc2_amt = 0 and STM.ptstm_lc2_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS	   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC2' and IVCD.strDocumentNumber is NULL

	---** INSERT LC3 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc3_rt,--dblRate					 
			STM.ptstm_lc3_amt,--dblTax					 
			STM.ptstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc3_amt = 0 and STM.ptstm_lc3_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS	   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC3' and IVCD.strDocumentNumber is NULL

	---** INSERT LC4 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc4_rt,--dblRate					 
			STM.ptstm_lc4_amt,--dblTax					 
			STM.ptstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc4_amt = 0 and STM.ptstm_lc4_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC4' and IVCD.strDocumentNumber is NULL

	---** INSERT LC5 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc5_rt,--dblRate					 
			STM.ptstm_lc5_amt,--dblTax					 
			STM.ptstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc5_amt = 0 and STM.ptstm_lc5_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC5' and IVCD.strDocumentNumber is NULL
	---** INSERT LC6 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc6_rt,--dblRate					 
			STM.ptstm_lc6_amt,--dblTax					 
			STM.ptstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc6_amt = 0 and STM.ptstm_lc6_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC6' and IVCD.strDocumentNumber is NULL

	---** INSERT LC7 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc7_rt,--dblRate					 
			STM.ptstm_lc7_amt,--dblTax					 
			STM.ptstm_lc7_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc7_amt = 0 and STM.ptstm_lc7_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC7' and IVCD.strDocumentNumber is NULL
	---** INSERT LC8 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc8_rt,--dblRate					 
			STM.ptstm_lc8_amt,--dblTax					 
			STM.ptstm_lc8_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc8_amt = 0 and STM.ptstm_lc8_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC8' and IVCD.strDocumentNumber is NULL

	---** INSERT LC9 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc9_rt,--dblRate					 
			STM.ptstm_lc9_amt,--dblTax					 
			STM.ptstm_lc9_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc9_amt = 0 and STM.ptstm_lc9_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC9' and IVCD.strDocumentNumber is NULL

	---** INSERT LC10 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc10_rt,--dblRate					 
			STM.ptstm_lc10_amt,--dblTax					 
			STM.ptstm_lc10_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc10_amt = 0 and STM.ptstm_lc10_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC10' and IVCD.strDocumentNumber is NULL

	---** INSERT LC11 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc11_rt,--dblRate					 
			STM.ptstm_lc11_amt,--dblTax					 
			STM.ptstm_lc11_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc11_amt = 0 and STM.ptstm_lc11_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC11' and IVCD.strDocumentNumber is NULL

	---** INSERT LC12 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])			   
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			TAXG.intTaxGroupId,	--[intTaxGroupId]
			TAXC.intTaxCodeId, --[intTaxCodeId]
			STM.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			TAXR.strCalculationMethod,--[strCalculationMethod]
			STM.ptstm_lc12_rt,--dblRate					 
			STM.ptstm_lc12_amt,--dblTax					 
			STM.ptstm_lc12_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.ptstm_lc12_amt = 0 and STM.ptstm_lc12_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax1 STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN ptcusmst CUS on CUS.ptcus_cus_no COLLATE Latin1_General_CI_AS = STM.strEntityNo COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = CUS.ptcus_state COLLATE Latin1_General_CI_AS
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC12' and IVCD.strDocumentNumber is NULL
	--***********************************************************************************************************************************************

	--************************************************************************************************************************************************
	--******************************** TAX FOR ITEM THAT HAVE TAX SETUP IN ORIGIN ********************************************************************
	--************************************************************************************************************************************************
	--drop table #temp_ptstm
	--drop table temp_sst
	--drop table #IVCTAX
	--drop table #tempDTL

	SELECT intInvoiceId,strInvoiceOriginId,ptstm_itm_no, ITM.intItemId, ptstm_tax_key, 
	ptstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_set_amt * -1 ELSE ptstm_set_amt END) as ptstm_set_amt, 
	ptstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_fet_amt * -1 ELSE ptstm_fet_amt END) as ptstm_fet_amt,
	ptstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_sst_amt * -1 ELSE ptstm_sst_amt END) as ptstm_sst_amt,
	ptstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc1_amt * -1 ELSE ptstm_lc1_amt END) as ptstm_lc1_amt,
	ptstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc2_amt * -1 ELSE ptstm_lc2_amt END) as ptstm_lc2_amt, 
	ptstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc3_amt * -1 ELSE ptstm_lc3_amt END) as ptstm_lc3_amt, 
	ptstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc4_amt * -1 ELSE ptstm_lc4_amt END) as ptstm_lc4_amt, 
	ptstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc5_amt * -1 ELSE ptstm_lc5_amt END) as ptstm_lc5_amt, 
	ptstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc6_amt * -1 ELSE ptstm_lc6_amt END) as ptstm_lc6_amt, 
	ptstm_lc7_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc7_amt * -1 ELSE ptstm_lc7_amt END) as ptstm_lc7_amt, 
	ptstm_lc8_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc8_amt * -1 ELSE ptstm_lc8_amt END) as ptstm_lc8_amt, 
	ptstm_lc9_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc9_amt * -1 ELSE ptstm_lc9_amt END) as ptstm_lc9_amt, 
	ptstm_lc10_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc10_amt * -1 ELSE ptstm_lc10_amt END) as ptstm_lc10_amt, 
	ptstm_lc11_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc11_amt * -1 ELSE ptstm_lc11_amt END) as ptstm_lc11_amt, 
	ptstm_lc12_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN ptstm_lc12_amt * -1 ELSE ptstm_lc12_amt END) as ptstm_lc12_amt into #temp_ptstm
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN ptstmmst STM ON STM.ptstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.ptstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.ptstm_itm_no  COLLATE Latin1_General_CI_AS
	WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL AND IVC.strInvoiceOriginId <> ''	
	and ptstm_itm_no in (select strOrgItemNo COLLATE Latin1_General_CI_AS  from tblSMTaxXRef)

	--------------------------------------------------------------------------------------------------------------------------------------
	---** INSERT SET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_set_rt,--dblRate					 
			stm.ptstm_set_amt,--dblTax					 
			stm.ptstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (ptstm_set_amt = 0 and ptstm_set_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'SET' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_set_rt, stm.ptstm_set_amt

	---** INSERT FET TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_fet_rt,--dblRate					 
			stm.ptstm_fet_amt,--dblTax					 
			stm.ptstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_fet_amt = 0 and ptstm_fet_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'FET' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_fet_rt, stm.ptstm_fet_amt	

	---** INSERT SST TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_sst_rt,--dblRate					 
			stm.ptstm_sst_amt,--dblTax					 
			stm.ptstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_sst_amt = 0 and ptstm_sst_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'SST' and IVCD.strDocumentNumber is null
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_sst_rt, stm.ptstm_sst_amt

	-----------------------------------------------------------------------------------------
	select stm.intInvoiceId,strInvoiceOriginId,ptstm_itm_no, stm.intItemId, ptstm_tax_key, 
	ptstm_set_rt,ptstm_set_amt, ptstm_fet_rt, ptstm_fet_amt,
	ptstm_sst_rt,ptstm_sst_amt, ptstm_lc1_rt, ptstm_lc1_amt,
	ptstm_lc2_rt,ptstm_lc2_amt, ptstm_lc3_rt, ptstm_lc3_amt,
	ptstm_lc4_rt,ptstm_lc4_amt, ptstm_lc5_rt, ptstm_lc5_amt,
	ptstm_lc6_rt,ptstm_lc6_amt, ptstm_lc7_rt, ptstm_lc7_amt,
	ptstm_lc8_rt,ptstm_lc8_amt, ptstm_lc9_rt, ptstm_lc9_amt,
	ptstm_lc10_rt,ptstm_lc10_amt, ptstm_lc11_rt, ptstm_lc11_amt,
	ptstm_lc12_rt,ptstm_lc12_amt
	into temp_sst
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	where  stm.ptstm_sst_amt <> 0 and not exists
	(select * from  tblSMTaxXRef XREF where XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 )  and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 ) and XREF.strOrgTaxType = 'SST') 


	if (select COUNT (*) from temp_sst) <> 0
	Begin
		INSERT INTO [tblARInvoiceDetailTax]
				([intInvoiceDetailId]
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
				,[ysnTaxExempt])
		select 
				IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
				XREF.intTaxGroupId,	--[intTaxGroupId]
				XREF.intTaxCodeId, --[intTaxCodeId]
				XREF.intTaxClassId,	--[intTaxClassId]
				0,--[strTaxableByOtherTaxes]
				CASE 
					WHEN ([strOrgCalcMethod] = 'U')
						THEN 'Unit' 
					ELSE 'Precentage'
				END,--[strCalculationMethod]
				stm.ptstm_sst_rt,--dblRate					 
				stm.ptstm_sst_amt,--dblTax					 
				stm.ptstm_sst_amt,--[dblAdjustedTax]
				0,--[ysnTaxAdjusted]
				0,--[ysnSeparateOnInvoice]
				0,--[ysnCheckoffTax]
				CASE 
					WHEN (stm.ptstm_sst_amt = 0 and ptstm_sst_rt <> 0)
						THEN  1
					ELSE 0
				END--[ysnTaxExempt]
		from temp_sst stm
		INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
		INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = ' ' and
					 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
					 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
					 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
		where XREF.strOrgTaxType = 'SST' and IVCD.strDocumentNumber is null	and XREF.intTaxCodeId is not null
		group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
		XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_sst_rt, stm.ptstm_sst_amt
	End
	---** INSERT LC1 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc1_rt,--dblRate					 
			stm.ptstm_lc1_amt,--dblTax					 
			stm.ptstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc1_amt = 0 and ptstm_lc1_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC1' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc1_rt, stm.ptstm_lc1_amt

	---** INSERT LC2 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc2_rt,--dblRate					 
			stm.ptstm_lc2_amt,--dblTax					 
			stm.ptstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc2_amt = 0 and ptstm_lc2_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC2' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc2_rt, stm.ptstm_lc2_amt


	---** INSERT LC3 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc3_rt,--dblRate					 
			stm.ptstm_lc3_amt,--dblTax					 
			stm.ptstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc3_amt = 0 and ptstm_lc3_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC3' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc3_rt, stm.ptstm_lc3_amt


	---** INSERT LC4 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END as [strOrgCalcMethod],
			stm.ptstm_lc4_rt,--dblRate					 
			stm.ptstm_lc4_amt,--dblTax					 
			stm.ptstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc4_amt = 0 and ptstm_lc4_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC4' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc4_rt, stm.ptstm_lc4_amt

	---** INSERT LC5 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc5_rt,--dblRate					 
			stm.ptstm_lc5_amt,--dblTax					 
			stm.ptstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc5_amt = 0 and ptstm_lc5_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC5' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc5_rt, stm.ptstm_lc5_amt


	---** INSERT LC6 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc6_rt,--dblRate					 
			stm.ptstm_lc6_amt,--dblTax					 
			stm.ptstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc6_amt = 0 and ptstm_lc6_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC6' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc6_rt, stm.ptstm_lc6_amt


	---** INSERT LC7 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc7_rt,--dblRate					 
			stm.ptstm_lc7_amt,--dblTax					 
			stm.ptstm_lc7_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc7_amt = 0 and ptstm_lc7_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC7' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc7_rt, stm.ptstm_lc7_amt


	---** INSERT LC8 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc8_rt,--dblRate					 
			stm.ptstm_lc8_amt,--dblTax					 
			stm.ptstm_lc8_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc8_amt = 0 and ptstm_lc8_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC8' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc8_rt, stm.ptstm_lc8_amt


	---** INSERT LC9 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc9_rt,--dblRate					 
			stm.ptstm_lc9_amt,--dblTax					 
			stm.ptstm_lc9_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc9_amt = 0 and ptstm_lc9_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC9' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc9_rt, stm.ptstm_lc9_amt


	---** INSERT LC10 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc10_rt,--dblRate					 
			stm.ptstm_lc10_amt,--dblTax					 
			stm.ptstm_lc10_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc10_amt = 0 and ptstm_lc10_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC10' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc10_rt, stm.ptstm_lc10_amt


	---** INSERT LC11 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc11_rt,--dblRate					 
			stm.ptstm_lc11_amt,--dblTax					 
			stm.ptstm_lc11_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc11_amt = 0 and ptstm_lc11_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC11' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc11_rt, stm.ptstm_lc11_amt


	---** INSERT LC12 TAX DETAILS **---
	INSERT INTO [tblARInvoiceDetailTax]
			([intInvoiceDetailId]
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
			,[ysnTaxExempt])
	select 
			IVCD.intInvoiceDetailId,--[intInvoiceDetailId]
			XREF.intTaxGroupId,	--[intTaxGroupId]
			XREF.intTaxCodeId, --[intTaxCodeId]
			XREF.intTaxClassId,	--[intTaxClassId]
			0,--[strTaxableByOtherTaxes]
			CASE 
				WHEN ([strOrgCalcMethod] = 'U')
					THEN 'Unit' 
				ELSE 'Precentage'
			END,--[strCalculationMethod]
			stm.ptstm_lc12_rt,--dblRate					 
			stm.ptstm_lc12_amt,--dblTax					 
			stm.ptstm_lc12_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.ptstm_lc12_amt = 0 and ptstm_lc12_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_ptstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.ptstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.ptstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.ptstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.ptstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC12' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.ptstm_lc12_rt, stm.ptstm_lc12_amt

	-----------------------------------------------------------------------------------------------------------------------
	--*** UPDATE AR INVOICE DETAILS **--

	select dtl.intInvoiceDetailId,tax.intTaxGroupId,sum(tax.dblTax)as dblTax into #tempDTL 
	from tblARInvoiceDetail dtl
	inner join tblARInvoice ivc on ivc.intInvoiceId = dtl.intInvoiceId
	inner join tblARInvoiceDetailTax tax on tax.intInvoiceDetailId = dtl.intInvoiceDetailId
	where ivc.strInvoiceOriginId <> '' group by dtl.intInvoiceDetailId, tax.intTaxGroupId

	update dtl 
	set dtl.intTaxGroupId = tmp.intTaxGroupId, dtl.dblTotalTax = tmp.dblTax
	from tblARInvoiceDetail dtl
	inner join #tempDTL tmp on tmp.intInvoiceDetailId = dtl.intInvoiceDetailId

	update tblARInvoiceDetail 
	set strDocumentNumber = ' ' where strDocumentNumber is null
	-----------------------------------------------------------------------------------------------------
	--*** UPDATE AR INVOICE ***--
	select ivc.intInvoiceId,sum(tax.dblTax) as ivctax into #IVCTAX
	from tblARInvoice ivc
	inner join tblARInvoiceDetail dtl on dtl.intInvoiceId = ivc.intInvoiceId
	inner join tblARInvoiceDetailTax tax on tax.intInvoiceDetailId = dtl.intInvoiceDetailId
	where ivc.strInvoiceOriginId <> '' group by ivc.intInvoiceId

	update ivc 
	set ivc.dblTax = itax.ivctax
	from tblARInvoice ivc
	inner join #IVCTAX itax on itax.intInvoiceId = ivc.intInvoiceId

	update ivc 
	set ivc.dblInvoiceSubtotal = dblInvoiceTotal-dblTax
	from tblARInvoice ivc 

END
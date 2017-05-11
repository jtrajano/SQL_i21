CREATE PROCEDURE [dbo].[uspARImportAGTax]
	AS
BEGIN

	--IMPORTS THE TAX XREF TABLE 
	EXEC [uspARImportAGTaxXref]
	--************************************************************************************************************************************************
	--******************************** TAX FOR ITEM DOESNOT HAVE TAX SETUP IN ORIGIN *****************************************************************
	--************************************************************************************************************************************************

	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'temp_agsst')
		DROP table temp_agsst
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#itmnotax')
		DROP table #itmnotax
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#itmnotax1')
		DROP table #itmnotax1	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#temp_agstm')
		DROP table #temp_agstm	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#tempDTL')
		DROP table #tempDTL	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#IVCTAX')
		DROP table IVCTAX
							

	SELECT IVC.intInvoiceId, IVC.strInvoiceOriginId, agstm_itm_no,IVC.intEntityCustomerId,agstm_bill_to_cus, ITM.intItemId,ITM.intCategoryId,
	CAT.intTaxClassId, --TAXG.intTaxGroupId, 
	(agstm_tax_state+agstm_tax_auth_id1+agstm_tax_auth_id2) as agstm_tax_key,
	agstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_set_amt * -1 ELSE agstm_set_amt END) as agstm_set_amt, 
	agstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_fet_amt * -1 ELSE agstm_fet_amt END) as agstm_fet_amt,
	agstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_sst_amt * -1 ELSE agstm_sst_amt END) as agstm_sst_amt,
	agstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc1_amt * -1 ELSE agstm_lc1_amt END) as agstm_lc1_amt,
	agstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc2_amt * -1 ELSE agstm_lc2_amt END) as agstm_lc2_amt, 
	agstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc3_amt * -1 ELSE agstm_lc3_amt END) as agstm_lc3_amt, 
	agstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc4_amt * -1 ELSE agstm_lc4_amt END) as agstm_lc4_amt, 
	agstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc5_amt * -1 ELSE agstm_lc5_amt END) as agstm_lc5_amt, 
	agstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc6_amt * -1 ELSE agstm_lc6_amt END) as agstm_lc6_amt into #itmnotax 
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN agstmmst STM ON STM.agstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.agstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.agstm_itm_no  COLLATE Latin1_General_CI_AS
	INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId
	WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL 
				   AND IVC.strInvoiceOriginId <> ''	AND STM.agstm_tax_state is not null
				   and agstm_itm_no COLLATE Latin1_General_CI_AS not in (select strOrgItemNo COLLATE Latin1_General_CI_AS from tblSMTaxXRef)

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
			STM.agstm_set_rt,--dblRate					 
			STM.agstm_set_amt,--dblTax					 
			STM.agstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_set_amt = 0 and STM.agstm_set_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_fet_rt,--dblRate					 
			STM.agstm_fet_amt,--dblTax					 
			STM.agstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_fet_amt = 0 and STM.agstm_fet_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_sst_rt,--dblRate					 
			STM.agstm_sst_amt,--dblTax					 
			STM.agstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_sst_amt = 0 and STM.agstm_sst_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc1_rt,--dblRate					 
			STM.agstm_lc1_amt,--dblTax					 
			STM.agstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc1_amt = 0 and STM.agstm_lc1_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc2_rt,--dblRate					 
			STM.agstm_lc2_amt,--dblTax					 
			STM.agstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc2_amt = 0 and STM.agstm_lc2_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc3_rt,--dblRate					 
			STM.agstm_lc3_amt,--dblTax					 
			STM.agstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc3_amt = 0 and STM.agstm_lc3_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc4_rt,--dblRate					 
			STM.agstm_lc4_amt,--dblTax					 
			STM.agstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc4_amt = 0 and STM.agstm_lc4_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc5_rt,--dblRate					 
			STM.agstm_lc5_amt,--dblTax					 
			STM.agstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc5_amt = 0 and STM.agstm_lc5_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
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
			STM.agstm_lc6_rt,--dblRate					 
			STM.agstm_lc6_amt,--dblTax					 
			STM.agstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc6_amt = 0 and STM.agstm_lc6_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	 from #itmnotax STM
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = STM.intInvoiceId and IVCD.intItemId = STM.intItemId
	INNER JOIN tblSMTaxClassXref XREF on XREF.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxCode TAXC on TAXC.intTaxClassId = STM.intTaxClassId
	INNER JOIN tblSMTaxGroup TAXG on TAXG.strTaxGroup COLLATE Latin1_General_CI_AS = SUBSTRING ( STM.agstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS		   
	INNER JOIN tblSMTaxGroupCode TAXGC on TAXGC.intTaxGroupId = TAXG.intTaxGroupId and TAXGC.intTaxCodeId = TAXC.intTaxCodeId
	INNER JOIN tblSMTaxCodeRate TAXR on TAXR.intTaxCodeId = TAXC.intTaxCodeId
	where XREF.strTaxClassType = 'LC6' and IVCD.strDocumentNumber is NULL
	
	--*************************************************************************************************************
	--************************************* TAX FOR ITEM THAT HAS NULL ON TAX KEY ********************************************************************
	--*************************************************************************************************************

	SELECT IVC.intInvoiceId, IVC.strInvoiceOriginId,ENT.strEntityNo, agstm_itm_no, ITM.intItemId,ITM.intCategoryId,
	CAT.intTaxClassId, --TAXG.intTaxGroupId, 
	(agstm_tax_state+agstm_tax_auth_id1+agstm_tax_auth_id2) as agstm_tax_key,
	agstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_set_amt * -1 ELSE agstm_set_amt END) as agstm_set_amt, 
	agstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_fet_amt * -1 ELSE agstm_fet_amt END) as agstm_fet_amt,
	agstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_sst_amt * -1 ELSE agstm_sst_amt END) as agstm_sst_amt,
	agstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc1_amt * -1 ELSE agstm_lc1_amt END) as agstm_lc1_amt,
	agstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc2_amt * -1 ELSE agstm_lc2_amt END) as agstm_lc2_amt, 
	agstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc3_amt * -1 ELSE agstm_lc3_amt END) as agstm_lc3_amt, 
	agstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc4_amt * -1 ELSE agstm_lc4_amt END) as agstm_lc4_amt, 
	agstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc5_amt * -1 ELSE agstm_lc5_amt END) as agstm_lc5_amt, 
	agstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc6_amt * -1 ELSE agstm_lc6_amt END) as agstm_lc6_amt into #itmnotax1
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN agstmmst STM ON STM.agstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.agstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.agstm_itm_no  COLLATE Latin1_General_CI_AS
	INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId
	WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL 
				   AND IVC.strInvoiceOriginId <> ''	AND STM.agstm_tax_state is null
				   and agstm_itm_no COLLATE Latin1_General_CI_AS not in (select strOrgItemNo COLLATE Latin1_General_CI_AS from tblSMTaxXRef)			  
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
			STM.agstm_set_rt,--dblRate					 
			STM.agstm_set_amt,--dblTax					 
			STM.agstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_set_amt = 0 and STM.agstm_set_rt <> 0)
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
			STM.agstm_fet_rt,--dblRate					 
			STM.agstm_fet_amt,--dblTax					 
			STM.agstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_fet_amt = 0 and STM.agstm_fet_rt <> 0)
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
			STM.agstm_sst_rt,--dblRate					 
			STM.agstm_sst_amt,--dblTax					 
			STM.agstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_sst_amt = 0 and STM.agstm_sst_rt <> 0)
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
			STM.agstm_lc1_rt,--dblRate					 
			STM.agstm_lc1_amt,--dblTax					 
			STM.agstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc1_amt = 0 and STM.agstm_lc1_rt <> 0)
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
			STM.agstm_lc2_rt,--dblRate					 
			STM.agstm_lc2_amt,--dblTax					 
			STM.agstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc2_amt = 0 and STM.agstm_lc2_rt <> 0)
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
			STM.agstm_lc3_rt,--dblRate					 
			STM.agstm_lc3_amt,--dblTax					 
			STM.agstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc3_amt = 0 and STM.agstm_lc3_rt <> 0)
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
			STM.agstm_lc4_rt,--dblRate					 
			STM.agstm_lc4_amt,--dblTax					 
			STM.agstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc4_amt = 0 and STM.agstm_lc4_rt <> 0)
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
			STM.agstm_lc5_rt,--dblRate					 
			STM.agstm_lc5_amt,--dblTax					 
			STM.agstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc5_amt = 0 and STM.agstm_lc5_rt <> 0)
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
			STM.agstm_lc6_rt,--dblRate					 
			STM.agstm_lc6_amt,--dblTax					 
			STM.agstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (STM.agstm_lc6_amt = 0 and STM.agstm_lc6_rt <> 0)
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

	--************************************************************************************************************************************************
	--******************************** TAX FOR ITEM THAT HAVE TAX SETUP IN ORIGIN ********************************************************************
	--************************************************************************************************************************************************
	--drop table #temp_agstm
	--drop table temp_agsst
	--drop table #IVCTAX
	--drop table #tempDTL

	SELECT intInvoiceId,strInvoiceOriginId,agstm_itm_no, ITM.intItemId, (agstm_tax_state+agstm_tax_auth_id1+agstm_tax_auth_id1) as agstm_tax_key, 
	agstm_set_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_set_amt * -1 ELSE agstm_set_amt END) as agstm_set_amt, 
	agstm_fet_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_fet_amt * -1 ELSE agstm_fet_amt END) as agstm_fet_amt,
	agstm_sst_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_sst_amt * -1 ELSE agstm_sst_amt END) as agstm_sst_amt,
	agstm_lc1_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc1_amt * -1 ELSE agstm_lc1_amt END) as agstm_lc1_amt,
	agstm_lc2_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc2_amt * -1 ELSE agstm_lc2_amt END) as agstm_lc2_amt, 
	agstm_lc3_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc3_amt * -1 ELSE agstm_lc3_amt END) as agstm_lc3_amt, 
	agstm_lc4_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc4_amt * -1 ELSE agstm_lc4_amt END) as agstm_lc4_amt, 
	agstm_lc5_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc5_amt * -1 ELSE agstm_lc5_amt END) as agstm_lc5_amt, 
	agstm_lc6_rt,(CASE WHEN IVC.strTransactionType = 'Credit Memo' THEN agstm_lc6_amt * -1 ELSE agstm_lc6_amt END) as agstm_lc6_amt into #temp_agstm
	FROM tblARInvoice IVC 
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = IVC.intEntityCustomerId
	INNER JOIN agstmmst STM ON STM.agstm_ivc_no COLLATE Latin1_General_CI_AS = IVC.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND STM.agstm_bill_to_cus COLLATE Latin1_General_CI_AS = ENT.strEntityNo
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = STM.agstm_itm_no  COLLATE Latin1_General_CI_AS
	WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL AND IVC.strInvoiceOriginId <> ''	
	and agstm_itm_no COLLATE Latin1_General_CI_AS in (select strOrgItemNo COLLATE Latin1_General_CI_AS from tblSMTaxXRef)

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
			stm.agstm_set_rt,--dblRate					 
			stm.agstm_set_amt,--dblTax					 
			stm.agstm_set_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (agstm_set_amt = 0 and agstm_set_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'SET' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_set_rt, stm.agstm_set_amt

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
			stm.agstm_fet_rt,--dblRate					 
			stm.agstm_fet_amt,--dblTax					 
			stm.agstm_fet_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_fet_amt = 0 and agstm_fet_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'FET' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_fet_rt, stm.agstm_fet_amt	

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
			stm.agstm_sst_rt,--dblRate					 
			stm.agstm_sst_amt,--dblTax					 
			stm.agstm_sst_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_sst_amt = 0 and agstm_sst_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'SST' and IVCD.strDocumentNumber is null
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_sst_rt, stm.agstm_sst_amt

	-----------------------------------------------------------------------------------------
	select stm.intInvoiceId,strInvoiceOriginId,agstm_itm_no, stm.intItemId, stm.agstm_tax_key, 
	agstm_set_rt,agstm_set_amt, agstm_fet_rt, agstm_fet_amt,
	agstm_sst_rt,agstm_sst_amt, agstm_lc1_rt, agstm_lc1_amt,
	agstm_lc2_rt,agstm_lc2_amt, agstm_lc3_rt, agstm_lc3_amt,
	agstm_lc4_rt,agstm_lc4_amt, agstm_lc5_rt, agstm_lc5_amt,
	agstm_lc6_rt,agstm_lc6_amt
	into temp_agsst
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	where  stm.agstm_sst_amt <> 0 and not exists
	(select * from  tblSMTaxXRef XREF where XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 )  and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 ) and XREF.strOrgTaxType = 'SST') 


	if (select COUNT (*) from temp_agsst) <> 0
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
				stm.agstm_sst_rt,--dblRate					 
				stm.agstm_sst_amt,--dblTax					 
				stm.agstm_sst_amt,--[dblAdjustedTax]
				0,--[ysnTaxAdjusted]
				0,--[ysnSeparateOnInvoice]
				0,--[ysnCheckoffTax]
				CASE 
					WHEN (stm.agstm_sst_amt = 0 and agstm_sst_rt <> 0)
						THEN  1
					ELSE 0
				END--[ysnTaxExempt]
		from temp_agsst stm
		INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
		INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = ' ' and
					 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
					 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
					 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
		where XREF.strOrgTaxType = 'SST' and IVCD.strDocumentNumber is null	and XREF.intTaxCodeId is not null
		group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
		XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_sst_rt, stm.agstm_sst_amt
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
			stm.agstm_lc1_rt,--dblRate					 
			stm.agstm_lc1_amt,--dblTax					 
			stm.agstm_lc1_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc1_amt = 0 and agstm_lc1_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC1' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc1_rt, stm.agstm_lc1_amt

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
			stm.agstm_lc2_rt,--dblRate					 
			stm.agstm_lc2_amt,--dblTax					 
			stm.agstm_lc2_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc2_amt = 0 and agstm_lc2_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC2' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc2_rt, stm.agstm_lc2_amt


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
			stm.agstm_lc3_rt,--dblRate					 
			stm.agstm_lc3_amt,--dblTax					 
			stm.agstm_lc3_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc3_amt = 0 and agstm_lc3_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC3' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc3_rt, stm.agstm_lc3_amt


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
			stm.agstm_lc4_rt,--dblRate					 
			stm.agstm_lc4_amt,--dblTax					 
			stm.agstm_lc4_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc4_amt = 0 and agstm_lc4_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC4' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc4_rt, stm.agstm_lc4_amt

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
			stm.agstm_lc5_rt,--dblRate					 
			stm.agstm_lc5_amt,--dblTax					 
			stm.agstm_lc5_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc5_amt = 0 and agstm_lc5_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC5' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc5_rt, stm.agstm_lc5_amt


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
			stm.agstm_lc6_rt,--dblRate					 
			stm.agstm_lc6_amt,--dblTax					 
			stm.agstm_lc6_amt,--[dblAdjustedTax]
			0,--[ysnTaxAdjusted]
			0,--[ysnSeparateOnInvoice]
			0,--[ysnCheckoffTax]
			CASE 
				WHEN (stm.agstm_lc6_amt = 0 and agstm_lc6_rt <> 0)
					THEN  1
				ELSE 0
			END--[ysnTaxExempt]
	from #temp_agstm stm
	INNER JOIN  tblARInvoiceDetail IVCD ON IVCD.intInvoiceId = stm.intInvoiceId and IVCD.intItemId = stm.intItemId
	INNER JOIN  tblSMTaxXRef XREF ON XREF.strOrgItemNo = SUBSTRING ( stm.agstm_tax_key ,1 , 10 ) and
				 XREF.strOrgState = SUBSTRING ( stm.agstm_tax_key ,11 , 2 ) and
				 XREF.strOrgLocal1 = SUBSTRING ( stm.agstm_tax_key ,13 , 3 ) and
				 XREF.strOrgLocal2 = SUBSTRING ( stm.agstm_tax_key ,16 , 3 )	
	where XREF.strOrgTaxType = 'LC6' and IVCD.strDocumentNumber is null	
	group by IVCD.intInvoiceDetailId,XREF.intTaxGroupId,XREF.intTaxCodeId, 
	XREF.intTaxClassId,XREF.[strOrgCalcMethod],stm.agstm_lc6_rt, stm.agstm_lc6_amt

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
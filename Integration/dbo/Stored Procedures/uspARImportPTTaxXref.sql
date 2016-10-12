CREATE PROCEDURE [dbo].[uspARImportPTTaxXref]
	AS
BEGIN
--DELETE AND REIMPORT THE TAX RECORDS

	DELETE FROM [tblSMTaxXRef]

 --=============================================
 --        Insert Origin Tax in XRef--
 --=============================================
	--INSERT SET TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'SET'
		,'U'
		,pttax_set_rt
		,0
	FROM pttaxmst otax
	WHERE pttax_set_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT FET TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'FET'
		,'U'	
		,pttax_fet_rt
		,0		
	FROM pttaxmst otax
	WHERE pttax_fet_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT SST TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'SST'
		,pttax_sst_pu
		,pttax_sst_rt	
		,0			
	FROM pttaxmst otax
	WHERE pttax_sst_rt <> 0 

	--------------------------------------------------------------------------------------------------------
	---INSERT XREFERENCE RECORD FOR Origin Tax without Item---
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intTaxGroupId]
			   ,[strOrgItemClass]
			   ,[intCategoryId]
			   ,[intTaxClassId]
			   ,[intConcurrencyId]) 
	select [strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intTaxGroupId]
			   ,[strOrgItemClass]
			   ,ctax.[intCategoryId]
			   ,ctax.[intTaxClassId]
			   ,0
				from tblSMTaxClassXref xrf
	inner join tblICCategoryTax ctax on ctax.intTaxClassId = xrf.intTaxClassId
	full outer join tblSMTaxXRef txrf on txrf.strOrgItemNo = '' 
	where strTaxClassType = 'SST' and txrf.strOrgItemNo = '' 

	 delete from tblSMTaxXRef where intCategoryId is null and strOrgItemNo = ''

	-------------------------------------------------------------------------------------------------

	--INSERT LC1 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]           
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC1'
		,pttax_lc1_pu	
		,pttax_lc1_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc1_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC2 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC2'
		,pttax_lc2_pu	
		,pttax_lc2_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc2_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC3 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC3'
		,pttax_lc3_pu	
		,pttax_lc3_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc3_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC4 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC4'
		,pttax_lc4_pu	
		,pttax_lc4_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc4_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC5 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC5'
		,pttax_lc5_pu	
		,pttax_lc5_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc5_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC6 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC6'
		,pttax_lc6_pu	
		,pttax_lc6_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc6_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC7 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC7'
		,pttax_lc7_pu	
		,pttax_lc7_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc7_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC8 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC8'
		,pttax_lc8_pu	
		,pttax_lc8_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc8_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC9 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC9'
		,pttax_lc9_pu	
		,pttax_lc9_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc9_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC10 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC10'
		,pttax_lc10_pu	
		,pttax_lc10_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc10_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC11 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC11'
		,pttax_lc11_pu	
		,pttax_lc11_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc11_rt <> 0 and  pttax_itm_no <> ' ' 

	--INSERT LC12 TAX--
	INSERT INTO [dbo].[tblSMTaxXRef]
			   ([strOrgItemNo]
			   ,[strOrgState]
			   ,[strOrgLocal1]
			   ,[strOrgLocal2]
			   ,[strOrgTaxType]
			   ,[strOrgCalcMethod]           
			   ,[dblRate]
			   ,[intConcurrencyId])

		 SELECT distinct pttax_itm_no
		,pttax_state
		,pttax_local1
		,pttax_local2
		,'LC12'
		,pttax_lc12_pu	
		,pttax_lc12_rt
		,0				
	FROM pttaxmst otax
	WHERE pttax_lc12_rt <> 0 and  pttax_itm_no <> ' ' 

	--Insert i21 TAX GROUP--
	UPDATE xrf
	SET xrf.intTaxGroupId = grp.intTaxGroupId
	FROM [tblSMTaxXRef] xrf
	INNER JOIN tblSMTaxGroup grp ON grp.strTaxGroup collate SQL_Latin1_General_CP1_CS_AS = xrf.strOrgState collate SQL_Latin1_General_CP1_CS_AS

	--Insert i21 TAX ITEM CATEGORY--
	UPDATE xrf
	SET xrf.[intCategoryId] = itm.[intCategoryId]
	FROM [tblSMTaxXRef] xrf
	INNER JOIN tblICItem itm ON itm.strItemNo collate SQL_Latin1_General_CP1_CS_AS = xrf.strOrgItemNo collate SQL_Latin1_General_CP1_CS_AS

	UPDATE xrf
	SET xrf.[strCategoryCode] = ctg.[strCategoryCode]
	FROM [tblSMTaxXRef] xrf
	INNER JOIN tblICCategory ctg ON ctg.intCategoryId = xrf.intCategoryId

	--Insert Origin TAX ITEM CLASS--
	UPDATE xrf
	SET xrf.[strOrgItemClass] = itm.ptitm_class
	FROM [tblSMTaxXRef] xrf
	INNER JOIN ptitmmst itm ON itm.ptitm_itm_no collate SQL_Latin1_General_CP1_CS_AS = xrf.strOrgItemNo collate SQL_Latin1_General_CP1_CS_AS

	------------------------------------------------------------------------------------------------------------------------
	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'SET' and xrf.[strOrgTaxType] = 'SET'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'FET' and xrf.[strOrgTaxType] = 'FET'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'SST' and xrf.[strOrgTaxType] = 'SST'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC1' and xrf.[strOrgTaxType] = 'LC1'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC2' and xrf.[strOrgTaxType] = 'LC2'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC3' and xrf.[strOrgTaxType] = 'LC3'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC4' and xrf.[strOrgTaxType] = 'LC4'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC5' and xrf.[strOrgTaxType] = 'LC5'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC6' and xrf.[strOrgTaxType] = 'LC6'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC7' and xrf.[strOrgTaxType] = 'LC7'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC8' and xrf.[strOrgTaxType] = 'LC8'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC9' and xrf.[strOrgTaxType] = 'LC9'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC10' and xrf.[strOrgTaxType] = 'LC10'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC11' and xrf.[strOrgTaxType] = 'LC11'

	Update xrf 
	SET xrf.intTaxClassId = ctg.intTaxClassId, xrf.intTaxCodeId = tgcd.intTaxCodeId 
	from [tblSMTaxXRef] xrf
	INNER JOIN tblICCategoryTax ctg ON ctg.intCategoryId = xrf.intCategoryId
	INNER JOIN tblSMTaxCode tcd ON tcd.intTaxClassId = ctg.intTaxClassId
	INNER JOIN [tblSMTaxClassXref] txf ON txf.intTaxClassId = ctg.intTaxClassId
	INNER JOIN tblSMTaxGroupCode tgcd ON tgcd.[intTaxGroupId] = xrf.[intTaxGroupId]
									   and tgcd.intTaxCodeId = tcd.intTaxCodeId
	where txf.[strTaxClassType] = 'LC12' and xrf.[strOrgTaxType] = 'LC12'

	------------------------------------------------------------------------------------------------------------------------------
END





IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportPTTaxExemption')
	DROP PROCEDURE uspARImportPTTaxExemption
GO

CREATE PROCEDURE [dbo].[uspARImportPTTaxExemption]
			@Checking BIT = 0,
			@Total INT = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpptcusname')
			DROP TABLE tmpptcusname

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpvndname')
			DROP TABLE tmpvndname

		SELECT	ptcus_cus_no, ptcus_bill_to,
				CAST(ISNULL((CASE WHEN ptcus_co_per_ind_cp = 'C' THEN 
							ptcus_last_name + ptcus_first_name 
					 WHEN ptcus_co_per_ind_cp = 'P' THEN 
							RTRIM(LTRIM(ptcus_last_name)) + ', ' + RTRIM(LTRIM(ptcus_first_name))
				 END),'') AS NVARCHAR(MAX)) as ptcus_name, 
				 ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id
		INTO tmpptcusname
		FROM ptcusmst WHERE ptcus_cus_no = ptcus_bill_to

		INSERT INTO tmpptcusname (ptcus_cus_no, ptcus_bill_to, ptcus_name,ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id)
		SELECT	ptcus_cus_no, ptcus_bill_to,
				CAST(ISNULL((RTRIM (CASE WHEN ptcus_co_per_ind_cp = 'C' THEN ptcus_last_name + ptcus_first_name 
							 WHEN ptcus_co_per_ind_cp = 'P' THEN RTRIM(LTRIM(ptcus_last_name)) 
							 + ', ' + RTRIM(LTRIM(ptcus_first_name))
						 END)) +'_' + CAST(A4GLIdentity AS NVARCHAR),'') AS NVARCHAR(MAX)),
				ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id 
		FROM ptcusmst  WHERE ptcus_cus_no <> ptcus_bill_to

	DECLARE @cnt			 INT = 1
	DECLARE @SQLCMD NVARCHAR(3000)
		  , @SQLCMD1 NVARCHAR(3000)	

	IF OBJECT_ID('tempdb..#TAXEXEMPT') IS NOT NULL DROP TABLE #TAXEXEMPT

	CREATE TABLE #TAXEXEMPT (
		  intEntityCustomerId	INT	NULL
		, intItemId				INT	NULL
		, intCategoryId			INT	NULL
		, intTaxCodeId			INT	NULL
		, intTaxClassId			INT	NULL
		, strState				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
		, strException			NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
		, dtmStartDate			DATETIME		NULL
		, dtmEndDate			DATETIME		NULL
	)

	INSERT INTO #TAXEXEMPT (
		  intEntityCustomerId
		, intItemId
		, intCategoryId
		, intTaxCodeId
		, intTaxClassId
		, strState
		, strException
		, dtmStartDate
		, dtmEndDate
	)
	SELECT intEntityCustomerId	= CUS.intEntityId
	     , intItemId			= NULL
	     , intCategoryId		= CAT.intCategoryId
	     , intTaxCodeId			= TCD.intTaxCodeId
	     , intTaxClassId		= TCD.intTaxClassId
	     , strState				= OCUS.ptcus_state
	     , strException			= ''
	     , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	     , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
	INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'FET')--Xrf.strTaxClassType = 'FET'
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_fet_yn = 'N' AND PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no = ''-- AND PDV.ptpdv_cus_no = @CustomerId
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])
	--ORDER BY OCUS.ptcus_cus_no	
	
	UNION ALL
	
	SELECT intEntityCustomerId	= CUS.intEntityId
	     , intItemId			= NULL
		 , intCategoryId		= CAT.intCategoryId
		 , intTaxCodeId			= TCD.intTaxCodeId
		 , intTaxClassId		= TCD.intTaxClassId
		 , strState				= OCUS.ptcus_state
		 , strException			= ''
		 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
		 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
	INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'SET')--Xrf.strTaxClassType = 'SET' 
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_set_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = ''
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])
	--ORDER BY OCUS.ptcus_cus_no
	
	UNION ALL

	SELECT intEntityCustomerId	= CUS.intEntityId
		 , intItemId			= NULL
		 , intCategoryId		= CAT.intCategoryId
		 , intTaxCodeId			= TCD.intTaxCodeId--[intTaxCodeId]
		 , intTaxClassId		= TCD.intTaxClassId--[intTaxClassId]
		 , strState				= OCUS.ptcus_state--[strState]
		 , strException			= (CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)
		 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
		 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
	INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'SST')--Xrf.strTaxClassType = 'SST' 
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_sst_yn = 'N' AND ptpdv_class <> '' AND ptpdv_itm_no = ''
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])
	--ORDER BY OCUS.ptcus_cus_no		

	UNION ALL

	SELECT intEntityCustomerId	= CUS.intEntityId
		 , intItemId			= ITM.intItemId
		 , intCategoryId		= ITM.intCategoryId
		 , intTaxCodeId			= TCD.intTaxCodeId
		 , intTaxClassId		= TCD.intTaxClassId
		 , strState				= OCUS.ptcus_state
		 , strException			= ''
		 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
		 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'FET')--Xrf.strTaxClassType = 'FET' 
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_fet_yn = 'N'
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])
	--ORDER BY OCUS.ptcus_cus_no											 
	
	UNION ALL
	
	SELECT intEntityCustomerId	= CUS.intEntityId
		 , intItemId			= ITM.intItemId
		 , intCategoryId		= ITM.intCategoryId
		 , intTaxCodeId			= TCD.intTaxCodeId
		 , intTaxClassId		= TCD.intTaxClassId
		 , strState				= OCUS.ptcus_state
		 , strException			= ''
		 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
		 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'SET')--Xrf.strTaxClassType = 'SET' 
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_set_yn = 'N'
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])		
	--ORDER BY OCUS.ptcus_cus_no
			
	UNION ALL

	SELECT intEntityCustomerId	= CUS.intEntityId
		 , intItemId			= ITM.intItemId
		 , intCategoryId		= ITM.intCategoryId
		 , intTaxCodeId			= TCD.intTaxCodeId
		 , intTaxClassId		= TCD.intTaxClassId
		 , strState				= OCUS.ptcus_state
		 , strException			= (CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)
		 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
		 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
	FROM ptpdvmst PDV
	INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
	INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
	INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND (Xrf.strTaxClassType IS NULL OR Xrf.strTaxClassType = 'SST')--Xrf.strTaxClassType = 'SST' 
	INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
	WHERE PDV.ptpdv_sst_yn = 'N'
	  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
	  AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
	  AND [intTaxClassId] = TCD.[intTaxClassId])		
	--ORDER BY OCUS.ptcus_cus_no

	UNION ALL

	--IMPORT SALES TAX EXEMPTION FROM PTCUSMST 
	SELECT intEntityCustomerId	= CUS.intEntityId
		 , intItemId			= NULL
		 , intCategoryId		= NULL
		 , intTaxCodeId			= NULL
		 , intTaxClassId		= TCD.intTaxClassId
		 , strState				= OCUS.ptcus_state
		 , strException			= ''
		 , dtmStartDate			= '1900-01-01 00:00:00.000'
		 , dtmEndDate			= NULL
	FROM ptcusmst OCUS 
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	CROSS APPLY (
		SELECT DISTINCT TC.intTaxClassId
		FROM tblSMTaxClass TC
		INNER JOIN tblSMTaxClassXref XREF ON TC.intTaxClassId = XREF.intTaxClassId 
		WHERE TC.strOriginTaxType = 'SST'
		  AND XREF.strTaxClassType = 'SST' 
	) TCD 
	WHERE OCUS.ptcus_sales_tax_yn = 'N'
	AND CUS.intEntityId NOT IN (
		SELECT DISTINCT intEntityCustomerId 
		FROM tblARCustomerTaxingTaxException TE
		INNER JOIN tblSMTaxClass TC ON TE.intTaxClassId = TC.intTaxClassId
		INNER JOIN tblSMTaxCode TCODE ON TC.intTaxClassId = TCODE.intTaxClassId  
		INNER JOIN tblSMTaxClassXref XREF ON TC.intTaxClassId = XREF.intTaxClassId 
		WHERE TC.strOriginTaxType = 'SST'
			AND XREF.strTaxClassType = 'SST' 
			AND [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL 
			AND [intCategoryId] IS NULL 
		)
	--ORDER BY OCUS.ptcus_cus_no
		
	WHILE @cnt < 12
		BEGIN
			SET @SQLCMD = 'INSERT INTO #TAXEXEMPT (
								  intEntityCustomerId
								, intCategoryId
								, intTaxCodeId
								, intTaxClassId
								, strState
								, strException
								, dtmStartDate
								, dtmEndDate
							)
							SELECT intEntityCustomerId	= CUS.intEntityId
							     , intCategoryId		= CAT.intCategoryId
								 , intTaxCodeId			= TCD.intTaxCodeId
								 , intTaxClassId		= TCD.intTaxClassId
								 , strState				= OCUS.ptcus_state
								 , strException			= ''''
								 , dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END)
								 , dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END)
							FROM ptpdvmst PDV
							INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
							INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
							INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
							INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
							WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
							  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
							  AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
							  AND [intTaxClassId] = TCD.[intTaxClassId])						
							--ORDER BY OCUS.ptcus_cus_no'
							
			EXEC (@SQLCMD)		
			
			SET @SQLCMD1 ='INSERT INTO #TAXEXEMPT (
								  intEntityCustomerId
								, intItemId
								, intCategoryId
								, intTaxCodeId
								, intTaxClassId
								, strState
								, strException
								, dtmStartDate
								, dtmEndDate
							)
							SELECT intEntityCustomerId	= CUS.intEntityId
								, intItemId				= ITM.intItemId
								, intCategoryId			= ITM.intCategoryId
							    , intTaxCodeId			= TCD.intTaxCodeId
								, intTaxClassId			= TCD.intTaxClassId
								, strState				= OCUS.ptcus_state
								, strException			= ''''
								, dtmStartDate			= (CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END)
								, dtmEndDate			= (CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END)
						FROM ptpdvmst PDV
						INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
						INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
						INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
						INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
						WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
						  AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
						  AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
						  AND [intTaxClassId] = TCD.[intTaxClassId])						
						--ORDER BY OCUS.ptcus_cus_no'
							
			EXEC (@SQLCMD1)

			SET @cnt = @cnt + 1;
		END
	
	IF ISNULL(@Checking, 0) = 0
		BEGIN
			INSERT INTO tblARCustomerTaxingTaxException (
				  intEntityCustomerId
				, intItemId
				, intCategoryId
			    , intTaxCodeId
			    , intTaxClassId
			    , strState
			    , strException
			    , dtmStartDate
			    , dtmEndDate
			    , intConcurrencyId
			)
			SELECT intEntityCustomerId	= intEntityCustomerId
				, intItemId				= intItemId
				, intCategoryId			= intCategoryId
			    , intTaxCodeId			= intTaxCodeId
			    , intTaxClassId			= intTaxClassId
			    , strState				= strState
			    , strException			= strException
			    , dtmStartDate			= dtmStartDate
			    , dtmEndDate			= dtmEndDate
			    , intConcurrencyId		= 1
			FROM #TAXEXEMPT
		END
		
	SELECT @Total = COUNT(1)
	FROM #TAXEXEMPT

END
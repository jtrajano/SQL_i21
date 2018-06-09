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
		
	IF (@Checking = 1)		
	BEGIN
			SELECT @Total = COUNT (*) FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_fet_yn = 'N' AND PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no = ''
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			
			SELECT @Total = @Total +  COUNT (*)	FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_set_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			
			SELECT @Total = @Total +  COUNT (*)	FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_sst_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])

			SELECT @Total = @Total +  COUNT (*)	FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_fet_yn = 'N'  --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])											 

			SELECT @Total = @Total +  COUNT (*)	FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_set_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])		

			SELECT @Total = @Total +  COUNT (*)	FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_sst_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])		

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC1'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc1_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])												

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC2'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc2_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])	

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC3'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc3_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC4'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc4_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC5'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc5_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC6'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc6_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC7'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc7_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC8'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc8_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC9'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc9_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						

			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC10'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc10_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])						
			
			SELECT @Total = @Total + COUNT(*) FROM ptpdvmst PDV 
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'LC11'
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_lc11_yn = 'N' 
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			
			SELECT @Total = @Total + COUNT(*) FROM ptcusmst OCUS 
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMTaxClassXref Xrf ON  Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE OCUS.ptcus_sales_tax_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = NULL AND [intCategoryId] = NULL AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
						

		RETURN @Total
	 
	END
			
	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]          
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,CAT.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,''--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_fet_yn = 'N' AND PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no = ''-- AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			Order by OCUS.ptcus_cus_no											 
																				 
	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]          
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,CAT.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,''--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_set_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			Order by OCUS.ptcus_cus_no
			
	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]          
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,CAT.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,(CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_sst_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			Order by OCUS.ptcus_cus_no		

	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]
			   ,[intItemId]
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,ITM.intItemId --[intItemId].
			   ,ITM.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,''--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_fet_yn = 'N'  --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])
			Order by OCUS.ptcus_cus_no											 
																				 
	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]						 
			   ([intEntityCustomerId]											 
			   ,[intItemId]
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,ITM.intItemId --[intItemId].
			   ,ITM.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,''--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_set_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])		
			Order by OCUS.ptcus_cus_no
			
	INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]
			   ,[intItemId]
			   ,[intCategoryId]
			   ,[intTaxCodeId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   --,[intEntityCustomerLocationId]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,ITM.intItemId --[intItemId].
			   ,ITM.intCategoryId--[intCategoryId]
			   ,TCD.intTaxCodeId--[intTaxCodeId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,(CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)--[strException]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
			   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
			   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
			   ,1	
			FROM ptpdvmst PDV
			INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
					   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
			INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
			INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE PDV.ptpdv_sst_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])		
			Order by OCUS.ptcus_cus_no

--IMPORT SALES TAX EXEMPTION FROM PTCUSMST 
		INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
			   ([intEntityCustomerId]
			   ,[intTaxClassId]
			   ,[strState]
			   ,[strException]
			   ,[dtmStartDate]
			   ,[dtmEndDate]
			   ,[intConcurrencyId])
			SELECT 
				CUS.intEntityId--[intEntityCustomerId]
			   ,TCD.intTaxClassId--[intTaxClassId]
			   ,OCUS.ptcus_state--[strState]
			   ,''--[strException]
			   ,'1900-01-01 00:00:00.000' --[dtmStartDate]
			   ,NULL --[dtmEndDate]
			   ,1	
			FROM ptcusmst OCUS 
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMTaxClassXref Xrf ON  Xrf.strTaxClassType = 'SST' 
			INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
			WHERE OCUS.ptcus_sales_tax_yn = 'N' --AND PDV.ptpdv_cus_no = @CustomerId
			AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
			AND [intItemId] = NULL AND [intCategoryId] = NULL AND [intTaxCodeId] = TCD.[intTaxCodeId]
			AND [intTaxClassId] = TCD.[intTaxClassId])		
			Order by OCUS.ptcus_cus_no
			
	DECLARE @cnt INT = 1
	DECLARE @SQLCMD NVARCHAR(3000),@SQLCMD1 NVARCHAR(3000)		
	WHILE @cnt < 12
			BEGIN
			   SET @SQLCMD ='INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
							([intEntityCustomerId]          
							,[intCategoryId]
							,[intTaxCodeId]
							,[intTaxClassId]
							,[strState]
							,[strException]
							,[dtmStartDate]
							,[dtmEndDate]
							--,[intEntityCustomerLocationId]
							,[intConcurrencyId])
							SELECT 
								CUS.intEntityId--[intEntityCustomerId]
							   ,CAT.intCategoryId--[intCategoryId]
							   ,TCD.intTaxCodeId--[intTaxCodeId]
							   ,TCD.intTaxClassId--[intTaxClassId]
							   ,OCUS.ptcus_state--[strState]
							   ,''''--[strException]
							   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmStartDate]
							   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmEndDate]
							   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
							   ,1	
							FROM ptpdvmst PDV
							INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
									   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS	   
							INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
							INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
							INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
							WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
							AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
							AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
							AND [intTaxClassId] = TCD.[intTaxClassId])						
							Order by OCUS.ptcus_cus_no'
							
			   EXEC (@SQLCMD)		
			
			   SET @SQLCMD1 ='INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
								([intEntityCustomerId]
								,[intItemId]
								,[intCategoryId]
								,[intTaxCodeId]
								,[intTaxClassId]
								,[strState]
								,[strException]
								,[dtmStartDate]
								,[dtmEndDate]
								--,[intEntityCustomerLocationId]
								,[intConcurrencyId])
							SELECT 
								CUS.intEntityId--[intEntityCustomerId]
							   ,ITM.intItemId --[intItemId].
							   ,ITM.intCategoryId--[intCategoryId]
							   ,TCD.intTaxCodeId--[intTaxCodeId]
							   ,TCD.intTaxClassId--[intTaxClassId]
							   ,OCUS.ptcus_state--[strState]
							   ,''''--[strException]
							   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmStartDate]
							   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmEndDate]
							   --,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
							   ,1	
							FROM ptpdvmst PDV
							INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
									   AND UPPER(CLOC.strLocationName) COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(OCUS.ptcus_name) COLLATE SQL_Latin1_General_CP1_CS_AS
							INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
							INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
							INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
							INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
							WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
							AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityId
							AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
							AND [intTaxClassId] = TCD.[intTaxClassId])						
							Order by OCUS.ptcus_cus_no'
							
				   EXEC (@SQLCMD1)

				   SET @cnt = @cnt + 1;
				END
	END
			

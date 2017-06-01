CREATE PROCEDURE [dbo].[uspARImportPTTaxExemption]
		@CustomerId NVARCHAR(50) = NULL

AS
BEGIN

	SET NOCOUNT ON;
		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpptcusname')
			DROP TABLE tmpptcusname

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpvndname')
			DROP TABLE tmpvndname

		SELECT	ptcus_cus_no, ptcus_bill_to,
				(CASE WHEN ptcus_co_per_ind_cp = 'C' THEN 
							ptcus_last_name + ptcus_first_name 
					 WHEN ptcus_co_per_ind_cp = 'P' THEN 
							RTRIM(LTRIM(ptcus_last_name)) + ', ' + RTRIM(LTRIM(ptcus_first_name))
				 END) as ptcus_name, 
				 ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id
		INTO tmpptcusname
		FROM ptcusmst WHERE ptcus_cus_no = ptcus_bill_to

		INSERT INTO tmpptcusname (ptcus_cus_no, ptcus_bill_to, ptcus_name,ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id)
		SELECT	ptcus_cus_no, ptcus_bill_to,
				(RTRIM (CASE WHEN ptcus_co_per_ind_cp = 'C' THEN ptcus_last_name + ptcus_first_name 
							 WHEN ptcus_co_per_ind_cp = 'P' THEN RTRIM(LTRIM(ptcus_last_name)) 
							 + ', ' + RTRIM(LTRIM(ptcus_first_name))
						 END)) +'_' + CAST(A4GLIdentity AS NVARCHAR),
				ptcus_state,ptcus_sales_tax_yn, ptcus_sales_tax_id 
		FROM ptcusmst  WHERE ptcus_cus_no <> ptcus_bill_to
		
INSERT INTO [dbo].[tblARCustomerTaxingTaxException]
           ([intEntityCustomerId]          
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[dtmStartDate]
           ,[dtmEndDate]
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,''--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_fet_yn = 'N' AND PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no = '' AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,''--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_set_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,(CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_sst_yn = 'N' AND ptpdv_class <> '' and ptpdv_itm_no = '' AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,''--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_fet_yn = 'N'  AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,''--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_set_yn = 'N' AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
           ,[intEntityCustomerLocationId]
           ,[intConcurrencyId])
		SELECT 
            CUS.intEntityCustomerId--[intEntityCustomerId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OCUS.ptcus_state--[strState]
           ,(CASE WHEN OCUS.ptcus_sales_tax_yn = 'Y' THEN OCUS.ptcus_sales_tax_id ELSE '' END)--[strException]
           ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmStartDate]
		   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END) --[dtmEndDate]
           ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
           ,1	
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptpdv_sst_yn = 'N' AND PDV.ptpdv_cus_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
		AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
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
						,[intEntityCustomerLocationId]
						,[intConcurrencyId])
						SELECT 
							CUS.intEntityCustomerId--[intEntityCustomerId]
						   ,CAT.intCategoryId--[intCategoryId]
						   ,TCD.intTaxCodeId--[intTaxCodeId]
						   ,TCD.intTaxClassId--[intTaxClassId]
						   ,OCUS.ptcus_state--[strState]
						   ,''''--[strException]
						   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmStartDate]
						   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmEndDate]
						   ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
						   ,1	
						FROM ptpdvmst PDV
						INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
								   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
						INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
						INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
						INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
						WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' AND PDV.ptpdv_cus_no = @CustomerId
						AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
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
							,[intEntityCustomerLocationId]
							,[intConcurrencyId])
						SELECT 
							CUS.intEntityCustomerId--[intEntityCustomerId]
						   ,ITM.intItemId --[intItemId].
						   ,ITM.intCategoryId--[intCategoryId]
						   ,TCD.intTaxCodeId--[intTaxCodeId]
						   ,TCD.intTaxClassId--[intTaxClassId]
						   ,OCUS.ptcus_state--[strState]
						   ,''''--[strException]
						   ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmStartDate]
						   ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE '' '' END) --[dtmEndDate]
						   ,CLOC.intEntityLocationId--[intEntityCustomerLocationId]
						   ,1	
						FROM ptpdvmst PDV
						INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityCustomerId 
								   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
						INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
						INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
						INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
						WHERE PDV.ptpdv_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' AND PDV.ptpdv_cus_no = @CustomerId
						AND NOT EXISTS ( SELECT * FROM tblARCustomerTaxingTaxException WHERE [intEntityCustomerId] = CUS.intEntityCustomerId
						AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
						AND [intTaxClassId] = TCD.[intTaxClassId])						
						Order by OCUS.ptcus_cus_no'
						
			   EXEC (@SQLCMD1)

			   SET @cnt = @cnt + 1;
			END
END
		

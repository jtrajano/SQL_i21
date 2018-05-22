GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportCustomerSpecialPrice')
	DROP PROCEDURE uspARImportCustomerSpecialPrice
GO


CREATE PROCEDURE [dbo].[uspARImportCustomerSpecialPrice]
			@Checking BIT = 0,
			@Total INT = 0 OUTPUT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ysnAG BIT = 0
	DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	
	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpagcusname')
	DROP TABLE tmpagcusname

	SELECT	agcus_key, agcus_bill_to,
			(CASE WHEN agcus_co_per_ind_cp = 'C' THEN 
						agcus_last_name + agcus_first_name 
				 WHEN agcus_co_per_ind_cp = 'P' THEN 
						RTRIM(LTRIM(agcus_last_name)) + ', ' + RTRIM(LTRIM(agcus_first_name))
			 END) as agcus_name 
	INTO tmpagcusname
	FROM agcusmst WHERE agcus_key = agcus_bill_to

	INSERT INTO tmpagcusname (agcus_key, agcus_bill_to, agcus_name)
	SELECT	agcus_key, agcus_bill_to,
			(RTRIM (CASE WHEN agcus_co_per_ind_cp = 'C' THEN agcus_last_name + agcus_first_name 
						 WHEN agcus_co_per_ind_cp = 'P' THEN RTRIM(LTRIM(agcus_last_name)) 
						 + ', ' + RTRIM(LTRIM(agcus_first_name))
					 END)) +'_' + CAST(A4GLIdentity AS NVARCHAR) 
	FROM agcusmst  WHERE agcus_key <> agcus_bill_to
	
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpptcusname')
		DROP TABLE tmpptcusname

	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpvndname')
		DROP TABLE tmpvndname

	SELECT	ptcus_cus_no, ptcus_bill_to,
			(CASE WHEN ptcus_co_per_ind_cp = 'C' THEN 
						ptcus_last_name + ptcus_first_name 
				 WHEN ptcus_co_per_ind_cp = 'P' THEN 
						RTRIM(LTRIM(ptcus_last_name)) + ', ' + RTRIM(LTRIM(ptcus_first_name))
			 END) as ptcus_name 
	INTO tmpptcusname
	FROM ptcusmst WHERE ptcus_cus_no = ptcus_bill_to

	INSERT INTO tmpptcusname (ptcus_cus_no, ptcus_bill_to, ptcus_name)
	SELECT	ptcus_cus_no, ptcus_bill_to,
			(RTRIM (CASE WHEN ptcus_co_per_ind_cp = 'C' THEN ptcus_last_name + ptcus_first_name 
						 WHEN ptcus_co_per_ind_cp = 'P' THEN RTRIM(LTRIM(ptcus_last_name)) 
						 + ', ' + RTRIM(LTRIM(ptcus_first_name))
					 END)) +'_' + CAST(A4GLIdentity AS NVARCHAR) 
	FROM ptcusmst  WHERE ptcus_cus_no <> ptcus_bill_to

	SELECT	ssvnd_vnd_no, ssvnd_pay_to,
			(RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
			ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
						+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
					END,''))) as ssvnd_name 
	INTO tmpvndname
	FROM ssvndmst  WHERE ssvnd_vnd_no = ssvnd_pay_to OR ssvnd_pay_to is null

	INSERT INTO tmpvndname (ssvnd_vnd_no,ssvnd_pay_to,ssvnd_name)
	SELECT	ssvnd_vnd_no, ssvnd_pay_to,
			(RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
			ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
						+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
					END,'')) + '_' + CAST(A4GLIdentity AS NVARCHAR))  
	FROM ssvndmst  WHERE ssvnd_vnd_no <> ssvnd_pay_to

	
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'spprcmst')
	AND (@Checking = 0) 
	BEGIN

		INSERT INTO [dbo].[tblARCustomerSpecialPrice]
				   ([intEntityCustomerId]
				   ,[intItemId]
				   ,[strClass]
				   ,[strPriceBasis]
				   ,[strCostToUse]
				   ,[dblDeviation]
				   ,[strLineNote]
				   ,[dtmBeginDate]
				   ,[dtmEndDate]
				   ,[intCustomerLocationId]
				   --,[strInvoiceType]
				   ,[intCategoryId]
				   ,[intConcurrencyId])

		SELECT DISTINCT CUS.intEntityId
			  ,(CASE WHEN SP.spprc_itm_no > ' ' THEN 
					 (SELECT intItemId FROM tblICItem  
							 WHERE strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = SP.spprc_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE SP.spprc_itm_no END) 
			  ,SP.spprc_class	  
			  ,SP.spprc_basis_ind
			  ,CASE WHEN SP.spprc_cost_to_use_las = 'L' THEN 'Last'
					WHEN SP.spprc_cost_to_use_las = 'A' THEN 'Average'
					ELSE 'Standard'
			   END 
			  ,(CASE WHEN SP.spprc_basis_ind = '1' THEN SP.spprc_factor * -1 ELSE SP.spprc_factor END) 
			--  ,SP.spprc_factor
			  ,SP.spprc_comment
			  ,(CASE WHEN ISDATE(SP.spprc_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(SP.spprc_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
			  ,(CASE WHEN ISDATE(SP.spprc_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(SP.spprc_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
			  ,CASE WHEN SP.spprc_cus_no <> OCUS.agcus_bill_to THEN CLOC.intEntityLocationId ELSE NULL END -- intEntityLocationId
			  --,'Standard' 
			  ,(CASE WHEN SP.spprc_class > ' ' THEN 
							(SELECT CAT.intCategoryId FROM tblICCategory CAT
							 WHERE CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = SP.spprc_class COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE ''
				END) 
			  ,1 
		FROM spprcmst SP
		INNER JOIN tmpagcusname OCUS ON OCUS.agcus_key COLLATE SQL_Latin1_General_CP1_CS_AS = SP.spprc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.agcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--    AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.agcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
				   
		--WHERE SP.spprc_cus_no = @CustomerId
	END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptpdvmst')
	AND (@Checking = 0) 
	
	BEGIN

		INSERT INTO [dbo].[tblARCustomerSpecialPrice]
				   ([intEntityCustomerId]
				   ,[intEntityVendorId]
				   ,[intItemId]
				   ,[strClass]
				   ,[strPriceBasis]
				   ,[strCustomerGroup]
				   ,[strCostToUse]
				   ,[dblDeviation]
				   ,[strLineNote]
				   ,[dtmBeginDate]
				   ,[dtmEndDate]
				   ,[intRackVendorId]
				   ,[intRackItemId]
				   ,[intEntityLocationId]
				   ,[intRackLocationId]
				   ,[intCustomerLocationId]
				   --,[strInvoiceType]
				   ,[intCategoryId]
				   ,[intConcurrencyId])
		SELECT  DISTINCT CUS.intEntityId
			  ,(CASE WHEN PDV.ptpdv_vnd_no > ' ' THEN 
					 (SELECT intEntityId FROM tblAPVendor  
							 WHERE strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = PDV.ptpdv_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE PDV.ptpdv_vnd_no END) 
			  ,(CASE WHEN PDV.ptpdv_itm_no > ' ' THEN 
					 (SELECT intItemId FROM tblICItem  
							 WHERE strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = PDV.ptpdv_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE PDV.ptpdv_itm_no END) 
			  ,PDV.ptpdv_class	  
			  ,PDV.ptpdv_basis_ind
			  ,PDV.ptpdv_grp_cus_no
			  ,CASE WHEN PDV.ptpdv_cost_to_use_las = 'L' THEN 'Last'
					WHEN PDV.ptpdv_cost_to_use_las = 'A' THEN 'Average'
					ELSE 'Standard'
			   END 
			  ,(CASE WHEN PDV.ptpdv_basis_ind = '1' THEN PDV.ptpdv_factor * -1 ELSE PDV.ptpdv_factor END) 
			  --,PDV.ptpdv_factor
			  ,PDV.ptpdv_comment
			  ,(CASE WHEN ISDATE(PDV.ptpdv_begin_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_begin_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
			  ,(CASE WHEN ISDATE(PDV.ptpdv_end_rev_dt) = 1 THEN CONVERT(DATE,CAST(PDV.ptpdv_end_rev_dt AS CHAR(12)), 112) ELSE ' ' END)
			  ,(CASE WHEN PDV.ptpdv_rack_vnd_no > ' ' THEN 
					 (SELECT intEntityId FROM tblAPVendor  
							 WHERE strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = PDV.ptpdv_rack_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE PDV.ptpdv_rack_vnd_no 
				END) 
			  ,(CASE WHEN PDV.ptpdv_rack_itm_no > ' ' THEN 
					 (SELECT intItemId FROM tblICItem  
							 WHERE strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = PDV.ptpdv_rack_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE PDV.ptpdv_rack_itm_no 
				END) 
			  ,(CASE WHEN PDV.ptpdv_vnd_no > ' ' THEN 
							(SELECT VLOC.intEntityLocationId FROM tmpvndname OVND
								INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
								INNER JOIN tblEMEntityLocation VLOC ON VLOC.intEntityId = VND.intEntityId 
								 AND VLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS			  
							 WHERE OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE NULL 
				END) 
			  ,(CASE WHEN PDV.ptpdv_rack_vnd_no > ' ' THEN 
							(SELECT VLOC.intEntityLocationId FROM tmpvndname OVND
								INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
								INNER JOIN tblEMEntityLocation VLOC ON VLOC.intEntityId = VND.intEntityId 
								 AND VLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS			  
							 WHERE OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_rack_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE NULL 
				END)
			  ,CASE WHEN PDV.ptpdv_cus_no <> OCUS.ptcus_bill_to THEN CLOC.intEntityLocationId ELSE NULL END -- intEntityLocationId
			  --,'Standard' 
			  ,(CASE WHEN PDV.ptpdv_class > ' ' THEN 
							(SELECT CAT.intCategoryId FROM tblICCategory CAT
							 WHERE CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS)
					 ELSE ''
				END) 
			  ,1 
		FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--    AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		--WHERE PDV.ptpdv_cus_no = @CustomerId
	END
	
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'spprcmst')
	AND (@Checking = 1) 
	BEGIN
		SELECT @Total = COUNT(*) FROM spprcmst SP
		INNER JOIN tmpagcusname OCUS ON OCUS.agcus_key COLLATE SQL_Latin1_General_CP1_CS_AS = SP.spprc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.agcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--    AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.agcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = SP.spprc_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategory CAT ON strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = SP.spprc_class COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE NOT EXISTS (SELECT * FROM tblARCustomerSpecialPrice WHERE intEntityCustomerId = CUS.intEntityId AND intItemId = ITM.intItemId AND intCategoryId = CAT.intCategoryId)		 						   
		
	END
	

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptpdvmst')
	AND (@Checking = 1) 
	BEGIN	
		
		SELECT  @Total = COUNT(*) FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--  AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE  PDV.ptpdv_class = '' AND PDV.ptpdv_itm_no <> ''AND NOT EXISTS (SELECT * FROM tblARCustomerSpecialPrice WHERE intEntityCustomerId = CUS.intEntityId AND intItemId = ITM.intItemId )


		SELECT  @Total = @Total + COUNT(*) FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--  AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategory CAT ON strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE  PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no = '' AND NOT EXISTS (SELECT * FROM tblARCustomerSpecialPrice WHERE intEntityCustomerId = CUS.intEntityId AND intCategoryId = CAT.intCategoryId )

		SELECT  @Total = @Total + COUNT(*) FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--  AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE  PDV.ptpdv_class = '' AND PDV.ptpdv_itm_no = '' AND NOT EXISTS (SELECT * FROM tblARCustomerSpecialPrice WHERE intEntityCustomerId = CUS.intEntityId)

		SELECT  @Total = @Total + COUNT(*) FROM ptpdvmst PDV
		INNER JOIN tmpptcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
				--AND ISNULL(CLOC.strOriginLinkCustomer , '') = ''
				--  AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategory CAT ON strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptpdv_class COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE  PDV.ptpdv_class <> '' AND PDV.ptpdv_itm_no <> '' AND NOT EXISTS (SELECT * FROM tblARCustomerSpecialPrice WHERE intEntityCustomerId = CUS.intEntityId AND intCategoryId = CAT.intCategoryId AND intItemId = ITM.intItemId)		
	END

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpagcusname')
			DROP TABLE tmpagcusname

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpptcusname')
			DROP TABLE tmpptcusname

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpvndname')
			DROP TABLE tmpvndname

END


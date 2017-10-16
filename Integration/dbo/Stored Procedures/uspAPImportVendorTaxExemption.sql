IF EXISTS (select top 1 1 from sys.procedures where name = 'uspAPImportVendorTaxExemption')
	DROP PROCEDURE uspAPImportVendorTaxExemption
GO

CREATE PROCEDURE [dbo].[uspAPImportVendorTaxExemption]
			@Checking BIT = 0,
			@Total INT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

		IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpvndname')
			DROP TABLE tmpvndname

	SELECT	ssvnd_vnd_no, ssvnd_pay_to,
			(RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
			ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
						+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
					END,''))) as ssvnd_name,ssvnd_st
	INTO tmpvndname
	FROM ssvndmst  WHERE ssvnd_vnd_no = ssvnd_pay_to OR ssvnd_pay_to is null

	INSERT INTO tmpvndname (ssvnd_vnd_no,ssvnd_pay_to,ssvnd_name,ssvnd_st)
	SELECT	ssvnd_vnd_no, ssvnd_pay_to,
			(RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
			ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
						+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
					END,'')) + '_' + CAST(A4GLIdentity AS NVARCHAR)), ssvnd_st  
	FROM ssvndmst  WHERE ssvnd_vnd_no <> ssvnd_pay_to
	
IF (@Checking = 1)	
BEGIN
		SELECT @Total = COUNT (*) FROM ptvtxmst PDV	
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE PDV.ptvtx_class <> '' AND PDV.ptvtx_itm_no = ''
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId])

		SELECT @Total = @Total + COUNT (*) FROM ptvtxmst PDV	
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS					   
		WHERE PDV.ptvtx_class = '' AND PDV.ptvtx_itm_no <> ''
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] = ITM.intItemId AND [intCategoryId] IS NULL)

		SELECT @Total = @Total + COUNT (*) FROM ptvtxmst PDV	
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS		
		WHERE NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] = ITM.intItemId AND [intCategoryId] = CAT.[intCategoryId])		
		
	   		
		RETURN (@Total)
		
END 		
		
INSERT INTO [dbo].[tblAPVendorTaxException]
           ([intEntityVendorId]         
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--([intEntityVendorId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_fet_yn = 'N' AND PDV.ptvtx_class <> '' AND PDV.ptvtx_itm_no = ''
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])
		Order by OVND.ssvnd_vnd_no											 
																			 
INSERT INTO [dbo].[tblAPVendorTaxException]
           ([intEntityVendorId]         
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--[intEntityVendorId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_set_yn = 'N' AND ptvtx_class <> '' and ptvtx_itm_no = '' 
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])
		Order by OVND.ssvnd_vnd_no
		
INSERT INTO [dbo].[tblAPVendorTaxException]
           ([intEntityVendorId]         
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--[intEntityVendorId]
           ,CAT.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
		INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_sst_ynp = 'N' AND ptvtx_class <> '' and ptvtx_itm_no = '' --AND PDV.ptvtx_vnd_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])
		Order by OVND.ssvnd_vnd_no		

INSERT INTO [dbo].[tblAPVendorTaxException]
           ([intEntityVendorId]
           ,[intItemId]
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--[intEntityVendorId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'FET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_fet_yn = 'N'  --AND PDV.ptvtx_vnd_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])
		Order by OVND.ssvnd_vnd_no											 
																			 
INSERT INTO [dbo].[tblAPVendorTaxException]						 
           ([intEntityVendorId]											 
           ,[intItemId]
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--[intEntityVendorId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SET' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_set_yn = 'N' --AND PDV.ptvtx_vnd_no = @CustomerId
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])		
		Order by OVND.ssvnd_vnd_no
		
INSERT INTO [dbo].[tblAPVendorTaxException]
           ([intEntityVendorId]
           ,[intItemId]
           ,[intCategoryId]
           ,[intTaxCodeId]
           ,[intTaxClassId]
           ,[strState]
           ,[strException]
           ,[intEntityVendorLocationId]
           ,[intConcurrencyId])
		SELECT 
            VND.intEntityId--[intEntityVendorId]
           ,ITM.intItemId --[intItemId].
           ,ITM.intCategoryId--[intCategoryId]
           ,TCD.intTaxCodeId--[intTaxCodeId]
           ,TCD.intTaxClassId--[intTaxClassId]
           ,OVND.ssvnd_st--[strState]
           ,''--[strException]
           ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
           ,1	
		FROM ptvtxmst PDV
		INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
				   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
		INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = 'SST' 
		INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
		WHERE PDV.ptvtx_sst_ynp = 'N' 
		AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
		AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
		AND [intTaxClassId] = TCD.[intTaxClassId])		
		Order by OVND.ssvnd_vnd_no
		
DECLARE @cnt INT = 1
DECLARE @SQLCMD NVARCHAR(3000),@SQLCMD1 NVARCHAR(3000)		
WHILE @cnt < 12
		BEGIN
		   SET @SQLCMD ='INSERT INTO [dbo].[tblAPVendorTaxException]
						([intEntityVendorId]         
						,[intCategoryId]
						,[intTaxCodeId]
						,[intTaxClassId]
						,[strState]
						,[strException]
						,[intEntityVendorLocationId]
						,[intConcurrencyId])
						SELECT 
							VND.intEntityId--[intEntityVendorId]
						   ,CAT.intCategoryId--[intCategoryId]
						   ,TCD.intTaxCodeId--[intTaxCodeId]
						   ,TCD.intTaxClassId--[intTaxClassId]
						   ,OVND.ssvnd_st--[strState]
						   ,''''--[strException]
						   ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
						   ,1	
						FROM ptvtxmst PDV
						INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
								   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS	   
						INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_class COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = CAT.intCategoryId
						INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
						INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
						WHERE PDV.ptvtx_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
						AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
						AND [intItemId] IS NULL AND [intCategoryId] = CAT.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
						AND [intTaxClassId] = TCD.[intTaxClassId])						
						Order by OVND.ssvnd_vnd_no'
						
		   EXEC (@SQLCMD)		
		
		   SET @SQLCMD1 ='INSERT INTO [dbo].[tblAPVendorTaxException]
							([intEntityVendorId]
							,[intItemId]
							,[intCategoryId]
							,[intTaxCodeId]
							,[intTaxClassId]
							,[strState]
							,[strException]
							,[intEntityVendorLocationId]
							,[intConcurrencyId])
						SELECT 
							VND.intEntityId--[intEntityVendorId]
						   ,ITM.intItemId --[intItemId].
						   ,ITM.intCategoryId--[intCategoryId]
						   ,TCD.intTaxCodeId--[intTaxCodeId]
						   ,TCD.intTaxClassId--[intTaxClassId]
						   ,OVND.ssvnd_st--[strState]
						   ,''''--[strException]
						   ,CLOC.intEntityLocationId--[intEntityVendorLocationId]
						   ,1	
						FROM ptvtxmst PDV
						INNER JOIN tmpvndname OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = VND.intEntityId 
								   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OVND.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
						INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = PDV.ptvtx_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS		   
						INNER JOIN tblICCategoryTax CTAX ON CTAX.intCategoryId = ITM.intCategoryId
						INNER JOIN tblSMTaxClassXref Xrf ON Xrf.intTaxClassId = CTAX.intTaxClassId AND Xrf.strTaxClassType = ''LC'+CAST(@cnt AS NVARCHAR)+'''
						INNER JOIN tblSMTaxCode TCD ON TCD.intTaxClassId =  Xrf.intTaxClassId
						WHERE PDV.ptvtx_lc'+CAST(@cnt AS NVARCHAR)+'_yn = ''N'' 
						AND NOT EXISTS ( SELECT * FROM tblAPVendorTaxException WHERE [intEntityVendorId]= VND.intEntityId
						AND [intItemId] = ITM.[intItemId] AND [intCategoryId] = ITM.[intCategoryId] AND [intTaxCodeId] = TCD.[intTaxCodeId]
						AND [intTaxClassId] = TCD.[intTaxClassId])						
						Order by OVND.ssvnd_vnd_no'
						
			   EXEC (@SQLCMD1)

			   SET @cnt = @cnt + 1;
			END
END
		

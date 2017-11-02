IF EXISTS (select top 1 1 from sys.procedures where name = 'uspEMImportPTTerminalToCustomer')
	DROP PROCEDURE uspEMImportPTTerminalToCustomer
GO
	
CREATE PROCEDURE [dbo].[uspEMImportPTTerminalToCustomer]
			@Checking BIT = 0,
			@Total INT = 0 OUTPUT

AS
BEGIN

	SET NOCOUNT ON;
	
IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpcusname')
	DROP TABLE tmpcusname
IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tmpcusname1')
	DROP TABLE tmpcusname1

SELECT	ptcus_cus_no, ptcus_bill_to,
		(CASE WHEN ptcus_co_per_ind_cp = 'C' THEN 
					ptcus_last_name + ptcus_first_name 
			 WHEN ptcus_co_per_ind_cp = 'P' THEN 
					RTRIM(LTRIM(ptcus_last_name)) + ', ' + RTRIM(LTRIM(ptcus_first_name))
		 END) as ptcus_name 
INTO tmpcusname
FROM ptcusmst WHERE ptcus_cus_no = ptcus_bill_to

SELECT	ptcus_cus_no, ptcus_bill_to,
		(RTRIM (CASE WHEN ptcus_co_per_ind_cp = 'C' THEN ptcus_last_name + ptcus_first_name 
	                 WHEN ptcus_co_per_ind_cp = 'P' THEN RTRIM(LTRIM(ptcus_last_name)) 
					 + ', ' + RTRIM(LTRIM(ptcus_first_name))
			     END)) +'_' + CAST(A4GLIdentity AS NVARCHAR) as ptcus_name 
INTO tmpcusname1
FROM ptcusmst  WHERE ptcus_cus_no <> ptcus_bill_to

IF (@Checking =1)
BEGIN 

	SELECT @Total = COUNT (*)
	 FROM trdvcmst DVC 
	INNER JOIN tmpcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_class COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
			   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE NOT EXISTS (SELECT * FROM tblARCustomerFreightXRef WHERE intEntityCustomerId = CUS.intEntityId AND intCategoryId = CAT.intCategoryId
					 AND intEntityLocationId = CLOC.intEntityLocationId)

	SELECT @Total = @Total + COUNT(*)
	 FROM trdvcmst DVC 
	INNER JOIN tmpcusname1 OCUS1 ON OCUS1.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS1.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_class COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
			   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS1.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE NOT EXISTS (SELECT * FROM tblARCustomerFreightXRef WHERE intEntityCustomerId = CUS.intEntityId AND intCategoryId = CAT.intCategoryId
					AND intEntityLocationId = CLOC.intEntityLocationId)
	RETURN @Total

END


INSERT INTO [dbo].[tblARCustomerFreightXRef]
           ([intEntityCustomerId]
           ,[intCategoryId]
           ,[ysnFreightOnly]
           ,[strFreightType]
           ,[dblFreightAmount]
           ,[dblFreightRate]
           ,[dblMinimumUnits]
           ,[ysnFreightInPrice]
           ,[dblFreightMiles]
           ,[intEntityLocationId]
           ,[strZipCode]
           ,[intConcurrencyId])
SELECT CUS.intEntityId
	  ,CAT.intCategoryId
	  ,CASE WHEN(DVC.trdvc_frt_only_yn = 'Y') THEN 1 ELSE 0 END
	  ,CASE WHEN(DVC.trdvc_frt_type = 'M') THEN 'Miles'
	        WHEN(DVC.trdvc_frt_type = 'R') THEN 'Rate'
			ELSE 'Amount' END 
	  ,DVC.trdvc_frt_amt
	  ,DVC.trdvc_frt_rt
	  ,DVC.trdvc_min_un
	  ,CASE WHEN(DVC.trdvc_frt_in_prc_yn = 'Y') THEN 1 ELSE 0 END
	  ,DVC.trdvc_frt_miles
	  ,CLOC.intEntityLocationId			 
	  ,OVND.ssvnd_zip
	  ,1
 FROM trdvcmst DVC 
INNER JOIN tmpcusname OCUS ON OCUS.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_class COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
		   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE NOT EXISTS (SELECT * FROM tblARCustomerFreightXRef WHERE intEntityCustomerId = CUS.intEntityId AND intCategoryId = CAT.intCategoryId)

INSERT INTO [dbo].[tblARCustomerFreightXRef]
           ([intEntityCustomerId]
           ,[intCategoryId]
           ,[ysnFreightOnly]
           ,[strFreightType]
           ,[dblFreightAmount]
           ,[dblFreightRate]
           ,[dblMinimumUnits]
           ,[ysnFreightInPrice]
           ,[dblFreightMiles]
           ,[intEntityLocationId]
           ,[strZipCode]
           ,[intConcurrencyId])
SELECT CUS.intEntityId
	  ,CAT.intCategoryId
	  ,CASE WHEN(DVC.trdvc_frt_only_yn = 'Y') THEN 1 ELSE 0 END
	  ,CASE WHEN(DVC.trdvc_frt_type = 'M') THEN 'Miles'
	        WHEN(DVC.trdvc_frt_type = 'R') THEN 'Rate'
			ELSE 'Amount' END 
	  ,DVC.trdvc_frt_amt
	  ,DVC.trdvc_frt_rt
	  ,DVC.trdvc_min_un
	  ,CASE WHEN(DVC.trdvc_frt_in_prc_yn = 'Y') THEN 1 ELSE 0 END
	  ,DVC.trdvc_frt_miles
	  ,CLOC.intEntityLocationId			 
	  ,OVND.ssvnd_zip
	  ,1
 FROM trdvcmst DVC 
INNER JOIN tmpcusname1 OCUS1 ON OCUS1.ptcus_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS1.ptcus_bill_to COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblICCategory CAT ON CAT.strCategoryCode COLLATE SQL_Latin1_General_CP1_CS_AS = DVC.trdvc_class COLLATE SQL_Latin1_General_CP1_CS_AS
INNER JOIN tblEMEntityLocation CLOC ON CLOC.intEntityId = CUS.intEntityId 
		   AND CLOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = OCUS1.ptcus_name COLLATE SQL_Latin1_General_CP1_CS_AS
--WHERE DVC.trdvc_cus_no = @CustomerId

END
GO

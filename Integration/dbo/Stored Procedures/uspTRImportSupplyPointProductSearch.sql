
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPointProductSearch')
	DROP PROCEDURE uspTRImportSupplyPointProductSearch
GO

CREATE PROCEDURE uspTRImportSupplyPointProductSearch
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblTRSupplyPointProductSearch] - TR Supply Point Product Search 
	--==========================================================
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = '#tmpvnd')
		DROP table #tmpvnd		

		SELECT 		ENT.intEntityId,
					ssvnd_vnd_no,
					RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'')) + '_' + CAST(A4GLIdentity AS NVARCHAR) AS ssvnd_name
	 INTO #tmpvnd			
	 FROM ssvndmst  
	 INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
	 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
	 --INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = ENT.intEntityId
	 WHERE ETYP.strType = 'Vendor'

	INSERT INTO #tmpvnd
			(ENT.intEntityId,
			ssvnd_vnd_no,
			ssvnd_name)
	 SELECT ENT.intEntityId,
			ssvnd_vnd_no,
			ssvnd_name                    			
	 FROM ssvndmst  
	 INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
	 INNER JOIN tblAPVendor APVND ON APVND.intEntityVendorId = ENT.intEntityId
	 WHERE APVND.ysnTransportTerminal = 1 AND ETYP.strType = 'Vendor'	 
		
	IF(@Checking = 0)
	BEGIN
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchHeader]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[intConcurrencyId])	   
		SELECT	ITM.intItemId
			   ,SUP.intSupplyPointId,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE SUP.intSupplyPointId NOT IN (SELECT intSupplyPointId FROM [tblTRSupplyPointProductSearchHeader] WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId) 
		
		--PRODUCT SEARCH 1--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search1,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search1 IS NOT NULL AND DVP.trdvp_search1 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search1 COLLATE SQL_Latin1_General_CP1_CS_AS) 

		--PRODUCT SEARCH 2--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search2,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search2 IS NOT NULL AND DVP.trdvp_search2 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search2 COLLATE SQL_Latin1_General_CP1_CS_AS)

		--PRODUCT SEARCH 3--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search3,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search3 IS NOT NULL AND DVP.trdvp_search3 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search3 COLLATE SQL_Latin1_General_CP1_CS_AS) 

		--PRODUCT SEARCH 4--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search4,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search4 IS NOT NULL AND DVP.trdvp_search4 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search4 COLLATE SQL_Latin1_General_CP1_CS_AS) 

		--PRODUCT SEARCH 5--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search5,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search5 IS NOT NULL AND DVP.trdvp_search5 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search5 COLLATE SQL_Latin1_General_CP1_CS_AS) 
		 
		--PRODUCT SEARCH 6--
		INSERT INTO [dbo].[tblTRSupplyPointProductSearchDetail]
				   ([intSupplyPointProductSearchHeaderId]
				   ,[strSearchValue]
				   ,[intConcurrencyId])
		SELECT	PHDR.intSupplyPointProductSearchHeaderId
			   ,DVP.trdvp_search6,1
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPointProductSearchHeader PHDR ON PHDR.intSupplyPointId = SUP.intSupplyPointId
			 AND PHDR.intItemId = ITM.intItemId
		WHERE DVP.trdvp_search6 IS NOT NULL AND DVP.trdvp_search6 <> ''
		AND NOT EXISTS (SELECT [intSupplyPointProductSearchDetailId] FROM [tblTRSupplyPointProductSearchDetail] DET WHERE PHDR.intSupplyPointProductSearchHeaderId =DET.intSupplyPointProductSearchHeaderId 
		AND [strSearchValue] COLLATE SQL_Latin1_General_CP1_CS_AS = DVP.trdvp_search6 COLLATE SQL_Latin1_General_CP1_CS_AS) 
	END

	IF(@Checking = 1)
	BEGIN
		SELECT @Total = COUNT(ITM.intItemId)
		FROM trdvpmst DVP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = DVP.trdvp_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = DVP.trdvp_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId	
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = trdvp_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE SUP.intSupplyPointId NOT IN (SELECT intSupplyPointId FROM [tblTRSupplyPointProductSearchHeader] WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId) 
	END
	
END
GO


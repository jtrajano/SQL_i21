IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPointRackPriceEquation')
	DROP PROCEDURE uspTRImportSupplyPointRackPriceEquation
GO

CREATE PROCEDURE uspTRImportSupplyPointRackPriceEquation
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--====================================================================================
	--     Insert into [tblTRSupplyPointRackPriceEquation] - TR SupplyPoint Rack Price Equation
	--====================================================================================
	
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
		--IMPORT RACK PRICE OPERAND1
		INSERT INTO [dbo].[tblTRSupplyPointRackPriceEquation]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[strOperand]
				   ,[dblFactor]
				   ,[intConcurrencyId])		   
		SELECT ITM.intItemId
			  ,SUP.intSupplyPointId
			  ,VPR.trvpr_operand1
			  ,VPR.trvpr_factor1
			  ,1
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand1 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId) 

		--IMPORT RACK PRICE OPERAND2
		INSERT INTO [dbo].[tblTRSupplyPointRackPriceEquation]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[strOperand]
				   ,[dblFactor]
				   ,[intConcurrencyId])		   
		SELECT ITM.intItemId
			  ,SUP.intSupplyPointId
			  ,VPR.trvpr_operand2
			  ,VPR.trvpr_factor2
			  ,1	
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand2 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		--IMPORT RACK PRICE OPERAND3
		INSERT INTO [dbo].[tblTRSupplyPointRackPriceEquation]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[strOperand]
				   ,[dblFactor]
				   ,[intConcurrencyId])		   
		SELECT ITM.intItemId
			  ,SUP.intSupplyPointId
			  ,VPR.trvpr_operand3
			  ,VPR.trvpr_factor3
			  ,1		
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand3 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		--IMPORT RACK PRICE OPERAND4
		INSERT INTO [dbo].[tblTRSupplyPointRackPriceEquation]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[strOperand]
				   ,[dblFactor]
				   ,[intConcurrencyId])		   
		SELECT ITM.intItemId
			  ,SUP.intSupplyPointId
			  ,VPR.trvpr_operand4
			  ,VPR.trvpr_factor4
			  ,1		
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand4 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		--IMPORT RACK PRICE WITHOUT OPERANDs 
		INSERT INTO [dbo].[tblTRSupplyPointRackPriceEquation]
				   ([intItemId]
				   ,[intSupplyPointId]
				   ,[strOperand]
				   ,[dblFactor]
				   ,[intConcurrencyId])		   
		SELECT ITM.intItemId
			  ,SUP.intSupplyPointId
			  ,' '
			  ,0
			  ,1		
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		where trvpr_operand1 IS NULL AND trvpr_operand2 IS NULL AND trvpr_operand3 IS NULL AND trvpr_operand4 IS NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)
	END

	IF(@Checking = 1)
	BEGIN
		SELECT @Total = COUNT(SUP.intSupplyPointId)
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand1 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId) 

		SELECT @Total = @Total + COUNT(SUP.intSupplyPointId)
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand2 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		SELECT @Total = @Total + COUNT(SUP.intSupplyPointId)	
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand3 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		SELECT @Total = @Total + COUNT(SUP.intSupplyPointId)
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		WHERE VPR.trvpr_operand4 IS NOT NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

		SELECT @Total = @Total + COUNT(SUP.intSupplyPointId)
		FROM trvprmst VPR
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VPR.trvpr_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = VPR.trvpr_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = VPR.trvpr_pt_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			 AND SUP.intEntityVendorId = ELOC.intEntityId
		where trvpr_operand1 IS NULL AND trvpr_operand2 IS NULL AND trvpr_operand3 IS NULL AND trvpr_operand4 IS NULL AND SUP.intSupplyPointId NOT IN 
		(SELECT intSupplyPointId FROM tblTRSupplyPointRackPriceEquation WHERE intSupplyPointId = SUP.intSupplyPointId AND intItemId =ITM.intItemId)

	END
END

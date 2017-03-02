
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportSupplyPoint')
	DROP PROCEDURE uspTRImportSupplyPoint
GO

CREATE PROCEDURE uspTRImportSupplyPoint
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblTRSupplyPoint] - TR SupplyPoint 
	--==========================================================
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tempvndloc')
		DROP table tempvndloc
	IF  EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'tempvnd')
		DROP table tempvnd		

		SELECT 		ENT.intEntityId,
					ssvnd_vnd_no,
					ssvnd_name,
                    RTRIM(ISNULL(CASE WHEN ssvnd_co_per_ind = 'C' THEN ssvnd_name
						   ELSE dbo.fnTrim(SUBSTRING(ssvnd_name, DATALENGTH([dbo].[fnGetVendorLastName](ssvnd_name)), DATALENGTH(ssvnd_name)))
									+ ' ' + dbo.fnTrim([dbo].[fnGetVendorLastName](ssvnd_name))
								END,'')) + '_' + CAST(A4GLIdentity AS NVARCHAR) AS LocName,
					ssvnd_tax_st
	 INTO tempvndloc			
	 FROM ssvndmst  
	 INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
	 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
	 --INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = ENT.intEntityId
	 WHERE ETYP.strType = 'Vendor'
	 
	 SELECT ENT.intEntityId,
			ssvnd_vnd_no,
			ssvnd_name,                    
			ssvnd_tax_st
	 INTO tempvnd			
	 FROM ssvndmst  
	 INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
	 INNER JOIN tblAPVendor APVND ON APVND.intEntityVendorId = ENT.intEntityId
	 WHERE APVND.ysnTransportTerminal = 1 AND ETYP.strType = 'Vendor'	 
 	
	IF(@Checking = 0)
	BEGIN
		INSERT INTO [dbo].[tblTRSupplyPoint]
				   ([intEntityVendorId]
				   ,[intEntityLocationId]
				   ,[intTerminalControlNumberId]
				   ,[strGrossOrNet]
				   ,[strFuelDealerId1]
				   ,[strFuelDealerId2]
				   ,[strDefaultOrigin]
				   ,[intTaxGroupId]
				   ,[ysnMultipleDueDates]
				   ,[ysnMultipleBolInvoiced]
				   ,[intConcurrencyId])		   
		SELECT
				VND.intEntityVendorId
			   ,ELOC.intEntityLocationId
			   ,(CASE WHEN VNC.ssvnc_tx_terminal_no IS NOT NULL THEN (select TCN.intTerminalControlNumberId FROM tblTFTerminalControlNumber TCN 
					  where TCN.strTerminalControlNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
							 = (SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 1,1)+'-'
							 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 2,2)+'-'
							 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 4,2)+'-'
							 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 6,4))) 
				 ELSE VNC.ssvnc_tx_terminal_no END)
			   ,(CASE WHEN VNC.ssvnc_tx_gross_net_ind = 'N' THEN 'Net' ELSE 'Gross' END)
			   ,VNC.ssvnc_tx_fuel_dlr_id
			   ,VNC.ssvnc_tx_fuel_dlr_id2
			   ,VNC.ssvnc_tx_dflt_origin
			   ,ELOC.intTaxGroupId
			   ,(CASE WHEN VNC.ssvnc_tx_multi_pay_yn = 'Y' THEN 1 ELSE 0 END)
			   ,(CASE WHEN VNC.ssvnc_tx_multi_bol_ivc_yn = 'Y' THEN 1 ELSE 0 END)
			   ,1
		FROM ssvncmst VNC
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VNC.ssvnc_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tempvnd tmp ON tmp.ssvnd_vnd_no = VNC.ssvnc_vnd_no AND SUBSTRING(VNC.ssvnc_seq_cd, 1, 2) = tmp.ssvnd_tax_st 
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 WHERE VNC.ssvnc_type = 'TX' AND VND.ysnTransportTerminal = 1 and ELOC.intEntityLocationId not in (SELECT intEntityLocationId FROM tblTRSupplyPoint)

			INSERT INTO [dbo].[tblTRSupplyPoint]
					   ([intEntityVendorId]
					   ,[intEntityLocationId]
					   ,[intTerminalControlNumberId]
					   ,[strGrossOrNet]
					   ,[strFuelDealerId1]
					   ,[strFuelDealerId2]
					   ,[strDefaultOrigin]
					   ,[intTaxGroupId]
					   ,[ysnMultipleDueDates]
					   ,[ysnMultipleBolInvoiced]
					   ,[intConcurrencyId])		   
			SELECT
					VND.intEntityVendorId
				   ,ELOC.intEntityLocationId
				   ,(CASE WHEN VNC.ssvnc_tx_terminal_no IS NOT NULL THEN (select TCN.intTerminalControlNumberId FROM tblTFTerminalControlNumber TCN 
						  where TCN.strTerminalControlNumber COLLATE SQL_Latin1_General_CP1_CS_AS 
								 = (SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 1,1)+'-'
								 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 2,2)+'-'
								 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 4,2)+'-'
								 +  SUBSTRING (VNC.ssvnc_tx_terminal_no COLLATE SQL_Latin1_General_CP1_CS_AS, 6,4))) 
					 ELSE VNC.ssvnc_tx_terminal_no END)
				   ,(CASE WHEN VNC.ssvnc_tx_gross_net_ind = 'N' THEN 'Net' ELSE 'Gross' END)
				   ,VNC.ssvnc_tx_fuel_dlr_id
				   ,VNC.ssvnc_tx_fuel_dlr_id2
				   ,VNC.ssvnc_tx_dflt_origin
				   ,ELOC.intTaxGroupId
				   ,(CASE WHEN VNC.ssvnc_tx_multi_pay_yn = 'Y' THEN 1 ELSE 0 END)
				   ,(CASE WHEN VNC.ssvnc_tx_multi_bol_ivc_yn = 'Y' THEN 1 ELSE 0 END)
				   ,1
			FROM ssvncmst VNC
				 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VNC.ssvnc_vnd_no
				 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
				 INNER JOIN tempvndloc tmp ON tmp.ssvnd_vnd_no = VNC.ssvnc_vnd_no  AND SUBSTRING(VNC.ssvnc_seq_cd, 1, 2) = tmp.ssvnd_tax_st
				 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
				 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.LocName COLLATE SQL_Latin1_General_CP1_CS_AS
				 where VNC.ssvnc_type = 'TX' AND VND.ysnTransportTerminal = 1 and ELOC.intEntityLocationId not in (SELECT intEntityLocationId FROM tblTRSupplyPoint)			 
	END

	IF(@Checking = 1)
	BEGIN
		SELECT @Total = COUNT(ELOC.intEntityLocationId)
		FROM ssvncmst VNC
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VNC.ssvnc_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tempvnd tmp ON tmp.ssvnd_vnd_no = VNC.ssvnc_vnd_no AND SUBSTRING(VNC.ssvnc_seq_cd, 1, 2) = tmp.ssvnd_tax_st 
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 WHERE VNC.ssvnc_type = 'TX' AND VND.ysnTransportTerminal = 1 and ELOC.intEntityLocationId not in (SELECT intEntityLocationId FROM tblTRSupplyPoint)
			 
		SELECT @Total = @Total + COUNT(ELOC.intEntityLocationId)
		FROM ssvncmst VNC
				 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = VNC.ssvnc_vnd_no
				 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
				 INNER JOIN tempvndloc tmp ON tmp.ssvnd_vnd_no = VNC.ssvnc_vnd_no AND SUBSTRING(VNC.ssvnc_seq_cd, 1, 2) = tmp.ssvnd_tax_st 
				 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
				 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.LocName COLLATE SQL_Latin1_General_CP1_CS_AS
				 WHERE VNC.ssvnc_type = 'TX' AND VND.ysnTransportTerminal = 1 and ELOC.intEntityLocationId not in (SELECT intEntityLocationId FROM tblTRSupplyPoint)			 
	END
	
END
GO


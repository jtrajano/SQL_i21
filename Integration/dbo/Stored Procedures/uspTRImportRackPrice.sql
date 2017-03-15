
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportRackPrice')
	DROP PROCEDURE uspTRImportRackPrice
GO

CREATE PROCEDURE uspTRImportRackPrice
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblTRuspTRImportRackPriceHeader] - TR Rack Prices 
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
		--IMPORT RACK PRICE HEADER--
		INSERT INTO [dbo].[tblTRRackPriceHeader]
				   ([intSupplyPointId]
				   ,[dtmEffectiveDateTime]
				   ,[strComments]
				   ,[intConcurrencyId])	   
		SELECT  SUP.[intSupplyPointId] 
			  ,CAST((LEFT(CONVERT(VARCHAR,trprc_rev_dt),4) + '-' + SUBSTRING(CONVERT(VARCHAR,trprc_rev_dt),5,2) +  '-' + RIGHT(CONVERT(VARCHAR,trprc_rev_dt),2)) + ' ' +
			   CAST((RTRIM(CONVERT(CHAR,LEFT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2)+':'
				+RIGHT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2),108))+':00') AS CHAR(10)) AS DATETIME)
			  ,CASE WHEN (MAX(CASE WHEN trprc_comment is NULL THEN 'zzzz' ELSE trprc_comment END)) = 'zzzz' THEN '' ELSE MAX( trprc_comment) END 	 			
			  ,1
		FROM trprcmst TRP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = TRP.trprc_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = TRP.trprc_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
		WHERE SUP.intSupplyPointId NOT IN (SELECT intSupplyPointId FROM tblTRRackPriceHeader WHERE intSupplyPointId = SUP.intSupplyPointId 
		AND dtmEffectiveDateTime =CAST((LEFT(CONVERT(VARCHAR,trprc_rev_dt),4) + '-' + SUBSTRING(CONVERT(VARCHAR,trprc_rev_dt),5,2) +  '-' + RIGHT(CONVERT(VARCHAR,trprc_rev_dt),2)) + ' ' 
		+CAST((RTRIM(CONVERT(CHAR,LEFT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2)+':'
		+RIGHT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2),108))+':00') AS CHAR(10)) AS DATETIME)) 
		 GROUP BY SUP.intSupplyPointId, trprc_rev_dt, trprc_time
		 		
		--IMPORT RACK PRICE DETAILS--
		INSERT INTO [dbo].[tblTRRackPriceDetail]
				   ([intRackPriceHeaderId]
				   ,[intItemId]
				   ,[dblVendorRack]
				   ,[dblJobberRack]
				   ,[intConcurrencyId])
		SELECT  RPH.intRackPriceHeaderId
			   ,ITM.intItemId
			   ,trprc_rack_prc
			   ,trprc_cost
			   ,1
		FROM trprcmst TRP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = TRP.trprc_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = TRP.trprc_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
			 INNER JOIN tblTRRackPriceHeader RPH ON RPH.intSupplyPointId = SUP.intSupplyPointId AND RPH.dtmEffectiveDateTime =CAST((LEFT(CONVERT(VARCHAR,trprc_rev_dt),4) + '-' + SUBSTRING(CONVERT(VARCHAR,trprc_rev_dt),5,2) +  '-' + RIGHT(CONVERT(VARCHAR,trprc_rev_dt),2)) + ' ' 
			 +CAST((RTRIM(CONVERT(CHAR,LEFT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2)+':'
			 +RIGHT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2),108))+':00') AS CHAR(10)) AS DATETIME)
			 INNER JOIN tblICItem ITM ON ITM.strItemNo  COLLATE SQL_Latin1_General_CP1_CS_AS = trprc_pt_itm_no  COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE NOT EXISTS (SELECT intRackPriceHeaderId FROM tblTRRackPriceDetail WHERE intRackPriceHeaderId = RPH.intRackPriceHeaderId)

	END

	IF(@Checking = 1)
	BEGIN
		SELECT @Total = COUNT(SUP.intSupplyPointId)
		FROM trprcmst TRP
			 INNER JOIN ssvndmst OVND ON OVND.ssvnd_vnd_no = TRP.trprc_vnd_no
			 INNER JOIN tblAPVendor VND ON VND.strVendorId COLLATE SQL_Latin1_General_CP1_CS_AS = ssvnd_pay_to COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN #tmpvnd tmp ON tmp.ssvnd_vnd_no = TRP.trprc_vnd_no  
			 INNER JOIN tblEMEntityLocation ELOC ON ELOC.intEntityId = VND.intEntityVendorId 
			 AND ELOC.strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = tmp.ssvnd_name COLLATE SQL_Latin1_General_CP1_CS_AS
			 INNER JOIN tblTRSupplyPoint SUP ON SUP.intEntityLocationId = ELOC.intEntityLocationId
		WHERE SUP.intSupplyPointId NOT IN (SELECT intSupplyPointId FROM tblTRRackPriceHeader WHERE intSupplyPointId = SUP.intSupplyPointId 
		AND dtmEffectiveDateTime =CAST((LEFT(CONVERT(VARCHAR,trprc_rev_dt),4) + '-' + SUBSTRING(CONVERT(VARCHAR,trprc_rev_dt),5,2) +  '-' + RIGHT(CONVERT(VARCHAR,trprc_rev_dt),2)) + ' ' 
		+CAST((RTRIM(CONVERT(CHAR,LEFT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2)+':'
		+RIGHT(CAST((RIGHT('0000'+CAST(trprc_time AS VARCHAR(4)),4) ) AS CHAR(4)),2),108))+':00') AS CHAR(10)) AS DATETIME)) 
		 GROUP BY SUP.intSupplyPointId, trprc_rev_dt, trprc_time
	END
	
END
GO


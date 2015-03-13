IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMSyncShipVia')
	DROP PROCEDURE uspSMSyncShipVia
GO

--IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE (strPrefix = 'AG' or strPrefix = 'PT') and ysnUsed = 1 and strDBName = db_name()) = 1
IF 1 = 1
BEGIN

	EXEC('
CREATE PROCEDURE uspSMSyncShipVia
	@ToOrigin			bit				= 0
	,@ShipViaIds		nvarchar(MAX)	= ''all''
	,@AddedCount		int				= 0 OUTPUT
	,@UpdatedCount		int				= 0 OUTPUT
AS
BEGIN

DECLARE @RecordsToProcess table(strShipViaOriginKey nvarchar(10))
DECLARE @RecordsToAdd table(strShipViaOriginKey varchar(10))
DECLARE @RecordsToUpdate table(strShipViaOriginKey varchar(10))

DELETE FROM @RecordsToProcess
DELETE FROM @RecordsToAdd
DELETE FROM @RecordsToUpdate


IF @ToOrigin = 1
	BEGIN
		UPDATE 
			tblSMShipVia
		SET
			strShipViaOriginKey = 
				(CASE WHEN EXISTS(SELECT null FROM [sscarmst] WHERE [sscar_name] COLLATE Latin1_General_CI_AS = [strShipVia])
					THEN (SELECT TOP 1 [sscar_key] FROM [sscarmst] WHERE [sscar_name] COLLATE Latin1_General_CI_AS = [strShipVia])
					ELSE REPLICATE(''0'',10 - LEN(RTRIM(LTRIM(CAST(intShipViaID as nvarchar(20)))))) + CAST(intShipViaID as nvarchar(20))
				END)
		WHERE 
			strShipViaOriginKey IS NULL
			OR RTRIM(LTRIM(strShipViaOriginKey)) = ''''
	END

IF(LOWER(@ShipViaIds) = ''all'')
	BEGIN
		IF (@ToOrigin = 1)
			INSERT INTO @RecordsToProcess(strShipViaOriginKey)
			SELECT [strShipViaOriginKey]
			FROM tblSMShipVia		
		ELSE
			INSERT INTO @RecordsToProcess(strShipViaOriginKey)
			SELECT [sscar_key]
			FROM [sscarmst]									
	END
ELSE
	BEGIN
		IF (@ToOrigin = 1)			
			INSERT INTO @RecordsToProcess(strShipViaOriginKey)
			SELECT SV.[strShipViaOriginKey]
			FROM fnGetRowsFromDelimitedValues(@ShipViaIds) T
			INNER JOIN tblSMShipVia SV ON T.[intID] = SV.[intShipViaID]
		ELSE
			INSERT INTO @RecordsToProcess(strShipViaOriginKey)
			SELECT SV.[sscar_key]
			FROM fnGetRowsFromDelimitedValues(@ShipViaIds) T
			INNER JOIN [sscarmst] SV ON T.[intID] = SV.[sscar_key]
	END		

IF (@ToOrigin = 1)
	INSERT INTO @RecordsToAdd
	SELECT P.[strShipViaOriginKey]
	FROM @RecordsToProcess P
	LEFT OUTER JOIN [sscarmst] SV ON P.[strShipViaOriginKey] = SV.[sscar_key]
	WHERE SV.[sscar_key] IS NULL	
ELSE
	INSERT INTO @RecordsToAdd
	SELECT P.[strShipViaOriginKey]
	FROM @RecordsToProcess P
	LEFT OUTER JOIN tblSMShipVia SV ON P.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS = SV.[strShipViaOriginKey]
	WHERE SV.[strShipViaOriginKey] IS NULL		


INSERT INTO @RecordsToUpdate
SELECT P.[strShipViaOriginKey]
FROM @RecordsToProcess P
LEFT JOIN @RecordsToAdd A ON P.[strShipViaOriginKey] = A.[strShipViaOriginKey]
WHERE A.[strShipViaOriginKey] IS NULL					


IF(@ToOrigin = 1)
	BEGIN				
		INSERT INTO [sscarmst]
			([sscar_key]
			,[sscar_name]
			,[sscar_addr]
			,[sscar_city]
			,[sscar_state]
			,[sscar_zip]
			,[sscar_fed_id]
			--,[sscar_trans_mode]
			,[sscar_in_sf401_yn]
			,[sscar_trans_lic_no]
			,[sscar_ifta_no]
			,[sscar_mi_c3859_yn]
			,[sscar_il_rpt_yn]
			,[sscar_oh_cc22_yn]
			,[sscar_co_owned_yn]
			--,[sscar_user_id]
			,[sscar_user_rev_dt])
		SELECT
			 P.[strShipViaOriginKey]						AS [sscar_key]
			,SUBSTRING(P.[strShipVia], 1, 20)				AS [sscar_name]
			,SUBSTRING(P.[strAddress], 1, 30)				AS [sscar_addr]
			,SUBSTRING(P.[strCity], 1, 20)					AS [sscar_city]
			,SUBSTRING(P.[strState], 1, 2)					AS [sscar_state]
			,SUBSTRING(P.[strZipCode], 1, 9)				AS [sscar_zip]
			,SUBSTRING(P.[strFederalId], 1, 15)				AS [sscar_fed_id]
			--,P.[strTransportationMode]					AS [sscar_trans_mode]
			,''N''											AS [sscar_in_sf401_yn]
			,SUBSTRING(P.[strTransporterLicense], 1, 15)	AS [sscar_trans_lic_no]
			,SUBSTRING(P.[strMotorCarrierIFTA], 1, 15)		AS [sscar_ifta_no]
			,''N''											AS [sscar_mi_c3859_yn]
			,''N''											AS [sscar_il_rpt_yn]
			,''N''											AS [sscar_oh_cc22_yn]
			,(CASE WHEN P.[ysnCompanyOwnedCarrier] = 1
				THEN ''Y''
				ELSE ''N''
			  END)		AS [sscar_co_owned_yn]
			--,1								AS [sscar_user_id]
			,P.[intSort]					AS [sscar_user_rev_dt]
		FROM
			tblSMShipVia P
		INNER JOIN
			@RecordsToAdd A
				ON P.[strShipViaOriginKey] = A.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS 			
		LEFT OUTER JOIN
			[sscarmst] SV
				ON P.[strShipViaOriginKey] = SV.[sscar_key] COLLATE Latin1_General_CI_AS 
		WHERE
			SV.[sscar_key] IS NULL
		ORDER BY
			P.[strShipViaOriginKey]           

		SET @AddedCount = @@ROWCOUNT

		UPDATE [sscarmst]
		SET 
			[sscar_key]				= P.[strShipViaOriginKey]
			,[sscar_name]			= SUBSTRING(P.[strShipVia], 1, 20)
			,[sscar_addr]			= SUBSTRING(P.[strAddress], 1, 30)
			,[sscar_city]			= SUBSTRING(P.[strCity], 1, 20)
			,[sscar_state]			= SUBSTRING(P.[strState], 1, 2)
			,[sscar_zip]			= SUBSTRING(P.[strZipCode], 1, 9)
			,[sscar_fed_id]			= SUBSTRING(P.[strFederalId], 1, 15)
			,[sscar_trans_mode]		= [sscar_trans_mode]
			,[sscar_in_sf401_yn]	= [sscar_in_sf401_yn]
			,[sscar_trans_lic_no]	= SUBSTRING(P.[strTransporterLicense], 1, 15)
			,[sscar_ifta_no]		= SUBSTRING(P.[strMotorCarrierIFTA], 1, 15)
			,[sscar_mi_c3859_yn]	= [sscar_mi_c3859_yn]
			,[sscar_il_rpt_yn]		= [sscar_il_rpt_yn]
			,[sscar_oh_cc22_yn]		= [sscar_oh_cc22_yn]
			,[sscar_co_owned_yn]	= 
									(CASE WHEN P.[ysnCompanyOwnedCarrier] = 1
										THEN ''Y''
										ELSE ''N''
									  END)
			,[sscar_user_id]		= [sscar_user_id]
			,[sscar_user_rev_dt]	= [sscar_user_rev_dt]		
		FROM
			tblSMShipVia P
		INNER JOIN
			@RecordsToUpdate A
				ON P.[strShipViaOriginKey] = A.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS 				
		WHERE
			 [sscarmst].[sscar_key] = A.[strShipViaOriginKey]  
	
		SET @UpdatedCount = @@ROWCOUNT				
	END
ELSE
	BEGIN
	
		DECLARE @MaxIntSort int
		SELECT @MaxIntSort = MAX([intSort]) FROM [tblSMShipVia]
		IF @MaxIntSort IS NULL
			SET @MaxIntSort = 0

		INSERT INTO [tblSMShipVia]
			([strShipViaOriginKey]
			,[strShipVia]
			,[strShippingService]
			,[strName]
			,[strAddress]
			,[strCity]
			,[strState]
			,[strZipCode]
			,[strFederalId]
			,[strTransporterLicense]
			,[strMotorCarrierIFTA]
			,[strTransportationMode]
			,[ysnCompanyOwnedCarrier]
			,[ysnActive]
			,[intSort]
			,[intConcurrencyId])
		SELECT
			 P.[sscar_key]			AS [strShipViaOriginKey]
			,P.[sscar_name]			AS [strShipVia]
			,P.[sscar_name]			AS [strShippingService]
			,P.[sscar_name]			AS [strName]
			,P.[sscar_addr]			AS [strAddress]
			,P.[sscar_city]			AS [strCity]
			,P.[sscar_state]		AS [strState]
			,P.[sscar_zip]			AS [strZipCode]
			,P.[sscar_fed_id]		AS [strFederalId]
			,P.[sscar_trans_lic_no]	AS [strTransporterLicense]
			,P.[sscar_ifta_no]		AS [strMotorCarrierIFTA]
			,P.[sscar_trans_mode]	AS [strTransportationMode]
			,(CASE WHEN P.[sscar_co_owned_yn] = ''Y'' 
				THEN 1
				ELSE 0
			 END)					AS [ysnCompanyOwnedCarrier]
			,1
			,@MaxIntSort + ROW_NUMBER() OVER (ORDER BY P.[sscar_name])
									AS [intSort]
			,0						AS [intConcurrencyId]
		FROM
			[sscarmst] P
		INNER JOIN
			@RecordsToAdd A
				ON P.[sscar_key] = SUBSTRING(RTRIM(LTRIM(A.[strShipViaOriginKey])),0 ,29)
		LEFT OUTER JOIN
			tblSMShipVia SV
				ON P.[sscar_key] COLLATE Latin1_General_CI_AS  = SV.[strShipViaOriginKey]
		WHERE
			SV.[strShipViaOriginKey] IS NULL
		ORDER BY
			P.[sscar_key]
	
		SET @AddedCount = @@ROWCOUNT	
		

		UPDATE [tblSMShipVia]
		SET 
			[strShipViaOriginKey]		= P.[sscar_key]
			,[strShipVia]				= P.[sscar_name]
			,[strShippingService]		= [strShippingService]
			,[strName]					= [strName]
			,[strAddress]				= P.[sscar_addr]
			,[strCity]					= P.[sscar_city]
			,[strState]					= P.[sscar_state]
			,[strZipCode]				= P.[sscar_zip]
			,[strFederalId]				= P.[sscar_fed_id]
			,[strTransporterLicense]	= P.[sscar_trans_lic_no]
			,[strMotorCarrierIFTA]		= P.[sscar_ifta_no]
			,[strTransportationMode]	= [strTransportationMode]
			,[ysnCompanyOwnedCarrier]	= 
										(CASE WHEN P.[sscar_co_owned_yn] = ''Y'' 
											THEN 1
											ELSE 0
										 END)
			,[ysnActive]				= [ysnActive]
			,[intSort]					= [intSort]
		FROM
			[sscarmst] P
		INNER JOIN
			@RecordsToUpdate A
				ON P.[sscar_key] = A.[strShipViaOriginKey]				
		WHERE
			 [tblSMShipVia].[strShipViaOriginKey] = A.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS  
	 
	 
		SET @UpdatedCount = @@ROWCOUNT			 


	END


END
')
END

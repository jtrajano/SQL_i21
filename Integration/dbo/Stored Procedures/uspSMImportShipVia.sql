IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportShipVia')
	DROP PROCEDURE uspSMImportShipVia
GO

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE (strPrefix = 'AG' or strPrefix = 'PT') and strDBName = db_name()) = 1
BEGIN

	EXEC('
CREATE PROCEDURE uspSMImportShipVia
	@Checking	bit = 0,
	@UserId		int = 0,
	@Total		int = 0 OUTPUT
AS
BEGIN

	IF(@Checking = 1) 
	BEGIN	
		SELECT
			@Total = COUNT(AG.[sscar_key])
		FROM
			[sscarmst] AG
		LEFT OUTER JOIN
			[tblSMShipVia] SV
				ON RTRIM(LTRIM(AG.[sscar_key] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(SV.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS))										
		WHERE
			SV.[strShipViaOriginKey] IS NULL
				
		RETURN @Total
	END	
				
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
		 [sscar_key]			AS [strShipViaOriginKey]
		,[sscar_name]			AS [strShipVia]
		,[sscar_name]			AS [strShippingService]
		,[sscar_name]			AS [strName]
		,[sscar_addr]			AS [strAddress]
		,[sscar_city]			AS [strCity]
		,[sscar_state]			AS [strState]
		,[sscar_zip]			AS [strZipCode]
		,[sscar_fed_id]			AS [strFederalId]
		,[sscar_trans_lic_no]	AS [strTransporterLicense]
		,[sscar_ifta_no]		AS [strMotorCarrierIFTA]
		,[sscar_trans_mode]		AS [strTransportationMode]
		,(CASE WHEN [sscar_co_owned_yn] = ''Y'' 
			THEN 1
			ELSE 0
		 END)					AS [ysnCompanyOwnedCarrier]
		,1
		,ROW_NUMBER() OVER (ORDER BY [sscar_name])
								AS [intSort]
		,0						AS [intConcurrencyId]
	FROM
		[sscarmst]
	LEFT OUTER JOIN
		[tblSMShipVia] SV
			ON RTRIM(LTRIM([sscar_key] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(SV.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS))										
	WHERE
		SV.[strShipViaOriginKey] IS NULL		

END
')
END

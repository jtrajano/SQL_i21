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
		 AG.[sscar_key]			AS [strShipViaOriginKey]
		 ,(CASE WHEN EXISTS(SELECT [sscar_key], [sscar_name] FROM [sscarmst] WHERE RTRIM(LTRIM([sscar_key])) <> RTRIM(LTRIM(AG.[sscar_key])) AND RTRIM(LTRIM([sscar_name])) = RTRIM(LTRIM(AG.[sscar_name])))
					THEN 
						RTRIM(LTRIM(AG.[sscar_name])) + '' - '' + RTRIM(LTRIM(AG.[sscar_key]))
					ELSE
						RTRIM(LTRIM(AG.[sscar_name]))
				  END)				AS [strShipVia]
		,AG.[sscar_name]			AS [strShippingService]
		,AG.[sscar_name]			AS [strName]
		,AG.[sscar_addr]			AS [strAddress]
		,AG.[sscar_city]			AS [strCity]
		,AG.[sscar_state]			AS [strState]
		,AG.[sscar_zip]			AS [strZipCode]
		,AG.[sscar_fed_id]			AS [strFederalId]
		,AG.[sscar_trans_lic_no]	AS [strTransporterLicense]
		,AG.[sscar_ifta_no]		AS [strMotorCarrierIFTA]
		,AG.[sscar_trans_mode]		AS [strTransportationMode]
		,(CASE WHEN AG.[sscar_co_owned_yn] = ''Y'' 
			THEN 1
			ELSE 0
		 END)					AS [ysnCompanyOwnedCarrier]
		,1
		,ROW_NUMBER() OVER (ORDER BY AG.[sscar_name])
								AS [intSort]
		,0						AS [intConcurrencyId]
	FROM
		[sscarmst] AG
	LEFT OUTER JOIN
		[tblSMShipVia] SV
			ON RTRIM(LTRIM(AG.[sscar_key] COLLATE Latin1_General_CI_AS)) = RTRIM(LTRIM(SV.[strShipViaOriginKey] COLLATE Latin1_General_CI_AS))										
	WHERE
		SV.[strShipViaOriginKey] IS NULL		

END
')
END

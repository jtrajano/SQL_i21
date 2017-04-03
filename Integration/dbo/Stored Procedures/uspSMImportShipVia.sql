IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportShipVia')
	DROP PROCEDURE uspSMImportShipVia
GO

--IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE (strPrefix = 'AG' or strPrefix = 'PT') and strDBName = db_name()) = 1
IF 1 = 1
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
	
	DECLARE @ImportShipViaTariff TABLE 
	(
		[intEntityTariffId] [int],
		[intEntityId] [int] ,
		[strDescription] [nvarchar](50) 
	)	
	
	DECLARE @ImportShipVia TABLE 
	(
		strShipViaOriginKey			nvarchar(10),
		strShipVia					nvarchar(100),
		[strShippingService]		nvarchar(250),
		[strName]					nvarchar(100),
		[strAddress]				nvarchar(250),
		[strCity]					nvarchar(100),
		[strState]					nvarchar(100),
		[strZipCode]				nvarchar(100),
		[strFederalId]				nvarchar(100),
		[strTransporterLicense]		nvarchar(100),
		[strMotorCarrierIFTA]		nvarchar(100),
		[strTransportationMode]		nvarchar(100),
		[ysnCompanyOwnedCarrier]	bit,
		[ysnActive]					bit,
		[intSort]					int,
		[intConcurrencyId]			int
	)
	INSERT INTO @ImportShipVia
	SELECT
		 AG.[sscar_key]			AS [strShipViaOriginKey]
		 ,(CASE WHEN EXISTS(SELECT [sscar_key], [sscar_name] FROM [sscarmst] WHERE RTRIM(LTRIM([sscar_key])) <> RTRIM(LTRIM(AG.[sscar_key])) AND RTRIM(LTRIM([sscar_name])) = RTRIM(LTRIM(AG.[sscar_name])))
					THEN 
						RTRIM(LTRIM(AG.[sscar_name])) + '' - '' + RTRIM(LTRIM(AG.[sscar_key]))
					ELSE
						RTRIM(LTRIM(ISNULL(AG.[sscar_name], AG.[sscar_key])))
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

	declare @CurKey nvarchar(10)

	WHILE EXISTS(SELECT TOP 1 1 FROM @ImportShipVia)
	begin
	
		select top 1 @CurKey = strShipViaOriginKey from @ImportShipVia

		DECLARE @EntityId			int
		Declare @EntityContactId	int
		DECLARE @EntityLocationId	int

		INSERT INTO tblEMEntity(strName,strEntityNo, strContactNumber)
		SELECT TOP 1  
			strName,
			@CurKey,
			''''
			from @ImportShipVia
				where strShipViaOriginKey = @CurKey
		set @EntityId = @@IDENTITY


		INSERT INTO [tblSMShipVia]
		(
		[intEntityId]
		,[strShipViaOriginKey]
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
		select top 1
		@EntityId  
		,[strShipViaOriginKey]
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
		,[intConcurrencyId]
		from @ImportShipVia
			where strShipViaOriginKey = @CurKey


		INSERT INTO tblEMEntity(strName, strContactNumber)
		SELECT TOP 1 
			strName,
			''''
			from @ImportShipVia
				where strShipViaOriginKey = @CurKey
		set @EntityContactId = @@IDENTITY

		INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, strAddress, strZipCode, strCity, strState, ysnDefaultLocation)
		SELECT TOP 1  
			@EntityId,
			strName + ''Loc'',
			strAddress,
			strZipCode,
			strCity,
			strState,
			1
			from @ImportShipVia
				where strShipViaOriginKey = @CurKey
		set @EntityLocationId = @@IDENTITY
			
		insert into tblEMEntityToContact(intEntityId, intEntityContactId, ysnPortalAccess, ysnDefaultContact, intConcurrencyId)		
		select @EntityId, @EntityContactId, 0, 1, 1

		
		insert into tblEMEntityType(intEntityId, intConcurrencyId, strType)
		select @EntityId, 1, ''Ship Via''

		IF NOT EXISTS (select top 1 * from [tblEMEntityTariffType] where [strTariffType] = ''Default'')
		Begin
			INSERT INTO [dbo].[tblEMEntityTariffType]
					   ([strTariffType]
					  ,[intConcurrencyId])
					VALUES (''Default'', 1)
		End

		--INSERT SHIPVIa Tariff
		INSERT INTO [dbo].[tblEMEntityTariff]
				   ([intEntityId]
				   ,[strDescription]
				   ,[dtmEffectiveDate]
				   ,[intEntityTariffTypeId]
				   ,[intConcurrencyId])

		SELECT SHP.intEntityId
			  ,CMR.trcmr_class
			  ,CONVERT(DATE, CAST(20170101 AS CHAR(12)), 112)
			  ,TRT.intEntityTariffTypeId,1 
		FROM trcmrmst CMR
		INNER JOIN tblSMShipVia SHP ON SHP.strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS = CMR.trcmr_carrier COLLATE SQL_Latin1_General_CP1_CS_AS
		INNER JOIN [tblEMEntityTariffType] TRT ON TRT.strTariffType = ''DEFAULT''
		WHERE SHP.intEntityId = @EntityId
		
		INSERT INTO @ImportShipViaTariff
				   ([intEntityTariffId]
				   ,[intEntityId]
				   ,[strDescription])
		SELECT TRF.[intEntityTariffId]
			  ,TRF.[intEntityId]
			  ,TRF.[strDescription]
		FROM [tblEMEntityTariff] TRF
		WHERE TRF.[intEntityId] = @EntityId		

		DECLARE @EntityTariffId			int
		WHILE EXISTS(SELECT TOP 1 1 FROM @ImportShipViaTariff WHERE intEntityId = @EntityId )
		BEGIN
				select top 1 @EntityTariffId = intEntityTariffId from @ImportShipViaTariff WHERE intEntityId = @EntityId

			--INSERT Ship Via Tariff Category
			INSERT INTO [dbo].[tblEMEntityTariffCategory]
					   ([intEntityTariffId]
					   ,[intCategoryId]
					   ,[intConcurrencyId])
			SELECT TRT.intEntityTariffId
				  ,CAT.intCategoryId
				  ,1
			FROM [tblEMEntityTariff] TRT
			INNER JOIN tblICCategory CAT ON CAT.strCategoryCode  COLLATE SQL_Latin1_General_CP1_CS_AS = TRT.strDescription  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE TRT.intEntityTariffId = @EntityTariffId

			--INSERT Ship Via FuelSurcharges
			INSERT INTO [dbo].[tblEMEntityTariffFuelSurcharge]
					   ([intEntityTariffId]
					   ,[dblFuelSurcharge]
					   ,[dtmEffectiveDate]
					   ,[intConcurrencyId])
			SELECT  TAR.intEntityTariffId
				   ,CRM.trcmr_fuel_surchrg1
				   ,(CASE WHEN ISDATE(CRM.trcmr_eff_rev_dt1) = 1 THEN CONVERT(DATE,CAST(CRM.trcmr_eff_rev_dt1 AS CHAR(12)), 112) ELSE '' '' END)
				   ,1
				   FROM trcmrmst CRM
			INNER JOIN tblSMShipVia SHP ON SHP.strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_carrier COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityTariff TAR ON TAR.intEntityId = SHP.intEntityId
			AND TAR.strDescription COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_class  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE trcmr_fuel_surchrg1 <> 0 AND TAR.intEntityTariffId = @EntityTariffId

			INSERT INTO [dbo].[tblEMEntityTariffFuelSurcharge]
					   ([intEntityTariffId]
					   ,[dblFuelSurcharge]
					   ,[dtmEffectiveDate]
					   ,[intConcurrencyId])
			SELECT  TAR.intEntityTariffId
				   ,CRM.trcmr_fuel_surchrg2
				   ,(CASE WHEN ISDATE(CRM.trcmr_eff_rev_dt2) = 1 THEN CONVERT(DATE,CAST(CRM.trcmr_eff_rev_dt1 AS CHAR(12)), 112) ELSE '' '' END)
				   ,1
				   FROM trcmrmst CRM
			INNER JOIN tblSMShipVia SHP ON SHP.strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_carrier COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityTariff TAR ON TAR.intEntityId = SHP.intEntityId
			AND TAR.strDescription COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_class  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE trcmr_fuel_surchrg2 <> 0 AND TAR.intEntityTariffId = @EntityTariffId

			INSERT INTO [dbo].[tblEMEntityTariffFuelSurcharge]
					   ([intEntityTariffId]
					   ,[dblFuelSurcharge]
					   ,[dtmEffectiveDate]
					   ,[intConcurrencyId])
			SELECT  TAR.intEntityTariffId
				   ,CRM.trcmr_fuel_surchrg3
				   ,(CASE WHEN ISDATE(CRM.trcmr_eff_rev_dt3) = 1 THEN CONVERT(DATE,CAST(CRM.trcmr_eff_rev_dt1 AS CHAR(12)), 112) ELSE '' '' END)
				   ,1
				   FROM trcmrmst CRM
			INNER JOIN tblSMShipVia SHP ON SHP.strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_carrier COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityTariff TAR ON TAR.intEntityId = SHP.intEntityId
			AND TAR.strDescription COLLATE SQL_Latin1_General_CP1_CS_AS = CRM.trcmr_class  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE trcmr_fuel_surchrg3 <> 0 AND TAR.intEntityTariffId = @EntityTariffId
			
			--INSERT Ship Via Tariff MILAGE 
			INSERT INTO [dbo].[tblEMEntityTariffMileage]
					   ([intEntityTariffId]
					   ,[intFromMiles]
					   ,[intToMiles]
					   ,[dblCostRatePerUnit]
					   ,[dblInvoiceRatePerUnit]
					   ,[intConcurrencyId])

			SELECT  TAR.intEntityTariffId
				   ,CASE WHEN (MDT.trcdt_seq_no = 1) THEN 0 
					ELSE 1 + (select trcdt_thru_miles from trcdtmst where trcdt_seq_no = MDT. trcdt_seq_no-1
												 AND trcdt_carrier = MDT.trcdt_carrier AND trcdt_class = MDT.trcdt_class)
					END
				   ,MDT.trcdt_thru_miles
				   ,MDT.trcdt_cost_rt_per_un
				   ,MDT.trcdt_invc_rt_per_un
				   ,1	 
			FROM trcdtmst MDT
			INNER JOIN tblSMShipVia SHP ON SHP.strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS = MDT.trcdt_carrier COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityTariff TAR ON TAR.intEntityId = SHP.intEntityId
			AND TAR.strDescription COLLATE SQL_Latin1_General_CP1_CS_AS = MDT.trcdt_class  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE TAR.intEntityTariffId = @EntityTariffId
		
			DELETE FROM @ImportShipViaTariff WHERE intEntityTariffId = @EntityTariffId
			
		END

		delete from @ImportShipVia where strShipViaOriginKey = @CurKey
	end
END
')
END

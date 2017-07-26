CREATE PROCEDURE [dbo].[uspAPConvertLocationToVendor]
	@EntityLocationId INT,
	@ResultMessage NVARCHAR(100) OUTPUT,
	@EntityIdReturn INT OUTPUT
AS
	
	SET @ResultMessage = ''

	DECLARE @EntityName AS NVARCHAR(100)
	DECLARE @DefaultLocation AS BIT
	SELECT @EntityName = strCheckPayeeName, @DefaultLocation = ysnDefaultLocation FROM tblEMEntityLocation WHERE intEntityLocationId = @EntityLocationId
	IF (@EntityName = '')
	BEGIN
		SET @ResultMessage = 'Printed name is blank.'
		RETURN 0 
	END

	IF( @DefaultLocation = 1)
	BEGIN
		SET @ResultMessage = 'Is set as default location.'
		RETURN 0
	END

	--begin transaction

	DECLARE @EntityNumber AS NVARCHAR(100) 

	DECLARE @EntityNewId AS INT
	DECLARE @EntityNewContactId AS INT
	DECLARE @EntityNewLocationId AS INT
	DECLARE @DefaultTerms AS INT

	SELECT @DefaultTerms = intDefaultTermId FROM tblSMCompanyPreference 

	IF( @DefaultTerms is null or @DefaultTerms <= 0)
	BEGIN
		SET @ResultMessage = 'Default term is not setup in company configuration.'
		RETURN 0
	END

	EXEC uspSMGetStartingNumber 43, @EntityNumber OUTPUT

	INSERT INTO tblEMEntity(strName, strContactNumber, strEntityNo, intConcurrencyId)
	SELECT @EntityName, '', @EntityNumber, 1

	SET @EntityNewId = @@IDENTITY

	INSERT INTO tblEMEntity(strName, strContactNumber, strEntityNo, intConcurrencyId)
	SELECT @EntityName, substring(@EntityNumber, 0, 20), '',  1

	SET @EntityNewContactId = @@IDENTITY

	INSERT INTO tblEMEntityLocation ( 
			intEntityId,	strLocationName,	strAddress,		strCity,	strCountry,		strState,	strZipCode,		strPhone,	strFax,		strPricingLevel,	strNotes,	intShipViaId,	intTermsId,		intWarehouseId,		ysnDefaultLocation,		intFreightTermId,	intCountyTaxCodeId,		intTaxGroupId,	intTaxClassId,	ysnActive,	dblLongitude,	dblLatitude,	strTimezone,	strCheckPayeeName,	intConcurrencyId 
	)
	SELECT TOP 1
			@EntityNewId,	strLocationName,	strAddress,		strCity,	strCountry,		strState,	strZipCode,		strPhone,	strFax,		strPricingLevel,	strNotes,	intShipViaId,	intTermsId,		intWarehouseId,		1,						intFreightTermId,	intCountyTaxCodeId,		intTaxGroupId,	intTaxClassId,	1,			dblLongitude,	dblLatitude,	strTimezone,	strCheckPayeeName,	1
		FROM tblEMEntityLocation
	WHERE intEntityLocationId = @EntityLocationId

	SET @EntityNewLocationId = @@IDENTITY

	INSERT INTO tblEMEntityToContact( 
		intEntityId,	intEntityContactId,		intEntityLocationId,	ysnDefaultContact,	ysnPortalAccess,	intConcurrencyId)
	SELECT 
		@EntityNewId,	@EntityNewContactId,	@EntityLocationId,		1				,	1				,	1

	INSERT INTO tblEMEntityType(	intEntityId,	strType,	intConcurrencyId)
	SELECT							@EntityNewId,	'Vendor',	1

	INSERT INTO tblAPVendor(intEntityId, intVendorType, ysnWithholding, dblCreditLimit, intTermsId) SELECT @EntityNewId, 0, 0, 0, @DefaultTerms
	INSERT INTO tblAPVendorTerm(intEntityVendorId, intTermId) SELECT @EntityNewId, @DefaultTerms

	UPDATE tblEMEntityLocation 
		SET ysnActive = 0 
			WHERE intEntityLocationId = @EntityLocationId
				
	--rollback transaction

	SET @EntityIdReturn = @EntityNewId

RETURN 1

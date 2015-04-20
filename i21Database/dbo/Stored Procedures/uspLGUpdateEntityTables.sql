CREATE PROCEDURE [dbo].[uspLGUpdateEntityTables] 
	 @intTransType				INT
	,@intConcurrencyId			INT
	,@intEntityId				INT = NULL
	,@intEntityLocationId		INT = NULL
	,@strEntityType				NVARCHAR (MAX) = NULL
	,@strName					NVARCHAR (200) = NULL
	,@strPhone					NVARCHAR (50) = NULL
	,@strEmail					NVARCHAR (150) = NULL
	,@strAddress				NVARCHAR (MAX) = NULL
	,@strZipCode				NVARCHAR (MAX) = NULL
	,@strCity					NVARCHAR (MAX) = NULL
	,@strState					NVARCHAR (MAX) = NULL
	,@strCountry				NVARCHAR (MAX) = NULL
	,@strAltPhone				NVARCHAR (50) = NULL
	,@strAltEmail				NVARCHAR (150) = NULL
	,@strMobile					NVARCHAR (50) = NULL
	,@strFax					NVARCHAR (50) = NULL
	,@strWebsite				NVARCHAR (MAX) = NULL
	,@strContactName			NVARCHAR (MAX) = NULL
	,@strVendorId				NVARCHAR (MAX) = NULL
	,@strNotes					NVARCHAR (MAX) = NULL
	,@ysnActive					BIT = NULL
	,@intOutEntityId			INT = 0 OUTPUT
	,@intOutEntityLocationId	INT = 0 OUTPUT
AS
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @intIdentityEntityId INT
DECLARE @intIdentityEntityLocationId INT

BEGIN TRY
	IF @intTransType = 1
	BEGIN
		INSERT INTO tblEntity 
		(
			strName,
			strEmail,
			strWebsite,
			strInternalNotes,
			ysnPrint1099,
			str1099Name,
			str1099Form,
			str1099Type,
			strFederalTaxId,
			dtmW9Signed,
			imgPhoto,
			strContactNumber,
			strTitle,
			strDepartment,
			strMobile,
			strPhone,
			strPhone2,
			strEmail2,
			strFax,
			strNotes,
			strContactMethod,
			strTimezone,
			strEntityNo,
			intDefaultLocationId,
			ysnActive,
			intConcurrencyId
		)
		VALUES 
		(
			@strName,
			@strEmail,
			@strWebsite,
			'',
			0,
			'',
			'',
			'',
			'',
			NULL,
			NULL,
			'',
			'',
			'',
			@strMobile,
			@strPhone,
			'',
			@strAltEmail,
			@strFax,
			@strNotes,
			'',
			'',
			@strVendorId,
			NULL,
			@ysnActive,
			@intConcurrencyId
		)

		SET @intIdentityEntityId = SCOPE_IDENTITY()

		INSERT INTO tblEntityLocation 
		(
			intEntityId,
			strLocationName,
			strAddress,
			strCity,
			strCountry,
			strState,
			strZipCode,
			strPhone,
			strFax,
			strPricingLevel,
			strNotes,
			intShipViaId,
			intTaxCodeId,
			intTermsId,
			intWarehouseId,
			ysnDefaultLocation,
			intConcurrencyId
		)
		VALUES 
		(
			@intIdentityEntityId,
			@strName,
			@strAddress,
			@strCity,
			@strCountry,
			@strState,
			@strZipCode,
			@strPhone,
			@strFax,
			'',
			@strContactName,
			NULL,
			NULL,
			NULL,
			NULL,
			1,
			@intConcurrencyId
		)

		SET @intIdentityEntityLocationId = SCOPE_IDENTITY()

		UPDATE tblEntity SET intDefaultLocationId = @intIdentityEntityLocationId WHERE intEntityId=@intIdentityEntityId

		INSERT INTO tblEntityType
		(
			intEntityId,
			strType,
			intConcurrencyId
		)
		VALUES
		(
			@intIdentityEntityId,
			@strEntityType,
			@intConcurrencyId
		)

		SET @intOutEntityId = @intIdentityEntityId
		SET @intOutEntityLocationId = @intIdentityEntityLocationId
	END

	IF @intTransType = 2
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblEntity WHERE intEntityId=@intEntityId) AND @intEntityId IS NOT NULL
		BEGIN
			RAISERROR('Invalid EntityId', 16, 1)
		END

		IF NOT EXISTS(SELECT 1 FROM tblEntityLocation WHERE intEntityLocationId=@intEntityLocationId) AND @intEntityLocationId IS NOT NULL
		BEGIN
			RAISERROR('Invalid EntityLocationId', 16, 1)
		END

		UPDATE tblEntity SET 
			strName = @strName,
			strEmail = @strEmail,
			strWebsite = @strWebsite,
			strMobile = @strMobile,
			strPhone = @strPhone,
			strEmail2 = @strAltEmail,
			strFax = @strFax,
			strNotes = @strNotes,
			strEntityNo = @strVendorId,
			ysnActive = @ysnActive,
			intConcurrencyId = @intConcurrencyId
		WHERE intEntityId=@intEntityId

		UPDATE tblEntityLocation SET
			strLocationName = @strName,
			strAddress = @strAddress,
			strCity = @strCity,
			strCountry = @strCountry,
			strState = @strState,
			strZipCode = @strZipCode,
			strPhone = @strPhone,
			strFax = @strFax,
			strNotes = @strContactName,
			intConcurrencyId = @intConcurrencyId
		WHERE intEntityLocationId=@intEntityLocationId
	END

	IF @intTransType = 3
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblEntity WHERE intEntityId=@intEntityId) AND @intEntityId IS NOT NULL
		BEGIN
			RAISERROR('Invalid EntityId', 16, 1)
		END
		DELETE FROM tblEntity WHERE intEntityId=@intEntityId
	END

END TRY

BEGIN CATCH
SET @ErrMsg = ERROR_MESSAGE()
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH

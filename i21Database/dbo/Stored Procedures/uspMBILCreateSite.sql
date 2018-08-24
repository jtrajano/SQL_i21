CREATE PROCEDURE [dbo].[uspMBILCreateSite]
	@EntityCustomerId INT,
	@ItemId INT,
	@LocationId INT,
	@DriverId INT,
	@UserId INT,
	@SiteId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @Message NVARCHAR(MAX)
		, @DefaultSiteNo NVARCHAR(50)
		, @CountNo INT = 0
		, @SiteNo NVARCHAR(50)
		, @SiteNumber INT = 0
		, @TMCustomerId INT

	SELECT TOP 1 @DefaultSiteNo = ISNULL(strDefaultSiteNo, '') FROM tblMBILCompanyPreference

	WHILE EXISTS(SELECT TOP 1 1 FROM tblTMSite WHERE strDescription = @SiteNo)
	BEGIN
		SET @CountNo += 1
		SET @SiteNo = @DefaultSiteNo + CAST(@CountNo AS NVARCHAR(50))
	END

	SELECT TOP 1 @TMCustomerId = intCustomerID, @SiteNumber = intCurrentSiteNumber FROM tblTMCustomer WHERE intCustomerNumber = @EntityCustomerId

	IF (ISNULL(@TMCustomerId, 0) = 0)
	BEGIN
		INSERT INTO tblTMCustomer(intCurrentSiteNumber, intCustomerNumber, intConcurrencyId)
		VALUES (1, @EntityCustomerId, 1)

		SET @TMCustomerId = SCOPE_IDENTITY()
		SET @SiteNumber = 1

	END

	INSERT INTO tblTMSite(intProduct
		, intCustomerID
		, intLocationId
		, intSiteNumber
		, intDriverID
		, strDescription)
	SELECT @ItemId
		, @TMCustomerId
		, @LocationId
		, @SiteNumber
		, @DriverId
		, @SiteNo

	SET @SiteId = SCOPE_IDENTITY()

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
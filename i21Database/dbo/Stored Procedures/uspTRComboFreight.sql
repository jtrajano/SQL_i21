CREATE PROCEDURE [dbo].[uspTRComboFreight]
	@dtmEffectiveDateTime DATETIME,
	@dblMinimumUnit DECIMAL(18,6),
	@strItemId NVARCHAR(100),
	@strFreightRateType NVARCHAR(100) OUT,
	@strGallonType NVARCHAR(100) OUT,
	@intItemId INT OUT,
	@strComboFreightType NVARCHAR(100),
	@intShipViaEntityId INT = NULL,
	@intCustomerEntityId INT = NULL,
	@intCustomerLocationId INT = NULL
AS
BEGIN

	IF EXISTS(SELECT TOP 1 1 FROM tblTRCompanyPreference WHERE ysnComboFreight = 1)
	BEGIN
		IF(@strComboFreightType = 'Receipt')
		BEGIN
			-- RECEIPT
			DECLARE @intCategoryId INT = NULL
			DECLARE @intComboFreightShipViaId INT = NULL	
			SELECT TOP 1 @intComboFreightShipViaId = intComboFreightShipViaId, @strFreightRateType = strFreightRateType, @strGallonType = strGallonType, @intCategoryId = intCategoryId 
			FROM tblTRComboFreightShipVia 
			WHERE dtmEffectiveDateTime <= @dtmEffectiveDateTime
				AND dblMinimumUnit >= @dblMinimumUnit
				AND intShipViaEntityId = @intShipViaEntityId
			ORDER BY dtmEffectiveDateTime DESC

			IF(@intComboFreightShipViaId IS NULL)
			BEGIN
				SELECT TOP 1 @intComboFreightShipViaId = intComboFreightShipViaId, @strFreightRateType = strFreightRateType, @strGallonType = strGallonType, @intCategoryId = intCategoryId 
				FROM tblTRComboFreightShipVia 
				WHERE dtmEffectiveDateTime <= @dtmEffectiveDateTime
					AND dblMinimumUnit >= @dblMinimumUnit
				ORDER BY dtmEffectiveDateTime DESC
			END

			IF(@strFreightRateType = 'Category' AND ISNULL(@strItemId, '') != '')
			BEGIN
				SELECT TOP 1 @intItemId = intItemId FROM tblICItem WHERE intItemId IN (
					SELECT CONVERT(INT,Item) 
					FROM dbo.fnTRSplit(@strItemId,','))
				AND intCategoryId = @intCategoryId	
			END
		END
		ELSE IF(@strComboFreightType = 'Invoice')
		BEGIN
			--DISTRIBUTION
			DECLARE @intCategoryIdInvoice INT = NULL
			DECLARE @intComboFreightCustomerId INT = NULL

			SELECT TOP 1 @intComboFreightCustomerId = intComboFreightCustomerId, @strFreightRateType = strFreightRateType, @strGallonType = strGallonType, @intCategoryId = intCategoryId 
			FROM tblTRComboFreightCustomer
			WHERE dtmEffectiveDateTime <= @dtmEffectiveDateTime
				AND dblMinimumUnit >= @dblMinimumUnit
				AND intCustomerEntityId = @intCustomerEntityId
				AND intCustomerLocationId = @intCustomerLocationId
			ORDER BY dtmEffectiveDateTime DESC

			IF(@intComboFreightCustomerId IS NULL)
			BEGIN
				SELECT TOP 1 @intComboFreightCustomerId = intComboFreightCustomerId, @strFreightRateType = strFreightRateType, @strGallonType = strGallonType, @intCategoryId = intCategoryId 
				FROM tblTRComboFreightCustomer
				WHERE dtmEffectiveDateTime <= @dtmEffectiveDateTime
					AND dblMinimumUnit >= @dblMinimumUnit
					AND intCustomerEntityId = @intCustomerEntityId
				ORDER BY dtmEffectiveDateTime DESC

				IF(@intComboFreightCustomerId IS NULL)
				BEGIN
					SELECT TOP 1 @intComboFreightCustomerId = intComboFreightCustomerId, @strFreightRateType = strFreightRateType, @strGallonType = strGallonType, @intCategoryId = intCategoryId 
					FROM tblTRComboFreightCustomer
					WHERE dtmEffectiveDateTime <= @dtmEffectiveDateTime
						AND dblMinimumUnit >= @dblMinimumUnit
					ORDER BY dtmEffectiveDateTime DESC
				END
			END

			IF(@strFreightRateType = 'Category' AND ISNULL(@strItemId, '') != '')
			BEGIN
				SELECT TOP 1 @intItemId = intItemId FROM tblICItem WHERE intItemId IN (
					SELECT CONVERT(INT,Item) 
					FROM dbo.fnTRSplit(@strItemId,','))
				AND intCategoryId = @intCategoryId
			END
		END
	END
END

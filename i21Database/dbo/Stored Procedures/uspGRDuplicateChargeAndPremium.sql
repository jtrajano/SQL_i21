CREATE PROCEDURE [dbo].[uspGRDuplicateChargeAndPremium]
	@intChargeAndPremiumId INT,
	@intNewChargeAndPremiumId INT OUTPUT
AS
BEGIN
	DECLARE @intChargeAndPremiumDetailIds AS Id
	DECLARE @intChargeAndPremiumDetailId AS INT
	DECLARE @intNewChargeAndPremiumDetailId AS INT
	DECLARE @strChargeAndPremiumId NVARCHAR(200)
	DECLARE @strNewChargeAndPremiumId NVARCHAR(200)	
	DECLARE @strNewChargeAndPremiumIdWithCounter NVARCHAR(200)	
	DECLARE @counter INT
	
	--ensure first that strChargeAndPremiumId is unique
	SELECT @strChargeAndPremiumId = strChargeAndPremiumId
		,@strNewChargeAndPremiumId = LEFT(strChargeAndPremiumId, 40) + '-copy' 
	FROM tblGRChargeAndPremiumId 
	WHERE intChargeAndPremiumId = @intChargeAndPremiumId

	IF EXISTS(SELECT TOP 1 1 FROM tblGRChargeAndPremiumId WHERE strChargeAndPremiumId = @strNewChargeAndPremiumId)
	BEGIN
		SET @counter = 1
		SET @strNewChargeAndPremiumIdWithCounter = @strNewChargeAndPremiumId + (CAST(@counter AS NVARCHAR(50)))
		WHILE EXISTS(SELECT TOP 1 1 FROM tblGRChargeAndPremiumId WHERE strChargeAndPremiumId = @strNewChargeAndPremiumIdWithCounter)
		BEGIN
			SET @counter += 1
			SET @strNewChargeAndPremiumIdWithCounter = @strNewChargeAndPremiumId + (CAST(@counter AS NVARCHAR(50)))
		END
		SET @strNewChargeAndPremiumId = @strNewChargeAndPremiumIdWithCounter
	END

	/*Generate new header*/
	INSERT INTO tblGRChargeAndPremiumId
	(
		strChargeAndPremiumId
		,strChargeAndPremiumIdDescription
		,ysnActive
		,dtmDateCreated
		,intConcurrencyId
	)
	SELECT 
		strChargeAndPremiumId = @strNewChargeAndPremiumId
		,strChargeAndPremiumIdDescription = strChargeAndPremiumIdDescription + '-copy'
		,ysnActive
		,GETDATE()
		,1
	FROM tblGRChargeAndPremiumId
	WHERE intChargeAndPremiumId = @intChargeAndPremiumId

	SET @intNewChargeAndPremiumId = SCOPE_IDENTITY()
	
	/*Generate new details*/
	INSERT INTO @intChargeAndPremiumDetailIds
	SELECT intChargeAndPremiumDetailId
	FROM tblGRChargeAndPremiumDetail 
	WHERE intChargeAndPremiumId = @intChargeAndPremiumId

	WHILE EXISTS(SELECT 1 FROM @intChargeAndPremiumDetailIds)
	BEGIN
		SET @intChargeAndPremiumDetailId = NULL
		SET @intNewChargeAndPremiumDetailId = NULL

		SELECT TOP 1 @intChargeAndPremiumDetailId = intId
		FROM @intChargeAndPremiumDetailIds

		INSERT INTO tblGRChargeAndPremiumDetail
		(
			intChargeAndPremiumId
			,intChargeAndPremiumItemId
			,intCalculationTypeId
			,intInventoryItemId
			,intOtherChargeItemId
			,dblRate
			,dtmDateCreated
			,intConcurrencyId
			,strRateType
		)
		SELECT 
			intChargeAndPremiumId		= @intNewChargeAndPremiumId
			,intChargeAndPremiumItemId
			,intCalculationTypeId
			,intInventoryItemId
			,intOtherChargeItemId
			,dblRate
			,dtmDateCreated				= GETDATE()
			,intConcurrencyId			= 1
			,strRateType
		FROM tblGRChargeAndPremiumDetail
		WHERE intChargeAndPremiumDetailId = @intChargeAndPremiumDetailId

		SET @intNewChargeAndPremiumDetailId = SCOPE_IDENTITY()

		INSERT INTO tblGRChargeAndPremiumDetailRange
		(
			intChargeAndPremiumDetailId
			,dblFrom
			,dblTo
			,dblRangeRate
			,intConcurrencyId
		)
		SELECT 
			intChargeAndPremiumDetailId = @intNewChargeAndPremiumDetailId
			,dblFrom
			,dblTo
			,dblRangeRate
			,intConcurrencyId			= 1
		FROM tblGRChargeAndPremiumDetailRange
		WHERE intChargeAndPremiumDetailId = @intChargeAndPremiumDetailId

		INSERT INTO tblGRChargeAndPremiumDetailLocation
		(
			intChargeAndPremiumDetailId
			,intCompanyLocationId
			,dblLocationRate
			,intConcurrencyId
		)
		SELECT 
			intChargeAndPremiumDetailId	= @intNewChargeAndPremiumDetailId
			,intCompanyLocationId
			,dblLocationRate
			,intConcurrencyId			= 1
		FROM tblGRChargeAndPremiumDetailLocation
		WHERE intChargeAndPremiumDetailId = @intChargeAndPremiumDetailId

		DELETE FROM @intChargeAndPremiumDetailIds WHERE intId = @intChargeAndPremiumDetailId
	END

	SELECT @intNewChargeAndPremiumId
END
GO
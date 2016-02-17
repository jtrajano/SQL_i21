﻿CREATE PROCEDURE uspSMGetStartingNumber
	@intStartingNumberId INT = NULL,
	@intCompanyLocationId INT = NULL,
	@strID	NVARCHAR(40) = NULL OUTPUT
AS

DECLARE @locationNumber VARCHAR(5)
SET @locationNumber = ''

IF @intCompanyLocationId IS NOT NULL
BEGIN
	-- Check if starting number does not requires company location id
	DECLARE @ysnUseLocation BIT
	SELECT @ysnUseLocation = ysnUseLocation FROM tblSMStartingNumber WHERE intStartingNumberId = @intStartingNumberId

	IF @ysnUseLocation = 1
	BEGIN
		SELECT @locationNumber = strLocationNumber + '-' FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId
		IF @locationNumber = '-'
		BEGIN
			SET @locationNumber = ''
		END
	END
END

-- Assemble the string ID. 
SELECT	@strID = strPrefix + @locationNumber + CAST(intNumber AS NVARCHAR(20))
FROM	tblSMStartingNumber
WHERE	intStartingNumberId = @intStartingNumberId

-- Increment the next number
UPDATE	tblSMStartingNumber
SET		intNumber = ISNULL(intNumber, 0) + 1
WHERE	intStartingNumberId = @intStartingNumberId

-- Raise an error if the generated id is invalid. 
IF @strID IS NULL 
BEGIN 
	DECLARE @STARTING_NUMBER_BATCH_ID AS INT = 3
			,@STARTING_NUMBER_BATCH_LOT_NUMBER AS INT = 24 	
			,@STARTING_NUMBER_BATCH_PARENT_LOT_NUMBER AS INT = 78
	
	IF @intStartingNumberId = @STARTING_NUMBER_BATCH_LOT_NUMBER
	BEGIN 
		-- Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.
		RAISERROR(80031, 11, 1);
	END 
	ELSE IF @intStartingNumberId = @STARTING_NUMBER_BATCH_ID
	BEGIN 
		-- 'Unable to generate the Batch Id. Please ask your local administrator to check the starting numbers setup.'
		RAISERROR(51120, 11, 1);
	END 
	ELSE 
	BEGIN 
		-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
		RAISERROR(50030, 11, 1);
	END 
	RETURN;
END 


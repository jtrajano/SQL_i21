CREATE PROCEDURE uspSMGetStartingNumber
	@intStartingNumberId INT = NULL,
	@strID	NVARCHAR(40) = NULL OUTPUT,
	@intCompanyLocationId INT = NULL
AS

DECLARE @locationNumber VARCHAR(5)
SET @locationNumber = ''

DECLARE @parameters VARCHAR(150)
SET @parameters = ''

-- IF MODULE IS CONTRACT MANAGEMENT
IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE intStartingNumberId = @intStartingNumberId AND strModule = 'Contract Management')
BEGIN

	-- Generate Parameters
	DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = Count(*) FROM tblSMStartingNumberParameter WHERE intStartingNumberId = @intStartingNumberId

	WHILE (@currentRow <= @totalRows)
	BEGIN

	Declare @param NVARCHAR(50)
	SELECT @param = strParameter FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY strParameter ASC) AS 'ROWID', *
		FROM tblSMStartingNumberParameter WHERE intStartingNumberId = @intStartingNumberId
	) a
	WHERE ROWID = @currentRow 
	ORDER BY intSort ASC

	SET @parameters += 
	CASE @param
		WHEN 'Company Location' THEN CASE WHEN @intCompanyLocationId IS NULL THEN '' ELSE (SELECT strLocationName FROM vyuSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId) END
		WHEN 'Company Location Number' THEN CASE WHEN @intCompanyLocationId IS NULL THEN '' ELSE (SELECT strProfitCenter FROM vyuSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId) END
		WHEN 'MMYYYY' THEN RIGHT(REPLACE(CONVERT(VARCHAR(10), SYSDATETIME(), 103), '/', ''), 6)
		WHEN 'YY' THEN LEFT(CONVERT(VARCHAR(5), SYSDATETIME(), 2), 2)
		WHEN 'YYYY' THEN LEFT(CONVERT(VARCHAR(7), SYSDATETIME(), 102), 4)
		WHEN 'MON-YYYY' THEN UPPER(LEFT(DATENAME(MONTH, SYSDATETIME()), 3)) + '-' + DATENAME(YEAR, SYSDATETIME())
		WHEN 'MON-YY' THEN UPPER(LEFT(DATENAME(MONTH, SYSDATETIME()), 3)) + '-' + RIGHT(DATENAME(YEAR, SYSDATETIME()), 2)
		WHEN 'DD-MM-YY' THEN REPLACE(CONVERT(VARCHAR(10), SYSDATETIME(), 4), '.', '-')
		WHEN 'DD-MMM-YYYY' THEN LEFT(CONVERT(VARCHAR(5), SYSDATETIME(), 5), 2) + '-' + UPPER(LEFT(DATENAME(MONTH, SYSDATETIME()), 3)) + '-' + DATENAME(YEAR, SYSDATETIME())
		ELSE @param
    END

	SET @currentRow = @currentRow + 1
	END

END

-- PADDING AND NUMBER OF DIGITS
DECLARE @padding NVARCHAR(10)
DECLARE @digit INT

SET @padding = '000000000' 

IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE intStartingNumberId = @intStartingNumberId)	
BEGIN
	SELECT @digit = ISNULL(intDigits, 0) FROM tblSMStartingNumber WHERE intStartingNumberId = @intStartingNumberId
END

-- BY COMPANY LOCATION
IF @intCompanyLocationId IS NOT NULL
BEGIN

	-- Check if starting number does not requires company location id
	DECLARE @ysnUseLocation BIT
	SELECT @ysnUseLocation = ysnUseLocation FROM tblSMStartingNumber WHERE intStartingNumberId = @intStartingNumberId

	IF @ysnUseLocation = 1
	BEGIN

		IF EXISTS (SELECT TOP 1 1 FROM vyuSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId)
		BEGIN

			SELECT @locationNumber = strProfitCenter + '-' FROM vyuSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

			IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumberLocation WHERE intStartingNumberId = @intStartingNumberId AND intCompanyLocationId = @intCompanyLocationId)
			BEGIN
				SELECT	@strID = @locationNumber + strPrefix + @parameters + CASE WHEN @digit = 0 THEN CAST(location.intNumber AS NVARCHAR(20)) ELSE RIGHT(@padding + CAST(ISNULL(location.intNumber, 1) AS NVARCHAR(20)), @digit) END --CAST(location.intNumber AS NVARCHAR(20))
				FROM tblSMStartingNumberLocation location
				INNER JOIN tblSMStartingNumber number
				ON location.intStartingNumberId = number.intStartingNumberId
				WHERE location.intStartingNumberId = @intStartingNumberId AND intCompanyLocationId = @intCompanyLocationId

				-- Increment the next number
				UPDATE	tblSMStartingNumberLocation
				SET		intNumber = ISNULL(intNumber, 0) + 1
				WHERE	intStartingNumberId = @intStartingNumberId AND intCompanyLocationId = @intCompanyLocationId
			END
			ELSE
			BEGIN
				INSERT INTO tblSMStartingNumberLocation (intStartingNumberId, intCompanyLocationId, intNumber, intConcurrencyId)
				VALUES (@intStartingNumberId, @intCompanyLocationId, 2, 1)

				-- Assemble the string ID.
				SELECT	@strID = @locationNumber + strPrefix + @parameters + CASE WHEN @digit = 0 THEN CAST(1 AS NVARCHAR(20)) ELSE RIGHT(@padding + CAST(1 AS NVARCHAR(20)), @digit) END--CAST(1 AS NVARCHAR(20))
				FROM	tblSMStartingNumber
				WHERE	intStartingNumberId = @intStartingNumberId
			END

		END
		
	END
	ELSE
	BEGIN
		-- Assemble the string ID. 
		SELECT	@strID = @locationNumber + strPrefix + @parameters + CASE WHEN @digit = 0 THEN CAST(intNumber AS NVARCHAR(20)) ELSE RIGHT(@padding + CAST(ISNULL(intNumber, 1) AS NVARCHAR(20)), @digit) END--CAST(intNumber AS NVARCHAR(20))
		FROM	tblSMStartingNumber
		WHERE	intStartingNumberId = @intStartingNumberId

		-- Increment the next number
		UPDATE	tblSMStartingNumber
		SET		intNumber = ISNULL(intNumber, 0) + 1
		WHERE	intStartingNumberId = @intStartingNumberId
	END
END
ELSE
BEGIN
	-- Assemble the string ID. 
	SELECT	@strID = @locationNumber + strPrefix + @parameters + CASE WHEN @digit = 0 THEN CAST(intNumber AS NVARCHAR(20)) ELSE RIGHT(@padding + CAST(ISNULL(intNumber, 1) AS NVARCHAR(20)), @digit) END--CAST(intNumber AS NVARCHAR(20))
	FROM	tblSMStartingNumber
	WHERE	intStartingNumberId = @intStartingNumberId

	-- Increment the next number
	UPDATE	tblSMStartingNumber
	SET		intNumber = ISNULL(intNumber, 0) + 1
	WHERE	intStartingNumberId = @intStartingNumberId
END

-- Raise an error if the generated id is invalid. 
IF @strID IS NULL 
BEGIN 
	DECLARE @STARTING_NUMBER_BATCH_ID AS INT = 3
			,@STARTING_NUMBER_BATCH_LOT_NUMBER AS INT = 24 	
			,@STARTING_NUMBER_BATCH_PARENT_LOT_NUMBER AS INT = 78
	
	IF @intStartingNumberId = @STARTING_NUMBER_BATCH_LOT_NUMBER
	BEGIN 
		-- Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.
		RAISERROR('Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.', 11, 1);
	END 
	ELSE IF @intStartingNumberId = @STARTING_NUMBER_BATCH_ID
	BEGIN 
		-- 'Unable to generate the Batch Id. Please ask your local administrator to check the starting numbers setup.'
		RAISERROR('Unable to generate the Batch Id. Please ask your local administrator to check the starting numbers setup.', 11, 1);
	END 
	ELSE 
	BEGIN 
		-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
		RAISERROR('Unable to generate the Transaction Id. Please ask your local administrator to check the starting numbers setup.', 11, 1);
	END 
	RETURN;
END 


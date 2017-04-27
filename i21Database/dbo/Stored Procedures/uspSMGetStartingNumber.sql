CREATE PROCEDURE uspSMGetStartingNumber
	@intStartingNumberId INT = NULL,
	@strID	NVARCHAR(40) = NULL OUTPUT,
	@intCompanyLocationId INT = NULL
AS

DECLARE @locationNumber VARCHAR(5)
SET @locationNumber = ''

DECLARE @parameters VARCHAR(150)
SET @parameters = ''

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
		WHEN 'Company Location' THEN CASE WHEN @intCompanyLocationId IS NULL THEN '' ELSE (SELECT strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId) END
		WHEN 'Company Location Number' THEN CASE WHEN @intCompanyLocationId IS NULL THEN '' ELSE (SELECT strLocationNumber FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId) END
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

-- Assemble the string ID. 
SELECT	@strID = @locationNumber + strPrefix + @parameters + CAST(intNumber AS NVARCHAR(20))
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


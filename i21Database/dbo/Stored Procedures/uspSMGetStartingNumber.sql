
CREATE PROCEDURE uspSMGetStartingNumber
	@intStartingNumberId INT = NULL,
	@strID	NVARCHAR(40) = NULL OUTPUT

AS

-- Assemble the string ID. 
SELECT	@strID = strPrefix + CAST(intNumber AS NVARCHAR(20))
FROM	tblSMStartingNumber
WHERE	intStartingNumberId = @intStartingNumberId

-- Increment the next number
UPDATE	tblSMStartingNumber
SET		intNumber = ISNULL(intNumber, 0) + 1
WHERE	intStartingNumberId = @intStartingNumberId
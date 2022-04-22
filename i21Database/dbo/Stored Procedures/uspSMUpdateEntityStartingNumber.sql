CREATE PROCEDURE uspSMUpdateEntityStartingNumber
	@EntityNumber NVARCHAR(20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
DECLARE @intNumber AS INT 
DECLARE @intStartingNumberId AS INT

BEGIN 
	IF ISNUMERIC(@EntityNumber) = 1
	BEGIN
		SELECT	@intStartingNumberId = intStartingNumberId
				,@intNumber = intNumber
		FROM	dbo.tblSMStartingNumber
		WHERE	strTransactionType = 'Entity Number'

		IF ISNULL(@intNumber, 0) < @EntityNumber
		BEGIN
			UPDATE tblSMStartingNumber SET intNumber = @EntityNumber WHERE intStartingNumberId = @intStartingNumberId
		END

	END

	

	-- Clean-up 
	SET @intNumber = NULL
	SET @intStartingNumberId = NULL
END 
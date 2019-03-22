CREATE PROCEDURE [dbo].[uspSMGetStartingNumberSubType]
	@intStartingNumberId INT,
	@intPrimarySubTypeId INT = NULL,
	@intSecondarySubTypeId INT = NULL,
	@strNumber	NVARCHAR(40) = NULL OUTPUT
AS
	IF(@intPrimarySubTypeId IS NULL OR @intSecondarySubTypeId IS NULL)
	BEGIN
		EXEC uspSMGetStartingNumber @intStartingNumberId, @strNumber OUT
	END
	ELSE
	BEGIN
		IF(@intPrimarySubTypeId = 1)
		BEGIN
			-- PAYMENT METHOD
			IF(@intPrimarySubTypeId = 1)
			BEGIN
			---- Assemble the string ID. 
			SELECT	@strNumber = strPrefix + CAST(intNumber AS NVARCHAR(20))
			FROM	tblSMPaymentMethod
			WHERE	intPaymentMethodID = @intSecondarySubTypeId

			-- Increment the next number
			UPDATE	tblSMPaymentMethod
			SET		intNumber = ISNULL(intNumber, 0) + 1
			WHERE	intPaymentMethodID = @intSecondarySubTypeId
			END
		END
		ELSE
		BEGIN
			EXEC uspSMGetStartingNumber @intStartingNumberId, @strNumber OUT
		END
	END

RETURN;

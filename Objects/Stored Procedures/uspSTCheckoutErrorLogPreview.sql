CREATE PROCEDURE [dbo].[uspSTCheckoutErrorLogPreview]
	@intCheckoutId INT,
	@ysnContinueToSave BIT OUTPUT
AS
BEGIN
	
	IF EXISTS(SELECT * FROM tblSTCheckoutErrorLogs WHERE intCheckoutId = @intCheckoutId AND strErrorType IN('XML VERSION'))
		BEGIN
			-- Saving checkout should not continue is there's a mismatching xml version

			-- Return only those error with mismatching versions
			SELECT strErrorMessage
					, strRegisterTag
					, strRegisterTagValue
			FROM tblSTCheckoutErrorLogs
			WHERE intCheckoutId = @intCheckoutId
			AND strErrorType IN('XML VERSION')

			-- FLAGGED not to continue saving
			SET @ysnContinueToSave = CAST(0 AS BIT)
		END
	ELSE
		BEGIN
			-- Return Preview result
			SELECT strErrorMessage
					, strRegisterTag
					, strRegisterTagValue
			FROM tblSTCheckoutErrorLogs
			WHERE intCheckoutId = @intCheckoutId
			ORDER BY strRegisterTag, strRegisterTagValue ASC

			SET @ysnContinueToSave = CAST(1 AS BIT)
		END
	

	-- Delete Logs
	--DELETE FROM tblSTCheckoutErrorLogs
	--WHERE intCheckoutId = @intCheckoutId
END
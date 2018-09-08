CREATE PROCEDURE [dbo].[uspSTCheckoutErrorLogPreview]
	@intCheckoutId INT
AS
BEGIN
	
	-- Return Preview result
	SELECT strErrorMessage
			, strRegisterTag
			, strRegisterTagValue
	FROM tblSTCheckoutErrorLogs
	WHERE intCheckoutId = @intCheckoutId
	ORDER BY strRegisterTag, strRegisterTagValue ASC

	-- Delete Logs
	DELETE FROM tblSTCheckoutErrorLogs
	WHERE intCheckoutId = @intCheckoutId
END
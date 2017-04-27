CREATE PROCEDURE [dbo].[uspARDuplicateQuotePage]
	@intQuotePageId INT,
	@NewQuotePageId INT = NULL OUTPUT
AS
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblARQuotePage WHERE intQuotePageId = @intQuotePageId)
		BEGIN
			RAISERROR('Invalid Quote Page ID.', 16, 1)
			RETURN;
		END

	INSERT INTO tblARQuotePage
		([strPageTitle]
		,[strPageDescription]
		,[strPageBody]
		,[intConcurrencyId])
	SELECT 		 
		 'DUP: ' + [strPageTitle]
		,[strPageDescription]
		,[strPageBody]
		,1
	FROM tblARQuotePage
		WHERE intQuotePageId = @intQuotePageId

	SET @NewQuotePageId = SCOPE_IDENTITY()

RETURN
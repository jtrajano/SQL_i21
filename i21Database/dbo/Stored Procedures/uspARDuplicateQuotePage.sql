CREATE PROCEDURE [dbo].[uspARDuplicateQuotePage]
	@intQuoteTemplateDetailId INT,
	@NewQuoteTemplateDetailId INT = NULL OUTPUT
AS
	DECLARE @intQuoteTemplateId INT
	      , @intNextSort		INT

	SELECT TOP 1 @intQuoteTemplateId = intQuoteTemplateId FROM tblARQuoteTemplateDetail WHERE intQuoteTemplateDetailId = @intQuoteTemplateDetailId

	IF ISNULL(@intQuoteTemplateId, 0) = 0
		BEGIN
			RAISERROR('Invalid Quote Template ID.', 16, 1)
			RETURN;
		END

	SELECT @intNextSort = MAX(intSort) + 1 FROM tblARQuoteTemplateDetail WHERE intQuoteTemplateId = @intQuoteTemplateId

	INSERT INTO tblARQuoteTemplateDetail
		([intQuoteTemplateId]
		,[strSectionName]
		,[strPageTitle]
		,[strPageDescription]
		,[strPageBody]
		,[ysnDisplayTitle]
		,[intSort]
		,[intConcurrencyId])
	SELECT 
		 [intQuoteTemplateId]
		,'DUP: ' + [strSectionName]
		,'DUP: ' + [strPageTitle]
		,[strPageDescription]
		,[strPageBody]
		,[ysnDisplayTitle]
		,@intNextSort
		,1
	FROM tblARQuoteTemplateDetail
		WHERE intQuoteTemplateDetailId = @intQuoteTemplateDetailId

	SET @NewQuoteTemplateDetailId = SCOPE_IDENTITY()

RETURN
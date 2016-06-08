print('/*******************  BEGIN Update tblARQuoteTemplateDetail Quote Order *******************/')
GO

DECLARE @tblARQuoteTemplate TABLE(intQuoteTemplateId INT)
DECLARE @tblARQuoteTemplateDetail TABLE(intQuoteTemplateId INT, intQuoteTemplateDetailId INT)
DECLARE @intQuoteTemplateId INT

UPDATE tblARQuoteTemplateDetail SET intQuotePageId = NULL WHERE intQuotePageId = 0

INSERT INTO @tblARQuoteTemplate
SELECT intQuoteTemplateId 
FROM tblARQuoteTemplate WHERE intQuoteTemplateId NOT IN(
		SELECT DISTINCT intQuoteTemplateId FROM tblARQuoteTemplateDetail
		WHERE strSectionName = 'Quote Order')

WHILE EXISTS (SELECT NULL FROM @tblARQuoteTemplate)
	BEGIN		
		SELECT TOP 1 @intQuoteTemplateId = ISNULL(intQuoteTemplateId, 0) FROM @tblARQuoteTemplate

		INSERT INTO tblARQuoteTemplateDetail VALUES (@intQuoteTemplateId, 'Quote Order', 0, NULL, 1, 0)

		DELETE FROM @tblARQuoteTemplate WHERE intQuoteTemplateId = @intQuoteTemplateId
	END

DELETE FROM @tblARQuoteTemplate

INSERT INTO @tblARQuoteTemplate
SELECT intQuoteTemplateId 
FROM tblARQuoteTemplate WHERE intQuoteTemplateId IN (
		SELECT DISTINCT intQuoteTemplateId FROM tblARQuoteTemplateDetail
		WHERE strSectionName = 'Quote Order' AND ISNULL(intSort, 0) = 0)

IF EXISTS (SELECT NULL FROM @tblARQuoteTemplate)
	BEGIN
		UPDATE tblARQuoteTemplateDetail SET intSort = 1 WHERE strSectionName = 'Quote Order'

		WHILE EXISTS (SELECT NULL FROM @tblARQuoteTemplate)
			BEGIN
				DECLARE @sortCounter INT = 2
				SELECT TOP 1 @intQuoteTemplateId = ISNULL(intQuoteTemplateId, 0) FROM @tblARQuoteTemplate

				INSERT INTO @tblARQuoteTemplateDetail
				SELECT intQuoteTemplateId
					 , intQuoteTemplateDetailId 
				FROM tblARQuoteTemplateDetail 
				WHERE intQuoteTemplateId = @intQuoteTemplateId 
				  AND strSectionName <> 'Quote Order'

				WHILE EXISTS (SELECT NULL FROM @tblARQuoteTemplateDetail)
					BEGIN
						DECLARE @intQuoteTemplateDetailId INT 

						SELECT TOP 1 @intQuoteTemplateDetailId = intQuoteTemplateDetailId FROM @tblARQuoteTemplateDetail

						UPDATE tblARQuoteTemplateDetail SET intSort = @sortCounter WHERE intQuoteTemplateDetailId = @intQuoteTemplateDetailId

						DELETE FROM @tblARQuoteTemplateDetail WHERE intQuoteTemplateDetailId = @intQuoteTemplateDetailId

						SET @sortCounter = @sortCounter + 1
					END

				SET @sortCounter = 2
				DELETE FROM @tblARQuoteTemplate WHERE intQuoteTemplateId = @intQuoteTemplateId
			END
	END

GO
print('/*******************  END Update tblARQuoteTemplateDetail Quote Order  *******************/')
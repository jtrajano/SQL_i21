CREATE FUNCTION [dbo].[fnARGetCustomerAccountStatusCodes]
(
	@intEntityCustomerId INT
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strStatusCodes NVARCHAR(MAX) = NULL

	DECLARE @tmpTable TABLE(intAccountStatusId INT)
	INSERT INTO @tmpTable
	SELECT intAccountStatusId FROM tblARCustomerAccountStatus WHERE intEntityCustomerId = @intEntityCustomerId
	
	IF EXISTS(SELECT NULL FROM @tmpTable)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 NULL FROM @tmpTable)
			BEGIN
				DECLARE @intAccountStatusId INT
				
				SELECT TOP 1 @intAccountStatusId = intAccountStatusId FROM @tmpTable ORDER BY intAccountStatusId
				
				IF (SELECT COUNT(*) FROM @tmpTable) > 1
					SELECT @strStatusCodes = ISNULL(@strStatusCodes, '') + strAccountStatusCode + ', ' FROM tblARAccountStatus WHERE intAccountStatusId = @intAccountStatusId
				ELSE
					SELECT @strStatusCodes = ISNULL(@strStatusCodes, '') + strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = @intAccountStatusId

				DELETE FROM @tmpTable WHERE intAccountStatusId = @intAccountStatusId
			END
		END

	RETURN @strStatusCodes
END

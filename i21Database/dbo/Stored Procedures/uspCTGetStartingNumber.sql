CREATE PROCEDURE [dbo].[uspCTGetStartingNumber]

	@strTransactionType NVARCHAR(100)

AS
BEGIN
	DECLARE @strNumber NVARCHAR(MAX)

	SELECT @strNumber = strPrefix + LTRIM(intNumber) FROM tblSMStartingNumber WHERE strTransactionType = @strTransactionType
	UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE  strTransactionType = @strTransactionType
	RETURN @strNumber
END

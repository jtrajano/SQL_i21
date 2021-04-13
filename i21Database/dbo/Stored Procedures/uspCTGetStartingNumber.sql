CREATE PROCEDURE [dbo].[uspCTGetStartingNumber]

	@strTransactionType NVARCHAR(100),
	@strNumber NVARCHAR(MAX) OUTPUT

AS
BEGIN
	SELECT @strNumber = strPrefix + LTRIM(intNumber) FROM tblSMStartingNumber WHERE strTransactionType = @strTransactionType
	UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE  strTransactionType = @strTransactionType
END

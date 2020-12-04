CREATE PROCEDURE [dbo].[uspCTGetStartingNumber]

	@strTransactionType NVARCHAR(100),
	@strNumber NVARCHAR(MAX) OUTPUT

AS
BEGIN
	SELECT @strNumber = strPrefix + LTRIM(intNumber+1) FROM tblSMStartingNumber WHERE strTransactionType = @strTransactionType
	UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE  strTransactionType = @strTransactionType
END

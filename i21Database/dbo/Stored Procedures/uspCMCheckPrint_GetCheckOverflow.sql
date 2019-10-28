CREATE PROCEDURE [dbo].[uspCMCheckPrint_GetCheckOverflow]
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@ysnCheckOverflow INT = NULL OUTPUT 
AS

SELECT TOP 1 @ysnCheckOverflow = 1 FROM tblCMBankTransaction F WHERE
F.intBankAccountId = @intBankAccountId
AND F.strTransactionId IN
        (SELECT strValues COLLATE Latin1_General_CI_AS
        FROM   dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
AND (ysnHasDetailOverflow = 1 OR ysnHasBasisPrepayOverflow = 1)

SELECT @ysnCheckOverflow = ISNULL(@ysnCheckOverflow, 0)
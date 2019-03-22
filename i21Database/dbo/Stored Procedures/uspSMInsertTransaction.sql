CREATE PROCEDURE uspSMInsertTransaction
@screenNamespace nvarchar(max) = NULL,
@strTransactionNo nvarchar(max) = NULL,
@intEntityId INT = NULL,
@intKeyValue INT,
@dtmDate DATETIME = NULL,
@output INT OUTPUT
AS
BEGIN

	DECLARE @screenId INT = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @screenNamespace)
	DECLARE @transactionId INT;
	  (SELECT @transactionId = transactions.intTransactionId
				 FROM  tblSMScreen screen
				INNER JOIN tblSMTransaction transactions ON screen.intScreenId = transactions.intScreenId
				where strNamespace = @screenNamespace AND  transactions.intRecordId =  @intKeyValue)

	IF(ISNULL(@transactionId,'') = '' AND @screenId IS NOT NULL)
		BEGIN

			INSERT INTO tblSMTransaction
			(
				intScreenId,
				strTransactionNo,
				intEntityId,
				dtmDate,
				intRecordId,
				intConcurrencyId
			)
			VALUES (@screenId,
					@strTransactionNo,
					@intEntityId,
					@dtmDate,
					@intKeyValue,
					1)

		SET @output = (SELECT SCOPE_IDENTITY())
		END
	ELSE
		BEGIN
			SET @output = @transactionId
		END


		SELECT @output


END


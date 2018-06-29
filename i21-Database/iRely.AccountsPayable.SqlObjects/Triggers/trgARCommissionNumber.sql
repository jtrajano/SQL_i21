CREATE TRIGGER trgARCommissionNumber
ON dbo.tblARCommission
AFTER INSERT
AS

DECLARE @inserted TABLE(intCommissionId INT)
DECLARE @count INT = 0
DECLARE @intCommissionId INT
DECLARE @strCommissionNumber NVARCHAR(50)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = (SELECT TOP 1 intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Commission')

INSERT INTO @inserted
SELECT intCommissionId FROM INSERTED WHERE strCommissionNumber IS NULL ORDER BY intCommissionId

WHILE EXISTS (SELECT TOP 1 NULL FROM @inserted) AND ISNULL(@intStartingNumberId, 0) > 0
	BEGIN
		SELECT TOP 1 @intCommissionId = intCommissionId FROM @inserted
		SET @strCommissionNumber = NULL

		EXEC dbo.uspSMGetStartingNumber @intStartingNumberId, @strCommissionNumber OUT, NULL

		IF(@strCommissionNumber IS NOT NULL)
			BEGIN
				IF EXISTS (SELECT NULL FROM tblARCommission WHERE strCommissionNumber = @strCommissionNumber)
					BEGIN
						SET @strCommissionNumber = NULL
				
						UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
						EXEC uspSMGetStartingNumber @intStartingNumberId, @strCommissionNumber OUT, NULL			
					END

				UPDATE tblARCommission
				SET strCommissionNumber = @strCommissionNumber
				WHERE intCommissionId = @intCommissionId
			END

			DELETE FROM @inserted
			WHERE intCommissionId = @intCommissionId
	END
GO
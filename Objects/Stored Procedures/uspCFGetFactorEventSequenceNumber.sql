
CREATE PROCEDURE [dbo].[uspCFGetFactorEventSequenceNumber]
@dtmDate DATETIME
,@strEventSequenceId NVARCHAR(MAX) = NULL OUTPUT
AS

	DECLARE @Id INT = 0
	SELECT TOP 1 @Id = intEventSequenceId FROM tblCFExportFactorEventSequenceNumber WHERE dtmExportDate = @dtmDate
	
	IF(@Id = 0)
	BEGIN
		
		DECLARE @count INT
		SELECT @count = COUNT(1) FROM tblCFExportFactorEventSequenceNumber
		IF(ISNULL(@count,0) > 5)
		BEGIN
			DELETE FROM tblCFExportFactorEventSequenceNumber
		END


		SET @Id = 1
		INSERT INTO tblCFExportFactorEventSequenceNumber 
		(
			intEventSequenceId
			,dtmExportDate
		)
		SELECT
			2
			,@dtmDate

		
	END
	ELSE
	BEGIN
		UPDATE tblCFExportFactorEventSequenceNumber SET intEventSequenceId = intEventSequenceId + 1 WHERE dtmExportDate = @dtmDate
	END


	SET @strEventSequenceId = CONVERT(NVARCHAR(10), @dtmDate, 12) + dbo.fnCFPadString(CONVERT(VARCHAR(MAX) ,@Id) , 5, '0', 'left') 
	




CREATE PROCEDURE [dbo].[uspCFEncodeCardToStagingTable]
	 @userId INT
AS
BEGIN
	
	DELETE FROM tblCFEncodeCardStagingTable WHERE ISNULL(intUserId,0) = 0 OR intUserId = @userId

	INSERT INTO tblCFEncodeCardStagingTable
	(
		 intEncodeCardId
		,intUserId
		,intConcurrencyId
	)
	SELECT
		 intEncodeCardId
		,@userId
		,1
	FROM vyuCFEncodeCard

	SELECT * FROM tblCFEncodeCardStagingTable WHERE ISNULL(intUserId,0) = 0 OR intUserId = 1

END

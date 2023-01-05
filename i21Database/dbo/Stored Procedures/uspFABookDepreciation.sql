CREATE PROCEDURE [dbo].[uspFABookDepreciation]
	@Id						AS Id READONLY,   
	@ysnPost				AS BIT = 0,    
	@ysnRecap				AS BIT = 0,    
	@intEntityId			AS INT = 1,    
	@ysnReverseCurrentDate	BIT = 0,  
	@strBatchId				AS NVARCHAR(100),  
	@successfulCount		AS INT = 0 OUTPUT
AS    

EXEC [dbo].[uspFADepreciateMultipleBooks] @Id, NULL, NULL, @ysnPost, @ysnRecap, @intEntityId, @ysnReverseCurrentDate, @strBatchId, @successfulCount OUTPUT

DECLARE @tCount INT
SELECT @tCount = COUNT(*) FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B on A.intLogId = B.intLogId
AND strBatchId = @strBatchId
AND ISNULL(ysnError,0) = 1

IF @tCount = 1
BEGIN
	IF EXISTS (SELECT 1 FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B 
		ON A.intLogId = B.intLogId
		WHERE strBook = 'GAAP' 
		AND strResult ='Asset already fully depreciated.' )
	
		RETURN 1

	DECLARE @strResult NVARCHAR(200)
	SELECT @strResult = strResult FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B on A.intLogId = B.intLogId
	AND strBatchId = @strBatchId
	AND ISNULL(ysnError,0) = 1
	RAISERROR(@strResult, 16, 1)

END

RETURN 1 
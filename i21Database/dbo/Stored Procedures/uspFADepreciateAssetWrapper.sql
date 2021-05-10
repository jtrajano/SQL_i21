CREATE PROCEDURE [dbo].[uspFADepreciateAssetWrapper]    
 @Id    AS Id READONLY,   
 @ysnPost   AS BIT    = 0,    
 @ysnRecap   AS BIT    = 0,    
 @intEntityId  AS INT    = 1,    
 @ysnReverseCurrentDate BIT = 0,  
 @strBatchId   AS NVARCHAR(100),  
 @successfulCount AS INT    = 0 OUTPUT
AS    
EXEC uspFADepreciateMultipleAsset  
@Id,  
1,  
@ysnPost,  
@ysnRecap,  
@intEntityId,  
@ysnReverseCurrentDate,  
@strBatchId,  
@successfulCount OUTPUT  



  
IF @ysnPost =1  
	BEGIN  
	DECLARE @Id1 Id  
	
	INSERT INTO @Id1  
	SELECT A.intId FROM @Id A  JOIN  
	tblFABookDepreciation B on B.intAssetId = A.intId  
	AND B.intBookId = 2  
	GROUP BY A.intId  
	
	IF EXISTS(SELECT 1 FROM @Id1)  
		EXEC uspFADepreciateMultipleAsset  
		@Id1,  
		2,  	
		@ysnPost,  
		@ysnRecap,  
		@intEntityId,  
		@ysnReverseCurrentDate,  
		@strBatchId,  
		@successfulCount OUTPUT
	
END  


DECLARE @tCount INT
SELECT @tCount = COUNT(*) FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B on A.intLogId = B.intLogId
AND strBatchId = @strBatchId
AND ISNULL(ysnError,0) = 1

IF @tCount = 1
BEGIN
	IF EXISTS (SELECT 1FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B 
		ON A.intLogId = B.intLogId
		AND strBatchId = @strBatchId
		AND strBook = 'GAAP' AND ISNULL(ysnError,0) = 1 
		AND strResult ='Asset already fully depreciated.' )
	
		RETURN 1

	DECLARE @strResult NVARCHAR(200)
	SELECT @strResult = strResult FROM tblFADepreciateLogDetail A JOIN tblFADepreciateLog B on A.intLogId = B.intLogId
	AND strBatchId = @strBatchId
	AND ISNULL(ysnError,0) = 1
	RAISERROR(@strResult, 16, 1)

END
		
	
  
RETURN 1  
  
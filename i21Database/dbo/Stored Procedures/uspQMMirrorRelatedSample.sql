CREATE PROCEDURE dbo.uspQMMirrorRelatedSample   
 @intSampleId INT,
 @intRelatedSampleId INT,
 @intUserId INT =1,
 @strAction NVARCHAR(20)
AS
SET XACT_ABORT ON  
SET NOCOUNT ON  
  
DECLARE @intLogId INT  
DECLARE @intTransactionId INT  
DECLARE @intLoadAuditParentId INT  
DECLARE @strCurrentRelatedSampleId NVARCHAR(20) = ''  
DECLARE @strRelatedSampleId NVARCHAR(20)  
  
IF ISNULL(@intRelatedSampleId,0) <> 0  
 SELECT @strCurrentRelatedSampleId = strSampleNumber from tblQMSample where intSampleId = @intRelatedSampleId  

SELECT @strRelatedSampleId = strSampleNumber from tblQMSample where intSampleId = @intSampleId  
  
  
  
IF ISNULL(@intRelatedSampleId,0) <> 0  
 UPDATE tblQMSample set intRelatedSampleId = @intSampleId where intSampleId = @intRelatedSampleId  
  
--SELECT @strRelatedSampleId = strSampleNumber from tblQMSample where intSampleId = @intRelatedSampleId  
  
DECLARE  @tblBefore TABLE(    
        [strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,    
        [dblSampleQty] [numeric](18, 6) NULL,    
        [strSampleUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strRepresentingUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [dblRepresentingQty] [numeric](18, 6) NULL,    
        [strDescription] [nvarchar](350) COLLATE Latin1_General_CI_AS NULL,    
        [strSampleNote] [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,    
        [strSamplingCriteria] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strRepresentLotNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL    
    )     
DECLARE  @tblAfter TABLE(    
        [strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,    
        [dblSampleQty] [numeric](18, 6) NULL,    
        [strSampleUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strRepresentingUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [dblRepresentingQty] [numeric](18, 6) NULL,    
        [strDescription] [nvarchar](350) COLLATE Latin1_General_CI_AS NULL,    
        [strSampleNote] [nvarchar](512) COLLATE Latin1_General_CI_AS NULL,    
        [strSamplingCriteria] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strRepresentLotNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,    
        [strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL    
    )     
   
IF @strAction = 'Updated'  
BEGIN  
	INSERT INTO @tblBefore(    
			strComment,    
			dblSampleQty,    
			strSampleUOM,    
			strRepresentingUOM,    
			dblRepresentingQty,    
			strDescription,    
			strSampleNote,    
			strSamplingCriteria,    
			strRepresentLotNumber,    
			strItemNo    
		)    
     
		SELECT    
			strComment,    
			dblSampleQty,    
			strSampleUOM,    
			strRepresentingUOM,    
			dblRepresentingQty,    
			strDescription,    
			strSampleNote,    
			strSamplingCriteria,    
			strRepresentLotNumber,    
			strItemNo    
	  FROM vyuQMSampleList    
	 WHERE intSampleId = @intRelatedSampleId    
		UPDATE A SET    
			strComment = B.strComment,    
			dblSampleQty = B.dblSampleQty,    
			intSampleUOMId = B.intSampleUOMId ,    
			intRepresentingUOMId = B.intRepresentingUOMId,    
			dblRepresentingQty = B.dblRepresentingQty,    
			strSampleNote = B.strSampleNote,    
			intSamplingCriteriaId = B.intSamplingCriteriaId,    
			strRepresentLotNumber = B.strRepresentLotNumber,    
			intItemId = B.intItemId    
		FROM tblQMSample  A  
		 OUTER APPLY(  
				SELECT strComment,dblSampleQty,intSampleUOMId,intRepresentingUOMId,
				dblRepresentingQty,strSampleNote,intSamplingCriteriaId,strRepresentLotNumber,
				intItemId
				FROM tblQMSample where intSampleId = @intSampleId  
		 ) B  
		WHERE A.intSampleId  = @intRelatedSampleId 
		INSERT INTO @tblAfter(    
			strComment,    
			dblSampleQty,    
			strSampleUOM,    
			strRepresentingUOM,    
			dblRepresentingQty,    
			strDescription,    
			strSampleNote,    
			strSamplingCriteria,    
			strRepresentLotNumber,    
			strItemNo    
		)    
     
		SELECT     
			strComment,    
			dblSampleQty,    
			strSampleUOM,    
			strRepresentingUOM,    
			dblRepresentingQty,    
			strDescription,    
			strSampleNote,    
			strSamplingCriteria,    
			strRepresentLotNumber,    
			strItemNo    
			FROM vyuQMSampleList    
	 WHERE intSampleId = @intRelatedSampleId    
END  
  
  
    DECLARE @tblAudit TABLE (    
        [strAction]       NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,    
        [strChange]    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,     
        [strFrom]    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,     
        [strTo]     NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NULL,     
        [strAlias]    NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,     
        [ysnField]    BIT,    
        [ysnHidden]    BIT,     
        [intParentAuditId]  INT     NULL,    
        [intOldAuditLogId]  INT     NULL    
    )    
    
    BEGIN    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strComment'    
        ,A.strComment    
        ,B.strComment,     
        'Comment', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strComment <> B.strComment     
     
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'dblSampleQty'    
        ,CAST(A.dblSampleQty AS NVARCHAR(10))    
        ,CAST (B.dblSampleQty AS NVARCHAR(10)),     
        'Sample Qty', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.dblSampleQty <> B.dblSampleQty     
     
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strSampleUOM'    
        ,A.strSampleUOM    
        ,B.strSampleUOM,     
        'Sample UOM', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strSampleUOM <> B.strSampleUOM     
     
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strRepresentingUOM'    
        ,A.strRepresentingUOM    
        ,B.strRepresentingUOM,     
        'Representing UOM', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strRepresentingUOM <> B.strRepresentingUOM     
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'dblRepresentingQty'    
        ,CAST(A.dblRepresentingQty AS NVARCHAR(10))    
        ,CAST (B.dblRepresentingQty AS NVARCHAR(10)),     
        'Representing Qty', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.dblRepresentingQty <> B.dblRepresentingQty     
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strDescription'    
        ,A.strDescription    
        ,B.strDescription    
        ,'Description', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strDescription <> B.strDescription     
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strSampleNote'    
        ,A.strSampleNote    
        ,B.strSampleNote    
        ,'Sample Note', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strSampleNote <> B.strSampleNote     
     
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strSamplingCriteria'    
        ,A.strSamplingCriteria    
        ,B.strSamplingCriteria    
        ,'Sampling Criteria', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strSamplingCriteria <> B.strSamplingCriteria     
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strRepresentLotNumber'    
        ,A.strRepresentLotNumber    
        ,B.strRepresentLotNumber    
        ,'Represent Lot Number', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strRepresentLotNumber <> B.strRepresentLotNumber     
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)    
        SELECT  'strItemNo'    
        ,A.strItemNo    
        ,B.strItemNo    
        ,'Item No.', 1    
        FROM @tblBefore A,@tblAfter B where    
        A.strItemNo <> B.strItemNo     
     
    END    

 IF @strAction = 'Unlink'  
 BEGIN
   INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)   
    SELECT 'strRelatedSampleNumber',   
             ISNULL(@strRelatedSampleId,''),  
             '',  
             'Related Sample Id', 1
	UPDATE tblQMSample set intRelatedSampleId = null where intRelatedSampleId = @intSampleId
END
 ELSE  
 IF @strCurrentRelatedSampleId <> @strRelatedSampleId  and @strAction = 'Establish Link'
    INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)   
    SELECT 'strRelatedSampleNumber',   
             ISNULL(@strCurrentRelatedSampleId,''),  
             @strRelatedSampleId,  
             'Related Sample Id', 1     

IF EXISTS (SELECT 1 FROM @tblAudit)    
BEGIN    
    EXEC uspSMInsertTransaction @screenNamespace = 'Quality.view.QualitySample',   
        @intKeyValue = @intRelatedSampleId,   
        @output = @intTransactionId OUTPUT    

            SELECT @strRelatedSampleId = strSampleNumber from vyuQMSampleList WHERE intSampleId = @intSampleId    

            --Insert to SM Log    
            INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId)     
            VALUES('Audit', GETUTCDATE(), @intUserId, @intTransactionId, 1)    
            SET @intLogId = SCOPE_IDENTITY()    

    DECLARE @strActionDescription nvarchar(100) = 'Updated by mirroring record: ' + @strRelatedSampleId  
    IF @strAction = 'Unlink' set @strActionDescription = 'Unlink from ' + @strRelatedSampleId 
	ELSE IF @strAction = 'Establish Link'
		SET @strActionDescription = 'Establish mirroring with ' + @strRelatedSampleId
    --Insert Load parent Audit entry    
    INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)    
    SELECT @intLogId, @intRelatedSampleId, @strActionDescription, 'Update', 1    
    SET @intLoadAuditParentId = SCOPE_IDENTITY()    

    INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId ,intConcurrencyId)    
    SELECT @intLogId, @intRelatedSampleId, strChange  
        ,strFrom    
        ,strTo    
        ,strAlias, 1,0,     
        @intLoadAuditParentId,1    
    FROM @tblAudit
END 
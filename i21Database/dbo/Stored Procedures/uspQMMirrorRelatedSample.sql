CREATE PROCEDURE dbo.uspQMMirrorRelatedSample 
	@intRelatedSampleId INT
    ,@intUserId INT
	,@strAction NVARCHAR(20)
AS
SET XACT_ABORT ON
SET NOCOUNT ON

IF (@strAction = 'Created')
BEGIN
	EXEC dbo.uspSMAuditLog
		@screenName = 'Quality.view.QualitySample'
		,@keyValue = @intRelatedSampleId
		,@entityId = @intUserId
		,@actionType = 'Created'
		,@actionIcon = 'small-new-plus'
		,@fromValue = ''
		,@toValue = ''
		,@changeDescription = 'Created (from mirroring)'
		,@details = ''
END
ELSE IF (@strAction = 'Updated')
BEGIN
--DECLARE @json NVARCHAR(MAX);
--SET @json = N'{"strRepresentLotNumber":"4556"}';


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
    FROM tblQMSample
    A join
    tblQMSample B
    on A.intRelatedSampleId = B.intSampleId
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

	DECLARE @intLogId INT
		,@intTransactionId INT
		,@intLoadAuditParentId INT

    DECLARE @tblAudit TABLE (
        [strAction]		     NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,
        [strChange]			 NVARCHAR(MAX)	  COLLATE Latin1_General_CI_AS NULL, 
        [strFrom]			 NVARCHAR(MAX)	  COLLATE Latin1_General_CI_AS NULL, 
        [strTo]				 NVARCHAR(MAX)	  COLLATE Latin1_General_CI_AS NULL, 
        [strAlias]			 NVARCHAR(255)	  COLLATE Latin1_General_CI_AS NULL, 
        [ysnField]			 BIT,
        [ysnHidden]			 BIT, 
        [intParentAuditId]	 INT			  NULL,
        [intOldAuditLogId]	 INT			  NULL
    )

	--Get Transaction Id


    --Insert child audit entry

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

    IF EXISTS (SELECT 1 FROM @tblAudit)
    BEGIN

        EXEC uspSMInsertTransaction @screenNamespace = 'Quality.view.QualitySample', @intKeyValue = @intRelatedSampleId, @output = @intTransactionId OUTPUT

        --Insert to SM Log
        INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId) 
        VALUES('Audit', GETUTCDATE(), @intUserId, @intTransactionId, 1)
        SET @intLogId = SCOPE_IDENTITY()

        --Insert Load parent Audit entry
        INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)
        SELECT @intLogId, @intRelatedSampleId, 'Updated', ('Updated (from mirroring) - Record: ' + CAST(@intRelatedSampleId AS nvarchar(20))), 1
        SET @intLoadAuditParentId = SCOPE_IDENTITY()



        INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
        SELECT @intLogId, @intRelatedSampleId,strChange
            ,strFrom
            ,strTo
            ,strAlias, 1,0, 
            @intLoadAuditParentId,1
        FROM @tblAudit

    END

END

GO
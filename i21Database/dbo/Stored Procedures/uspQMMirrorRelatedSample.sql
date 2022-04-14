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
        [strLoadNumber] [nvarchar](100) NULL,
        [strContainerNumber] [nvarchar](100) NULL,
        [strComment] [nvarchar](max) NULL,
        [strSampleRefNo] [nvarchar](30) NULL,
        [dblSampleQty] [numeric](18, 6) NULL,
        [strSampleUOM] [nvarchar](50) NULL,
        [dtmSampleReceivedDate] [datetime] NULL,
        [strSampleNote] [nvarchar](512) NULL,
        [strRefNo] [nvarchar](100) NULL,
        [strMarks] [nvarchar](100) NULL,
        [dtmTestingStartDate] [datetime] NULL,
        [dtmTestingEndDate] [datetime] NULL,
        [dtmSamplingEndDate] [datetime] NULL,
        [strSamplingMethod] [nvarchar](50) NULL,
        [strSubLocationName] [nvarchar](50) NULL,
        [strSamplingCriteria] [nvarchar](50) NULL,
        [strRepresentLotNumber] [nvarchar](50) NULL,
        [strSentBy] [nvarchar](50) NULL
    ) 
DECLARE  @tblAfter TABLE(
         [strLoadNumber] [nvarchar](100) NULL,
        [strContainerNumber] [nvarchar](100) NULL,
        [strComment] [nvarchar](max) NULL,
        [strSampleRefNo] [nvarchar](30) NULL,
        [dblSampleQty] [numeric](18, 6) NULL,
        [strSampleUOM] [nvarchar](50) NULL,
        [dtmSampleReceivedDate] [datetime] NULL,
        [strSampleNote] [nvarchar](512) NULL,
        [strRefNo] [nvarchar](100) NULL,
        [strMarks] [nvarchar](100) NULL,
        [dtmTestingStartDate] [datetime] NULL,
        [dtmTestingEndDate] [datetime] NULL,
        [dtmSamplingEndDate] [datetime] NULL,
        [strSamplingMethod] [nvarchar](50) NULL,
        [strSubLocationName] [nvarchar](50) NULL,
        [strSamplingCriteria] [nvarchar](50) NULL,
        [strRepresentLotNumber] [nvarchar](50) NULL,
        [strSentBy] [nvarchar](50) NULL
    ) 

INSERT INTO @tblBefore(
        strLoadNumber,
        strContainerNumber,
        strComment,
        strSampleRefNo,
        dblSampleQty,
        strSampleUOM,
        dtmSampleReceivedDate,
        strSampleNote,
        strRefNo,
        strMarks,
        dtmTestingStartDate,
        dtmTestingEndDate,
        dtmSamplingEndDate,
        strSamplingMethod,
        strSubLocationName,
        strSamplingCriteria,
        strRepresentLotNumber,
        strSentBy
    )
	
    SELECT 
         strLoadNumber,
        strContainerNumber,
        strComment,
        strSampleRefNo,
        dblSampleQty,
        strSampleUOM,
        dtmSampleReceivedDate,
        strSampleNote,
        strRefNo,
        strMarks,
        dtmTestingStartDate,
        dtmTestingEndDate,
        dtmSamplingEndDate,
        strSamplingMethod,
        strSubLocationName,
        strSamplingCriteria,
        strRepresentLotNumber,
        strSentBy
		FROM vyuQMSampleList
	WHERE intSampleId = @intRelatedSampleId


    UPDATE A SET
        intLoadDetailId = B.intLoadDetailId,
        intLoadDetailContainerLinkId = B.intLoadDetailContainerLinkId,
        strContainerNumber=B.strContainerNumber,
        strComment=B.strComment,
        strSampleRefNo=B.strSampleRefNo,
        dblSampleQty=B.dblSampleQty,
        intSampleUOMId=B.intSampleUOMId,
        dtmSampleReceivedDate=B.dtmSampleReceivedDate,
        strSampleNote=B.strSampleNote,
        strRefNo=B.strRefNo,
        strMarks=B.strMarks,
        dtmTestingStartDate=B.dtmTestingStartDate,
        dtmTestingEndDate=B.dtmTestingEndDate,
        dtmSamplingEndDate=B.dtmSamplingEndDate,
        strSamplingMethod=B.strSamplingMethod,
        intCompanyLocationSubLocationId=B.intCompanyLocationSubLocationId,
        intSamplingCriteriaId=B.intSamplingCriteriaId,
        strRepresentLotNumber=B.strRepresentLotNumber
    FROM tblQMSample
    A join
    tblQMSample B
    on A.intRelatedSampleId = B.intSampleId
    WHERE A.intSampleId  = @intRelatedSampleId

    INSERT INTO @tblAfter(
        strLoadNumber,
        strContainerNumber,
        strComment,
        strSampleRefNo,
        dblSampleQty,
        strSampleUOM,
        dtmSampleReceivedDate,
        strSampleNote,
        strRefNo,
        strMarks,
        dtmTestingStartDate,
        dtmTestingEndDate,
        dtmSamplingEndDate,
        strSamplingMethod,
        strSubLocationName,
        strSamplingCriteria,
        strRepresentLotNumber,
        strSentBy
    )
	
    SELECT 
         strLoadNumber,
        strContainerNumber,
        strComment,
        strSampleRefNo,
        dblSampleQty,
        strSampleUOM,
        dtmSampleReceivedDate,
        strSampleNote,
        strRefNo,
        strMarks,
        dtmTestingStartDate,
        dtmTestingEndDate,
        dtmSamplingEndDate,
        strSamplingMethod,
        strSubLocationName,
        strSamplingCriteria,
        strRepresentLotNumber,
        strSentBy
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
        SELECT  'strLoadNumber'
        ,A.strLoadNumber
        ,B.strLoadNumber, 
        'Load Number', 1 
        FROM @tblBefore A,@tblAfter B where
        A.strLoadNumber <> B.strLoadNumber 

 

        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strContainerNumber'
        ,A.strContainerNumber
        ,B.strContainerNumber, 
        'Container Number', 1
        FROM @tblBefore A,@tblAfter B where
        A.strContainerNumber <> B.strContainerNumber 
 

        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strComment'
        ,A.strComment
        ,B.strComment, 
        'Comment', 1
        FROM @tblBefore A,@tblAfter B where
        A.strComment <> B.strComment 
 

        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strSampleRefNo'
        ,A.strSampleRefNo
        ,B.strSampleRefNo, 
        'Sample RefNo', 1
        FROM @tblBefore A,@tblAfter B where
        A.strSampleRefNo <> B.strSampleRefNo 
 

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
        SELECT  'dtmSampleReceivedDate'
        ,CONVERT(VARCHAR(20),A.dtmSampleReceivedDate,101) 
        ,CONVERT(VARCHAR(20),B.dtmSampleReceivedDate,101)  
        ,'Sample Received Date', 1
        FROM @tblBefore A,@tblAfter B where
        A.dtmSampleReceivedDate <> B.dtmSampleReceivedDate 
 



        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strSampleNote'
        ,A.strSampleNote
        ,B.strSampleNote
        ,'Sample Note', 1
        FROM @tblBefore A,@tblAfter B where
        A.strSampleNote <> B.strSampleNote 
 


        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strRefNo'
        ,A.strRefNo
        ,B.strRefNo
        ,'Ref No', 1
        FROM @tblBefore A,@tblAfter B where
        A.strRefNo <> B.strRefNo 
 
    
        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strMarks'
        ,A.strMarks
        ,B.strMarks
        ,'Marks', 1
        FROM @tblBefore A,@tblAfter B where
        A.strMarks <> B.strMarks 
 



        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strSamplingMethod'
        ,A.strSamplingMethod
        ,B.strSamplingMethod
        ,'Sampling Method', 1
        FROM @tblBefore A,@tblAfter B where
        A.strSamplingMethod <> B.strSamplingMethod 
 

        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'strSubLocationName'
        ,A.strSubLocationName
        ,B.strSubLocationName
        ,'Sub Location Name', 1
        FROM @tblBefore A,@tblAfter B where
        ISNULL(A.strSubLocationName,'') <> ISNULL(B.strSubLocationName ,'')
 

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
        SELECT  'strSentBy'
        ,A.strSentBy
        ,B.strSentBy
        ,'Sent By', 1
        FROM @tblBefore A,@tblAfter B where
        A.strSentBy <> B.strSentBy 
 


        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'dtmTestingStartDate'
        ,CONVERT(VARCHAR(20),A.dtmTestingStartDate,101) 
        ,CONVERT(VARCHAR(20),B.dtmTestingStartDate,101)  
        ,'Testing Start Date', 1
        FROM @tblBefore A,@tblAfter B where
        A.dtmTestingStartDate <> B.dtmTestingStartDate 
 


        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'dtmTestingEndDate'
        ,CONVERT(VARCHAR(20),A.dtmTestingEndDate,101) 
        ,CONVERT(VARCHAR(20),B.dtmTestingEndDate,101)  
        ,'Testing End Date', 1
        FROM @tblBefore A,@tblAfter B where
        A.dtmTestingEndDate <> B.dtmTestingEndDate 
 


        INSERT INTO @tblAudit ( strChange, strFrom, strTo, strAlias, ysnField)
        SELECT  'dtmSamplingEndDate'
        ,CONVERT(VARCHAR(20),A.dtmSamplingEndDate,101) 
        ,CONVERT(VARCHAR(20),B.dtmSamplingEndDate,101)  
        ,'Sampling End Date', 1
        FROM @tblBefore A,@tblAfter B where
        A.dtmSamplingEndDate <> B.dtmSamplingEndDate 
 

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
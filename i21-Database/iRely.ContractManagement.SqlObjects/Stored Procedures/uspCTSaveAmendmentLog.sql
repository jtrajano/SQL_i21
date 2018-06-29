CREATE PROCEDURE [dbo].[uspCTSaveAmendmentLog]
  @intSequenceAmendmentLogId INT
 ,@intUserId				 INT
 ,@ysnSigned				 NVARCHAR(30)
 ,@dtmSigned				 NVARCHAR(30)
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE @details				NVARCHAR(MAX)
	DECLARE @ChildDetails			NVARCHAR(MAX)
	DECLARE @ysnOldSigned			NVARCHAR(30)
	DECLARE @dtmOldSigned			NVARCHAR(30)
	DECLARE @intContractHeaderId	INT
	
	SELECT @intContractHeaderId = intContractHeaderId 
	FROM tblCTSequenceAmendmentLog 
	WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId
	
	IF EXISTS(SELECT 1 FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId AND ISNULL(ysnSigned,0)<> ISNULL(@ysnSigned,0)) AND @ysnSigned IS NOT NULL 
	BEGIN
		SELECT @ysnOldSigned = CASE WHEN ISNULL(ysnSigned,0) = 0 THEN 'false' ELSE 'true' END
		FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId
		
		SET @ysnSigned = CASE WHEN ISNULL(@ysnSigned,0) = 0 THEN 'false' ELSE 'true' END

		SELECT @ChildDetails = '{"change":"Signed","iconCls":"small-gear","from":"'+LTRIM(@ysnOldSigned)+'","to":"' + LTRIM(ISNULL(@ysnSigned,0)) + '","leaf":true}'
	END
	
	IF    EXISTS(SELECT 1 FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId AND dtmSigned IS NULL AND @dtmSigned IS NOT NULL) 
	   OR EXISTS(SELECT 1 FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId AND dtmSigned IS NOT NULL AND @dtmSigned IS NULL) 
	   OR EXISTS(SELECT 1 FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId AND dtmSigned IS NOT NULL AND @dtmSigned IS NOT NULL AND dbo.fnRemoveTimeOnDate(dtmSigned) <> dbo.fnRemoveTimeOnDate(@dtmSigned)) 
	BEGIN
		SELECT @dtmOldSigned = dtmSigned FROM tblCTSequenceAmendmentLog WHERE intSequenceAmendmentLogId = @intSequenceAmendmentLogId
		
		IF ISNULL(@ChildDetails,'') = '' 
			SELECT @ChildDetails = '{"change":"Date Signed","iconCls":"small-gear","from":"'+LTRIM(ISNULL(@dtmOldSigned,''))+'","to":"' + LTRIM(ISNULL(@dtmSigned,''))+ '","leaf":true}'
        ELSE
			SELECT @ChildDetails = @ChildDetails+',{"change":"Date Signed","iconCls":"small-gear","from":"'+LTRIM(ISNULL(@dtmOldSigned,''))+'","to":"' + LTRIM(ISNULL(@dtmSigned,''))+ '","leaf":true}'


	END
	SELECT @ChildDetails
	SELECT	@details = '{"change":"tblCTSequenceAmendmentLogs"
						,"children":[{"action":"Updated","change":"Updated - Record: '+LTRIM(@intSequenceAmendmentLogId)+'",
						 "iconCls":"small-tree-modified",
							"children":['+@ChildDetails+']}]
							,"iconCls":"small-tree-grid"}'

	 EXEC
	 [uspSMAuditLog]
	 @screenName         = 'ContractManagement.view.Contract'			
	,@keyValue           =  @intContractHeaderId			
	,@entityId	         =  @intUserId		
	,@actionType	     = 'Updated' 		
	,@actionIcon	     = 'small-tree-modified'		
	,@changeDescription  = ''  
	,@fromValue			 = ''			
	,@toValue			 = ''			
	,@details			 = @details
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH

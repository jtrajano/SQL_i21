CREATE PROCEDURE [dbo].[uspCTChangeContractStatus]
@strIds					NVARCHAR(MAX),
	@intContractStatusId	INT,
	@intEntityId			INT
AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intId					INT,
			@intContractHeaderid	INT,
			@details 				NVARCHAR(MAX),
			@strOldStatus			NVARCHAR(50),
			@strNewStatus			NVARCHAR(50),
			@intOldContractStatusId	INT

	DECLARE @ids TABLE (intId INT)

	INSERT INTO @ids SELECT * FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> ''
	SELECT @intId = MIN(intId) FROM @ids

	WHILE ISNULL(@intId,0) > 0
	BEGIN
		SELECT	@intContractHeaderid = intContractHeaderId,@intOldContractStatusId = intContractStatusId FROM tblCTContractDetail WHERE intContractDetailId = @intId
		SELECT	@strNewStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intContractStatusId
		SELECT	@strOldStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intOldContractStatusId

		SET @details = '{"change": "tblCTContractDetails","children": [{"action": "Updated","change": "Updated - Record: ' + LTRIM(@intId)+ '","iconCls": "small-tree-modified","children": [{"change": "Contract Status","from": "' + @strOldStatus + '","to": "' + @strNewStatus + ' ","leaf": true,"iconCls": "small-gear"}]}],"iconCls":"small-tree-grid"}';

		EXEC	dbo.uspSMAuditLog
				@keyValue				= @intContractHeaderid,				
				@screenName				= 'ContractManagement.view.Contract', 
				@entityId				= @intEntityId,	
				@actionType				= 'Updated',
				@actionIcon				= 'small-tree-modified',
				@changeDescription		= '',
				@fromValue				= '',
				@toValue				= '',
				@details				= @details 		

		DELETE FROM @ids WHERE intId = @intId 

		SELECT @intId = MIN(intId) FROM @ids
	END

	UPDATE tblCTContractDetail SET intContractStatusId = @intContractStatusId WHERE intContractDetailId IN 
	(SELECT Item FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> '')

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
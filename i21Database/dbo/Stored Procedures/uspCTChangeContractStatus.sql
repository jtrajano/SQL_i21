CREATE PROCEDURE [dbo].[uspCTChangeContractStatus]
	@strIds					NVARCHAR(MAX),
	@intContractStatusId	INT,
	@intEntityId			INT,
	@strIdType				NVARCHAR(50) = 'Detail'
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

	IF @strIdType = 'Detail'
	BEGIN
		INSERT INTO @ids SELECT * FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> ''
	END
	IF @strIdType = 'Header'
	BEGIN
		INSERT INTO @ids SELECT intContractDetailId FROM tblCTContractDetail WHERE intContractHeaderId IN 
							(SELECT * FROM dbo.fnSplitStringWithTrim(@strIds,',') WHERE LTRIM(RTRIM(ISNULL(Item,''))) <> '')
	END

	SELECT @intId = MIN(intId) FROM @ids

	WHILE ISNULL(@intId,0) > 0
	BEGIN
		SELECT	@intContractHeaderid = intContractHeaderId,@intOldContractStatusId = intContractStatusId FROM tblCTContractDetail WHERE intContractDetailId = @intId
		SELECT	@strNewStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intContractStatusId
		SELECT	@strOldStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intOldContractStatusId

		IF @strOldStatus NOT IN ('Open', 'Unconfirmed', 'Re-Open') AND @intContractStatusId = 3
		BEGIN
			RAISERROR('Only Open, Unconfirmed and Re-Open contract can be changed to cancel.',16,1)
		END

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

		SELECT @intId = MIN(intId) FROM @ids WHERE intId > @intId
	END

	UPDATE tblCTContractDetail SET intContractStatusId = @intContractStatusId WHERE intContractDetailId IN  (SELECT intId FROM @ids)

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
CREATE PROCEDURE [dbo].[uspCTChangeContractStatus]
	@strIds					NVARCHAR(MAX),
	@intContractStatusId	INT,
	@intEntityId			INT,
	@strIdType				NVARCHAR(50) = 'Detail'
AS

BEGIN TRY
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intId					INT,
			@intContractHeaderId	INT,
			@details 				NVARCHAR(MAX),
			@strOldStatus			NVARCHAR(50),
			@strNewStatus			NVARCHAR(50),
			@intOldContractStatusId	INT,
			@dblQuantity			NUMERIC(18,6),
			@dblBalance				NUMERIC(18,6),
			@dblScheduleQty			NUMERIC(18,6),
			@intItemId				INT,
			@intItemUOMId			INT,
			@intCommodityUnitMeasureId INT,
			@IntFromUnitMeasureId	INT,
			@intToUnitMeasureId		INT

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
		SELECT	@intContractHeaderId	=	intContractHeaderId,
				@intOldContractStatusId =	intContractStatusId,
				@dblQuantity			=	dblQuantity,
				@dblBalance				=	dblBalance,
				@dblScheduleQty			=	dblScheduleQty,
				@intItemId				=	intItemId,
				@intItemUOMId			=	intItemUOMId
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId		=	@intId

		SELECT	@strNewStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intContractStatusId
		SELECT	@strOldStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @intOldContractStatusId

		IF  @intContractStatusId = 3
		BEGIN
			IF @strOldStatus NOT IN ('Open', 'Unconfirmed', 'Re-Open')
			BEGIN
				RAISERROR('Only Open, Unconfirmed and Re-Open contract can be changed to cancel.',16,1)
			END
			IF ISNULL(@dblQuantity,0) <> ISNULL(@dblBalance,0) OR ISNULL(@dblScheduleQty,0) > 0
			BEGIN
				RAISERROR('Cannot change status of the sequence to cancel as it is used.',16,1)
			END

			SELECT	@IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId
			SELECT	@intCommodityUnitMeasureId	=	intCommodityUnitMeasureId FROM vyuCTContractDetailView WHERE intContractDetailId	=	@intId
			SELECT	@intToUnitMeasureId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityUnitMeasureId = @intCommodityUnitMeasureId
			

			SELECT	@dblQuantity = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@IntFromUnitMeasureId,@intToUnitMeasureId,@dblQuantity * -1)

			UPDATE	tblCTContractHeader
			SET		dblQuantity			=	dblQuantity + @dblQuantity,
					intConcurrencyId	=	intConcurrencyId + 1
			WHERE	intContractHeaderId	=	@intContractHeaderId
		END
		

		SET @details = '{"change": "tblCTContractDetails","children": [{"action": "Updated","change": "Updated - Record: ' + LTRIM(@intId)+ '","iconCls": "small-tree-modified","children": [{"change": "Contract Status","from": "' + @strOldStatus + '","to": "' + @strNewStatus + ' ","leaf": true,"iconCls": "small-gear"}]}],"iconCls":"small-tree-grid"}';

		EXEC	dbo.uspSMAuditLog
				@keyValue				= @intContractHeaderId,				
				@screenName				= 'ContractManagement.view.Contract', 
				@entityId				= @intEntityId,	
				@actionType				= 'Updated',
				@actionIcon				= 'small-tree-modified',
				@changeDescription		= '',
				@fromValue				= '',
				@toValue				= '',
				@details				= @details 		

		UPDATE tblCTContractDetail SET intContractStatusId = @intContractStatusId,intLastModifiedById = @intEntityId WHERE intContractDetailId = @intId

		IF @intContractStatusId IN (3,6)
		BEGIN
			EXEC uspCTCancelOpenLoadSchedule @intId
		END

		EXEC	uspCTCreateDetailHistory @intContractHeaderId = NULL, 
										 @intContractDetailId = @intId,
										 @strSource			  = 'Contract',
										 @strProcess		  = 'Change Contract Status',
										 @intUserId			  = @intEntityId										 

		SELECT @intId = MIN(intId) FROM @ids WHERE intId > @intId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
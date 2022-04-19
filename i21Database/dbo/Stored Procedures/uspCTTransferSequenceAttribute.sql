CREATE PROCEDURE [dbo].[uspCTTransferSequenceAttribute]
	
	@intFromContractDetailId	INT,
	@intToContractDetailId		INT,
	@intUserId					INT

AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@strFromDetails			NVARCHAR(MAX),
			@strToDetails			NVARCHAR(MAX),
			@actionType				NVARCHAR(100),
			@intFromHeaderId		INT,
			@intToHeaderId			INT,
			@strFromContractNumber  NVARCHAR(200),
			@strToContractNumber	NVARCHAR(200),
			@strFromSeq				NVARCHAR(200),
			@strToSeq				NVARCHAR(200)

	SELECT	@intFromHeaderId		=	CH.intContractHeaderId,
			@strFromContractNumber	=	CH.strContractNumber +  ' - ' + LTRIM(CD.intContractSeq),
			@strFromSeq				=	LTRIM(CD.intContractSeq)
	FROM	tblCTContractDetail		CD 
	JOIN	tblCTContractHeader		CH	ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE	CD.intContractDetailId	=	@intFromContractDetailId

	SELECT	@intToHeaderId			=	CH.intContractHeaderId,
			@strToContractNumber	=	CH.strContractNumber +  ' - ' + LTRIM(CD.intContractSeq),
			@strToSeq				=	LTRIM(CD.intContractSeq)
	FROM	tblCTContractDetail		CD 
	JOIN	tblCTContractHeader		CH	ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE	CD.intContractDetailId	=	@intToContractDetailId

	SELECT	@strFromDetails = COALESCE(@strFromDetails+',' ,'') + strFromObj,
			@strToDetails	= COALESCE(@strToDetails+',' ,'') + strToObj
	FROM	(
				SELECT  '{"change":"Sample","iconCls":"small-gear","from":"' + strSampleNumber + '","to":"","leaf":true}' AS strFromObj,
						'{"change":"Sample","iconCls":"small-gear","from":"","to":"' + strSampleNumber + '","leaf":true}' AS strToObj
				FROM	tblQMSample
				WHERE	intContractDetailId = @intFromContractDetailId

				UNION ALL 

				SELECT  '{"change":"Load","iconCls":"small-gear","from":"' + LO.strLoadNumber + '","to":"","leaf":true}' AS strFromObj,
						'{"change":"Load","iconCls":"small-gear","from":"","to":"' + LO.strLoadNumber + '","leaf":true}' AS strToObj
				FROM	tblLGLoad		LO
				JOIN	tblLGLoadDetail	LD	ON	LO.intLoadId = LD.intLoadId
				WHERE	(LD.intPContractDetailId = @intFromContractDetailId OR LD.intSContractDetailId = @intFromContractDetailId)
	)t

	

	IF ISNULL(@strFromDetails,'') <> '' 
	BEGIN
		SELECT	@actionType	=	'Transferred To ' + @strToContractNumber
		SELECT	@strFromDetails = '{"change":"tblCTContractDetails","children":[{"action":"Updated","change":"Sequence: '+@strFromSeq+'","iconCls":"small-tree-modified","children":['+@strFromDetails+']}],"iconCls":"small-tree-grid"}'

		EXEC	uspSMAuditLog	
				@keyValue	=	@intFromHeaderId,
				@screenName =	'ContractManagement.view.Contract',
				@entityId	=	@intUserId,
				@actionType =	@actionType,
				@actionIcon =	'small-tree-modified',
				@details	=	@strFromDetails

		BEGIN TRY
			DECLARE @SingleAuditLogParam SingleAuditLogParam
			INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT 1, '', @actionType, @actionType + ' - Record: ' + CAST(@intFromHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
					UNION ALL
					SELECT 2, '', '', 'tblCTContractDetails', NULL, NULL, NULL, NULL, NULL, 1
					UNION ALL
					SELECT 3, '', 'Updated', 'Sequence: '+@strFromSeq, NULL, NULL, NULL, NULL, NULL, 2

			EXEC uspSMSingleAuditLog 
				@screenName     = 'ContractManagement.view.Contract',
				@recordId       = @intFromHeaderId,
				@entityId       = @intUserId,
				@AuditLogParam  = @SingleAuditLogParam
		END TRY
		BEGIN CATCH
		END CATCH

		SELECT	@actionType	=	'Transferred From ' + @strFromContractNumber
		SELECT	@strToDetails = '{"change":"tblCTContractDetails","children":[{"action":"Updated","change":"Sequence: '+@strToSeq+'","iconCls":"small-tree-modified","children":['+@strToDetails+']}],"iconCls":"small-tree-grid"}'

		EXEC	uspSMAuditLog	
				@keyValue	=	@intToHeaderId,
				@screenName =	'ContractManagement.view.Contract',
				@entityId	=	@intUserId,
				@actionType =	@actionType,
				@actionIcon =	'small-tree-modified',
				@details	=	@strToDetails

		BEGIN TRY
			DECLARE @SingleAuditLogParam2 SingleAuditLogParam
			INSERT INTO @SingleAuditLogParam2 ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT 1, '', @actionType, @actionType + ' - Record: ' + CAST(@intToHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
					UNION ALL
					SELECT 2, '', '', 'tblCTContractDetails', NULL, NULL, NULL, NULL, NULL, 1
					UNION ALL
					SELECT 3, '', 'Updated', 'Sequence: '+@strToSeq, NULL, NULL, NULL, NULL, NULL, 2

			EXEC uspSMSingleAuditLog 
				@screenName     = 'ContractManagement.view.Contract',
				@recordId       = @intToHeaderId,
				@entityId       = @intUserId,
				@AuditLogParam  = @SingleAuditLogParam2
		END TRY
		BEGIN CATCH
		END CATCH
	END

	EXEC uspQMTransferContractSample @intFromContractDetailId, @intToContractDetailId, @intUserId
	EXEC uspLGTransferContractLoads @intFromContractDetailId, @intToContractDetailId, @intUserId

	EXEC	uspCTCreateDetailHistory	@intContractHeaderId = NULL,
										@intContractDetailId = @intFromContractDetailId,
										@strSource			 = 'Contract',
										@strProcess		  	 = 'Transfer Sequence Attribute',
										@intUserId			 = @intUserId
										
	EXEC	uspCTCreateDetailHistory	@intContractHeaderId = NULL,
										@intContractDetailId = @intToContractDetailId,
										@strSource			 = 'Contract',
										@strProcess		  	 = 'Transfer Sequence Atrribute',
										@intUserId			 = @intUserId

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
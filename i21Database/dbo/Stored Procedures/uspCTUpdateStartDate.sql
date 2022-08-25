CREATE PROCEDURE uspCTUpdateStartDate
	@intContractDetailId INT,
	@dtmStartDate DATETIME,
	@intUserId INT

AS

BEGIN

	IF EXISTS (SELECT TOP 1 1 FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId
					AND @dtmStartDate > dtmEndDate)
	BEGIN
		RAISERROR ('Start Date must be earlier than or equal to current end date.', 16, 1)
	END

	DECLARE @intContractHeaderId INT
		, @strDetails NVARCHAR(MAX)
		, @dtmPreviousStartDate DATETIME
		, @dtmPreviousStartDateUTC DATETIME
		, @intContractSeq INT

	SELECT @intContractHeaderId = intContractHeaderId
		, @dtmPreviousStartDate = dtmStartDate
		, @dtmPreviousStartDateUTC = dtmStartDateUTC
		, @intContractSeq = intContractSeq
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intContractDetailId

	UPDATE tblCTContractDetail
	SET dtmStartDate = CAST(FLOOR(CAST(@dtmStartDate AS FLOAT)) AS DATETIME)
		, dtmStartDateUTC = CAST(FLOOR(CAST(@dtmStartDate AS FLOAT)) AS DATETIME)
	WHERE intContractDetailId = @intContractDetailId

	EXEC uspCTCreateDetailHistory
		@intContractHeaderId	= @intContractHeaderId
		, @intContractDetailId	= @intContractDetailId
		, @strSource			= 'Contract'
		, @strProcess			= 'Save Contract'
		, @intUserId			= @intUserId


	SET @strDetails ='{  
						"change":"tblCTContractDetails",
						"children":[  
							{  
							"action":"Updated",
							"change":"Updated - Record: Sequence - ' + CAST(@intContractSeq AS NVARCHAR) + '",
							"keyValue":' + CAST(@intContractSeq AS NVARCHAR) + ',
							"iconCls":"small-tree-modified",
							"children":
								[   
									{  
									"change":"dtmStartDate",
									"from":"' + CAST(@dtmPreviousStartDate AS NVARCHAR) + '",
									"to":"' + CAST(@dtmStartDate AS NVARCHAR) + '",
									"leaf":true,
									"iconCls":"small-gear",
									"isField":true,
									"keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',
									"associationKey":"tblCTContractDetails",
									"changeDescription":"Start Date"
									},
									{  
									"change":"dtmStartDateUTC",
									"from":"' + CAST(@dtmPreviousStartDateUTC AS NVARCHAR) + '",
									"to":"' + CAST(@dtmStartDate AS NVARCHAR) + '",
									"leaf":true,
									"iconCls":"small-gear",
									"isField":true,
									"keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',
									"associationKey":"tblCTContractDetails",
									"changeDescription":"Start Date UTC"
									}
							]
						}
						],
						"iconCls":"small-tree-grid",
						"changeDescription":"Details"
						}'

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
			,@details			 = @strDetails


END
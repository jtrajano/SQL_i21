CREATE PROCEDURE [dbo].[uspCTProcessApprovedContractToFeed]
	@intApprovedContractId	INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX),
			@intContractDetailId INT,
			@intPrevApprovedContractId INT,
			@strModifiedColumns NVARCHAR(MAX),
			@listStr NVARCHAR(MAX),
			@ysnFeedExist BIT = 0,
			@intLastFeedId INT = 0,
			@strSQL NVARCHAR(MAX),
			@strFeedColumns  NVARCHAR(MAX)

		DECLARE	@IdName TABLE (strIdField  NVARCHAR(MAX),strNameField  NVARCHAR(MAX))
		INSERT	INTO @IdName
		SELECT	'intContractBasisId','strContractBasis,strContractBasisDesc'		 UNION ALL
		SELECT	'intSubLocationId','strSubLocation'		 UNION ALL
		SELECT	'intEntityId','strEntityNo'		 UNION ALL
		SELECT	'intTermId'	,'strTerm'		 UNION ALL
		SELECT	'intPurchasingGroupId','strPurchasingGroup'		 UNION ALL
		SELECT	'intItemId','strItemNo'		 UNION ALL
		SELECT	'intStorageLocationId','strStorageLocation'		 UNION ALL
		SELECT	'intCurrencyId'	,'strCurrency'		 UNION ALL
		SELECT	'dblCashPrice'	,'dblCashPrice,dblUnitCashPrice'		 UNION ALL
		SELECT	'intPriceUOMId'	,'strPriceUOM'			 UNION ALL
		SELECT	'intQtyUOMId'	,'strQuantityUOM'	

	SELECT @intContractDetailId = intContractDetailId FROM tblCTApprovedContract WHERE intApprovedContractId = @intApprovedContractId
	
	IF	EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractDetailId = ISNULL(@intContractDetailId,0))
	BEGIN
		SET @ysnFeedExist = 1
		SELECT TOP 1 @intLastFeedId =  intContractFeedId FROM tblCTContractFeed WHERE intContractDetailId = ISNULL(@intContractDetailId,0) ORDER BY intContractFeedId DESC
	END

	IF	@ysnFeedExist = 0 OR 
		EXISTS(SELECT * FROM tblCTContractFeed WHERE intContractFeedId = @intLastFeedId AND ISNULL(strFeedStatus,'') IN (''))
	BEGIN

		DELETE FROM tblCTContractFeed WHERE intContractFeedId = @intLastFeedId
		
		INSERT INTO tblCTContractFeed
		(
				intContractHeaderId,		intContractDetailId,		strCommodityCode,	strCommodityDesc,
				strContractBasis,			strContractBasisDesc,		strSubLocation,		strCreatedBy,
				strCreatedByNo,				strEntityNo,				strTerm,			strPurchasingGroup,
				strContractNumber,			strERPPONumber,				intContractSeq,		strItemNo,
				strStorageLocation,			dblQuantity,				dblCashPrice,		strQuantityUOM,
				dtmPlannedAvailabilityDate,	dblBasis,					strCurrency,		dblUnitCashPrice,
				strPriceUOM,				strRowState,				dtmContractDate,	dtmStartDate,	
				dtmEndDate,					dtmFeedCreated,				strSubmittedBy,		strSubmittedByNo,
				strOrigin
		)
		SELECT	intContractHeaderId,		intContractDetailId,		strCommodityCode,	strCommodityDesc,
				strContractBasis,			strContractBasisDesc,		strSubLocation,		strCreatedBy,
				strCreatedByNo,				strEntityNo,				strTerm,			strPurchasingGroup,
				strContractNumber,			strERPPONumber,				intContractSeq,		strItemNo,
				strStorageLocation,			dblQuantity,				dblCashPrice,		strQuantityUOM,
				dtmPlannedAvailabilityDate,	dblBasis,					strCurrency,		dblUnitCashPrice,	
				strPriceUOM,				'Added',					dtmContractDate,	dtmStartDate,	
				dtmEndDate,					GETDATE(),					strSubmittedBy,		strSubmittedByNo,
				strOrigin
		FROM	vyuCTContractFeed
		WHERE	intContractDetailId = @intContractDetailId

	END
	ELSE
	BEGIN
		SELECT	TOP 1 @intPrevApprovedContractId =  intApprovedContractId 
		FROM	tblCTApprovedContract 
		WHERE	intContractDetailId = ISNULL(@intContractDetailId,0) AND intApprovedContractId <> @intApprovedContractId 
		ORDER BY intApprovedContractId DESC

		EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intApprovedContractId,'intApprovedById,dtmApproved', @strModifiedColumns OUTPUT

		IF ISNULL(@strModifiedColumns,'') <> ''
		BEGIN
				IF OBJECT_ID('tempdb..#Modified') IS NOT NULL  	
					DROP TABLE #Modified

				SELECT * INTO #Modified FROM dbo.fnSplitString(@strModifiedColumns,',')
				
				SELECT	@listStr = COALESCE(@listStr+',' ,'') + ISNULL(strNameField,Item)
				FROM	#Modified A LEFT JOIN @IdName B ON A.Item = B.strIdField


				SELECT	@listStr = 'intContractHeaderId,intContractDetailId,strCommodityCode,strCommodityDesc,strERPPONumber,intContractSeq,' + @listStr 
				
				SELECT	@strFeedColumns = COALESCE(@strFeedColumns+',' ,'') + COLUMN_NAME
				FROM	INFORMATION_SCHEMA.COLUMNS COL 
				WHERE	COL.TABLE_NAME = 'tblCTContractFeed' AND COLUMN_NAME IN (SELECT * FROM dbo.fnSplitString(@listStr,','))
				
				SELECT @strSQL =	'INSERT INTO tblCTContractFeed ('+@strFeedColumns+',strRowState,dtmFeedCreated)
									SELECT	'+@strFeedColumns+',''Modified'',GETDATE()
									FROM	vyuCTContractFeed
									WHERE	intContractDetailId = @intContractDetailId'
				
				
				EXEC sp_executesql @strSQL,N'@intContractDetailId INT', @intContractDetailId =  @intContractDetailId

		END

	END
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
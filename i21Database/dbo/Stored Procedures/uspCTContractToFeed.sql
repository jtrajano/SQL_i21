
Create PROCEDURE [dbo].[uspCTContractToFeed]
	@intContractDetailId	INT
AS

BEGIN TRY


	DECLARE @ErrMsg						NVARCHAR(MAX),
			@strRowState				NVARCHAR(10)

			
			SELECT CAST(@intContractDetailId as varchar)

				SELECT @strRowState= 'Added'
				--DELETE FROM tblCTContractFeed WHERE intContractDetailId = @intContractDetailId
				INSERT INTO tblCTContractFeed
				(
						intContractHeaderId,		intContractDetailId,		strCommodityCode,		strCommodityDesc,
						strContractBasis,			strContractBasisDesc,		strSubLocation,			strCreatedBy,
						strCreatedByNo,				strEntityNo,				strTerm,				strPurchasingGroup,
						strContractNumber,			strERPPONumber,				intContractSeq,			strItemNo,
						strStorageLocation,			dblQuantity,				dblCashPrice,			strQuantityUOM,
						dtmPlannedAvailabilityDate,	dblBasis,					strCurrency,			dblUnitCashPrice,
						strPriceUOM,				strRowState,				dtmContractDate,		dtmStartDate,	
						dtmEndDate,					dtmFeedCreated,				strSubmittedBy,			strSubmittedByNo,
						strOrigin,					dblNetWeight,				strNetWeightUOM,		strVendorAccountNum,
						strTermCode,				strContractItemNo,			strContractItemName,	strERPItemNumber,			
						strERPBatchNumber,			strLoadingPoint,			strPackingDescription,	ysnMaxPrice,
						ysnSubstituteItem,			strLocationName,			strSalesperson,			strSalespersonExternalERPId,	
						strProducer,				intItemId

				)
				SELECT	intContractHeaderId,		intContractDetailId,		strCommodityCode,		strCommodityDesc,
						strContractBasis,			strContractBasisDesc,		strSubLocation,			strCreatedBy,
						strCreatedByNo,				strEntityNo,				strTerm,				strPurchasingGroup,
						strContractNumber,			strERPPONumber,				intContractSeq,			strItemNo,
						strStorageLocation,			dblQuantity,				dblCashPrice,			strQuantityUOM,
						dtmPlannedAvailabilityDate,	dblBasis,					strCurrency,			dblUnitCashPrice,	
						strPriceUOM,				
						CASE WHEN intContractStatusId = 3 THEN 'Delete' ELSE @strRowState END,				
						dtmContractDate,			dtmStartDate,	
						dtmEndDate,					GETDATE(),					strSubmittedBy,			strSubmittedByNo,
						strOrigin,					dblNetWeight,				strNetWeightUOM,		strVendorAccountNum,
						strTermCode,				strContractItemNo,			strContractItemName,	strERPItemNumber,			
						strERPBatchNumber,			strLoadingPoint,			strPackingDescription,	ysnMaxPrice,
						ysnSubstituteItem,			strLocationName,			strSalesperson,			strSalespersonExternalERPId,  
						strProducer,				intItemId

				FROM	vyuCTContractFeed
				WHERE	intContractDetailId = @intContractDetailId
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH


CREATE PROCEDURE [dbo].[uspCTReportContractMotherParkers]
	@xmlParam NVARCHAR(MAX) = NULL    
   
AS

BEGIN TRY  
   
	DECLARE
		@ErrMsg NVARCHAR(MAX),
		@strCompanyName   NVARCHAR(500),  
		@xmlDocumentId   INT,  
		@strIds      NVARCHAR(MAX),
		@strSequenceHistoryId     NVARCHAR(MAX),  
		@type      NVARCHAR(50),
		@intContractHeaderId INT,  
		@intScreenId   INT,  
		@intTransactionId       INT,  
		@IsFullApproved         BIT = 0,
		@FirstApprovalId  INT,  
		@SecondApprovalId       INT,  
		@intApproverGroupId   INT,
		@FirstApprovalSign      VARBINARY(MAX),
		@FirstApprovalName      NVARCHAR(MAX),  
		@SecondApprovalSign     VARBINARY(MAX),  
		@SecondApprovalName     NVARCHAR(MAX),  
		@strContractDocuments NVARCHAR(MAX),
		@ysnFairtrade   BIT = 0,  
		@intContractDetailId  INT,  
		@intPrevApprovedContractId INT,
		@intLastApprovedContractId INT,
		@dtmApproved   DATETIME,  
		@strAmendedColumns   NVARCHAR(MAX),  
		@strDetailAmendedColumns NVARCHAR(MAX),  
		@ysnFeedOnApproval  BIT = 0
     
	IF LTRIM(RTRIM(@xmlParam)) = '' SET @xmlParam = NULL     
        
	DECLARE @temp_xml_table TABLE   
	(    
		[fieldname]  NVARCHAR(50),    
		condition  NVARCHAR(20),          
		[from]   NVARCHAR(50),   
		[to]   NVARCHAR(50),    
		[join]   NVARCHAR(10),    
		[begingroup] NVARCHAR(50),    
		[endgroup]  NVARCHAR(50),    
		[datatype]  NVARCHAR(50)   
	)    
   
	DECLARE @tblSequenceHistoryId TABLE  
	(  
		intSequenceAmendmentLogId INT  
	)
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam    
    
	INSERT INTO @temp_xml_table    
	SELECT *    
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)    
	WITH (    
		[fieldname]  NVARCHAR(50),    
		condition  NVARCHAR(20),          
		[from]   NVARCHAR(50),   
		[to]   NVARCHAR(50),    
		[join]   NVARCHAR(10),    
		[begingroup] NVARCHAR(50),    
		[endgroup]  NVARCHAR(50),    
		[datatype]  NVARCHAR(50)    
	)    
      
	INSERT INTO @temp_xml_table  
	SELECT *    
	FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)    
	WITH (    
		[fieldname]  NVARCHAR(50),    
		condition  NVARCHAR(20),          
		[from]   NVARCHAR(50),   
		[to]   NVARCHAR(50),    
		[join]   NVARCHAR(10),    
		[begingroup] NVARCHAR(50),    
		[endgroup]  NVARCHAR(50),    
		[datatype]  NVARCHAR(50)    
	) 
      
	SELECT @strIds = [from]  
	FROM @temp_xml_table     
	WHERE [fieldname] = 'intContractHeaderId'  
   
	SELECT @strSequenceHistoryId = [from]  
	FROM @temp_xml_table     
	WHERE [fieldname] = 'strSequenceHistoryId'
  
	SELECT @type = [from]  
	FROM @temp_xml_table     
	WHERE [fieldname] = 'Type'  
  
	SELECT TOP 1 @intContractHeaderId = Item FROM dbo.fnSplitString(@strIds,',')  
  
	INSERT INTO @tblSequenceHistoryId  
	(  
		intSequenceAmendmentLogId  
	)  
	SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)  
  
	SELECT @intContractHeaderId = intContractHeaderId  
	FROM tblCTSequenceAmendmentLog WITH (NOLOCK)     
	WHERE intSequenceAmendmentLogId = (SELECT MIN(intSequenceAmendmentLogId) FROM @tblSequenceHistoryId)  
  
	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT @intTransactionId=intTransactionId,@IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId  
  
	SELECT TOP 1 @FirstApprovalId=intApproverId,@intApproverGroupId = intApproverGroupId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' ORDER BY intApprovalId  
	SELECT TOP 1 @SecondApprovalId=intApproverId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' AND (intApproverId <> @FirstApprovalId OR ISNULL(intApproverGroupId,0) <> @intApproverGroupId) ORDER BY intApprovalId  

	SELECT @FirstApprovalSign =  Sig.blbDetail, @FirstApprovalName = ent.strName   
	FROM tblSMSignature Sig  WITH (NOLOCK)
	left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId  
	WHERE Sig.intEntityId=@FirstApprovalId  
  
	SELECT @SecondApprovalSign =Sig.blbDetail, @SecondApprovalName = ent.strName  
	FROM tblSMSignature Sig  WITH (NOLOCK)
	left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId  
	WHERE Sig.intEntityId=@SecondApprovalId   
  
	SELECT @strCompanyName = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM tblSMCompanySetup WITH (NOLOCK)
   
	SELECT @strContractDocuments = STUFF(          
		(
			SELECT CHAR(13)+CHAR(10) + DM.strDocumentName   
			FROM tblCTContractDocument CD   
			JOIN tblICDocument DM WITH (NOLOCK) ON DM.intDocumentId = CD.intDocumentId   
			WHERE CD.intContractHeaderId=CH.intContractHeaderId   
			ORDER BY DM.strDocumentName    
			FOR XML PATH(''), TYPE      
		).value('.','varchar(max)')  
		,1,2, ''        
	)
	FROM tblCTContractHeader CH  
	left join tblCTBookVsEntity be on be.intEntityId = CH.intEntityId  
	WHERE CH.intContractHeaderId = @intContractHeaderId  
 
	IF EXISTS  
	(  
		SELECT TOP 1 1   
		FROM tblCTContractCertification CC  WITH (NOLOCK)  
		JOIN tblCTContractDetail   CH WITH (NOLOCK) ON CC.intContractDetailId = CH.intContractDetailId  
		JOIN tblICCertification   CF WITH (NOLOCK) ON CF.intCertificationId = CC.intCertificationId   
		WHERE UPPER(CF.strCertificationName) = 'FAIRTRADE' AND CH.intContractHeaderId = @intContractHeaderId  
	)  
	BEGIN  
		SET @ysnFairtrade = 1  
	END  
  
	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId  
  
	WHILE ISNULL(@intContractDetailId,0) > 0  
	BEGIN  
		SELECT @intPrevApprovedContractId = NULL, @intLastApprovedContractId = NULL  
		
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId,@dtmApproved = dtmApproved   
		FROM   tblCTApprovedContract  WITH (NOLOCK)  
		WHERE  intContractDetailId = @intContractDetailId AND strApprovalType IN ('Amendment and Approvals','Contract Amendment ') AND ysnApproved = 1  
		ORDER BY intApprovedContractId DESC  
  
		SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId  
		FROM   tblCTApprovedContract  WITH (NOLOCK)  
		WHERE  intContractDetailId = @intContractDetailId AND intApprovedContractId < @intLastApprovedContractId AND ysnApproved = 1  
		ORDER BY intApprovedContractId DESC  
  
		IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL  
		BEGIN  
			EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,  
			intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,  
			intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType,strVendorLotID,ysnApproved,intCertificationId,intLoadingPortId', @strAmendedColumns OUTPUT  
		END  
     
		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId  
	END  
  
	IF @strAmendedColumns IS NULL AND EXISTS(SELECT 1 FROM @tblSequenceHistoryId)  
	BEGIN  
		SELECT  @strAmendedColumns= STUFF(
			(  
				SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))  
				FROM tblCTAmendmentApproval AAP  
				JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId  
				JOIN @tblSequenceHistoryId SH  ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId    
				WHERE ISNULL(AAP.ysnAmendment,0) =1  
				FOR XML PATH('')  
			), 1, 1, ''
		)  
          
		SELECT @strDetailAmendedColumns = STUFF(
			(  
				SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))  
				FROM tblCTAmendmentApproval AAP  
				JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId  
				JOIN @tblSequenceHistoryId SH  ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId   
				WHERE ISNULL(AAP.ysnAmendment,0) =1 AND AAP.intAmendmentApprovalId BETWEEN 7 AND 19  
				FOR XML PATH('')  
			), 1, 1, ''
		)  
  
	END  
  
	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = '' 

	IF @type = 'MULTIPLE'  
	BEGIN  
		SELECT @ErrMsg =  STUFF(
			(  
				SELECT DISTINCT '-' + RIGHT(strContractNumber,3)  
				FROM tblCTContractHeader WITH (NOLOCK)  
				WHERE intContractHeaderId IN (SELECT Item FROM dbo.fnSplitString(@strIds,','))  
				AND intContractHeaderId <> @intContractHeaderId  
				FOR XML PATH('')  
			), 1, 1, ''
		)  
	END

	SELECT
		blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')  
		,strCaption = TP.strContractType + ' Contract:- ' + CH.strContractNumber  
		,dtmContractDate = CH.dtmContractDate  
		,strOtherPartyAddress = case
									when CH.intContractTypeId = 1
									then 'Seller:'
									else 'Buyer:'
								end
								+ CHAR(13)+CHAR(10) +   
								CASE   
								WHEN CH.strReportTo = 'Buyer'
								THEN  
									LTRIM(RTRIM(EC.strEntityName)) + ', '    + CHAR(13)+CHAR(10) +  
									ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +  
									ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'') +  
									CASE
										WHEN @ysnFairtrade = 1
										THEN ISNULL( CHAR(13)+CHAR(10) + 'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
										ELSE ''
									END               
								ELSE  
									LTRIM(RTRIM(EY.strEntityName)) + ', '    + CHAR(13)+CHAR(10) +  
									ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +  
									ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +   
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'') +  
									CASE
										WHEN @ysnFairtrade = 1
										THEN ISNULL( CHAR(13)+CHAR(10) + 'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
										ELSE ''
									END  
								END  
		,strAssociation = 'We confirm having' + CASE WHEN CH.intContractTypeId = 1 THEN ' bought from ' ELSE ' sold to ' END + 'you as follows:'
		,strBuyerRefNo = CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END  
		,strContractBasis = CB.strFreightTerm  
		,strPosition = PO.strPosition  
		,strSellerRefNo = CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END  
		,strLocationName = SQ.strLocationName  
		,strCropYear = CY.strCropYear
		,strCaller =  case
						when CH.intPricingTypeId = 6
						then ''
						else
							CASE
								WHEN LTRIM(RTRIM(SQ.strFixationBy)) = ''
								THEN NULL
								ELSE SQ.strFixationBy
							END
							+ '''s Call vs '
							+ case
									when CH.ysnMultiplePriceFixation = 1 and SQ.dblNoOfLots <= 0
									then convert(nvarchar(20),convert(numeric(10,2),isnull(CH.dblNoOfLots,0.00)))
									else convert(nvarchar(20),convert(numeric(10,2),SQ.dblNoOfLots))
							  end
							+ ' lot(s) '
							+ SQ.strFutureMonth
							+ ' '
							+ SQ.strFutMarketName
					end
		,strPricingLabel = case when CH.intPricingTypeId = 6 then null else 'Pricing' end
		,strPricingLabelColon = case when CH.intPricingTypeId = 6 then null else ':' end
		,strWeight = W1.strWeightGradeDesc  
		,strTerm = TM.strTerm  
		,strGrade = W2.strWeightGradeDesc  
		,strContractDocuments = @strContractDocuments  
		,strPrintableRemarks = CH.strPrintableRemarks  
		,strContractConditions =  case
									when CH.intPricingTypeId = 6
									then ''
									else
										ISNULL(TX.strText,'') 
								end
		,strContractLabel = case when CH.intPricingTypeId = 6 then null else 'Contract' end
		,strContractLabelColon = case when CH.intPricingTypeId = 6 then null else ':' end
		  
		,strBuyer = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END  
		,strSeller = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
		,intContractHeaderId = CH.intContractHeaderId  
		,strDetailAmendedColumns = @strDetailAmendedColumns 
		,blbFirstApprovalSignPurchase = case
											when CH.intContractTypeId = 1
											then @FirstApprovalSign
											else null
										end
		,blbSecondApprovalSignPurchase = case
											 when CH.intContractTypeId = 1
											 then @SecondApprovalSign
											 else null
										 end
		,blbFirstApprovalSignSale = case
										when CH.intContractTypeId = 2
										then @FirstApprovalSign
										else null
									end
		,blbSecondApprovalSignSale = case
										when CH.intContractTypeId = 2
										then @SecondApprovalSign
										else null
									 end
  
	FROM
		tblCTContractHeader CH  
		JOIN tblCTContractType TP WITH (NOLOCK) ON TP.intContractTypeId   = CH.intContractTypeId   
		LEFT JOIN vyuCTEntity EC WITH (NOLOCK) ON EC.intEntityId     = CH.intCounterPartyId AND EC.strEntityType    = 'Customer'      
		LEFT JOIN tblAPVendor VR WITH (NOLOCK) ON VR.intEntityId     = CH.intEntityId      
		LEFT JOIN tblARCustomer CR WITH (NOLOCK) ON CR.intEntityId     = CH.intEntityId  
		JOIN vyuCTEntity EY WITH (NOLOCK) ON EY.intEntityId     = CH.intEntityId AND EY.strEntityType     = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)   
		LEFT JOIN tblCTAssociation AN WITH (NOLOCK) ON AN.intAssociationId    = CH.intAssociationId  
		LEFT JOIN tblSMFreightTerms CB WITH (NOLOCK) ON CB.intFreightTermId    = CH.intFreightTermId      
		LEFT JOIN tblCTPosition PO WITH (NOLOCK) ON PO.intPositionId    = CH.intPositionId
		LEFT JOIN (    
			SELECT  
				ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum,     
				CD.intContractHeaderId,    
				CL.strLocationName,    
				CD.strFixationBy,
				dblNoOfLots = isnull(CD.dblNoOfLots,0.00),    
				strFutMarketName = MA.strFutMarketName,  
				strFutureMonth = convert(nvarchar(3),datename(m,fm.dtmFutureMonthsDate)) + ' ' + convert(nvarchar(4),year(fm.dtmFutureMonthsDate))
			FROM
				tblCTContractDetail  CD  WITH (NOLOCK)    
				JOIN  tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId  = CD.intCompanyLocationId     
				LEFT JOIN tblRKFutureMarket  MA WITH (NOLOCK) ON MA.intFutureMarketId  = CD.intFutureMarketId    
				left join tblRKFuturesMonth fm with (nolock) on fm.intFutureMonthId = CD.intFutureMonthId
		) SQ ON SQ.intContractHeaderId  = CH.intContractHeaderId AND SQ.intRowNum = 1
		LEFT JOIN tblCTCropYear    CY WITH (NOLOCK) ON CY.intCropYearId    = CH.intCropYearId    
		LEFT JOIN tblCTWeightGrade   W1 WITH (NOLOCK) ON W1.intWeightGradeId    = CH.intWeightId       
		LEFT JOIN tblSMTerm     TM WITH (NOLOCK) ON TM.intTermID     = CH.intTermId       
		LEFT JOIN tblCTWeightGrade   W2 WITH (NOLOCK) ON W2.intWeightGradeId    = CH.intGradeId
		LEFT JOIN tblCTContractText			TX	WITH (NOLOCK) ON	TX.intContractTextId			=	CH.intContractTextId		  

	where
		CH.intContractHeaderId = @intContractHeaderId
   
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference  
  
	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0  
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId = @intContractHeaderId  
  
END TRY  
  
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()    
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH  
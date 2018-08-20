CREATE PROCEDURE uspCTReportContractDetailGrain

	@intContractHeaderId	INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intContractDetailId INT
    
	DECLARE @ContractDetailGrain AS TABLE 
	(
		 intContractDetailGrainKey			INT IDENTITY(1, 1)
		,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,dblDetailQuantity					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblPrice							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dtmStartDate						DATE
		,dtmEndDate							DATE
		,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strShipVia							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractHeaderId				INT
		,intContractDetailId				INT
		,lblRemark							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strRemark							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strDetailUnitMeasure				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPriceUOMWithCurrency			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strTerm							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	)

	
	SELECT @intContractDetailId = MIN(intContractDetailId)
	FROM    vyuCTContractDetailView DV
	WHERE	intContractHeaderId	=	@intContractHeaderId ORDER BY MIN(intContractSeq)

	WHILE @intContractDetailId > 0
	BEGIN
		
			INSERT INTO @ContractDetailGrain
			(
				 strItemNo					
				,dblDetailQuantity			
				,dblPrice					
				,dtmStartDate				
				,dtmEndDate					
				,strPricingType				
				,strShipVia					
				,strLocationName			
				,intContractHeaderId
				,intContractDetailId
				,lblRemark		
				,strRemark					
				,strDetailUnitMeasure		
				,strPriceUOMWithCurrency	
				,strCommodityCode			
				,strTerm					
			)
			 SELECT 
			 strItemNo					 = strItemNo
			,dblDetailQuantity			 = dblDetailQuantity
			,dblPrice					 = CASE	
													WHEN intPricingTypeId IN (1,6)	THEN	CAST(ISNULL(dblCashPrice,0) AS DECIMAL(24,2))
													WHEN intPricingTypeId = 2		THEN	CAST(ISNULL(dblBasis,0)		AS DECIMAL(24,2))
													WHEN intPricingTypeId = 3		THEN	CAST(ISNULL(dblFutures,0)	AS DECIMAL(24,2))
													ELSE 0
										   END
			,dtmStartDate				 = dtmStartDate
			,dtmEndDate					 = dtmEndDate
			,strPricingType				 = strPricingType
			,strShipVia					 = strShipVia
			,strLocationName			 = strLocationName
			,intContractHeaderId		 = intContractHeaderId
			,intContractDetailId		 = @intContractDetailId
			,lblRemark					 = NULL
			,strRemark					 = NULL
			,strDetailUnitMeasure		 = strItemUOM
			,strPriceUOMWithCurrency	 = strPriceUOM + ' ' + strCurrency
			,strCommodityCode			 = strCommodityCode
			,strTerm					 = strTerm
			FROM	vyuCTContractDetailView DV
			WHERE	intContractDetailId	=	@intContractDetailId

			INSERT INTO @ContractDetailGrain
			(
				 strItemNo					
				,dblDetailQuantity			
				,dblPrice					
				,dtmStartDate				
				,dtmEndDate					
				,strPricingType				
				,strShipVia					
				,strLocationName			
				,intContractHeaderId
				,intContractDetailId
				,lblRemark		
				,strRemark					
				,strDetailUnitMeasure		
				,strPriceUOMWithCurrency	
				,strCommodityCode			
				,strTerm					
			)
			SELECT 
			 strItemNo			= 'Other Charges'
			,dblDetailQuantity  = Item.strItemNo
			,dblPrice			=	  CASE	
											WHEN CC.strCostMethod IN('Per Unit','Gross Unit') 
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) +' per '										
											
											WHEN CC.strCostMethod = 'Amount'   
												THEN '$ '+LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) +' '
											
											WHEN CC.strCostMethod = 'Percentage'   
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) +' %'
							          END  
            ,dtmStartDate			 = NULL
		    ,dtmEndDate				 = NULL
			,strPricingType			 = NULL
			,strShipVia				 = NULL
			,strLocationName		 = CL.strLocationName
			,intContractHeaderId	 = NULL
			,intContractDetailId	 = @intContractDetailId
			,lblRemark				 = NULL
			,strRemark				 = NULL
			,strDetailUnitMeasure	 = NULL
			,strPriceUOMWithCurrency = CASE	
										WHEN CC.strCostMethod = 'Per Unit' THEN UM.strUnitMeasure+' '+ISNULL(Currency.strCurrency,'')										
										WHEN CC.strCostMethod = 'Amount'   THEN ISNULL(Currency.strCurrency,'')
							          END
			,strCommodityCode		 = CY.strCommodityCode
			,strTerm				 = NULL
			FROM tblCTContractCost   CC
			JOIN tblCTContractDetail CD        ON CD.intContractDetailId = CC.intContractDetailId
			JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
			JOIN    tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN	tblICCommodity						CY	ON	CY.intCommodityId					=		CH.intCommodityId
			JOIN tblICItem			 Item      ON Item.intItemId = CC.intItemId
			LEFT JOIN tblSMCurrency       Currency  ON Currency.intCurrencyID = CC.intCurrencyId
			JOIN tblICItemUOM		 UOM	   ON UOM.intItemUOMId = CC.intItemUOMId
			JOIN tblICUnitMeasure	 UM        ON UM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN	tblICItemUOM		QU ON QU.intItemUOMId			=	CD.intItemUOMId	
			LEFT JOIN	tblICItemUOM		CM ON CM.intUnitMeasureId		=	UOM.intUnitMeasureId AND CM.intItemId =	CD.intItemId 
			
			WHERE CD.intContractDetailId	=	@intContractDetailId AND CC.ysnPrice = 1

			UPDATE tbl 
			SET 
			lblRemark				 = 'Remarks : '
		   ,strRemark				 =  CD.strRemark
			FROM @ContractDetailGrain tbl
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = tbl.intContractDetailId
			WHERE intContractDetailGrainKey = (
													SELECT MAX (intContractDetailGrainKey) 
													FROM @ContractDetailGrain
													WHERE intContractDetailId	=	@intContractDetailId
											   ) 

	  SELECT @intContractDetailId = MIN(intContractDetailId)
	  FROM    vyuCTContractDetailView DV
	  WHERE	intContractHeaderId	=	@intContractHeaderId AND intContractDetailId > @intContractDetailId ORDER BY MIN(intContractSeq)

	END

	SELECT * FROM @ContractDetailGrain ORDER BY intContractDetailGrainKey
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractDetailGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO

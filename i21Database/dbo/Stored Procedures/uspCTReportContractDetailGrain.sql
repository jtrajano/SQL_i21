CREATE PROCEDURE uspCTReportContractDetailGrain

	@intContractHeaderId	INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@intContractDetailId	INT,
			@intDecimalDPR			INT = 0
    
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
		,lblLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractHeaderId				INT
		,intContractDetailId				INT
		,lblRemark							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strRemark							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strDetailUnitMeasure				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPriceUOMWithCurrency			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strTerm							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonthZee					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strQuantity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPrice							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPriceZee						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strQuantityRoth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strQuantityZee						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPriceRoth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	)

	SELECT @intContractDetailId = MIN(intContractDetailId)
	FROM    vyuCTContractDetailView DV
	WHERE	intContractHeaderId	=	@intContractHeaderId ORDER BY MIN(intContractSeq)

	SELECT	@intDecimalDPR = ISNULL(CO.intDecimalDPR ,0)
	FROM	tblCTContractHeader CH
	JOIN	tblICCommodity		CO ON CO.intCommodityId = CH.intCommodityId
	WHERE	CH.intContractHeaderId	=	@intContractHeaderId

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
				,lblLocationName
				,intContractHeaderId
				,intContractDetailId
				,lblRemark		
				,strRemark					
				,strDetailUnitMeasure		
				,strPriceUOMWithCurrency	
				,strCommodityCode			
				,strTerm
				,strFutureMonth
				,strFutureMonthZee
				,strQuantity
				,strPrice
				,strPriceZee
				,strQuantityRoth
				,strQuantityZee
				,strPriceRoth
			)
			 SELECT 
			 strItemNo					 = strItemNo
			,dblDetailQuantity			 = dblDetailQuantity
			,dblPrice					 = CASE	
													WHEN intPricingTypeId IN (1,6)	THEN	CAST(ISNULL(dblCashPrice,0) AS DECIMAL(24,4))
													WHEN intPricingTypeId = 2		THEN	CAST(ISNULL(dblBasis,0)		AS DECIMAL(24,4))
													WHEN intPricingTypeId = 3		THEN	CAST(ISNULL(dblFutures,0)	AS DECIMAL(24,4))
													ELSE 0
										   END
			,dtmStartDate				 = dtmStartDate
			,dtmEndDate					 = dtmEndDate
			,strPricingType				 = strPricingType
			,strShipVia					 = strShipVia
			,strLocationName			 = CASE WHEN CP.strDefaultContractReport = 'GrainLSM' THEN '' ELSE strLocationName  END
			,lblLocationName			 = CASE WHEN CP.strDefaultContractReport = 'GrainLSM' THEN '' ELSE 'Location : '  END 
			,intContractHeaderId		 = intContractHeaderId
			,intContractDetailId		 = @intContractDetailId
			,lblRemark					 = NULL
			,strRemark					 = NULL
			,strDetailUnitMeasure		 = strItemUOM
			,strPriceUOMWithCurrency	 = strPriceUOM + ' ' + strCurrency
			,strCommodityCode			 = CASE	
											WHEN ISNULL(DV.strCommodityCode,'') < > ISNULL(DV.strCommodityDescription,'') THEN DV.strCommodityCode +' - '+ DV.strCommodityDescription										
											ELSE DV.strCommodityCode
							               END	
			,strTerm					 = strTerm
			,strFutureMonth				 = REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ')
			,strFutureMonthZee			 = CASE	WHEN intPricingTypeId = 1 THEN '' ELSE REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ') END
			,strQuantity				 = convert(nvarchar(30),dblDetailQuantity) + ' ' + strItemUOM
			,strPrice					 = convert(nvarchar(30),(CASE	
													WHEN intPricingTypeId IN (1,6)	THEN	CAST(ISNULL(dblCashPrice,0) AS DECIMAL(24,4))
													WHEN intPricingTypeId = 2		THEN	CAST(ISNULL(dblBasis,0)		AS DECIMAL(24,4))
													WHEN intPricingTypeId = 3		THEN	CAST(ISNULL(dblFutures,0)	AS DECIMAL(24,4))
													ELSE 0
										   END)) + ' per ' + strPriceUOM + ' ' + strCurrency
			,strPriceZee				 = CASE	
													WHEN intPricingTypeId IN (1,6)	THEN	dbo.fnCTChangeNumericScale(ISNULL(dblCashPrice,0),@intDecimalDPR)
													WHEN intPricingTypeId = 2		THEN	dbo.fnCTChangeNumericScale(ISNULL(dblBasis,0),@intDecimalDPR)
													WHEN intPricingTypeId = 3		THEN	dbo.fnCTChangeNumericScale(ISNULL(dblFutures,0),@intDecimalDPR)
													ELSE '0'
											END
											+ ' ' + strPriceUOM + ' ' + strCurrency
			,strQuantityRoth			 = convert(nvarchar(30),CAST(ISNULL(dblDetailQuantity,0) AS DECIMAL(24,2))) + ' ' + strItemUOM
			,strQuantityZee				 = REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,dblDetailQuantity),1), '.00','') + ' ' + strItemUOM
			,strPriceRoth				 = convert(nvarchar(30),(CASE	
													WHEN intPricingTypeId IN (1,6)	THEN	CAST(ISNULL(dblCashPrice,0) AS DECIMAL(24,2))
													WHEN intPricingTypeId = 2		THEN	CAST(ISNULL(dblBasis,0)		AS DECIMAL(24,2))
													WHEN intPricingTypeId = 3		THEN	CAST(ISNULL(dblFutures,0)	AS DECIMAL(24,2))
													ELSE 0
										   END)) --+ ' ' + strPriceUOM 
										   + ' ' + strCurrency
			FROM	vyuCTContractDetailView DV
			LEFT JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId = DV.intFutureMonthId
			CROSS JOIN tblCTCompanyPreference   CP
			WHERE	DV.intContractDetailId	=	@intContractDetailId

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
				,strQuantity
				,strPrice
				,strPriceZee
				,strQuantityRoth
				,strQuantityZee
				,strPriceRoth
			)
			SELECT 
			 strItemNo			= 'Other Charges'
			,dblDetailQuantity  = Item.strItemNo
			,dblPrice			=	  CASE	
											WHEN CC.strCostMethod IN('Per Unit','Gross Unit') 
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' per '										
											
											WHEN CC.strCostMethod = 'Amount'   
												THEN '$ '+LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' '
											
											WHEN CC.strCostMethod = 'Percentage'   
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' %'
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
			,strCommodityCode		 = CASE	
											WHEN ISNULL(CY.strCommodityCode,'') < > ISNULL(CY.strDescription,'') THEN CY.strCommodityCode +' - '+ CY.strDescription										
											ELSE CY.strCommodityCode
							          END			
			,strTerm				 = NULL
			,strQuantity				 = Item.strItemNo
			,strPrice					 = (CASE	
											WHEN CC.strCostMethod IN('Per Unit','Gross Unit') 
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' per '										
											
											WHEN CC.strCostMethod = 'Amount'   
												THEN '$ '+LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' '
											
											WHEN CC.strCostMethod = 'Percentage'   
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' %'
											END) + ' ' +
											  (CASE	
												WHEN CC.strCostMethod = 'Per Unit' THEN UM.strUnitMeasure+' '+ISNULL(Currency.strCurrency,'')										
												WHEN CC.strCostMethod = 'Amount'   THEN ISNULL(Currency.strCurrency,'')
											  END)
			,strPriceZee				 = (CASE	
											WHEN CC.strCostMethod IN('Per Unit','Gross Unit') 
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' per '										
											
											WHEN CC.strCostMethod = 'Amount'   
												THEN '$ '+LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' '
											
											WHEN CC.strCostMethod = 'Percentage'   
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,4))) +' %'
											END) + ' ' +
											  (CASE	
												WHEN CC.strCostMethod = 'Per Unit' THEN UM.strUnitMeasure+' '+ISNULL(Currency.strCurrency,'')										
												WHEN CC.strCostMethod = 'Amount'   THEN ISNULL(Currency.strCurrency,'')
											  END)
			,strQuantityRoth			 = Item.strItemNo
			,strQuantityZee				= Item.strItemNo
			,strPriceRoth				 = (CASE	
											WHEN CC.strCostMethod IN('Per Unit','Gross Unit') 
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) + ' ' --' per '
											
											WHEN CC.strCostMethod = 'Amount'   
												THEN '$ ' +LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) + ' '
											
											WHEN CC.strCostMethod = 'Percentage'   
												THEN LTRIM(CAST(CC.dblRate AS DECIMAL(24,2))) + ' %'
											END) + ' ' +
											  (CASE	
												WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(Currency.strCurrency,'')--UM.strUnitMeasure + ' ' + ISNULL(Currency.strCurrency,'')
												WHEN CC.strCostMethod = 'Amount'   THEN ISNULL(Currency.strCurrency,'')
												ELSE ''
											  END)
			FROM		tblCTContractCost			CC
			JOIN		tblCTContractDetail			CD	      ON CD.intContractDetailId  = CC.intContractDetailId
			JOIN		tblSMCompanyLocation		CL	      ON CL.intCompanyLocationId = CD.intCompanyLocationId
			JOIN		tblCTContractHeader			CH        ON CH.intContractHeaderId  = CD.intContractHeaderId
			JOIN		tblICCommodity				CY	      ON CY.intCommodityId		 = CH.intCommodityId
			JOIN		tblICItem				    Item      ON Item.intItemId			 = CC.intItemId
			LEFT JOIN		tblICItemUOM				UOM	      ON UOM.intItemUOMId		 = CC.intItemUOMId
			LEFT JOIN		tblICUnitMeasure			UM        ON UM.intUnitMeasureId	 = UOM.intUnitMeasureId
			LEFT JOIN   tblSMCurrency				Currency  ON Currency.intCurrencyID  = CC.intCurrencyId
			LEFT JOIN	tblICItemUOM				QU        ON QU.intItemUOMId		 = CD.intItemUOMId	
			LEFT JOIN	tblICItemUOM				CM        ON CM.intUnitMeasureId	 = UOM.intUnitMeasureId 
																AND CM.intItemId =	CD.intItemId 
															 			
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

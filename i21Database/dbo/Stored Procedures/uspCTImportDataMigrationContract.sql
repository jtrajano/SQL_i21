CREATE PROCEDURE [dbo].[uspCTImportDataMigrationContract]
	@FileLocation nvarchar(max) = null
AS

	DECLARE
		@guiUniqueId uniqueidentifier = newid()
		,@intUserId int = 1;

	declare @PackingDescription table(
		strPackingDescription nvarchar(50) COLLATE Latin1_General_CI_AS
	);

	declare @RequiredDocuments table(
		strRequiredDocuments nvarchar(50) COLLATE Latin1_General_CI_AS
	);

	declare @RequiredDocumentIds table(
		intDocumentId int
	);

	declare @Certificates table(
		strCertificationIdName nvarchar(100) COLLATE Latin1_General_CI_AS
	);

	declare @CertificateIds table(
		intCertificationId int
		,intContractSeq int
		,intContractHeaderId int
	);

	declare @BasisCost table (
		intConcurrencyId int
		,intPrevConcurrencyId int
		,intContractDetailId int
		,intItemId int
		,strCostMethod nvarchar(100)
		,intCurrencyId int
		,dblRate numeric(18,6)
		,intItemUOMId int
		,ysnAccrue bit
		,ysnMTM bit
		,ysnPrice bit
		,ysnAdditionalCost bit
		,ysnBasis bit
		,ysnReceivable bit
		,ysn15DaysFromShipment bit
		,dblAccruedAmount numeric(18,6)
		,ysnFromBasisComponent bit
		,ysnUnforcasted bit
		,strContractNumber nvarchar(100)
		,intContractSeq int
		,strBasisUnitOfMeasure nvarchar(100)
		,strBasisCost nvarchar(100)
	);

	DECLARE @XML NVARCHAR(MAX)
	DECLARE @intContractHeaderId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @idoc INT
	DECLARE @strTblXML NVARCHAR(MAX)
	DECLARE @intEntityId INT
	DECLARE @intContractDetailId INT
	DECLARE @SQL NVARCHAR(MAX)

	declare
		@intActiveContractImportId int
		,@validationErrorMsg nvarchar(max) = ''
		,@strRequiredDocuments nvarchar(max)
		,@strActiveRequiredDocument nvarchar(max)
		,@intDocumentId int
		,@intActiveContractDetailId int
		,@strCondition nvarchar(100)
		,@intActiveContractSeq int
		,@strCertificationIdName nvarchar(max)
		,@strActiveCertificationIdName nvarchar(100)
		,@intCertificationId int
		,@ysnBasisComponent bit = 0
		,@strBasisCostContractNumber nvarchar(100)
		,@intBasisCostContractSeq int
		,@strBasisCostUnitOfMeasure nvarchar(100)
		,@strBasisCost nvarchar(100)
		;
		
		DECLARE @intContractImportId INT
		DECLARE @intContractTypeId INT
		DECLARE @intContractEntityId INT
		DECLARE @dtmContractDate DATETIME
		DECLARE @intCommodityId INT
		DECLARE @intCommodityUOMId INT
		DECLARE @dblQuantity INT
		DECLARE @intSalespersonId INT
		DECLARE @ysnSigned BIT
		DECLARE @strContractNumber NVARCHAR(200)
		DECLARE @ysnPrinted BIT
		DECLARE @intCropYearId INT
		DECLARE @intPositionId INT
		DECLARE @intPricingTypeId INT
		DECLARE @intCreatedById INT
		DECLARE @dtmCreated DATETIME
		DECLARE @intConcurrencyId INT
		DECLARE @ysnReceivedSignedFixationLetter BIT
		DECLARE @ysnReadOnlyInterCoContract BIT
		DECLARE @Date DATETIME = GETUTCDATE()
		declare
			@intBookId int
			,@strCustomerContract nvarchar(30)
			,@intTermId int
			,@intDaysForFinance int
			,@intGradeId int
			,@intSampleTypeId int
			,@intWeightId int
			,@intAssociationId int
			,@intArbitrationId int
			,@intProducerId int
			,@intFreightTermId int
			,@intCompanyLocationId int
			,@intWarehouseId int
			,@intCountryId int
			;

	BEGIN TRY

		BEGIN TRAN

			SELECT TOP 1 
				@intUserId = intEntityId 
			FROM 
				tblSMUserSecurity 		
			WHERE 
				lower(strUserName) IN ('irelyadmin', 'aussup');

			if (isnull(ltrim(rtrim(@FileLocation)),'') = '')
			begin
				select @FileLocation = 'C:\Import\Contract\Contracts.txt';
			end

			exec('
				BULK INSERT tblCTContractImportTemp
				FROM ''' + @FileLocation + '''
				WITH
				(
					FIRSTROW = 2,
					FIELDTERMINATOR = ''\t'',
					ROWTERMINATOR = ''\n'',
					CODEPAGE = ''ACP'',
					TABLOCK
				)	
			');


			insert into tblCTContractImport (
				strContractType
				,strEntityName
				,strEntityNo
				,strCommodity
				,strContractNumber
				,dtmContractDate
				,strSalesperson
				,strCropYear
				,strPosition
				,strContractStatus
				,intContractSeq
				,strLocationName
				,dtmStartDate
				,dtmEndDate
				,dtmM2MDate
				,strItem
				,dblQuantity
				,strQuantityUOM
				,strPricingType
				,strFutMarketName
				,intMonth
				,intYear
				,dblFutures
				,dblBasis
				,dblCashPrice
				,strCurrency
				,strPriceUOM
				,strRemark
				,strShipperId
				,strShipper
				,strBook
				,strVendorRef
				,strFreightTerm
				,strLoadingPort
				,strDestinationPort
				,strTerms
				,intDaysFOrFinance
				,strGrade
				,strSampleType
				,strWeights
				,strAssociation
				,strArbitration
				,strProducer
				,strRequiredDocuments
				,strPackingDescription
				,strContainerType
				,intNoOfContainers
				,strCertification
				,strCounterCurrency
				,dblFXRate
				,strCashFlowOverride
				,dtmCashFlowDate
				,strMarketZone
				,dblBudgetPrice
				,strBundleItem
				,strCostTerm
				,strMTMPoint
				,dtmHistoricDate
				,strRevolutionCurrencyPair
				,dblHistoricRate
				,strHistoricType
				,strWarehouse
				,guiUniqueId
				,intImportFrom
			)
			select
				strContractType = substring(ltrim(rtrim(src.strContractType)),1,50)
				,strEntityName = substring(ltrim(rtrim(src.strEntityName)),1,100)
				,strEntityNo = substring(ltrim(rtrim(src.strEntityNo)),1,100)
				,strCommodity = substring(ltrim(rtrim(src.strCommodity)),1,100)
				,strContractNumber = substring(ltrim(rtrim(src.strContractNumber)),1,50)
				,dtmContractDate = src.dtmContractDate
				,strSalesperson = substring(ltrim(rtrim(src.strSalesperson)),1,100)
				,strCropYear = substring(ltrim(rtrim(src.strCropYear)),1,100)
				,strPosition = substring(ltrim(rtrim(src.strPosition)),1,100)
				,strContractStatus = substring(ltrim(rtrim(src.strContractStatus)),1,50)
				,intContractSeq = src.intContractSeq
				,strLocationName = substring(ltrim(rtrim(src.strLocationName)),1,100)
				,dtmStartDate = src.dtmStartDate
				,dtmEndDate = src.dtmEndDate
				,dtmM2MDate = src.dtmM2MDate
				,strItem = substring(ltrim(rtrim(src.strItem)),1,256)
				,dblQuantity = src.dblQuantity
				,strQuantityUOM = substring(ltrim(rtrim(src.strQuantityUOM)),1,100)
				,strPricingType = substring(ltrim(rtrim(src.strPricingType)),1,50)
				,strFutMarketName = substring(ltrim(rtrim(src.strFutMarketName)),1,100)
				,intMonth = src.intMonth
				,intYear = src.intYear
				,dblFutures = src.dblFutures
				,dblBasis = src.dblBasis
				,dblCashPrice = src.dblCashPrice
				,strCurrency = substring(ltrim(rtrim(src.strCurrency)),1,50)
				,strPriceUOM = substring(ltrim(rtrim(src.strPriceUOM)),1,50)
				,strRemark = ltrim(rtrim(src.strRemark))
				,strShipperId = substring(ltrim(rtrim(src.strShipperId)),1,100)
				,strShipper = substring(ltrim(rtrim(src.strShipper)),1,100)
				,strBook = substring(ltrim(rtrim(src.strBook)),1,100)
				,strVendorRef = substring(ltrim(rtrim(src.strVendorRef)),1,30)
				,strFreightTerm = substring(ltrim(rtrim(src.strFreightTerm)),1,100)
				,strLoadingPort = substring(ltrim(rtrim(src.strLoadingPort)),1,100)
				,strDestinationPort = substring(ltrim(rtrim(src.strDestinationPort)),1,100)
				,strTerms = substring(ltrim(rtrim(src.strTerms)),1,100)
				,intDaysFOrFinance = src.intDaysFOrFinance
				,strGrade = substring(ltrim(rtrim(src.strGrade)),1,100)
				,strSampleType = substring(ltrim(rtrim(src.strSampleType)),1,100)
				,strWeights = substring(ltrim(rtrim(src.strWeights)),1,100)
				,strAssociation = substring(ltrim(rtrim(src.strAssociation)),1,100)
				,strArbitration = substring(ltrim(rtrim(src.strArbitration)),1,100)
				,strProducer = substring(ltrim(rtrim(src.strProducer)),1,100)
				,strRequiredDocuments = ltrim(rtrim(src.strRequiredDocuments))
				,strPackingDescription = ltrim(rtrim(src.strPackingDescription))
				,strContainerType = substring(ltrim(rtrim(src.strContainerType)),1,100)
				,intNoOfContainers = src.intNoOfContainers
				,strCertification = ltrim(rtrim(src.strCertification))
				,strCounterCurrency = substring(ltrim(rtrim(src.strCounterCurrency)),1,100)
				,dblFXRate = src.dblFXRate
				,strCashFlowOverride = substring(ltrim(rtrim(src.strCashFlowOverride)),1,100)
				,dtmCashFlowDate = src.dtmCashFlowDate
				,strMarketZone = substring(ltrim(rtrim(src.strMarketZone)),1,100)
				,dblBudgetPrice = src.dblBudgetPrice
				,strBundleItem = substring(ltrim(rtrim(src.strBundleItem)),1,100)
				,strCostTerm = substring(ltrim(rtrim(src.strCostTerm)),1,100)
				,strMTMPoint = substring(ltrim(rtrim(src.strMTMPoint)),1,100)
				,dtmHistoricDate = src.dtmHistoricDate
				,strRevolutionCurrencyPair = substring(ltrim(rtrim(src.strRevolutionCurrencyPair)),1,100)
				,dblHistoricRate = src.dblHistoricRate
				,strHistoricType = substring(ltrim(rtrim(src.strHistoricType)),1,100)
				,strWarehouse = substring(ltrim(rtrim(src.strWarehouse)),1,100)
				,guiUniqueId = @guiUniqueId
				,intImportFrom = 2

			from tblCTContractImportTemp src;

			truncate table tblCTContractImportTemp;

			insert into @PackingDescription
			select strPackingDescription = 'Bags' union all
			select strPackingDescription = 'Bulk' union all
			select strPackingDescription = 'Liquid bulk' union all
			select strPackingDescription = 'Cartons' union all
			select strPackingDescription = 'Totes' union all
			select strPackingDescription = 'Cubes'

					
			EXEC sp_xml_preparedocument @idoc OUTPUT, @XML

			IF OBJECT_ID('tempdb..#tmpContractHeader') IS NOT NULL  					
				DROP TABLE #tmpContractHeader					

			SELECT * INTO #tmpContractHeader FROM tblCTContractHeader WHERE 1 = 2

			SELECT @SQL =  STUFF((SELECT ' ALTER TABLE #tmpContractHeader ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
			CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
					WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
					ELSE ''
			END + ' NULL' 
			FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpContractHeader%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME <> 'intContractHeaderId' FOR xml path('')) ,1,1,'')
			
			EXEC sp_executesql @SQL 

			IF OBJECT_ID('tempdb..#tmpContractDetail') IS NOT NULL  					
				DROP TABLE #tmpContractDetail					

			SELECT * INTO #tmpContractDetail FROM tblCTContractDetail WHERE 1 = 2

			SELECT @SQL =  STUFF((SELECT ' ALTER TABLE #tmpContractDetail ALTER COLUMN '+COLUMN_NAME+' ' + DATA_TYPE + 
			CASE	WHEN DATA_TYPE LIKE '%varchar' THEN '('+LTRIM(CHARACTER_MAXIMUM_LENGTH)+')' 
					WHEN DATA_TYPE = 'numeric' THEN '('+LTRIM(NUMERIC_PRECISION)+','+LTRIM(NUMERIC_SCALE)+')'
					ELSE ''
			END + ' NULL' 
			FROM tempdb.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE '#tmpContractDetail%' AND IS_NULLABLE = 'NO' AND COLUMN_NAME <> 'intContractDetailId' FOR xml path('')) ,1,1,'')
			
			EXEC sp_executesql @SQL 

			IF OBJECT_ID('tempdb..#tmpExtracted') IS NOT NULL  					
				DROP TABLE #tmpExtracted	
			
			CREATE TABLE #tmpExtracted
			( intContractImportId INT,
				intContractTypeId			INT,			intEntityId			INT,			dtmContractDate		DATETIME,		strContractNumber	NVARCHAR(100) COLLATE Latin1_General_CI_AS,
				intCommodityId				INT,			intCommodityUOMId	INT,			dblHeaderQuantity	NUMERIC(18,6),	intSalespersonId	INT,
				ysnSigned					BIT,			ysnPrinted			BIT,			intCropYearId		INT,			intPositionId		INT,


				intContractStatusId			INT,			intContractSeq		INT,			dtmStartDate		DATETIME,		dtmEndDate			DATETIME,
				intCompanyLocationId		INT,			intItemId			INT,			intItemUOMId		INT,			dblQuantity			NUMERIC(18,6),
				dblBalance					NUMERIC(18,6),	intPricingTypeId	INT,			intFutureMarketId	INT,			intFutureMonthId	INT,
				dblFutures					NUMERIC(18,6),	dblBasis			NUMERIC(18,6),	dblCashPrice		NUMERIC(18,6),	intPriceItemUOMId	INT,
				intStorageScheduleRuleId	INT,			intCurrencyId		INT,			dtmCreated			DATETIME,		intCreatedById		INT,
				intConcurrencyId			INT,			dblTotalCost		NUMERIC(18,6),	intUnitMeasureId	INT,			strRemark			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
				dtmM2MDate					DATETIME,
				intShipperId int,
				intBookId int,
				strCustomerContract nvarchar(30) COLLATE Latin1_General_CI_AS,
				intFreightTermId int,
				intLoadingPortId int,
				intDestinationPortId int,
				intTermId int,
				intDaysForFinance int,
				intGradeId int,
				intSampleTypeId int,
				intWeightId int,
				intAssociationId int,
				intArbitrationId int,
				intProducerId int,
				strRequiredDocuments nvarchar(max) COLLATE Latin1_General_CI_AS,
				strPackingDescription nvarchar(50) COLLATE Latin1_General_CI_AS,
				intContainerTypeId int,
				intNumberOfContainers int,
				strCertification nvarchar(max) COLLATE Latin1_General_CI_AS,
				intInvoiceCurrencyId int,
				dblRate numeric(18,6),
				ysnCashFlowOverride bit,
				dtmCashFlowDate datetime,
				intMarketZoneId int,
				dblBudgetPrice numeric(18,6),
				intItemBundleId int,
				intCostTermId int,
				intMTMPointId int,
				dtmHistoricalDate datetime,
				intRevaluationCurrencyExchangeRateId int,
				dblHistoricalRate numeric(18,6),
				intHistoricalRateTypeId int,
				intBasisUOMId int,
				dblNoOfLots numeric(18,6),
				intCurrencyExchangeRateId int,
				intMarketUOMId int,
				intItemItemUOMId int,
				intWarehouseId INT, 
				intCountryId INT,
				dblNetWeight numeric(18,6),
				intNetWeightUOMId int
			); 

			IF OBJECT_ID('tempdb..#tmpXMLHeader') IS NOT NULL  					
				DROP TABLE #tmpXMLHeader	

			IF ISNULL(@XML,'') <> ''
			BEGIN
				SELECT	@intEntityId	=	intEntityId
				FROM	OPENXML(@idoc, 'overrides',2)
				WITH
				(
						intEntityId		INT
				)
			END


			INSERT	INTO #tmpExtracted
			(
				intContractImportId, intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblHeaderQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,
				intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
				intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId,dtmM2MDate
				,intShipperId
				,intBookId
				,strCustomerContract
				,intFreightTermId
				,intLoadingPortId
				,intDestinationPortId
				,intTermId
				,intDaysForFinance
				,intGradeId
				,intSampleTypeId
				,intWeightId
				,intAssociationId
				,intArbitrationId
				,intProducerId
				,strRequiredDocuments
				,strPackingDescription
				,intContainerTypeId
				,intNumberOfContainers
				,strCertification
				,intInvoiceCurrencyId
				,dblRate
				,ysnCashFlowOverride
				,dtmCashFlowDate
				,intMarketZoneId
				,dblBudgetPrice
				,intItemBundleId
				,intCostTermId
				,intMTMPointId
				,dtmHistoricalDate
				,intRevaluationCurrencyExchangeRateId
				,dblHistoricalRate
				,intHistoricalRateTypeId
				,intBasisUOMId
				,dblNoOfLots
				,intCurrencyExchangeRateId
				,intMarketUOMId
				,intItemItemUOMId
				,intWarehouseId
				,intCountryId
				,dblNetWeight
				,intNetWeightUOMId
			)
			SELECT	DISTINCT CI.intContractImportId,			intContractTypeId	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 1 ELSE 2 END,
					intEntityId			=	EY.intEntityId,			dtmContractDate				=	CI.dtmContractDate,
					intCommodityId		=	CM.intCommodityId,		intCommodityUOMId			=	CU.intCommodityUnitMeasureId,
					dblHeaderQuantity	=	CI.dblQuantity,			intSalespersonId			=	SY.intEntityId,	
					ysnSigned			=	0,						strContractNumber			=	CI.strContractNumber,
					ysnPrinted			=	0,						intCropYearId				=	CP.intCropYearId,
					intPositionId		=	PN.intPositionId,

					intItemId			=	IM.intItemId,			intItemUOMId				=	QU.intItemUOMId,
					intContractSeq		=	CI.intContractSeq,						intStorageScheduleRuleId	=	NULL,
					dtmEndDate			=	CI.dtmEndDate,			intCompanyLocationId		=	CL.intCompanyLocationId, 
					dblQuantity			=	CI.dblQuantity,			intContractStatusId			=	1,
					dblBalance			=	CI.dblQuantity,			dtmStartDate				=	CI.dtmStartDate,
					intPriceItemUOMId	=	puom.intItemUOMId,		dtmCreated					=	GETDATE(),
					intConcurrencyId	=	1,						intCreatedById				=	@intUserId,
					intFutureMarketId	=	MA.intFutureMarketId,	intFutureMonthId			=	MO.intFutureMonthId,
					dblFutures			=	CI.dblFutures,			dblBasis					=	CI.dblBasis,
					dblCashPrice		=	CI.dblCashPrice,		strRemark					=	CI.strRemark,
					intPricingTypeId	=	pt.intPricingTypeId,
					dblTotalCost		=	CI.dblCashPrice * CI.dblQuantity,
					intCurrencyId		=	CY.intCurrencyID,
					intUnitMeasureId	=	QU.intUnitMeasureId,
					dtmM2MDate 			= 	ISNULL(CI.dtmM2MDate,getdate())
					,intShipperId = s.intEntityId
					,intBookId = b.intBookId
					,strCustomerContract = CI.strVendorRef
					,intFreightTermId = ft.intFreightTermId
					,intLoadingPortId = lp.intCityId
					,intDestinationPortId = dp.intCityId
					,intTermId = t.intTermID
					,intDaysForFinance = CI.intDaysFOrFinance
					,intGradeId = g.intWeightGradeId
					,intSampleTypeId = st.intSampleTypeId
					,intWeightId = w.intWeightGradeId
					,intAssociationId = an.intAssociationId
					,intArbitrationId = ar.intCityId
					,intProducerId = p.intEntityId
					,strRequiredDocuments = CI.strRequiredDocuments
					,strPackingDescription = pd.strPackingDescription
					,intContainerTypeId = ctp.intContainerTypeId
					,intNumberOfContainers = CI.intNoOfContainers
					,strCertification = CI.strCertification
					,intInvoiceCurrencyId = ic.intCurrencyID
					,dblRate = CI.dblFXRate
					,ysnCashFlowOverride = case when upper(CI.strCashFlowOverride) = 'Y' then 1 else 0 end
					,dtmCashFlowDate = CI.dtmCashFlowDate
					,intMarketZoneId = mz.intMarketZoneId
					,dblBudgetPrice = CI.dblBudgetPrice
					,intItemBundleId = ib.intItemId
					,intCostTermId = ctm.intFreightTermId
					,intMTMPointId = mtmp.intMTMPointId
					,dtmHistoricalDate = CI.dtmHistoricDate
					,intRevaluationCurrencyExchangeRateId = cero.intCurrencyExchangeRateId
					,dblHistoricalRate = CI.dblHistoricRate
					,intHistoricalRateTypeId = ert.intCurrencyExchangeRateTypeId
					,intBasisUOMId = puom.intItemUOMId
					,dblNoOfLots = CI.dblQuantity / dbo.fnCTConvertQuantityToTargetItemUOM(IM.intItemId,MA.intUnitMeasureId,IU.intUnitMeasureId, MA.dblContractSize)
					,cp.intCurrencyExchangeRateId
					,intMarketUOMId = MA.intUnitMeasureId
					,intItemItemUOMId = MAUOM.intUnitMeasureId
					,intWarehouseId = wc.intCityId
					,intCountryId = wc.intCountryId
					,dblNetWeight = dbo.fnCTConvertQuantityToTargetItemUOM(IM.intItemId,IU.intUnitMeasureId,nwuom.intUnitMeasureId, CI.dblQuantity)
					,intNetWeightUOMId = nwuom.intItemUOMId

			FROM	tblCTContractImport			CI	LEFT
			JOIN	tblICItem					IM	ON	IM.strItemNo		=	CI.strItem				LEFT
			JOIN	tblICUnitMeasure			IU	ON	IU.strUnitMeasure	=	CI.strQuantityUOM		LEFT
			JOIN	tblICItemUOM				QU	ON	QU.intItemId		=	IM.intItemId		
													AND	QU.intUnitMeasureId	=	IU.intUnitMeasureId		LEFT
			JOIN	tblICCommodity				CM	ON	CM.strCommodityCode	=	CI.strCommodity			LEFT
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CM.intCommodityId	 		
													AND	CU.intUnitMeasureId =	IU.intUnitMeasureId		LEFT
			JOIN	tblSMCurrency				CY	ON	CY.strCurrency		=	CI.strCurrency			LEFT
			JOIN	tblSMCompanyLocation		CL	ON	CL.strLocationName	=	CI.strLocationName		LEFT
			JOIN	tblCTCropYear				CP	ON	CP.strCropYear		=	CI.strCropYear			
													AND	CP.intCommodityId	=	CM.intCommodityId		LEFT
			JOIN	tblCTPosition				PN	ON	PN.strPosition		=	CI.strPosition			LEFT
			JOIN	tblRKFutureMarket			MA	ON	LTRIM(RTRIM(LOWER(MA.strFutMarketName))) =	LTRIM(RTRIM(LOWER(CI.strFutMarketName)))
			left join tblICItemUOM MAUOM on MAUOM.intItemId = IM.intItemId and MAUOM.intUnitMeasureId = MA.intUnitMeasureId
			LEFT
			JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMarketId=	MA.intFutureMarketId
													AND	MONTH(MO.dtmFutureMonthsDate) = CI.intMonth
													AND	((YEAR(MO.dtmFutureMonthsDate) % 100) = CI.intYear or YEAR(MO.dtmFutureMonthsDate) = CI.intYear)		LEFT
			JOIN	vyuCTEntity					EY	ON	EY.strEntityName				=	CI.strEntityName	
													AND ISNULL(EY.strEntityNumber,'')	= ISNULL(CI.strEntityNo,'')	
													AND	EY.strEntityType	=	CASE WHEN CI.strContractType IN ('B','Purchase') THEN 'Vendor' ELSE 'Customer' END LEFT
			JOIN	vyuCTEntity					SY	ON	SY.strEntityName	=	CI.strSalesperson
													AND	SY.strEntityType	=	'Salesperson'	
			left join tblEMEntity s on s.strEntityNo = CI.strShipperId and s.strName = CI.strShipper
			left join tblCTBook b on b.strBook = CI.strBook
			left join tblSMFreightTerms ft on ft.strFreightTerm = CI.strFreightTerm
			left join tblSMCity lp on lp.strCity = CI.strLoadingPort
			left join tblSMCity dp on dp.strCity = CI.strDestinationPort
			left join tblSMTerm t on t.strTerm = CI.strTerms
			left join tblCTWeightGrade g on g.strWeightGradeDesc = CI.strGrade
			left join tblQMSampleType st on st.strSampleTypeName = CI.strSampleType
			left join tblCTWeightGrade w on w.strWeightGradeDesc = CI.strWeights
			left join tblCTAssociation an on an.strName = CI.strAssociation
			left join tblSMCity ar on ar.strCity = CI.strArbitration
			left join tblEMEntity p on p.strName = CI.strProducer
			left join @PackingDescription pd on pd.strPackingDescription = CI.strPackingDescription
			left join tblLGContainerType ctp on ctp.strContainerType = CI.strContainerType
			left join tblSMCurrency ic on ic.strCurrency = CI.strCounterCurrency
			left join tblARMarketZone mz on mz.strMarketZoneCode = CI.strMarketZone
			left join tblICItem ib on ib.strItemNo = CI.strBundleItem
			left join tblSMFreightTerms ctm on ctm.strFreightTerm = CI.strCostTerm
			left join tblCTMTMPoint mtmp on mtmp.strMTMPoint = CI.strMTMPoint
			left join (
				select
					cer.intCurrencyExchangeRateId
					,strCurrencyExchangeRate = 'From ' + fcu.strCurrency + ' To ' + tcu.strCurrency
				from
					tblSMCurrencyExchangeRate cer
					join tblSMCurrency fcu on fcu.intCurrencyID = cer.intFromCurrencyId
					join tblSMCurrency tcu on tcu.intCurrencyID = cer.intToCurrencyId
			)cero on cero.strCurrencyExchangeRate = CI.strRevolutionCurrencyPair
			left join tblSMCurrencyExchangeRateType ert on ert.strCurrencyExchangeRateType = CI.strHistoricType
			left join tblCTPricingType pt on pt.strPricingType = CI.strPricingType
			left join tblSMCurrencyExchangeRate cp on cp.intFromCurrencyId = isnull(ic.intMainCurrencyId,ic.intCurrencyID) and cp.intToCurrencyId = isnull(CY.intMainCurrencyId,CY.intCurrencyID)
			left join tblICUnitMeasure pum on pum.strUnitMeasure = CI.strPriceUOM
			left join tblICItemUOM puom on puom.intItemId = IM.intItemId  and puom.intUnitMeasureId = pum.intUnitMeasureId
			left join tblSMCity wc on wc.strCity = CI.strWarehouse
			left join tblICItemUOM nwuom on nwuom.intItemId = IM.intItemId and nwuom.ysnStockUnit = 1
			WHERE CI.guiUniqueId = @guiUniqueId;

			select @intActiveContractImportId = min(intContractImportId) from tblCTContractImport where guiUniqueId = @guiUniqueId;
			while @intActiveContractImportId is not null
			begin
				select
					@validationErrorMsg = 
					case
					when (isnull(c.strShipperId,'') <> '' or isnull(c.strShipper,'') <> '') and t.intShipperId is null then 'Shipper ID: "' + c.strShipperId + '" with Shipper Name: "' + c.strShipper + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strBook,'') <> '' and t.intBookId is null then 'Book: "' + c.strBook + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strFreightTerm,'') <> '' and t.intFreightTermId is null then 'Freight Term: "' + c.strFreightTerm + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strLoadingPort,'') <> '' and t.intLoadingPortId is null then 'Loading Port: "' + c.strLoadingPort + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strDestinationPort,'') <> '' and t.intDestinationPortId is null then 'Destination Port: "' + c.strDestinationPort + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strTerms,'') <> '' and t.intTermId is null then 'Terms: "' + c.strTerms + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strGrade,'') <> '' and t.intGradeId is null then 'Grade: "' + c.strGrade + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strSampleType,'') <> '' and t.intSampleTypeId is null then 'Sample Type: "' + c.strSampleType + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strWeights,'') <> '' and t.intWeightId is null then 'Weights: "' + c.strWeights + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strAssociation,'') <> '' and t.intAssociationId is null then 'Association: "' + c.strAssociation + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strArbitration,'') <> '' and t.intArbitrationId is null then 'Arbitration: "' + c.strArbitration + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strProducer,'') <> '' and t.intProducerId is null then 'Producer: "' + c.strProducer + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strPackingDescription,'') <> '' and t.strPackingDescription is null then 'Packing Description: "' + c.strPackingDescription + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strContainerType,'') <> '' and t.intContainerTypeId is null then 'Container Type: "' + c.strContainerType + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strCounterCurrency,'') <> '' and t.intInvoiceCurrencyId is null then 'Counter Currency: "' + c.strCounterCurrency + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strCashFlowOverride,'') = 'Y' and t.dtmCashFlowDate is null then 'Missing Cash Flow Date for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strMarketZone,'') <> '' and t.intMarketZoneId is null then 'Market Zone: "' + c.strMarketZone + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strBundleItem,'') <> '' and t.intItemBundleId is null then 'Bundle Item: "' + c.strBundleItem + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strCostTerm,'') <> '' and t.intCostTermId is null then 'Cost Term: "' + c.strCostTerm + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strMTMPoint,'') <> '' and t.intMTMPointId is null then 'MTM Point: "' + c.strMTMPoint + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strRevolutionCurrencyPair,'') <> '' and t.intRevaluationCurrencyExchangeRateId is null then 'Revaluation Currency Pair does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strHistoricType,'') <> '' and t.intHistoricalRateTypeId is null then 'Historic Type: "' + c.strHistoricType + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strLocationName,'') <> '' and t.intCompanyLocationId is null then ' Location: "' + c.strLocationName + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when t.intItemItemUOMId is null then ' Lot Calculation: Future Market UOM is missing in Item UOM for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when t.intPriceItemUOMId is null then 'Price Item UOM: Price Item UOM is missing in Item UOM for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when t.intPricingTypeId = 1 and t.dblFutures is null then 'Missing Futures Price for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when isnull(c.strWarehouse,'') <> '' and t.intWarehouseId is null then ' Warehouse Location: "' + c.strWarehouse + '" does not exists for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					when t.intNetWeightUOMId is null then 'Net Weight UOM: Item "' + c.strItem + '" has no UOM Stock Unit for contract ' + c.strContractNumber + '-' + convert(nvarchar(20),c.intContractSeq) + '.'
					else @validationErrorMsg
					end
				from
					tblCTContractImport c
					join #tmpExtracted t on t.intContractImportId = c.intContractImportId
				where
					c.intContractImportId = @intActiveContractImportId

				if (isnull(@validationErrorMsg,'') <> '')
				begin
					RAISERROR(@validationErrorMsg,16,1);
				end
		
				select @intActiveContractImportId = min(intContractImportId) from tblCTContractImport where guiUniqueId = @guiUniqueId and intContractImportId > @intActiveContractImportId;
			end


			IF EXISTS(SELECT * FROM #tmpExtracted)
			BEGIN

				DECLARE cur CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT DISTINCT	MAX(intContractImportId), intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,MAX(dblHeaderQuantity),intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,MAX(intCreatedById),MAX(dtmCreated),1, 0, 0
					,intBookId
					,strCustomerContract
					,intTermId
					,max(intDaysForFinance)
					,intGradeId
					,intSampleTypeId
					,intWeightId
					,intAssociationId
					,intArbitrationId
					,intProducerId
					,intFreightTermId
					,intCompanyLocationId
					,intWarehouseId
					,intCountryId
				FROM	#tmpExtracted
				GROUP BY intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,
					intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId
					,intBookId
					,strCustomerContract
					,intTermId
					,intGradeId
					,intSampleTypeId
					,intWeightId
					,intAssociationId
					,intArbitrationId
					,intProducerId
					,intFreightTermId
					,intCompanyLocationId
					,intWarehouseId
					,intCountryId

				OPEN cur

				FETCH NEXT FROM cur INTO
					  @intContractImportId
					, @intContractTypeId
					, @intContractEntityId
					, @dtmContractDate
					, @intCommodityId
					, @intCommodityUOMId
					, @dblQuantity
					, @intSalespersonId
					, @ysnSigned
					, @strContractNumber
					, @ysnPrinted
					, @intCropYearId
					, @intPositionId
					, @intPricingTypeId
					, @intCreatedById
					, @dtmCreated
					, @intConcurrencyId
					, @ysnReceivedSignedFixationLetter
					, @ysnReadOnlyInterCoContract
					, @intBookId
					, @strCustomerContract
					, @intTermId
					, @intDaysForFinance
					, @intGradeId
					, @intSampleTypeId
					, @intWeightId
					, @intAssociationId
					, @intArbitrationId
					, @intProducerId
					, @intFreightTermId
					, @intCompanyLocationId
					, @intWarehouseId
					, @intCountryId

				WHILE @@FETCH_STATUS = 0
				BEGIN
					DELETE FROM #tmpContractHeader

					INSERT INTO #tmpContractHeader(intContractTypeId,intEntityId,dtmContractDate,intCommodityId,intCommodityUOMId,dblQuantity,intSalespersonId,ysnSigned,strContractNumber,ysnPrinted,intCropYearId,intPositionId,intPricingTypeId,intCreatedById,dtmCreated,intConcurrencyId, ysnReceivedSignedFixationLetter, ysnReadOnlyInterCoContract
						,intBookId
						,strCustomerContract
						,intTermId
						,intDaysForFinance
						,intGradeId
						,intSampleTypeId
						,intWeightId
						,intAssociationId
						,intArbitrationId
						,intProducerId
						,intFreightTermId
						,intCompanyLocationId
						,intWarehouseId
						,intCountryId
					)
					SELECT @intContractTypeId
						, @intContractEntityId
						, @dtmContractDate
						, @intCommodityId
						, @intCommodityUOMId
						, @dblQuantity
						, @intSalespersonId
						, @ysnSigned
						, @strContractNumber
						, @ysnPrinted
						, @intCropYearId
						, @intPositionId
						, @intPricingTypeId
						, @intCreatedById
						, @dtmCreated
						, @intConcurrencyId
						, @ysnReceivedSignedFixationLetter
						, @ysnReadOnlyInterCoContract
						, @intBookId
						, @strCustomerContract
						, @intTermId
						, @intDaysForFinance
						, @intGradeId
						, @intSampleTypeId
						, @intWeightId
						, @intAssociationId
						, @intArbitrationId
						, @intProducerId
						, @intFreightTermId
						, @intCompanyLocationId
						, @intWarehouseId
						, @intCountryId

					EXEC uspCTGetTableDataInXML '#tmpContractHeader', null, @strTblXML OUTPUT,'tblCTContractHeader'
					EXEC uspCTValidateContractHeader @strTblXML,'Added'

					select @strRequiredDocuments = '';
					delete @RequiredDocumentIds;
					select top 1 @strRequiredDocuments = strRequiredDocuments from #tmpExtracted where strContractNumber = @strContractNumber;
					if (isnull(@strRequiredDocuments,'') <> '')
					begin
						insert into @RequiredDocuments (strRequiredDocuments)
						select distinct Item from fnSplitString(@strRequiredDocuments, ';');

						if exists(select top 1 1 from @RequiredDocuments)
						begin
							select top 1 @strActiveRequiredDocument = strRequiredDocuments from @RequiredDocuments;
							while isnull(@strActiveRequiredDocument,'') <> ''
							begin
								select top 1 @intDocumentId=intDocumentId from tblICDocument where strDocumentName = @strActiveRequiredDocument and intCommodityId = @intCommodityId;
								if (isnull(@intDocumentId,0) = 0)
								begin
									select @validationErrorMsg = 'Document "' + @strActiveRequiredDocument + '" does not exists.';
									RAISERROR(@validationErrorMsg,16,1);
								end
								insert into @RequiredDocumentIds select intDocumentId = @intDocumentId;
								select @intDocumentId = null;

								delete from @RequiredDocuments where strRequiredDocuments = @strActiveRequiredDocument;
								select @strActiveRequiredDocument = '';
								select top 1 @strActiveRequiredDocument = strRequiredDocuments from @RequiredDocuments;
							end
						end
					end

					INSERT INTO tblCTContractHeader (
						  intContractTypeId
						, intEntityId
						, dtmContractDate
						, intCommodityId
						, intCommodityUOMId
						, dblQuantity
						, intSalespersonId
						, ysnSigned
						, strContractNumber
						, ysnPrinted
						, intCropYearId
						, intPositionId
						, intPricingTypeId
						, intCreatedById
						, dtmCreated
						, intConcurrencyId
						, ysnReceivedSignedFixationLetter
						, ysnReadOnlyInterCoContract
						,intBookId
						,strCustomerContract
						,intTermId
						,intDaysForFinance
						,intGradeId
						,intSampleTypeId
						,intWeightId
						,intAssociationId
						,intArbitrationId
						,intProducerId
						,intFreightTermId
						,intCompanyLocationId
						,intINCOLocationTypeId
						,intCountryId
					)
					VALUES (
						  @intContractTypeId
						, @intContractEntityId
						, @dtmContractDate
						, @intCommodityId
						, @intCommodityUOMId
						, @dblQuantity
						, @intSalespersonId
						, @ysnSigned
						, @strContractNumber
						, @ysnPrinted
						, @intCropYearId
						, @intPositionId
						, @intPricingTypeId
						, @intCreatedById
						, @dtmCreated
						, @intConcurrencyId
						, @ysnReceivedSignedFixationLetter
						, @ysnReadOnlyInterCoContract
						, @intBookId
						, @strCustomerContract
						, @intTermId
						, @intDaysForFinance
						, @intGradeId
						, @intSampleTypeId
						, @intWeightId
						, @intAssociationId
						, @intArbitrationId
						, @intProducerId
						, @intFreightTermId
						, @intCompanyLocationId
						, @intWarehouseId
						, @intCountryId
					)

					SET @intContractHeaderId = SCOPE_IDENTITY()

					if exists (select top 1 1 from @RequiredDocumentIds)
					begin
						insert into tblCTContractDocument (intContractHeaderId,intDocumentId,intConcurrencyId,intContractDocumentRefId)
						select intContractHeaderId=@intContractHeaderId,intDocumentId=intDocumentId,intConcurrencyId=1,intContractDocumentRefId=null from @RequiredDocumentIds;
					end

					DELETE FROM #tmpContractDetail

					INSERT	INTO #tmpContractDetail(intContractHeaderId,intItemId,intItemUOMId,intContractSeq,intStorageScheduleRuleId,dtmEndDate,intCompanyLocationId,dblQuantity,intContractStatusId,dblBalance,dtmStartDate,intPriceItemUOMId,dtmCreated,intConcurrencyId,intCreatedById,
						intFutureMarketId,intFutureMonthId,dblFutures,dblBasis,dblCashPrice,strRemark,intPricingTypeId,dblTotalCost,intCurrencyId,intUnitMeasureId,dblNetWeight,intNetWeightUOMId,dtmM2MDate, ysnProvisionalPNL, ysnFinalPNL
						,intShipperId
						,intLoadingPortId
						,intDestinationPortId
						,strPackingDescription
						,intContainerTypeId
						,intNumberOfContainers
						,intInvoiceCurrencyId
						,dblRate
						,ysnCashFlowOverride
						,dtmCashFlowDate
						,intMarketZoneId
						,dblBudgetPrice
						,intItemBundleId
						,intCostTermId
						,intMTMPointId
						,dtmHistoricalDate
						,intRevaluationCurrencyExchangeRateId
						,dblHistoricalRate
						,intHistoricalRateTypeId
						,intBasisUOMId
					)
					SELECT
						  @intContractHeaderId
						, intItemId
						, intItemUOMId
						, intContractSeq
						, intStorageScheduleRuleId
						, dtmEndDate
						, intCompanyLocationId
						, dblQuantity
						, intContractStatusId
						, dblBalance
						, dtmStartDate
						, intPriceItemUOMId
						, dtmCreated
						, intConcurrencyId
						, intCreatedById
						, intFutureMarketId
						, intFutureMonthId
						, dblFutures
						, dblBasis
						, dblCashPrice
						, strRemark
						, intPricingTypeId
						, dblTotalCost
						, intCurrencyId
						, intUnitMeasureId
						, dblNetWeight
						, intNetWeightUOMId
						, dtmM2MDate
						, 0
						, 0
						,intShipperId
						,intLoadingPortId
						,intDestinationPortId
						,strPackingDescription
						,intContainerTypeId
						,intNumberOfContainers
						,intInvoiceCurrencyId
						,dblRate
						,ysnCashFlowOverride
						,dtmCashFlowDate
						,intMarketZoneId
						,dblBudgetPrice
						,intItemBundleId
						,intCostTermId
						,intMTMPointId
						,dtmHistoricalDate
						,intRevaluationCurrencyExchangeRateId
						,dblHistoricalRate
						,intHistoricalRateTypeId
						,intBasisUOMId
					FROM #tmpExtracted
					WHERE
							ISNULL(intContractTypeId, 0) = ISNULL(@intContractTypeId, 0)
						AND ISNULL(intEntityId, 0) = ISNULL(@intContractEntityId, 0)
						AND ISNULL(dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
						AND ISNULL(intCommodityId, 0) = ISNULL(@intCommodityId, 0)
						AND ISNULL(intCommodityUOMId, 0) = ISNULL(@intCommodityUOMId, 0)
						AND ISNULL(dblQuantity, 0) = ISNULL(@dblQuantity, 0)
						AND ISNULL(intSalespersonId, 0) = ISNULL(@intSalespersonId, 0)
						AND ISNULL(ysnSigned, 0) = ISNULL(@ysnSigned, 0)
						AND ISNULL(strContractNumber, '') = ISNULL(@strContractNumber, '')
						AND ISNULL(ysnPrinted, 0) = ISNULL(@ysnPrinted, 0)
						AND ISNULL(intCropYearId, 0) = ISNULL(@intCropYearId, 0)
						AND ISNULL(intPositionId, 0) = ISNULL(@intPositionId, 0)
						AND ISNULL(intPricingTypeId, 0) = ISNULL(@intPricingTypeId, 0)

					if exists (select top 1 1 from #tmpContractDetail)
					begin
						select @intActiveContractDetailId=min(intContractDetailId) from #tmpContractDetail;
						while (isnull(@intActiveContractDetailId,0) > 0)
						begin
							select @strCondition = ' intContractDetailId='+convert(nvarchar(20),@intActiveContractDetailId)+' ';

							EXEC uspCTGetTableDataInXML '#tmpContractDetail', @strCondition, @strTblXML OUTPUT,'tblCTContractDetail'
							EXEC uspCTValidateContractDetail @strTblXML, 'Added'

							select @intActiveContractSeq=intContractSeq from #tmpContractDetail where intContractDetailId = @intActiveContractDetailId;
					

							select @strCertificationIdName = '';
							delete @Certificates;
							select top 1 @strCertificationIdName = strCertification from #tmpExtracted where strContractNumber = @strContractNumber and intContractSeq = @intActiveContractSeq;
							if (isnull(@strCertificationIdName,'') <> '')
							begin
								insert into @Certificates (strCertificationIdName)
								select distinct Item from fnSplitString(@strCertificationIdName, ';');

								if exists(select top 1 1 from @Certificates)
								begin
									select top 1 @strActiveCertificationIdName = strCertificationIdName from @Certificates;
									while isnull(@strActiveCertificationIdName,'') <> ''
									begin
										select top 1 @intCertificationId=intCertificationId from tblICCertification where strCertificationName = @strActiveCertificationIdName and ysnMultiple = 0;
										if (isnull(@intCertificationId,0) = 0)
										begin
											select @validationErrorMsg = 'Certification "' + @strActiveCertificationIdName + '" does not exists.';
											RAISERROR(@validationErrorMsg,16,1);
										end
										insert into @CertificateIds select intCertificationId = @intCertificationId, intContractSeq = @intActiveContractSeq, intContractHeaderId = @intContractHeaderId;
										select @intCertificationId = null;

										delete from @Certificates where strCertificationIdName = @strActiveCertificationIdName;
										select @strActiveCertificationIdName = '';
										select top 1 @strActiveCertificationIdName = strCertificationIdName from @Certificates;
									end
								end
							end

							select @intActiveContractDetailId=min(intContractDetailId) from #tmpContractDetail where intContractDetailId > @intActiveContractDetailId;
						end
				
					end

					INSERT INTO tblCTContractDetail (
						intContractHeaderId
						, intItemId
						, intItemUOMId
						, intContractSeq
						, intStorageScheduleRuleId
						, dtmEndDate
						, intCompanyLocationId
						, dblQuantity
						, intContractStatusId
						, dblBalance
						, dtmStartDate
						, intPriceItemUOMId
						, dtmCreated
						, intConcurrencyId
						, intCreatedById
						, intFutureMarketId
						, intFutureMonthId
						, dblFutures
						, dblBasis
						, dblCashPrice
						, strRemark
						, intPricingTypeId
						, intCurrencyId
						, intUnitMeasureId
						, dblNetWeight
						, intNetWeightUOMId
						, dtmM2MDate
						, ysnProvisionalPNL
						, ysnFinalPNL
						,intShipperId
						,intLoadingPortId
						,intDestinationPortId
						,strPackingDescription
						,intContainerTypeId
						,intNumberOfContainers
						,intInvoiceCurrencyId
						,dblRate
						,ysnCashFlowOverride
						,dtmCashFlowDate
						,intMarketZoneId
						,dblBudgetPrice
						,intItemBundleId
						,intCostTermId
						,intMTMPointId
						,dtmHistoricalDate
						,intRevaluationCurrencyExchangeRateId
						,dblHistoricalRate
						,intHistoricalRateTypeId
						,intBookId
						,strLoadingPointType
						,strDestinationPointType
						,intBasisCurrencyId
						,intBasisUOMId
						,dblTotalBudget
						,dblTotalCost
						,dblNoOfLots
						,intCurrencyExchangeRateId
						)
					SELECT
							@intContractHeaderId
						, intItemId
						, intItemUOMId
						, intContractSeq
						, intStorageScheduleRuleId
						, dtmEndDate
						, intCompanyLocationId
						, dblQuantity
						, intContractStatusId
						, dblBalance
						, dtmStartDate
						, intPriceItemUOMId
						, dtmCreated
						, intConcurrencyId
						, intCreatedById
						, intFutureMarketId
						, intFutureMonthId
						, dblFutures
						, dblBasis
						, dblCashPrice = case when intPricingTypeId = 1 then isnull(dblBasis,0) + isnull(dblFutures,0) else dblCashPrice end
						, strRemark
						, intPricingTypeId
						, intCurrencyId
						, intUnitMeasureId
						, dblNetWeight
						, intNetWeightUOMId
						, dtmM2MDate
						, 0
						, 0
						,intShipperId
						,intLoadingPortId
						,intDestinationPortId
						,strPackingDescription
						,intContainerTypeId
						,intNumberOfContainers
						,intInvoiceCurrencyId
						,dblRate
						,ysnCashFlowOverride
						,dtmCashFlowDate
						,intMarketZoneId
						,dblBudgetPrice
						,intItemBundleId
						,intCostTermId
						,intMTMPointId
						,dtmHistoricalDate
						,intRevaluationCurrencyExchangeRateId
						,dblHistoricalRate
						,intHistoricalRateTypeId
						,intBookId
						,strLoadingPointType = case when isnull(intLoadingPortId,0) <> 0 then 'Port' else null end
						,strDestinationPointType = case when isnull(intDestinationPortId,0) <> 0 then 'Port' else null end
						,intBasisCurrencyId = intCurrencyId
						,intBasisUOMId = intBasisUOMId
						,dblTotalBudget = case when isnull(dblBudgetPrice,0) <> 0 then dbo.fnCTConvertQtyToTargetItemUOM(intItemItemUOMId,intPriceItemUOMId, dblQuantity) * (isnull(dblBudgetPrice,0) + isnull(dblBasis,0)) else null end
						,dblTotalCost = case when intPricingTypeId = 1 then dbo.fnCTConvertQtyToTargetItemUOM(intItemItemUOMId,intPriceItemUOMId, dblQuantity) * (isnull(dblBasis,0) + isnull(dblFutures,0)) when intPricingTypeId = 6 then dbo.fnCTConvertQtyToTargetItemUOM(intItemItemUOMId,intPriceItemUOMId, dblQuantity) * isnull(dblCashPrice,1) else null end
						,dblNoOfLots = case when round(1*dblNoOfLots,0) = 0 then 1 else round(1*dblNoOfLots,0) end
						,intCurrencyExchangeRateId
					FROM #tmpExtracted
					WHERE
							ISNULL(intContractTypeId, 0) = ISNULL(@intContractTypeId, 0)
						AND ISNULL(intEntityId, 0) = ISNULL(@intContractEntityId, 0)
						AND ISNULL(dtmContractDate, @Date) = ISNULL(@dtmContractDate, @Date)
						AND ISNULL(intCommodityId, 0) = ISNULL(@intCommodityId, 0)
						AND ISNULL(intCommodityUOMId, 0) = ISNULL(@intCommodityUOMId, 0)
						AND ISNULL(intSalespersonId, 0) = ISNULL(@intSalespersonId, 0)
						AND ISNULL(ysnSigned, 0) = ISNULL(@ysnSigned, 0)
						AND ISNULL(strContractNumber, '') = ISNULL(@strContractNumber, '')
						AND ISNULL(ysnPrinted, 0) = ISNULL(@ysnPrinted, 0)
						AND ISNULL(intCropYearId, 0) = ISNULL(@intCropYearId, 0)
						AND ISNULL(intPositionId, 0) = ISNULL(@intPositionId, 0)
						AND ISNULL(intPricingTypeId, 0) = ISNULL(@intPricingTypeId, 0)

					if exists (select top 1 1 from @CertificateIds)
					begin
						insert into tblCTContractCertification (intCertificationId,intContractDetailId,intConcurrencyId)
						select intCertificationId=c.intCertificationId,intContractDetailId=cd.intContractDetailId,intConcurrencyId=1
						from
							tblCTContractDetail cd
							join @CertificateIds c on c.intContractSeq = cd.intContractSeq and c.intContractHeaderId = cd.intContractHeaderId
						where
							cd.intContractHeaderId = @intContractHeaderId
					end

					set @ysnBasisComponent = 0;
					select @ysnBasisComponent = case when @intContractTypeId = 1 then isnull(ysnBasisComponentPurchase,0) else isnull(ysnBasisComponentSales,0) end from tblCTCompanyPreference;
					if (@ysnBasisComponent = 1)
					begin
						if not exists (select top 1 1 from tblCTBasisCost)
						begin
							set @ErrMsg = 'No available Basis Cost for ' + case when @intContractTypeId = 1 then 'purchase contract.' else 'sale contract.' end;
							RAISERROR(@ErrMsg, 16, 1)
						end

						delete @BasisCost;

						insert @BasisCost(
							intConcurrencyId
							,intPrevConcurrencyId
							,intContractDetailId
							,intItemId
							,strCostMethod
							,intCurrencyId
							,dblRate
							,intItemUOMId
							,ysnAccrue
							,ysnMTM
							,ysnPrice
							,ysnAdditionalCost
							,ysnBasis
							,ysnReceivable
							,ysn15DaysFromShipment
							,dblAccruedAmount
							,ysnFromBasisComponent
							,ysnUnforcasted

							,strContractNumber
							,intContractSeq
							,strBasisUnitOfMeasure
							,strBasisCost
						)
						select
							intConcurrencyId = 1
							,intPrevConcurrencyId = 0
							,intContractDetailId = cd.intContractDetailId
							,intItemId = bc.intItemId
							,strCostMethod = bc.strCostMethod
							,intCurrencyId = cd.intCurrencyId
							,dblRate = cd.dblBasis
							,intItemUOMId = uom.intItemUOMId
							,ysnAccrue = 0
							,ysnMTM = 0
							,ysnPrice = 0
							,ysnAdditionalCost = 0
							,ysnBasis = 1
							,ysnReceivable = 0
							,ysn15DaysFromShipment = 0
							,dblAccruedAmount = 0
							,ysnFromBasisComponent = 1
							,ysnUnforcasted = 0

							,strContractNumber = @strContractNumber
							,cd.intContractSeq
							,strBasisUnitOfMeasure = um.strUnitMeasure
							,strBasisCost = bc.strItemNo
						from tblCTContractDetail cd
						outer apply (select top 1 * from tblCTBasisCost order by intSort) bc
						left join tblICItemUOM buom on buom.intItemUOMId = cd.intBasisUOMId
						left join tblICUnitMeasure um on um.intUnitMeasureId = buom.intUnitMeasureId
						left join tblICItemUOM uom on uom.intItemId = bc.intItemId and uom.intUnitMeasureId = buom.intUnitMeasureId
						where cd.intContractHeaderId = @intContractHeaderId and isnull(cd.dblBasis,0) <> 0;

						select
							@strBasisCostContractNumber = null
							,@intBasisCostContractSeq = null
							,@strBasisCostUnitOfMeasure = null
							,@strBasisCost = null

						select top 1
							@strBasisCostContractNumber = strContractNumber
							,@intBasisCostContractSeq = intContractSeq
							,@strBasisCostUnitOfMeasure = strBasisUnitOfMeasure
							,@strBasisCost = strBasisCost
						from
							@BasisCost
						where
							isnull(intItemUOMId,0) = 0;

						if (isnull(@strBasisCostContractNumber,'') <> '')
						begin
							set @ErrMsg = 'Basis Cost: ' + @strBasisCostUnitOfMeasure + ' UOM does not exists in ' + @strBasisCost + ' Basis Cost for contract ' + @strBasisCostContractNumber + '-' + convert(nvarchar(20),@intBasisCostContractSeq) + '.';
							RAISERROR(@ErrMsg, 16, 1)
						end

						insert into tblCTContractCost (
							intConcurrencyId
							,intPrevConcurrencyId
							,intContractDetailId
							,intItemId
							,strCostMethod
							,intCurrencyId
							,dblRate
							,intItemUOMId
							,ysnAccrue
							,ysnMTM
							,ysnPrice
							,ysnAdditionalCost
							,ysnBasis
							,ysnReceivable
							,ysn15DaysFromShipment
							,dblAccruedAmount
							,ysnFromBasisComponent
							--,ysnUnforcasted
						)
						select
							intConcurrencyId
							,intPrevConcurrencyId
							,intContractDetailId
							,intItemId
							,strCostMethod
							,intCurrencyId
							,dblRate
							,intItemUOMId
							,ysnAccrue
							,ysnMTM
							,ysnPrice
							,ysnAdditionalCost
							,ysnBasis
							,ysnReceivable
							,ysn15DaysFromShipment
							,dblAccruedAmount
							,ysnFromBasisComponent
							--,ysnUnforcasted
						from
							@BasisCost

					end

					UPDATE tblCTContractHeader
					SET dblQuantity = (SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId)
					WHERE intContractHeaderId = @intContractHeaderId

					EXEC uspCTCreateDetailHistory	@intContractHeaderId = @intContractHeaderId, 
													@intContractDetailId = NULL,
													@strSource			 = 'Contract',
													@strProcess		     = 'Create Contract',
													@intUserId			 = @intUserId

					UPDATE	tblCTContractImport
					SET		ysnImported				=	1,
							intImportedById			=	@intUserId,
							dtmImported				=	GETDATE(),
							intContractHeaderId		=	@intContractHeaderId,
							ysnIsProcessed			=   1
					WHERE	guiUniqueId = @guiUniqueId AND intContractImportId = @intContractImportId

					FETCH NEXT FROM cur INTO
						  @intContractImportId
						, @intContractTypeId
						, @intContractEntityId
						, @dtmContractDate
						, @intCommodityId
						, @intCommodityUOMId
						, @dblQuantity
						, @intSalespersonId
						, @ysnSigned
						, @strContractNumber
						, @ysnPrinted
						, @intCropYearId
						, @intPositionId
						, @intPricingTypeId
						, @intCreatedById
						, @dtmCreated
						, @intConcurrencyId
						, @ysnReceivedSignedFixationLetter
						, @ysnReadOnlyInterCoContract
						, @intBookId
						, @strCustomerContract
						, @intTermId
						, @intDaysForFinance
						, @intGradeId
						, @intSampleTypeId
						, @intWeightId
						, @intAssociationId
						, @intArbitrationId
						, @intProducerId
						, @intFreightTermId
						, @intCompanyLocationId
						, @intWarehouseId
						, @intCountryId

					END

					CLOSE cur;
					DEALLOCATE cur;
				END

				select [Import Status] = 'Successful.';

		COMMIT TRAN;

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		SET @ErrMsg = ERROR_MESSAGE();
		select [Import Status]= 'Failed: ' + @ErrMsg;
	END CATCH

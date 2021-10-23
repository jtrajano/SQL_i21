CREATE PROCEDURE [dbo].[uspCTValidateContractHeader]
	
	@XML		NVARCHAR(MAX),
	@RowState	NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE @SQL						NVARCHAR(MAX) = '',
			@ErrMsg						NVARCHAR(MAX),
			@strCustomerContract		NVARCHAR(100),
			@idoc						INT,

			@intCommodityId				INT,
			@intCommodityUOMId			INT,
			@ysnCategory				BIT,
			@dblQuantity				NUMERIC(18,6),
			@dtmContractDate			DATETIME,
			@intContractHeaderId		INT,
			@intContractTypeId			INT,
			@intEntityId				INT,
			@intSalespersonId			INT,
			@strContractNumber			NVARCHAR(50),
			@intPricingTypeId			INT,
			@intCreatedById				INT,
			@dtmCreated					DATETIME,
			@intConcurrencyId			INT,
			@intContractBasisId			INT,
			@intTermId					INT,
			@intContractTextId			INT,
			@intWeightId				INT,
			@intGradeId					INT,
			@intCropYearId				INT,
			@intAssociationId			INT,
			@intProducerId				INT,
			@ysnMultiplePriceFixation	BIT,
			@dblNoOfLots				NUMERIC(18,6),
			@dblLotsFixed				NUMERIC(18,6),
			@intYear					INT,
			@intFiscalYearId			INT,
			@dblDeferPayRate			NUMERIC(18,6),
			@dblTolerancePct			NUMERIC(18,6),
			@dblProvisionalInvoicePct   NUMERIC(18,6),
			@dblQuantityPerLoad			NUMERIC(18,6),
			@intNoOfLoad				INT,
			
			@intFutureMarketId			INT,
			@intFutureMonthId			INT,
			@dblFutures					NUMERIC(18, 6),
			@ysnUniqueEntityReference	BIT,
			@ysnUsed					BIT = 0,
			@dblTotalPriced				NUMERIC(18, 6) = 0

	SELECT	@ysnUniqueEntityReference = ysnUniqueEntityReference FROM tblCTCompanyPreference
	--SELECT	@XML	=	dbo.[fnCTRemoveStringXMLTag](@XML,'strAmendmentLog')

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	@intCommodityId		            =	intCommodityId,
			@intCommodityUOMId	            =	intCommodityUOMId,
			@dblQuantity		            =	dblQuantity,
			@dtmContractDate	            =	dtmContractDate,
			@intContractHeaderId            =	intContractHeaderId,
			@intContractTypeId	            =	intContractTypeId,
			@intEntityId		            =	intEntityId,
			@intSalespersonId	            =	intSalespersonId,
			@strContractNumber	            =	strContractNumber,
			@ysnCategory		            =	ysnCategory,
			@intPricingTypeId	            =	intPricingTypeId,
			@intCreatedById		            =	intCreatedById,
			@dtmCreated			            =	dtmCreated,
			@intConcurrencyId	            =	intConcurrencyId,
			@intContractBasisId	            =	intFreightTermId,
			@intTermId			            =	intTermId,
			@intContractTextId	            =	intContractTextId,
			@intWeightId		            =	intWeightId,
			@intGradeId			            =	intGradeId,
			@intCropYearId		            =	intCropYearId,
			@intAssociationId	            =	intAssociationId,
			@intProducerId		            =	intProducerId,
			@ysnMultiplePriceFixation		=	ysnMultiplePriceFixation,
			@dblNoOfLots					=	dblNoOfLots
           ,@strCustomerContract			=   strCustomerContract
		   ,@dblDeferPayRate				=   dblDeferPayRate
		   ,@dblTolerancePct				=   dblTolerancePct
		   ,@dblProvisionalInvoicePct		=   dblProvisionalInvoicePct
		   ,@dblQuantityPerLoad				=   dblQuantityPerLoad
		   ,@intNoOfLoad					=   intNoOfLoad
		   ,@intFutureMarketId				=	intFutureMarketId
		   ,@intFutureMonthId				=	intFutureMonthId
		   ,@dblFutures						=	dblFutures

	FROM	OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader',2)
	WITH
	(
			intCommodityId				INT,
			intCommodityUOMId			INT,
			dblQuantity					NUMERIC(18,6),
			dtmContractDate				DATETIME,
			intContractHeaderId			INT,
			intContractTypeId			INT,
			intEntityId					INT,
			intSalespersonId			INT,
			strContractNumber			NVARCHAR(50),
			ysnCategory					BIT,
			intPricingTypeId			INT,
			intCreatedById				INT,
			dtmCreated					DATETIME,
			intConcurrencyId			INT,
			intFreightTermId			INT,
			intTermId					INT,
			intContractTextId			INT,
			intWeightId					INT,
			intGradeId					INT,
			intCropYearId				INT,
			intAssociationId			INT,
			intProducerId				INT,
			ysnMultiplePriceFixation	BIT,
			dblNoOfLots					NUMERIC(18,6),
			strCustomerContract			NVARCHAR(1000),
			dblDeferPayRate				NUMERIC(18,6),
			dblTolerancePct				NUMERIC(18,6),
			dblProvisionalInvoicePct	NUMERIC(18,6),
			dblQuantityPerLoad			NUMERIC(18,6),
			intNoOfLoad					INT,
			intFutureMarketId			INT,
			intFutureMonthId			INT,
			dblFutures					NUMERIC(18,6)
			
	);  

	SELECT @dblTotalPriced = ISNULL(SUM(ISNULL(dblQty, 0)), 0)
	FROM (
		SELECT dblQty = ISNULL(pfd.dblQuantity, 0) --dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId, tCum.intUnitMeasureId, fCum.intUnitMeasureId, ISNULL(pfd.dblQuantity, 0))
		FROM tblCTPriceFixation pf
		JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId
		--JOIN tblICCommodityUnitMeasure fCum ON fCum.intCommodityUnitMeasureId = @intCommodityUOMId
		--JOIN tblICItemUOM tCum ON tCum.intItemUOMId = pfd.intQtyItemUOMId
		WHERE intContractHeaderId = @intContractHeaderId 
	) tbl
	

	IF @RowState = 'Added'
	BEGIN
		IF	@intContractTypeId IS NULL
		BEGIN
			SET @ErrMsg = 'Contract Type is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF	@intEntityId IS NULL
		BEGIN
			SET @ErrMsg = 'Entity is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF ISNULL(@ysnCategory,0) = 0 
		BEGIN
			IF	@intCommodityId IS NULL
			BEGIN
				SET @ErrMsg = 'Commodity is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END
			IF	@intCommodityUOMId IS NULL
			BEGIN
				SET @ErrMsg = 'UOM is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND intCommodityUnitMeasureId = @intCommodityUOMId)
			BEGIN
				SET @ErrMsg = 'Combination of commodity id and UOM id is not matching.'
				RAISERROR(@ErrMsg,16,1)
			END
		END
		
		IF	@dblQuantity IS NULL
		BEGIN
			SET @ErrMsg = 'Quantity is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		---Quantity UOM

		IF	@dtmContractDate IS NULL
		BEGIN
			SET @ErrMsg = 'Contract Date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF	@intPricingTypeId IS NULL
		BEGIN
			SET @ErrMsg = 'Pricing Type is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intSalespersonId IS NULL
		BEGIN
			SET @ErrMsg = 'Salesperson is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF LEN(ISNULL(@strCustomerContract,'')) > 30
		BEGIN
			SET @ErrMsg = 'Entity Contract cannot be more than 30 characters.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF ISNULL(@dblDeferPayRate,0) > 999.99
		BEGIN
			SET @ErrMsg = 'Defer PayRate cannot be more than 999.99.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF ISNULL(@dblTolerancePct,0) > 99999999.9999
		BEGIN
			SET @ErrMsg = 'Tolerance Pct cannot be more than 99999999.9999.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF ISNULL(@dblProvisionalInvoicePct,0) > 99999999.9999
		BEGIN
			SET @ErrMsg = 'Tolerance Pct cannot be more than 99999999.9999.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF ISNULL(@dblQuantityPerLoad,0) > 99999999999999.9999
		BEGIN
			SET @ErrMsg = 'Quantity Per Load cannot be more than 99999999999999.9999.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF ISNULL(@intNoOfLoad,0) > 9999
		BEGIN
			SET @ErrMsg = 'No Of Load cannot be more than 9999.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF @ysnMultiplePriceFixation = 1
		BEGIN
			
			IF ISNULL(@intFutureMarketId,0) = 0 
			BEGIN
				SET @ErrMsg = 'Future Market is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END
			
			IF ISNULL(@intFutureMonthId,0) = 0 
			BEGIN
				SET @ErrMsg = 'Future Month is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END
			
			IF ISNULL(@intPricingTypeId,0) = 1 AND @dblFutures IS NULL
			BEGIN
				SET @ErrMsg = 'Futures is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END

			IF ISNULL(@dblQuantity,0) > 0 AND ISNULL(@dblNoOfLots,0) = 0
			BEGIN
				SET @ErrMsg = 'No Of Lots is missing while creating contract.'
				RAISERROR(@ErrMsg,16,1)
			END
		END

		IF	@strContractNumber IS NULL
		BEGIN
			SET @ErrMsg = 'Contract Number is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intCreatedById IS NULL
		BEGIN
			SET @ErrMsg = 'Created by is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dtmCreated IS NULL
		BEGIN
			SET @ErrMsg = 'Created date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@intConcurrencyId IS NULL
		BEGIN
			SET @ErrMsg = 'Concurrency Id is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		

		IF EXISTS(SELECT TOP 1 1 FROM tblCTContractHeader WHERE intContractTypeId  = @intContractTypeId AND strContractNumber = @strContractNumber)
		BEGIN
			SET @ErrMsg = 'Contract number is already available.'
			RAISERROR(@ErrMsg,16,1)
		END

		--Active check
		
		IF	@intEntityId IS NOT NULL AND (
			(@intContractTypeId = 1 AND NOT EXISTS(SELECT TOP 1 1 FROM vyuCTEntity WHERE intEntityId = @intEntityId AND ysnActive = 1 AND strEntityType = 'Vendor') ) OR
			(@intContractTypeId = 2 AND NOT EXISTS(SELECT TOP 1 1 FROM vyuCTEntity WHERE intEntityId = @intEntityId AND ysnActive = 1 AND strEntityType = 'Customer') )
		)
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intEntityId
			SET @ErrMsg = 'Entity ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intContractBasisId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMFreightTerms WHERE intFreightTermId = @intContractBasisId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strFreightTerm FROM tblSMFreightTerms WHERE intFreightTermId = @intContractBasisId
			SET @ErrMsg = 'Freight Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intTermId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMTerm WHERE intTermID = @intTermId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strTerm FROM tblSMTerm WHERE intTermID = @intTermId
			SET @ErrMsg = 'Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intSalespersonId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM vyuCTEntity WHERE intEntityId = @intSalespersonId AND ysnActive = 1 AND strEntityType = 'Salesperson')
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intSalespersonId
			SET @ErrMsg = 'Salesperson ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intContractTextId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractText WHERE intContractTextId = @intContractTextId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strTextCode FROM tblCTContractText WHERE intContractTextId = @intContractTextId
			SET @ErrMsg = 'Contract Text ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intGradeId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTWeightGrade WHERE intWeightGradeId = @intGradeId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @intGradeId
			SET @ErrMsg = 'Grade ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intWeightId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTWeightGrade WHERE intWeightGradeId = @intWeightId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @intWeightId
			SET @ErrMsg = 'Weight ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intCropYearId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTCropYear WHERE intCropYearId = @intCropYearId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strCropYear FROM tblCTCropYear WHERE intCropYearId = @intCropYearId
			SET @ErrMsg = 'Crop Year ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intAssociationId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTAssociation WHERE intAssociationId = @intAssociationId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strName FROM tblCTAssociation WHERE intAssociationId = @intAssociationId
			SET @ErrMsg = 'Association ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intProducerId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 1 FROM vyuCTEntity WHERE intEntityId = @intProducerId AND strEntityType = 'Producer' AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intProducerId
			SET @ErrMsg = 'Producer ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END
		--End Active check

		SELECT	@intYear = YEAR(@dtmContractDate)
		SELECT @intFiscalYearId = intFiscalYearId FROM tblGLFiscalYear WHERE strFiscalYear = LTRIM(@intYear)
		IF EXISTS(SELECT TOP 1 1 FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @intFiscalYearId AND @dtmContractDate BETWEEN dtmStartDate AND dtmEndDate AND ysnCTOpen = 0)
		BEGIN
			SET @ErrMsg = 'Selected contract date is in a fiscal period that has been closed.'
			RAISERROR(@ErrMsg,16,1)
		END
	END
	ELSE IF @RowState = 'Modified'
	BEGIN
		SELECT	@ysnMultiplePriceFixation	=	ISNULL(@ysnMultiplePriceFixation,ysnMultiplePriceFixation)
		FROM	tblCTContractHeader
		WHERE	intContractHeaderId	=	@intContractHeaderId

		--SELECT * FROM vyuCTSequenceUsageHistory WHERE intContractHeaderId = @intContractHeaderId

		IF EXISTS(SELECT TOP 1 1 FROM vyuCTSequenceUsageHistory WHERE intContractHeaderId = @intContractHeaderId AND ysnDeleted <> 1)
		BEGIN
			SET @ysnUsed = 1
		END

		IF @ysnMultiplePriceFixation = 1 AND @ysnUsed = 1
		BEGIN
			SELECT @dblLotsFixed = dblLotsFixed FROM tblCTPriceFixation WHERE intContractHeaderId = @intContractHeaderId
			IF @dblLotsFixed IS NOT NULL AND @dblNoOfLots IS NOT NULL AND @dblNoOfLots < @dblLotsFixed 
			BEGIN
				SET @ErrMsg = 'Cannot reduce number of lots to '+LTRIM(CAST(@dblNoOfLots AS INT)) + '. As '+LTRIM(CAST(@dblLotsFixed AS INT)) + ' lots are price fixed.'
				RAISERROR(@ErrMsg,16,1)
			END
		END

		IF (@ysnMultiplePriceFixation = 1) AND (ISNULL(@dblQuantity, 0) < ISNULL(@dblTotalPriced, 0))
		BEGIN
			SET @ErrMsg = 'Quantity cannot be reduced below price fixed quantity of ' + CAST(ISNULL(@dblTotalPriced, 0) AS NVARCHAR) + '.'
			RAISERROR(@ErrMsg,16,1)
		END
	END

	--Common added and modified
	IF ISNULL(@ysnUniqueEntityReference,0) = 1 AND LTRIM(RTRIM(ISNULL(@strCustomerContract,''))) <> '' AND EXISTS(SELECT TOP 1 1 FROM tblCTContractHeader WHERE strCustomerContract = @strCustomerContract)
	BEGIN
		SELECT @ErrMsg = 'The Vendor/Customer Ref '+@strCustomerContract+' is already available for the selected vendor.'
		RAISERROR(@ErrMsg,16,1)
	END

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
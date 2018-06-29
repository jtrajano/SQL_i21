CREATE PROCEDURE [dbo].[uspCTValidateContractHeader]
	
	@XML		NVARCHAR(MAX),
	@RowState	NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE @SQL					NVARCHAR(MAX) = '',
			@ErrMsg					NVARCHAR(MAX),
			@idoc					INT,

			@intCommodityId			INT,
			@intCommodityUOMId		INT,
			@ysnCategory			BIT,
			@dblQuantity			NUMERIC(18,6),
			@dtmContractDate		DATETIME,
			@intContractHeaderId	INT,
			@intContractTypeId		INT,
			@intEntityId			INT,
			@intSalespersonId		INT,
			@strContractNumber		NVARCHAR(50),
			@intPricingTypeId		INT,
			@intCreatedById			INT,
			@dtmCreated				DATETIME,
			@intConcurrencyId		INT,
			@intContractBasisId		INT,
			@intTermId				INT,
			@intContractTextId		INT,
			@intWeightId			INT,
			@intGradeId				INT,
			@intCropYearId			INT,
			@intAssociationId		INT,
			@intProducerId			INT,
			@ysnMultiplePriceFixation	BIT,
			@dblNoOfLots			NUMERIC(18,6),
			@dblLotsFixed			NUMERIC(18,6),
			@intYear				INT,
			@intFiscalYearId		INT

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	@intCommodityId		=	intCommodityId,
			@intCommodityUOMId	=	intCommodityUOMId,
			@dblQuantity		=	dblQuantity,
			@dtmContractDate	=	dtmContractDate,
			@intContractHeaderId=	intContractHeaderId,
			@intContractTypeId	=	intContractTypeId,
			@intEntityId		=	intEntityId,
			@intSalespersonId	=	intSalespersonId,
			@strContractNumber	=	strContractNumber,
			@ysnCategory		=	ysnCategory,
			@intPricingTypeId	=	intPricingTypeId,
			@intCreatedById		=	intCreatedById,
			@dtmCreated			=	dtmCreated,
			@intConcurrencyId	=	intConcurrencyId,
			@intContractBasisId	=	intContractBasisId,
			@intTermId			=	intTermId,
			@intContractTextId	=	intContractTextId,
			@intWeightId		=	intWeightId,
			@intGradeId			=	intGradeId,
			@intCropYearId		=	intCropYearId,
			@intAssociationId	=	intAssociationId,
			@intProducerId		=	intProducerId,
			@ysnMultiplePriceFixation		=	ysnMultiplePriceFixation,
			@dblNoOfLots		=	dblNoOfLots

	FROM	OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader',2)
	WITH
	(
			intCommodityId		INT,
			intCommodityUOMId	INT,
			dblQuantity			NUMERIC(18,6),
			dtmContractDate		DATETIME,
			intContractHeaderId	INT,
			intContractTypeId	INT,
			intEntityId			INT,
			intSalespersonId	INT,
			strContractNumber	NVARCHAR(50),
			ysnCategory			BIT,
			intPricingTypeId	INT,
			intCreatedById		INT,
			dtmCreated			DATETIME,
			intConcurrencyId	INT,
			intContractBasisId	INT,
			intTermId			INT,
			intContractTextId	INT,
			intWeightId			INT,
			intGradeId			INT,
			intCropYearId		INT,
			intAssociationId	INT,
			intProducerId		INT,
			ysnMultiplePriceFixation	BIT,
			dblNoOfLots			NUMERIC(18,6)
	);  

	IF @RowState = 'Added'
	BEGIN
		IF	@dtmContractDate IS NULL
		BEGIN
			SET @ErrMsg = 'Contract Date is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
		IF	@dblQuantity IS NULL
		BEGIN
			SET @ErrMsg = 'Quantity is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
		END
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
		IF	@intSalespersonId IS NULL
		BEGIN
			SET @ErrMsg = 'Salesperson is missing while creating contract.'
			RAISERROR(@ErrMsg,16,1)
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
			IF NOT EXISTS(SELECT * FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND intCommodityUnitMeasureId = @intCommodityUOMId)
			BEGIN
				SET @ErrMsg = 'Combination of commodity id and UOM id is not matching.'
				RAISERROR(@ErrMsg,16,1)
			END
		END

		IF EXISTS(SELECT * FROM tblCTContractHeader WHERE intContractTypeId  = @intContractTypeId AND strContractNumber = @strContractNumber)
		BEGIN
			SET @ErrMsg = 'Contract number is already available.'
			RAISERROR(@ErrMsg,16,1)
		END

		--Active check
		
		IF	@intEntityId IS NOT NULL AND (
			(@intContractTypeId = 1 AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intEntityId AND ysnActive = 1 AND strEntityType = 'Vendor') ) OR
			(@intContractTypeId = 2 AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intEntityId AND ysnActive = 1 AND strEntityType = 'Customer') )
		)
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intEntityId
			SET @ErrMsg = 'Entity ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intContractBasisId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTContractBasis WHERE intContractBasisId = @intContractBasisId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strContractBasis FROM tblCTContractBasis WHERE intContractBasisId = @intContractBasisId
			SET @ErrMsg = 'INCO/Ship Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intTermId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblSMTerm WHERE intTermID = @intTermId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strTerm FROM tblSMTerm WHERE intTermID = @intTermId
			SET @ErrMsg = 'Term ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intSalespersonId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intSalespersonId AND ysnActive = 1 AND strEntityType = 'Salesperson')
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intSalespersonId
			SET @ErrMsg = 'Salesperson ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intContractTextId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTContractText WHERE intContractTextId = @intContractTextId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strTextCode FROM tblCTContractText WHERE intContractTextId = @intContractTextId
			SET @ErrMsg = 'Contract Text ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intGradeId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTWeightGrade WHERE intWeightGradeId = @intGradeId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @intGradeId
			SET @ErrMsg = 'Geade ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intWeightId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTWeightGrade WHERE intWeightGradeId = @intWeightId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strWeightGradeDesc FROM tblCTWeightGrade WHERE intWeightGradeId = @intWeightId
			SET @ErrMsg = 'Weight ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intCropYearId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTCropYear WHERE intCropYearId = @intCropYearId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strCropYear FROM tblCTCropYear WHERE intCropYearId = @intCropYearId
			SET @ErrMsg = 'Crop Year ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intAssociationId IS NOT NULL AND NOT EXISTS(SELECT * FROM tblCTAssociation WHERE intAssociationId = @intAssociationId AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strName FROM tblCTAssociation WHERE intAssociationId = @intAssociationId
			SET @ErrMsg = 'Association ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intProducerId IS NOT NULL AND NOT EXISTS(SELECT * FROM vyuCTEntity WHERE intEntityId = @intProducerId AND strEntityType = 'Producer' AND ysnActive = 1)
		BEGIN
			SELECT @ErrMsg = strName FROM tblEMEntity WHERE intEntityId = @intProducerId
			SET @ErrMsg = 'Producer ' + ISNULL(@ErrMsg,'selected') + ' is inactive.'
			RAISERROR(@ErrMsg,16,1)
		END
		--End Active check

		SELECT	@intYear = YEAR(@dtmContractDate)
		SELECT @intFiscalYearId = intFiscalYearId FROM tblGLFiscalYear WHERE strFiscalYear = LTRIM(@intYear)
		IF EXISTS(SELECT * FROM tblGLFiscalYearPeriod WHERE intFiscalYearId = @intFiscalYearId AND @dtmContractDate BETWEEN dtmStartDate AND dtmEndDate AND ysnCTOpen = 0)
		BEGIN
			SET @ErrMsg = 'Selected contract date is in a fiscal period that has been closed.'
			RAISERROR(@ErrMsg,16,1)
		END
	END
	IF @RowState = 'Modified'
	BEGIN
		IF @ysnMultiplePriceFixation = 1
		BEGIN
			SELECT @dblLotsFixed = dblLotsFixed FROM tblCTPriceFixation WHERE intContractHeaderId = @intContractHeaderId
			IF @dblLotsFixed IS NOT NULL AND @dblNoOfLots IS NOT NULL AND @dblNoOfLots < @dblLotsFixed 
			BEGIN
				SET @ErrMsg = 'Cannot reduce number of lots to '+LTRIM(CAST(@dblNoOfLots AS INT)) + '. As '+LTRIM(CAST(@dblLotsFixed AS INT)) + ' lots are price fixed.'
				RAISERROR(@ErrMsg,16,1)
			END
		END
	END

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
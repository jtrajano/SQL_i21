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
			@intConcurrencyId		INT

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
			@intConcurrencyId	=	intConcurrencyId

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
			intConcurrencyId	INT
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

	END

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
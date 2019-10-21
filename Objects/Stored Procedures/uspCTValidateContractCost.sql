CREATE PROCEDURE [dbo].[uspCTValidateContractCost]

	@XML		NVARCHAR(MAX),
	@RowState	NVARCHAR(50)

AS

BEGIN TRY
	
	DECLARE  @SQL					NVARCHAR(MAX) = ''
			,@ErrMsg				NVARCHAR(MAX)
			,@idoc					INT
			,@intConcurrencyId		INT
			,@intContractDetailId	INT
			,@intItemId				INT
			--,@intVendorId			INT
			,@strCostMethod			NVARCHAR(200)
			,@intCurrencyId			INT
			,@dblRate				NUMERIC(18,6)
			,@intItemUOMId			INT
		  --,@intRateTypeId		 INT
		  --,@dblFX				 NUMERIC(18,6)
		  --,@ysnAccrue			 BIT
		  --,@ysnMTM			 BIT
		  --,@ysnPrice			 BIT
		  --,@ysnAdditionalCost	 BIT
		  --,@ysnBasis			 BIT
		  --,@ysnReceivable		 BIT
		  --,@strPaidBy			 NVARCHAR(200)
		  --,@dtmDueDate			 DATETIME
		  --,@strReference		 NVARCHAR(200)
		  --,@strRemarks			 NVARCHAR(200)
		  --,@strStatus			 NVARCHAR(200)
		  --,@strCostStatus		 NVARCHAR(200)
		  --,@dblReqstdAmount		 NUMERIC(18,6)
		  --,@dblRcvdPaidAmount	 NUMERIC(18,6)
		  --,@dblActualAmount		 NUMERIC(18,6)
		  --,@dblAccruedAmount	 NUMERIC(18,6)
		  --,@dblRemainingPercent	 NUMERIC(18,6)
		  --,@dtmAccrualDate		 DATETIME
		  --,@strAPAR			 NVARCHAR(200)
		  --,@strPayToReceiveFrom	 NVARCHAR(200)


	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT   @intConcurrencyId		=	intConcurrencyId
			,@intContractDetailId	=	intContractDetailId
			,@intItemId				=	intItemId
			,@strCostMethod			=	strCostMethod
			,@intCurrencyId			=	intCurrencyId
			,@dblRate				=	dblRate
			,@intItemUOMId			=	intItemUOMId

	FROM	OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost',2)
	WITH
	(
			 intConcurrencyId		INT
			,intContractDetailId	INT
			,intItemId				INT
			,strCostMethod			NVARCHAR(200)
			,intCurrencyId			INT
			,dblRate				NUMERIC(18,6)
			,intItemUOMId			INT
	);  

	IF @RowState = 'Added'
	BEGIN
		IF	@intConcurrencyId IS NULL
		BEGIN
			SET @ErrMsg = 'Concurrency Id is missing.'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF	@intContractDetailId IS NULL
		BEGIN
			SET @ErrMsg = 'Sequence information is missing.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intItemId IS NULL
		BEGIN
			SET @ErrMsg = 'Item is missing.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@strCostMethod IS NULL
		BEGIN
			SET @ErrMsg = 'Cost method is missing.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intCurrencyId IS NULL
		BEGIN
			SET @ErrMsg = 'Currency is missing.'
			RAISERROR(@ErrMsg,16,1)
		END

		IF	@intItemUOMId IS NULL
		BEGIN
			SET @ErrMsg = 'UOM is missing.'
			RAISERROR(@ErrMsg,16,1)
		END
	END

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
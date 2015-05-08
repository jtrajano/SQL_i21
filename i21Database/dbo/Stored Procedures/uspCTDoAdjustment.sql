CREATE PROCEDURE [dbo].[uspCTDoAdjustment]
	@XML NvARCHAR(MAX)
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@intContractDetailId	INT,
			@intConcurrencyId		INT,
			@intContractHeaderId	INT,
			@dblQuantity			DECIMAL(12,4),
			@dblBalance				DECIMAL(12,4),
			@dblAdjAmount			DECIMAL(12,4)
			          
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML ,'<row xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'
	
	SELECT	@intContractDetailId	=	intContractDetailId,
			@intConcurrencyId		=	intConcurrencyId,
			@dblAdjAmount			=	dblAdjAmount	
	FROM	OPENXML(@idoc, 'ArrayOfVyuCTContractAdjustment/vyuCTContractAdjustment',2)
	WITH
	(
			intContractDetailId		INT,
			intConcurrencyId		INT,
			dblAdjAmount			NUMERIC(12,4)
	)
	  
	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('This sequence has been deleted by other user.',16,1)
	END
	IF (SELECT intConcurrencyId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId) <> @intConcurrencyId
	BEGIN
		RAISERROR('This sequence has been modified by other user.',16,1)
	END
	
	SELECT	@dblQuantity			=	dblQuantity,
			@dblBalance				=	dblBalance,
			@intContractHeaderId	=	intContractHeaderId
	FROM	tblCTContractDetail 
	WHERE	intContractDetailId		=	@intContractDetailId 
	
	INSERT INTO tblCTContractAdjustment
	(
			intContractDetailId,	strAdjustmentNo,		dtmAdjustmentDate,			strComment,						ysnAdjustment,		dblOldQuantity,
			dblOldBalance,			dblAdjAmount,			dblNewBalance,				dblNewQuantity,					dblContractPrice,	dblCancellationPrice,
			dblGainLossPerUnit,		dblCancelFeePerUnit,	dblCancelFeeFlatAmount,		dblTotalGainLoss,				intUserId,			dtmCreatedDate
	)
	SELECT	intContractDetailId,	strAdjustmentNo,		dtmAdjustmentDate,			strComment,						1,					@dblQuantity,
			@dblBalance,			dblAdjAmount,			@dblBalance + dblAdjAmount,	@dblQuantity + dblAdjAmount,	dblContractPrice,	dblCancellationPrice,
			dblGainLossPerUnit,		dblCancelFeePerUnit,	dblCancelFeeFlatAmount,		dblTotalGainLoss,				intUserId,			GETDATE()
			
	FROM	OPENXML(@idoc, 'ArrayOfVyuCTContractAdjustment/vyuCTContractAdjustment',2)
	WITH
	(
			intContractDetailId		INT,
			strAdjustmentNo			NVARCHAR(50),
			dtmAdjustmentDate		DATETIME,
			strComment				NVARCHAR(MAX),
			dblAdjAmount			NUMERIC(12, 4)'dblAdjAmount[not(@xsi:nil = "true")]',
			dblContractPrice		NUMERIC(8, 4) 'dblContractPrice[not(@xsi:nil = "true")]',
			dblCancellationPrice	NUMERIC(8, 4) 'dblCancellationPrice[not(@xsi:nil = "true")]',
			dblGainLossPerUnit		NUMERIC(10, 4) 'dblGainLossPerUnit[not(@xsi:nil = "true")]',
			dblCancelFeePerUnit		NUMERIC(8, 4) 'dblCancelFeePerUnit[not(@xsi:nil = "true")]',
			dblCancelFeeFlatAmount	NUMERIC(10, 4) 'dblCancelFeeFlatAmount[not(@xsi:nil = "true")]',
			dblTotalGainLoss		NUMERIC(18, 4) 'dblTotalGainLoss[not(@xsi:nil = "true")]',
			intUserId				INT ,
			dtmCreatedDate			DATETIME
	)  
	
	UPDATE	tblCTContractDetail
	SET		dblQuantity			=	dblQuantity + @dblAdjAmount,
			dblBalance			=	dblBalance + @dblAdjAmount,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId	=	@intContractDetailId

	UPDATE	tblCTContractHeader
	SET		dblQuantity			=	dblQuantity + @dblAdjAmount,
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
END TRY      
BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH

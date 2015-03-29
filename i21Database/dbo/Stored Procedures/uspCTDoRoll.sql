CREATE PROCEDURE [dbo].[uspCTDoRoll]
	@XML varchar(max)
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@ContractDetailId		INT,
			@ConcurrencyId			INT,
			@StartDate				DATETIME,
			@EndDate				DATETIME,
			@Quantity				DECIMAL(12,4),
			@Futures				DECIMAL(12,4),
			@Basis					DECIMAL(12,4),
			@FutureMarketId			INT,
			@FuturesMonth			NVARCHAR(50),
			@ContractOptHeaderId	INT,
			@CurrentQty				DECIMAL(12,4),
			@ContractSeq			INT,
	        @Count					INT 
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	IF OBJECT_ID('tempdb..#tblCTContractDetail') IS NOT NULL  				
		DROP TABLE #tblCTContractDetail				
	
	SELECT	*
	INTO	#tblCTContractDetail	
	FROM	OPENXML(@idoc, 'root/detail',2)
	WITH
	(
			intContractDetailId		INT,
			intConcurrencyId		INT,
			dtmEndDate				DATETIME,
			dblFutures				DECIMAL(12,4),
			dblBasis				DECIMAL(12,4),
			strFuturesMonth			NVARCHAR(50)
	)  
	
	SELECT	@Count = COUNT(1) 
	FROM	tblCTContractDetail		CD
	JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId AND TD.intConcurrencyId = CD.intConcurrencyId
	
	IF	@Count <> (SELECT COUNT(1) FROM #tblCTContractDetail)
		RAISERROR('Some of the sequences are modified or deleted by other users.',16,1)
		
	UPDATE	CD
	SET		CD.intConcurrencyId	=	CD.intConcurrencyId +1,	
			CD.dtmEndDate		=	TD.dtmEndDate,
			CD.dblFutures		=	CASE WHEN TD.dblFutures IS NULL THEN CD.dblFutures ELSE TD.dblFutures END,
			CD.dblBasis			=	CASE WHEN TD.dblBasis IS NULL THEN CD.dblBasis ELSE TD.dblBasis END,
			CD.strFuturesMonth	=	TD.strFuturesMonth
			
	FROM	tblCTContractDetail		CD
	JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId
	
END TRY      

BEGIN CATCH       

	SET @ErrMsg = ERROR_MESSAGE()      
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      

END CATCH

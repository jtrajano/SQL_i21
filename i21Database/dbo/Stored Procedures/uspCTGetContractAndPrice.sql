CREATE PROCEDURE [dbo].[uspCTGetContractAndPrice]
	@intLocationId		INT,
	@intItemId			INT,
	@dblTransactionDate	DATETIME,
	@dblQuantity		NUMERIC(18,4)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT	TOP 1 
		intContractHeaderId,
		dblCashPrice
FROM	tblCTContractDetail
WHERE	intCompanyLocationId	=		@intLocationId	AND	
		intItemId				=		@intItemId		AND	
		dblQuantity				=		@dblQuantity	AND
		ISNULL(dblCashPrice,0)	>		0				AND
		@dblTransactionDate	 BETWEEN	dtmStartDate	AND 
										dtmEndDate		
END 
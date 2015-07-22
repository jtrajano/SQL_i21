CREATE PROCEDURE [dbo].[uspCTGetContractAndPrice]
	@intContractTypeId	INT,
	@intEntityId		INT,
	@intLocationId		INT,
	@intItemId			INT,
	@dtmTransactionDate	DATETIME,
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
FROM	vyuCTContractDetailView
WHERE	intContractTypeId		=		@intContractTypeId	AND
		intEntityId				=		@intEntityId		AND
		intCompanyLocationId	=		@intLocationId		AND	
		intItemId				=		@intItemId			AND	
		dblDetailQuantity		=		@dblQuantity		AND
		ISNULL(dblCashPrice,0)	>		0					AND
		@dtmTransactionDate	 BETWEEN	dtmStartDate		AND 
										dtmEndDate		
END 
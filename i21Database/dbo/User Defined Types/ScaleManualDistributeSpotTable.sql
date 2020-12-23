/*
	This is a user-defined table type used in the manual scale ticket distribution 
*/
CREATE TYPE [dbo].[ScaleManualDistributeSpotTable] AS TABLE
(
	intTicketId INT NOT NULL								
	,intEntityId INT NOT NULL								
	,dblQty NUMERIC(18, 6) NOT NULL DEFAULT 0
	,dblBasis NUMERIC(18, 6) NOT NULL DEFAULT 0
	,dblFuture NUMERIC(18, 6) NOT NULL DEFAULT 0
)

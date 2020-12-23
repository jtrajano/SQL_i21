/*
	This is a user-defined table type used in the manual scale ticket distribution 
*/
CREATE TYPE [dbo].[ScaleManualDistributeLoadTable] AS TABLE
(
	intTicketId INT NOT NULL								
	,intEntityId INT NOT NULL								
	,intLoadDetailId INT NOT NULL		
	,dblQty NUMERIC(18, 6) NOT NULL DEFAULT 0
	
)

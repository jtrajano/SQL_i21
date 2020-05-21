/*
	This is a user-defined table type used in the manual scale ticket distribution for inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[SCTicketDestinationWeightsAndGradesPosting] AS TABLE
(
	[intTicketId] INT NOT NULL								-- scale ticket id
	,dblNetUnits NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblGrossUnits NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblGrossWeight NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblGrossWeight1 NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblGrossWeight2 NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblTareWeight NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblTareWeight1 NUMERIC(18,6) NOT NULL DEFAULT 0
	,dblTareWeight2 NUMERIC(18,6) NOT NULL DEFAULT 0
	,intDiscountId INT NOT NULL 
	,dblShrink NUMERIC(18,6) NOT NULL DEFAULT 0
)
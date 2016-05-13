/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[RouteOrdersTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intOrderId] INT NOT NULL					-- intDispatchID of tblTMDispatch. 
	,[intRouteId] INT NOT NULL					-- Primary key of tblLGRoute
	,[intDriverEntityId] INT NOT NULL			-- Primary key of tblEMEntity
    ,[dblLatitude] NUMERIC(18, 6) NULL DEFAULT 0
    ,[dblLongitude] NUMERIC(18, 6) NULL DEFAULT 0
    ,[intSequence] INT NOT NULL					-- Sequence of orders that are routed
	,[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		-- The string id of the source transaction. 
)

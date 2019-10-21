/*
	This is a user-defined table type used in least cost routing post. 
*/
CREATE TYPE [dbo].[RouteOrdersTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intOrderId] INT NOT NULL					-- intDispatchID of tblTMDispatch. 
	,[intRouteId] INT NULL					-- Primary key of tblLGRoute
	,[intDriverEntityId] INT NULL			-- Primary key of tblEMEntity
    ,[dblLatitude] NUMERIC(18, 6) NULL DEFAULT 0
    ,[dblLongitude] NUMERIC(18, 6) NULL DEFAULT 0
    ,[intSequence] INT NULL					-- Sequence of orders that are routed
	,[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		-- The string id of the source transaction. 
)

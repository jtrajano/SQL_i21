/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[TMGPSUpdateByIdTable] AS TABLE
(
	[intGPSUpdateId] INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED, 
    [intSiteId] INT NOT NULL,
    [dblLatitude] NUMERIC(18, 6) NULL, 
    [dblLongitude] NUMERIC(18, 6) NULL
)


    
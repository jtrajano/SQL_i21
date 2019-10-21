/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[TMGPSUpdateTable] AS TABLE
(
	[intGPSUpdateId] INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED, 
    [strCustomerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL , 
    [strSiteNumber] NVARCHAR(5) COLLATE Latin1_General_CI_AS  NULL , 
    [dblLatitude] NUMERIC(18, 6) NULL, 
    [dblLongitude] NUMERIC(18, 6) NULL
)


    
/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[TMCompactItem] AS TABLE
(
	[intCntId] INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED, 
	[intItemId] INT NOT NULL, 
    [strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL , 
    [strLocation] NVARCHAR(5) COLLATE Latin1_General_CI_AS  NULL  
    
)


    
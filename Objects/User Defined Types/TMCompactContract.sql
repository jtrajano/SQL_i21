/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
	CREATE TYPE [dbo].[TMCompactContract] AS TABLE
	(
		[intCntId] INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED, 
		[intContractId] INT NOT NULL, 
		[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL , 
		[strLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
		[strItemOrClass] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL , 
		[strCustomerNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL 
	)


    
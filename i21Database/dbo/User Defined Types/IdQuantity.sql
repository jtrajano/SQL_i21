/*
	Use this if you needed to pass rows of primary key to stored procedure
*/
CREATE TYPE [dbo].[IdQuantity] AS TABLE (
	[intId] INT NOT NULL,
	[dblQuantity] NUMERIC(36,20)
	PRIMARY KEY CLUSTERED ([intId] ASC)  
)


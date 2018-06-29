/*
	Use this if you needed to pass rows of primary key to stored procedure
*/
CREATE TYPE [dbo].[Id] AS TABLE (
	[intId] INT NOT NULL,
	PRIMARY KEY CLUSTERED ([intId] ASC)  
)


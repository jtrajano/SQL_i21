/*
    Used by the function fnJoinDelimitedValues as a table parameter that holds the row values to be joined as a single delimited string.
*/
CREATE TYPE [dbo].[JointDelimitedValues] AS TABLE
(
	
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
    [varValue] SQL_VARIANT NULL
)
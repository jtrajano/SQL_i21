/*
	Raise the commonly used Inventory Error messages. 
*/

CREATE PROCEDURE uspICRaiseError(
  @msgIdOrString SQL_VARIANT,
  @p1 SQL_VARIANT = null,
  @p2 SQL_VARIANT = null,
  @p3 SQL_VARIANT = null,
  @p4 SQL_VARIANT = null,
  @p5 SQL_VARIANT = null,
  @p6 SQL_VARIANT = null,
  @p7 SQL_VARIANT = null,
  @p8 SQL_VARIANT = null,
  @p9 SQL_VARIANT = null,
  @p10 SQL_VARIANT = null
)
AS 
BEGIN
	DECLARE @msgString NVARCHAR(MAX)

	SELECT @msgString = 
		dbo.fnICFormatErrorMessage (
		  @msgIdOrString
		  ,@p1
		  ,@p2
		  ,@p3
		  ,@p4
		  ,@p5
		  ,@p6
		  ,@p7
		  ,@p8
		  ,@p9
		  ,@p10
		) 	

	RAISERROR(@msgString, 11, 1)
END

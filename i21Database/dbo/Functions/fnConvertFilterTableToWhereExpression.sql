CREATE FUNCTION [dbo].[fnConvertFilterTableToWhereExpression]
(
	-- Add the parameters for the function here
	@filterTable FilterTableType READONLY
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result NVARCHAR(MAX)=''
	DECLARE @FilterId INT
	DECLARE @FieldName NVARCHAR(50)
	DECLARE @Condition NVARCHAR(20)
	DECLARE @From NVARCHAR(50)
	DECLARE @To NVARCHAR(50)
	DECLARE @Join NVARCHAR(10)
	DECLARE @BeginGroup NVARCHAR(50)
	DECLARE @EndGroup NVARCHAR(50)
	DECLARE @DataType NVARCHAR(50)
	DECLARE @tempTable TABLE (ID INT)
	DECLARE @Id INT
	DECLARE @Count INT

	DECLARE @Counter SMALLINT = 0
	-- Add the T-SQL statements to compute the return value here
	INSERT INTO @tempTable SELECT filterId FROM @filterTable  WHERE [from] <> ''
	SELECT @Count = COUNT(1) FROM @tempTable

	WHILE EXISTS(SELECT TOP 1 1 FROM @tempTable)
	BEGIN
		SELECT top 1 @Id = ID from @tempTable
		SELECT  
		@FieldName = [fieldname]
		,@Condition = [condition]
		,@From = [from]
		,@To = [to]
		,@Join = [join]
		,@BeginGroup= [begingroup]
		,@EndGroup = [endgroup]
		,@DataType = [datatype]
		,@FilterId =filterId  FROM @filterTable
		WHERE filterId = @Id
		
		select @Result += @FieldName + ' '
		select @Result += 
			CASE WHEN @Condition ='Equal To'  or
			(@Condition = 'Custom' AND @From IS NOT NULL AND @To IS NULL) 
			THEN '='
			WHEN @Condition ='Not Equal To' THEN '<>'
			WHEN @Condition in ('Starts With','Ends With') THEN 'Like'
			WHEN @Condition in ('Like','Not Like','Between') THEN @Condition
			WHEN @Condition ='Greater Than' THEN '>'
			WHEN @Condition ='Greater Than Or Equal' THEN '>='
			WHEN @Condition ='Less Than' THEN '<'
			WHEN @Condition IN ('Less Than Or Equal','As Of') THEN '<='
			WHEN (@Condition = 'Custom' AND @From IS NOT NULL AND @To IS NOT NULL) or
				 @Condition like '%Date'  or
				 @Condition like '%Month' or
				 @Condition like '%Period' or
				 @Condition like '%Year' or
				 @Condition like '%Quarter' or
				 @Condition = 'Between' or
				 @Condition = 'As Of' THEN 'Between'
			END + ' '
			
		Select @Result +=
 			CASE WHEN @Condition IN('Equal To','Not Equal To','Greater Than',
			'Greater Than Or Equal','Less Than','Less Than Or Equal','As Of') or
			(@Condition = 'Custom' AND @From IS NOT NULL AND @To IS NULL) 
			THEN '''' + @From + ''''
			WHEN @Condition like '%Date'  or
				 @Condition like '%Month' or
				 @Condition like '%Period' or
				 @Condition like '%Year' or
				 @Condition like '%Quarter' or
				 @Condition = 'As Of' or
				 @Condition = 'Between' or
				 (@Condition = 'Custom' AND @From IS NOT NULL AND @To IS NOT NULL) 
			THEN '''' + @From + '''' + ' AND ' + '''' + @To + ''''
			WHEN @Condition = 'Starts With' THEN '''' + @From + '%' + ''''
			WHEN @Condition = 'Ends With' THEN '''' + '%' + @From + ''''
			END + ' '
		SET @Counter +=1
		Select @Result +=
			CASE WHEN @Counter < @Count THEN @Join + ' ' ELSE '' END
		DELETE FROM  @tempTable WHERE ID = @Id
	END

	-- Return the result of the function
	RETURN 	'Where ' + @Result

END
GO


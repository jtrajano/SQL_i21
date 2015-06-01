CREATE FUNCTION [dbo].[fnAPCreateFilter]
(
	@fieldname nvarchar(50)
	, @condition nvarchar(20)
	, @from nvarchar(50)
	, @to nvarchar(50)
	, @join nvarchar(10)
	, @begingroup nvarchar(50)
	, @endgroup nvarchar(50)
	, @datatype nvarchar(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @filter NVARCHAR(MAX)

	SET @filter = @fieldname

	SET @filter = @filter + CASE @datatype
				WHEN 'Date'
					THEN ' BETWEEN ' + @from + ' AND ' + @to
				WHEN 'String'
					THEN
						CASE @condition
						WHEN 'Like' THEN ' LIKE ''' + @from + ''''
						WHEN 'Not Like' THEN ' NOT LIKE ''' + @from + ''''
						WHEN 'Between' THEN ' BETWEEN ''' + @from + ''' AND ''' + @to + ''''
						WHEN 'Starts With' THEN ' LIKE ''' + @from + '%'''
						WHEN 'Ends With' THEN ' LIKE ''%' + @from + '%'''
						WHEN 'Equal To' THEN ' = ' + @from
						WHEN 'Not Equa lTo' THEN ' != ' + @from
						WHEN 'Greater Than' THEN ' > ' + @from
						WHEN 'In' THEN ' (' + @from + ')' END
				WHEN 'Decimal' 
						THEN 
							CASE @condition
							WHEN 'BETWEEN' THEN ' BETWEEN ' + @from + ' AND ' + @to
							WHEN 'Equal To' THEN ' = ' + @from
							WHEN 'Not Equal To' THEN ' != ' + @from
							WHEN 'Greater Than' THEN ' > ' + @from
							WHEN 'Greater Than Or Eqal' THEN ' >= ' + @from
							WHEN 'Less Than' THEN ' < ' + @from
							WHEN 'Less Than Or Equal' THEN ' <= ' + @from END
				WHEN 'Integer'
						THEN 
							CASE @condition
							WHEN 'BETWEEN' THEN ' BETWEEN ' + @from + ' AND ' + @to
							WHEN 'Equal To' THEN ' = ' + @from
							WHEN 'Not Equal To' THEN ' != ' + @from
							WHEN 'Greater Than' THEN ' > ' + @from
							WHEN 'Greater Than Or Eqal' THEN ' >= ' + @from
							WHEN 'Less Than' THEN ' < ' + @from
							WHEN 'Less Than Or Equal' THEN ' <= ' + @from END
				WHEN 'Bool'
					THEN ' = ' + (CASE WHEN @from = 1 THEN 'TRUE' ELSE 'FALSE' END)
				END

	RETURN @filter
END

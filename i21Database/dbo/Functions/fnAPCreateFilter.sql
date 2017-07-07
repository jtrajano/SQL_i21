CREATE FUNCTION [dbo].[fnAPCreateFilter]
(
	@fieldname nvarchar(50)
	, @condition nvarchar(20)
	, @from nvarchar(MAX)
	, @to nvarchar(MAX)
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
						CASE UPPER(@condition)
						WHEN UPPER('Like') THEN ' LIKE ''%' + @from + '%'''
						WHEN UPPER('Not Like') THEN ' NOT LIKE ''%' + @from + '%'''
						WHEN UPPER('Between') THEN ' BETWEEN ''' + @from + ''' AND ''' + @to + ''''
						WHEN UPPER('Starts With') THEN ' LIKE ''' + @from + '%'''
						WHEN UPPER('Ends With') THEN ' LIKE ''%' + @from + '%'''
						WHEN UPPER('Equal To') THEN ' = ''' + @from + ''''
						WHEN UPPER('Not Equal To') THEN ' != ''' + @from + ''''
						WHEN UPPER('Greater Than') THEN ' > ''' + @from + ''''
						WHEN UPPER('In') THEN ' IN (''' + @from + ''')' END
				WHEN 'Decimal' 
						THEN 
							CASE UPPER(@condition)
							WHEN UPPER('BETWEEN') THEN ' BETWEEN ' + @from + ' AND ' + @to
							WHEN UPPER('Equal To') THEN ' = ' + @from
							WHEN UPPER('Not Equal To') THEN ' != ' + @from
							WHEN UPPER('Greater Than') THEN ' > ' + @from
							WHEN UPPER('Greater Than Or Equal') THEN ' >= ' + @from
							WHEN UPPER('Less Than') THEN ' < ' + @from
							WHEN UPPER('Less Than Or Equal') THEN ' <= ' + @from END
				WHEN 'Integer'
						THEN 
							CASE UPPER(@condition)
							WHEN UPPER('BETWEEN') THEN ' BETWEEN ' + @from + ' AND ' + @to
							WHEN UPPER('Equal To') THEN ' = ' + @from
							WHEN UPPER('Not Equal To') THEN ' != ' + @from
							WHEN UPPER('Greater Than') THEN ' > ' + @from
							WHEN UPPER('Greater Than Or Equal') THEN ' >= ' + @from
							WHEN UPPER('Less Than') THEN ' < ' + @from
							WHEN UPPER('Less Than Or Equal') THEN ' <= ' + @from END
				WHEN 'Bool'
					THEN ' = ' + (CASE WHEN @from = 1 THEN 'TRUE' ELSE 'FALSE' END)
				WHEN 'Boolean'
					THEN ' = ' + (CASE WHEN @from = 1 THEN 'TRUE' ELSE 'FALSE' END)
				END

	RETURN @filter
END

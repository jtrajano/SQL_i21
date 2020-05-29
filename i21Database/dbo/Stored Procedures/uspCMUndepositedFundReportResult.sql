CREATE PROCEDURE uspCMUndepositedFundReportResult
(
    @sqlMain NVARCHAR(MAX),
    @strFrom NVARCHAR(50),
    @strTo NVARCHAR(50),
    @strField NVARCHAR(50),
    @strCondition NVARCHAR(20),
    @strResult NVARCHAR(MAX) OUTPUT
   
)
AS
    
	


    IF( @strCondition = 'Not Equal To')
	BEGIN
        SELECT @strResult = @sqlMain + @strField + ' <> ''' + @strFrom + ''''
	END
	
	IF( @strCondition = 'Between')
	BEGIN
        SELECT @strResult = @sqlMain + @strField + ' BETWEEN ''' + @strFrom + '''  AND ''' + @strTo  + ''''
	END
	IF( @strCondition = 'Like')
	BEGIN
        SELECT @strResult = @sqlMain + @strField + ' LIKE ''%' + @strFrom + '%'''
	END

	IF( @strCondition = 'Not Like')
	BEGIN
		SELECT @strResult = @sqlMain + @strField + ' NOT LIKE ''%' + @strFrom + '%'''
	END
	IF( @strCondition = 'Starts With')
	BEGIN
		SELECT @strResult = @sqlMain + @strField + ' LIKE ''' + @strFrom + '%'''
	END
	IF( @strCondition = 'Ends With')
	BEGIN
		SELECT @strResult = @sqlMain + @strField + ' LIKE ''%' + @strFrom + ''''
	END








    

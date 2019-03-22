CREATE PROCEDURE [dbo].[uspCRMGetPipelineForecast]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @queryResult CURSOR
	DECLARE @strSalesPerson nvarchar(100);
	DECLARE @strLineOfBusinessColumn nvarchar(100);
	DECLARE @dblTotalNetOpportunityAmount numeric(18,6);
	
	DECLARE @strLineOfBusiness nvarchar(max);
	DECLARE @strLineOfBusinessColumnField nvarchar(max);
	DECLARE @strLineOfBusinessColumnFieldWithValue nvarchar(max);

	SELECT
		@strLineOfBusiness = COALESCE(@strLineOfBusiness + ', ', '') + strFieldName
		,@strLineOfBusinessColumnField = COALESCE(@strLineOfBusinessColumnField + ', ', '') + strFieldNameColumn
		,@strLineOfBusinessColumnFieldWithValue = COALESCE(@strLineOfBusinessColumnFieldWithValue + ', ', '') + strFieldNameColumnWithValue
	FROM
		(
			select distinct
				b.strLineOfBusiness
				,strFieldName = 'str' + replace(b.strLineOfBusiness, ' ', '') + ' numeric(18,6) null'
				,strFieldNameColumn = 'str' + replace(b.strLineOfBusiness, ' ', '')
				,strFieldNameColumnWithValue = 'str' + replace(b.strLineOfBusiness, ' ', '') + ' = null'
			from
				tblICCategory a
				,(
					select
						intLineOfBusinessId
						,strLineOfBusiness = replace(REPLACE(strLineOfBusiness, '&', 'And'), '-', '')
						,intEntityId
						,strSICCode
						,ysnVisibleOnWeb
						,intSegmentCodeId
						,strType
						,intConcurrencyId
					from
						tblSMLineOfBusiness
				) b
			where
				b.intLineOfBusinessId = a.intLineOfBusinessId
			union all
			select
				strLineOfBusiness = 'Undefined LOB'
				,strFieldName = 'strUndefinedLOB numeric(18,6) null'
				,strFieldNameColumn = 'strUndefinedLOB'
				,strFieldNameColumnWithValue = 'strUndefinedLOB = null'
		) as result
--		(select distinct b.strLineOfBusiness, strFieldName = 'str' + replace(b.strLineOfBusiness, ' ', '') + ' numeric(18,6) null', strFieldNameColumn = 'str' + replace(b.strLineOfBusiness, ' ', ''), strFieldNameColumnWithValue = 'str' + replace(b.strLineOfBusiness, ' ', '') + ' = null' from tblICCategory a, tblSMLineOfBusiness b where b.intLineOfBusinessId = a.intLineOfBusinessId union all select strLineOfBusiness = 'Undefined LOB', strFieldName = 'strUndefinedLOB numeric(18,6) null', strFieldNameColumn = 'strUndefinedLOB', strFieldNameColumnWithValue = 'strUndefinedLOB = null') as result

	exec('IF OBJECT_ID(''tempdb..##tmpCRMPipelineForecast'') IS NOT NULL DROP TABLE ##tmpCRMPipelineForecast create table ##tmpCRMPipelineForecast (strSalesperson nvarchar(100) COLLATE Latin1_General_CI_AS null,' + @strLineOfBusiness + ')');
	
	SET @queryResult = CURSOR FOR
	select strSalesPerson, strLineOfBusinessColumn, dblTotalNetOpportunityAmount from vyuCRMOpportunitySearchSummary1

	OPEN @queryResult
	FETCH NEXT
	FROM @queryResult INTO @strSalesPerson, @strLineOfBusinessColumn, @dblTotalNetOpportunityAmount
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if exists(select * from ##tmpCRMPipelineForecast where strSalesperson = @strSalesPerson)
		begin
			exec('update ##tmpCRMPipelineForecast set '+@strLineOfBusinessColumn+' = '+@dblTotalNetOpportunityAmount+' where strSalesperson = '''+@strSalesPerson+'''');
		end
		else
		begin
			exec('insert into ##tmpCRMPipelineForecast (strSalesperson,'+@strLineOfBusinessColumnField+') select strSalesperson = ''' + @strSalesPerson + ''', ' + @strLineOfBusinessColumnFieldWithValue + '');
			exec('update ##tmpCRMPipelineForecast set '+@strLineOfBusinessColumn+' = '+@dblTotalNetOpportunityAmount+' where strSalesperson = '''+@strSalesPerson+'''');
		end
				
		FETCH NEXT
		FROM @queryResult INTO @strSalesPerson, @strLineOfBusinessColumn, @dblTotalNetOpportunityAmount
	END

	CLOSE @queryResult
	DEALLOCATE @queryResult

	select * from ##tmpCRMPipelineForecast

END
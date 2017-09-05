CREATE VIEW [dbo].[vyuCRMOpportunitySalesrepFromLob]
	AS
		select
			intId = convert(int,ROW_NUMBER() over (order by intEntityId))
			,intEntityId
			,strEntityName
			,intSalespersonId
			,strSalespersonName
		from (
			select
				distinct intEntityId
				,strEntityName
				,intSalespersonId
				,strSalespersonName
			from
				vyuCRMOpportunitySalesrepAndLob
			) as result

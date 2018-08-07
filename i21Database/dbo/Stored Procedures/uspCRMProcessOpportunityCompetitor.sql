CREATE PROCEDURE [dbo].[uspCRMProcessOpportunityCompetitor]
	@intOpportunityId int = 0
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	BEGIN TRANSACTION
	BEGIN TRY
		delete from tblCRMOpportunityCompetitor where intOpportunityId = (case when @intOpportunityId > 0 then @intOpportunityId else intOpportunityId end);
	   COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
	  ROLLBACK TRANSACTION;
	END CATCH

	DECLARE @queryResultOpportunityCompetitor CURSOR;
	declare @intOpportunityCompetitorId int;
	declare @strCompetitorEntityId nvarchar(50);
	declare @strCurrentSolutionId nvarchar(50);

	declare @queryResultCompetitorItem cursor;
	declare @queryResultCurrentSolutionItem cursor;
	declare @ItemCompetitor nvarchar(50);
	declare @ItemCurrentSolution nvarchar(50);
	declare @intItemCompetitor int;
	declare @intItemCurrentSolution int;
	declare @returnStatus nvarchar(50) = 'success';

	begin transaction;
	begin try
	
		SET @queryResultOpportunityCompetitor = CURSOR FOR

			select
				intOpportunityId
				,strCompetitorEntityId = ltrim(rtrim(strCompetitorEntityId))
				,strCurrentSolutionId = ltrim(rtrim(strCurrentSolutionId))
			from
				tblCRMOpportunity
			where
				intOpportunityId = (case when @intOpportunityId > 0 then @intOpportunityId else intOpportunityId end)

				--strCompetitorEntityId is not null
				--and ltrim(rtrim(strCompetitorEntityId)) <> ''
				--and intOpportunityId = (case when @intOpportunityId > 0 then @intOpportunityId else intOpportunityId end)

		OPEN @queryResultOpportunityCompetitor
		FETCH NEXT
		FROM
			@queryResultOpportunityCompetitor
		INTO
			@intOpportunityCompetitorId
			,@strCompetitorEntityId
			,@strCurrentSolutionId

		WHILE @@FETCH_STATUS = 0
		BEGIN

			/*---------------------------------------------------------------*/
			SET @queryResultCompetitorItem = CURSOR FOR

				select
					Item
				from
					dbo.fnSplitString(@strCompetitorEntityId, ',')

			OPEN @queryResultCompetitorItem
			FETCH NEXT
			FROM
				@queryResultCompetitorItem
			INTO
				@ItemCompetitor

			WHILE @@FETCH_STATUS = 0
			BEGIN

		
				begin try
					set @intItemCompetitor = convert(int, @ItemCompetitor);
				end try
				begin catch
					set @intItemCompetitor = 0;
				end catch

				if (@intItemCompetitor <> 0)
				begin
					IF NOT EXISTS (select * from tblCRMOpportunityCompetitor where intOpportunityId = @intOpportunityCompetitorId and intEntityId = @intItemCompetitor and strReferenceType = 'Competitor')
					begin
						IF EXISTS (select * from tblEMEntity where intEntityId = @intItemCompetitor)
						begin
							INSERT INTO [dbo].[tblCRMOpportunityCompetitor]
									   ([intOpportunityId]
									   ,[intEntityId]
									   ,[strReferenceType]
									   ,[intConcurrencyId])
								 VALUES
									   (@intOpportunityCompetitorId
									   ,@intItemCompetitor
									   ,'Competitor'
									   ,1)
						end
					end
				end

				FETCH NEXT
				FROM
					@queryResultCompetitorItem
				INTO
					@ItemCompetitor
			END

			CLOSE @queryResultCompetitorItem
			DEALLOCATE @queryResultCompetitorItem
			/*---------------------------------------------------------------*/

			/*---------------------------------------------------------------*/
			SET @queryResultCurrentSolutionItem = CURSOR FOR

				select
					Item
				from
					dbo.fnSplitString(@strCurrentSolutionId, ',')

			OPEN @queryResultCurrentSolutionItem
			FETCH NEXT
			FROM
				@queryResultCurrentSolutionItem
			INTO
				@ItemCurrentSolution

			WHILE @@FETCH_STATUS = 0
			BEGIN

		
				begin try
					set @intItemCurrentSolution = convert(int, @ItemCurrentSolution);
				end try
				begin catch
					set @intItemCurrentSolution = 0;
				end catch

				if (@intItemCurrentSolution <> 0)
				begin
					IF NOT EXISTS (select * from tblCRMOpportunityCompetitor where intOpportunityId = @intOpportunityCompetitorId and intEntityId = @intItemCurrentSolution and strReferenceType = 'Solution')
					begin
						IF EXISTS (select * from tblEMEntity where intEntityId = @intItemCurrentSolution)
						begin
							INSERT INTO [dbo].[tblCRMOpportunityCompetitor]
									   ([intOpportunityId]
									   ,[intEntityId]
									   ,[strReferenceType]
									   ,[intConcurrencyId])
								 VALUES
									   (@intOpportunityCompetitorId
									   ,@intItemCurrentSolution
									   ,'Solution'
									   ,1)
						end
					end
				end

				FETCH NEXT
				FROM
					@queryResultCurrentSolutionItem
				INTO
					@ItemCurrentSolution
			END

			CLOSE @queryResultCurrentSolutionItem
			DEALLOCATE @queryResultCurrentSolutionItem
			/*---------------------------------------------------------------*/

			FETCH NEXT
			FROM
				@queryResultOpportunityCompetitor
			INTO
			@intOpportunityCompetitorId
			,@strCompetitorEntityId
			,@strCurrentSolutionId
		END

		CLOSE @queryResultOpportunityCompetitor
		DEALLOCATE @queryResultOpportunityCompetitor
		COMMIT TRANSACTION;
	end try
	begin catch
		set @returnStatus = 'failed';
		ROLLBACK TRANSACTION;
	end catch	

	select strStatus = @returnStatus;

END

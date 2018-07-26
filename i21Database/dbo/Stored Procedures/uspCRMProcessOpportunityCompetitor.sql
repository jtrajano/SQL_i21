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

	declare @queryResultCompetitorItem cursor;
	declare @ItemCompetitor nvarchar(50);
	declare @intItemCompetitor int;
	declare @returnStatus nvarchar(50) = 'success';

	begin transaction;
	begin try
	
		SET @queryResultOpportunityCompetitor = CURSOR FOR

			select
				intOpportunityId
				,strCompetitorEntityId = ltrim(rtrim(strCompetitorEntityId))
			from
				tblCRMOpportunity
			where
				strCompetitorEntityId is not null
				and ltrim(rtrim(strCompetitorEntityId)) <> ''
				and intOpportunityId = (case when @intOpportunityId > 0 then @intOpportunityId else intOpportunityId end)

		OPEN @queryResultOpportunityCompetitor
		FETCH NEXT
		FROM
			@queryResultOpportunityCompetitor
		INTO
			@intOpportunityCompetitorId
			,@strCompetitorEntityId

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

			FETCH NEXT
			FROM
				@queryResultOpportunityCompetitor
			INTO
			@intOpportunityCompetitorId
			,@strCompetitorEntityId
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

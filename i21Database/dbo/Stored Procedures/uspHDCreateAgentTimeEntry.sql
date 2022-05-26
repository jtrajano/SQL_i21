CREATE PROCEDURE [dbo].[uspHDCreateAgentTimeEntry]
(
	   @EntityId INT = null
	  ,@TimeEntryPeriodDetailId INT = null
)
AS
BEGIN

	IF @EntityId IS NULL OR @TimeEntryPeriodDetailId IS NULL
		RETURN

		
	IF NOT EXISTS (
			SELECT TOP 1 ''
			FROM tblHDTimeEntry
			WHERE intEntityId = @EntityId AND
				  intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId
	
	)
	BEGIN
			INSERT INTO tblHDTimeEntry
			(
				 [intEntityId]
				,[intTimeEntryPeriodDetailId]
			)
			SELECT  [intEntityId]				= @EntityId
					,[intTimeEntryPeriodDetailId]	= @TimeEntryPeriodDetailId
	END

END
GO
CREATE PROCEDURE [dbo].[uspHDCreateAgentTimeEntry]
(
	   @EntityId INT = null
	  ,@TimeEntryPeriodDetailId INT = null
	  ,@ResetSelectedDate nvarchar(50) = null
)
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET ANSI_WARNINGS OFF

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
	ELSE IF ISNULL(@ResetSelectedDate, '') <> ''
	BEGIN
		UPDATE tblHDTimeEntry
		SET strSelectedDate = NULL
		WHERE intEntityId = @EntityId AND
			  intTimeEntryPeriodDetailId = @TimeEntryPeriodDetailId

	END

END
GO
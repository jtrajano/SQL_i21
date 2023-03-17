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

	DECLARE @intEntityId INT 
		  ,@intTimeEntryPeriodDetailId INT 
		  ,@strResetSelectedDate nvarchar(50) 

    SET     @intEntityId				= @EntityId
	SET		@intTimeEntryPeriodDetailId =  @TimeEntryPeriodDetailId
	SET	    @strResetSelectedDate	    = @ResetSelectedDate

	IF @intEntityId IS NULL OR @intTimeEntryPeriodDetailId IS NULL
		RETURN

		
	IF NOT EXISTS (
			SELECT TOP 1 ''
			FROM tblHDTimeEntry
			WHERE intEntityId = @intEntityId AND
				  intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetailId
	
	)
	BEGIN
			INSERT INTO tblHDTimeEntry
			(
				 [intEntityId]
				,[intTimeEntryPeriodDetailId]
			)
			SELECT  [intEntityId]				= @intEntityId
					,[intTimeEntryPeriodDetailId]	= @intTimeEntryPeriodDetailId
	END
	ELSE IF ISNULL(@strResetSelectedDate, '') <> ''
	BEGIN
		UPDATE tblHDTimeEntry
		SET strSelectedDate = NULL
		WHERE intEntityId = @intEntityId AND
			  intTimeEntryPeriodDetailId = @intTimeEntryPeriodDetailId

	END

END
GO
CREATE PROCEDURE [dbo].[uspARGetDueDateBasedOnTerm]
	@dtmDate	DATETIME,
	@intTermId	INT,
	@dtmDueDate	DATETIME = NULL OUTPUT
AS

SET @dtmDueDate = dbo.[fnGetDueDateBasedOnTerm](@dtmDate, @intTermId)

SELECT @dtmDueDate = ISNULL(@dtmDueDate, GETDATE())
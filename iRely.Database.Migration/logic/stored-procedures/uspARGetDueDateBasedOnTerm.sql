--liquibase formatted sql

-- changeset Von:uspAGCalculateWOTotal.1 runOnChange:true splitStatements:false
-- comment: AP-1234

CREATE OR ALTER PROCEDURE [dbo].[uspARGetDueDateBasedOnTerm]
	@dtmDate	DATETIME,
	@intTermId	INT,
	@dtmDueDate	DATETIME = NULL OUTPUT
AS
BEGIN

SET @dtmDueDate = dbo.[fnGetDueDateBasedOnTerm](@dtmDate, @intTermId)

SELECT @dtmDueDate = ISNULL(@dtmDueDate, GETDATE())




END
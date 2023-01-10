CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactionsByAccountId]
	@intEntityId INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_NULLS ON;
	SET NOCOUNT ON;

	DELETE [dbo].[tblGLAuditorTransactionsByAccountId] WHERE intGeneratedBy = @intEntityId;

end
CREATE PROCEDURE [dbo].[uspGLGenerateAuditorTransactions]
	@intEntityId INT,
	@intType INT = 0
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_NULLS ON;
	SET NOCOUNT ON;

	DELETE [dbo].[tblGLAuditorTransaction] WHERE intGeneratedBy = @intEntityId AND intType = @intEntityId;

END
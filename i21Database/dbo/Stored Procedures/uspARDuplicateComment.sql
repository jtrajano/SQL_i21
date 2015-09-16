﻿CREATE PROCEDURE [dbo].[uspARDuplicateComment]
	 @intCommentId		INT		
	,@NewCommentId		INT = NULL OUTPUT
AS
	INSERT INTO tblARCommentMaintenance
		([intCompanyLocationId]
		,[intEntityCustomerId]
		,[strCommentDesc]
		,[strCommentTitle]
		,[strTransactionType]
		,[strType])
	SELECT 
		 [intCompanyLocationId]
		,[intEntityCustomerId]
		,[strCommentDesc]
		,[strCommentTitle]
		,[strTransactionType]
		,[strType]
	FROM tblARCommentMaintenance
		WHERE intCommentId = @intCommentId

	SET @NewCommentId = SCOPE_IDENTITY()

RETURN 
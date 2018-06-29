CREATE PROCEDURE uspGLSyncTemplateToStructure
	
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE A 
	SET A.strCode =
	CASE WHEN LEN(A.strCode) < B.intLength THEN A.strCode + REPLICATE(B.strMask,B.intLength - LEN(A.strCode)) 
	     WHEN LEN(A.strCode) > B.intLength 	 THEN LEFT(A.strCode,B.intLength)ELSE A.strCode END
	FROM tblGLCOATemplateDetail A INNER JOIN tblGLAccountStructure B ON A.intAccountStructureId = B.intAccountStructureId
	
	EXEC dbo.uspGLGenerateAccountRange
	
END


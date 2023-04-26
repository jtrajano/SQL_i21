CREATE FUNCTION [dbo].[fnAPFormatBillGLDescription]
(
	@intBillDetailId INT,
	@intFormat INT,
	@intOverrideAccount INT = NULL
)
RETURNS NVARCHAR(255) AS
BEGIN
	DECLARE @description NVARCHAR(255) = ''
	DECLARE @intAccountId INT 
	SELECT @intAccountId = ISNULL(@intOverrideAccount, intAccountId) FROM tblAPBillDetail WHERE intBillDetailId = @intBillDetailId

	IF @intFormat IS NULL OR @intFormat = 0 OR @intFormat = 1
	BEGIN
		SELECT TOP 1 @description = LTRIM(RTRIM(A.strDescription)) + 
								' - Item: ' + LTRIM(RTRIM(I.strItemNo)) + 
								', Qty: ' + dbo.fnFormatNumber(CAST(BD.dblQtyReceived AS NVARCHAR(55))) + 
								', Cost: ' + dbo.fnFormatNumber(CAST(ISNULL(BD.dblOldCost, BD.dblCost) AS NVARCHAR(55)))
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = @intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END

	IF @intFormat = 2
	BEGIN
		SELECT TOP 1 @description = LTRIM(RTRIM(A.strDescription)) + 
								', ' + LTRIM(RTRIM(I.strItemNo))
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = @intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END

	IF @intFormat = 3
	BEGIN
		SELECT TOP 1 @description = LTRIM(RTRIM(A.strDescription)) + 
									', Charges from ' + LTRIM(RTRIM(I.strItemNo))
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = @intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END
	
	RETURN @description
END
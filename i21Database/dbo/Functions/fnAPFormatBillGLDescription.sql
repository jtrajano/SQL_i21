CREATE FUNCTION [dbo].[fnAPFormatBillGLDescription]
(
	@intBillDetailId INT,
	@intFormat INT
)
RETURNS NVARCHAR(255) AS
BEGIN
	DECLARE @description NVARCHAR(255) = ''

	IF @intFormat IS NULL OR @intFormat = 0 OR @intFormat = 1
	BEGIN
		SELECT TOP 1 @description = TRIM(A.strDescription) + 
								' - Item: ' + TRIM(I.strItemNo) + 
								', Qty: ' + dbo.fnFormatNumber(CAST(BD.dblQtyReceived AS NVARCHAR(55))) + 
								', Cost: ' + dbo.fnFormatNumber(CAST(ISNULL(BD.dblOldCost, BD.dblCost) AS NVARCHAR(55)))
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = BD.intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END

	IF @intFormat = 2
	BEGIN
		SELECT TOP 1 @description = TRIM(A.strDescription) + 
								', ' + TRIM(I.strItemNo)
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = BD.intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END

	IF @intFormat = 3
	BEGIN
		SELECT TOP 1 @description = TRIM(A.strDescription) + 
									', Charges from ' + TRIM(I.strItemNo)
		FROM tblAPBillDetail BD
		INNER JOIN tblGLAccount A ON A.intAccountId = BD.intAccountId
		INNER JOIN tblICItem I ON I.intItemId = BD.intItemId
		WHERE BD.intBillDetailId = @intBillDetailId
	END
	
	RETURN @description
END
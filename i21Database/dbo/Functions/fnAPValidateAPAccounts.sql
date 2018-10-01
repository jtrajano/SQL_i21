CREATE FUNCTION [dbo].[fnAPValidateAPAccounts]
(
	@intBillId		INT
)
RETURNS @returntable TABLE
(
	[intAccountId]              INT              NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
	DECLARE @SCREEN_NAME NVARCHAR(25) = 'Payable'

	INSERT INTO @returntable
	SELECT A.intBillId, 
		   A.strMiscDescription + ' is missing GL Account for AP Clearing Account Category' 
	FROM tblAPBillDetail A 
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
		LEFT JOIN tblICItemLocation loc ON loc.intLocationId = B.intShipToId AND loc.intItemId = A.intItemId
		WHERE  [dbo].[fnGetItemGLAccount](A.intItemId, loc.intItemLocationId, 'AP Clearing') IS NULL 
		AND B.intBillId = @intBillId AND A.intAccountId IS NULL
		
	RETURN
END
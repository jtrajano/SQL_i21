﻿CREATE FUNCTION [dbo].[fnGetItemBaseGLAccount]
(
	@intItemId INT 
	,@intLocationId INT
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	--Hierarchy:
	--1. Item-location is checked first. 
	--2. If account id is not found in item-location, try the category 
	--3. If account id is not found in category, try the company location. 

	-- 1: Try to get the account id from the item (G/L Setup tab)
	SELECT	@intGLAccountId = intAccountId
	FROM	tblICItemAccount
	WHERE	tblICItemAccount.intItemId = @intItemId
			AND tblICItemAccount.intLocationId = @intLocationId
			AND tblICItemAccount.strAccountDescription = @strAccountDescription 

	IF @intGLAccountId IS NOT NULL 
		RETURN @intGLAccountId

	-- 2: Try to get the account id from the category (G/L Setup tab)
	SELECT	@intGLAccountId = CatGLAccounts.intAccountId
	FROM	tblICItem Item INNER JOIN tblICCategory Cat
				ON Item.intTrackingId = Cat.intCategoryId
			INNER JOIN tblICCategoryAccount CatGLAccounts
				ON Cat.intCategoryId = CatGLAccounts.intCategoryId
	WHERE	Item.intItemId = @intItemId
			AND CatGLAccounts.intLocationId = @intLocationId
			AND CatGLAccounts.strAccountDescription = @strAccountDescription 

	IF @intGLAccountId IS NOT NULL 
		RETURN @intGLAccountId
	
	-- 3: Try to get the account id from the Company Location (G/L Setup tab)
	SELECT	@intGLAccountId = intAccountId
	FROM	tblSMCompanyLocationAccount
	WHERE	intCompanyLocationId = @intLocationId
			AND tblSMCompanyLocationAccount.strAccountDescription = @strAccountDescription 
	
	RETURN @intGLAccountId 
END
GO
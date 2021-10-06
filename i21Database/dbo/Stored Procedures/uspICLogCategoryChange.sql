CREATE PROCEDURE [dbo].[uspICLogCategoryChange]
	@intItemId AS INT
	,@intCategoryId AS INT 
	,@intEntitySecurityUserId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

INSERT INTO tblICItemCategoryChangeLog (
	[intItemId]
	,[intOriginalCategoryId]
	,[intNewCategoryId]
	,[dtmDateChanged]
	,[intCreatedByUserId]
)
SELECT 
	[intItemId]
	,[intOriginalCategoryId] = i.intCategoryId
	,[intNewCategoryId] = @intCategoryId
	,[dtmDateChanged] = GETDATE() 
	,[intCreatedByUserId] = @intEntitySecurityUserId
FROM 
	tblICItem i 
WHERE
	i.intItemId = @intItemId
	AND ISNULL(i.intCategoryId, 0) <> ISNULL(@intCategoryId, 0)
	
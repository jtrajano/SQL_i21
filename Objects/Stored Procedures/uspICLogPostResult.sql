CREATE PROCEDURE [dbo].[uspICLogPostResult]
	@strMessage AS NVARCHAR(4000) = NULL 
	,@intErrorId AS INT = NULL 
	,@strTransactionType AS NVARCHAR(50) = NULL 
	,@strTransactionId AS NVARCHAR(50) = NULL 
	,@intTransactionId AS INT = NULL 
	,@strBatchNumber AS NVARCHAR(50) = NULL 
	,@intItemId AS INT = NULL 
	,@intItemLocationId AS INT = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

INSERT INTO tblICPostResult (
    [strMessage] 
	,[intErrorId]
    ,[strTransactionType] 
    ,[strTransactionId] 
    ,[strBatchNumber] 
    ,[intTransactionId] 
	,[intItemId] 
	,[intItemLocationId] 
)
SELECT 
	@strMessage 
	,@intErrorId
	,@strTransactionType 
	,@strTransactionId 
	,@strBatchNumber 
	,@intTransactionId 	
	,@intItemId 
	,@intItemLocationId 

GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPPostOriginPayment')
	DROP PROCEDURE uspAPPostOriginPayment
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		CREATE PROCEDURE [dbo].[uspAPPostOriginPayment]
			@batchId			AS NVARCHAR(20)		= NULL,
			@transactionType	AS NVARCHAR(30)		= NULL,
			@post				AS BIT				= 0,
			@recap				AS BIT				= 0,
			@param				AS NVARCHAR(MAX)	= NULL,
			@userId				AS INT				= 1,
			@beginDate			AS DATE				= NULL,
			@endDate			AS DATE				= NULL,
			@beginTransaction	AS NVARCHAR(50)		= NULL,
			@endTransaction		AS NVARCHAR(50)		= NULL,
			@successfulCount	AS INT				= 0 OUTPUT,
			@invalidCount		AS INT				= 0 OUTPUT,
			@success			AS BIT				= 0 OUTPUT,
			@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT,
			@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
		AS
		BEGIN

				DECLARE @successful BIT,
				@successCount INT,
				@invalid INT,
				@usedBatchId NVARCHAR(20),
				@idRecap NVARCHAR(250);

				CREATE TABLE #tmpPayments(intPaymentId INT)

				INSERT INTO #tmpPayments
				EXEC uspAPPostPayment @post=@post,
					@recap=@recap,
					@param=@param,
					@transactionType=@transactionType,
					@beginDate=@beginDate,
					@endDate=@endDate,
					@beginTransaction=@beginTransaction,
					@endTransaction=@endTransaction,
					@userId=@userId,
					@batchId=@batchId,
					@success=@successful OUTPUT,
					@successfulCount=@successCount OUTPUT,
					@invalidCount=@invalid OUTPUT,
					@batchIdUsed=@usedBatchId OUTPUT,
					@recapId=@idRecap OUTPUT
	
				SET @successfulCount = @successCount;
				SET @invalidCount = @invalid;
				SET @batchIdUsed = @usedBatchId;
				SET @recapId = @idRecap;
				SET @success = @successful;

		END')
END

CREATE PROCEDURE [testi21Database].[test the uspCMAddDeposit stored procedure]
AS
BEGIN
	-- Prepare the fake table 
	EXEC tSQLt.FakeTable 'dbo.tblCMBankTransaction';

	DECLARE @p1 AS INT
			,@p2 AS DATETIME
			,@p3 AS INT
			,@p4 AS NUMERIC(18,6)
			,@p5 AS NVARCHAR(255)
			,@p6 AS INT 
			,@p7 AS BIT;

	SET @p1 = 19
	SET @p2 = '02/28/2012'
	SET @p3 = 1099
	SET @p4 = 496.88
	SET @p5 = 'this is the description'
	SET @p6 = 4546
	SET @p7 = 0

	-- Act
	EXEC dbo.uspCMAddDeposit 
		@intBankAccountId = @p1, 
		@dtmDate = @p2, 
		@intGLAccountId = @p3, 
		@dblAmount = @p4, 
		@strDescription = @p5, 
		@intUserId = @p6, 
		@isAddSuccessful = @p7 OUTPUT

	-- Assert
	SELECT intBankAccountId, dtmDate, dblAmount, strMemo, intCreatedUserId
	INTO actual 
	FROM dbo.tblCMBankTransaction

	CREATE TABLE expected (
		[intBankAccountId]         INT              NOT NULL,
		[dtmDate]                  DATETIME         NOT NULL,
		[dblAmount]                DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
		[strMemo]                  NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
		[intCreatedUserId]         INT              NULL
	)

	INSERT INTO expected (intBankAccountId, dtmDate, dblAmount, strMemo, intCreatedUserId) SELECT 19, '02/28/2012', 496.88, 'this is the description', 4546
	 
	EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
END 
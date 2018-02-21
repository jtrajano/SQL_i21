CREATE FUNCTION [dbo].[fnARGetMonthlyAccrual]
(
	  @intInvoiceId			INT
	, @dtmAsOfDate			DATETIME
)
RETURNS @tblMonthlyAccrual TABLE
(
	  intInvoiceId				INT				NOT NULL
	, strMonthAccrued			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL
	, dblRunningAccrualBalance	NUMERIC(18, 6)	NOT NULL DEFAULT 0
)
AS
BEGIN
	DECLARE @intPeriodsAccrue			INT
		  , @intCounter					INT	= 1
		  , @dtmPostDate				DATETIME
		  , @dblInvoiceTotal			NUMERIC(18, 6)	= 0
		  , @dblRunningAccrualBalance	NUMERIC(18, 6)	= 0		  

	SELECT TOP 1 @intPeriodsAccrue			= intPeriodsToAccrue
			   , @dtmPostDate				= dtmPostDate
			   , @dblInvoiceTotal			= dblInvoiceTotal
			   , @dblRunningAccrualBalance	= dblInvoiceTotal
	FROM dbo.tblARInvoice WITH (NOLOCK)
	WHERE intInvoiceId = @intInvoiceId

	WHILE (@intCounter <= @intPeriodsAccrue + 1)
		BEGIN
			IF (@dtmPostDate >= @dtmAsOfDate)
				BEGIN
					INSERT @tblMonthlyAccrual
					SELECT @intInvoiceId, CONVERT(CHAR(4), @dtmPostDate, 100) + CONVERT(CHAR(4), @dtmPostDate, 120), @dblRunningAccrualBalance
				END

			SET @intCounter = @intCounter + 1
			SET @dtmPostDate = DATEADD(MONTH, 1, @dtmPostDate)
			SET @dblRunningAccrualBalance = dbo.fnRoundBanker(@dblRunningAccrualBalance - (@dblInvoiceTotal / @intPeriodsAccrue), 2)
		END

	RETURN
END

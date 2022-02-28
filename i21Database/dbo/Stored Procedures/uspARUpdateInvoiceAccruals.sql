CREATE PROCEDURE [dbo].[uspARUpdateInvoiceAccruals] 
	 @intInvoiceId	INT = NULL
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

IF(OBJECT_ID('tempdb..#ACCRUALS') IS NOT NULL) DROP TABLE #ACCRUALS

CREATE TABLE #ACCRUALS (
	  intInvoiceId			INT NOT NULL PRIMARY KEY
	, intPeriodsToAccrue	INT NOT NULL DEFAULT 1
	, dblInvoiceSubtotal 	NUMERIC(18,6) NULL DEFAULT 0
	, dblDifference			NUMERIC(18,6) NULL DEFAULT 0
)

IF @intInvoiceId IS NOT NULL
	BEGIN
		INSERT INTO #ACCRUALS (
			  intInvoiceId
			, intPeriodsToAccrue
			, dblInvoiceSubtotal
			, dblDifference
		)
		SELECT intInvoiceId			= I.intInvoiceId
			, intPeriodsToAccrue	= I.intPeriodsToAccrue
			, dblInvoiceSubtotal	= I.dblInvoiceSubtotal
			, dblDifference			= ISNULL(ACC.dblTotalAmount, 0) - I.dblInvoiceSubtotal
		FROM tblARInvoice I
		LEFT JOIN (
			SELECT intInvoiceId		= A.intInvoiceId
				 , dblTotalAmount	= SUM(A.dblAmount)
			FROM tblARInvoiceAccrual A
			GROUP BY A.intInvoiceId
		) ACC ON I.intInvoiceId = ACC.intInvoiceId
		WHERE I.intInvoiceId = @intInvoiceId
		  AND I.intPeriodsToAccrue > 1
	END
ELSE IF (OBJECT_ID('tempdb..##ARPostInvoiceHeader') IS NOT NULL)
	BEGIN
		INSERT INTO #ACCRUALS (
			  intInvoiceId
			, intPeriodsToAccrue
			, dblInvoiceSubtotal
			, dblDifference
		)
		SELECT intInvoiceId			= I.intInvoiceId
			, intPeriodsToAccrue	= I.intPeriodsToAccrue
			, dblInvoiceSubtotal	= I.dblInvoiceSubtotal
			, dblDifference			= ISNULL(ACC.dblTotalAmount, 0) - I.dblInvoiceSubtotal
		FROM tblARInvoice I
		INNER JOIN ##ARPostInvoiceHeader II ON I.intInvoiceId = II.intInvoiceId
		LEFT JOIN (
			SELECT intInvoiceId		= A.intInvoiceId
				 , dblTotalAmount	= SUM(A.dblAmount)
			FROM tblARInvoiceAccrual A
			GROUP BY A.intInvoiceId
		) ACC ON I.intInvoiceId = ACC.intInvoiceId
		WHERE I.intPeriodsToAccrue > 1
	END
	
IF EXISTS (SELECT TOP 1 NULL FROM #ACCRUALS WHERE dblDifference <> 0)
BEGIN
	DELETE IA
	FROM tblARInvoiceAccrual IA
	INNER JOIN #ACCRUALS A ON IA.intInvoiceId = A.intInvoiceId
	WHERE A.dblDifference <> 0
	
	INSERT INTO tblARInvoiceAccrual WITH (TABLOCK) (
		  intInvoiceId
		, intInvoiceDetailId
		, dtmAccrualDate
		, dblAmount
		, intConcurrencyId
	)
	SELECT intInvoiceId			= ID.intInvoiceId
		 , intInvoiceDetailId	= ID.intInvoiceDetailId
		 , dtmAccrualDate		= dtmAccrualMonth
		 , dblAmount			= CAST(ID.dblTotal/ACC.intPeriodsToAccrue AS NUMERIC(16,2))
		 , intConcurrencyId		= 1 
	FROM tblARInvoiceDetail ID 
	INNER JOIN #ACCRUALS ACC ON ID.intInvoiceId = ACC.intInvoiceId
	CROSS APPLY(
		SELECT TOP (intPeriodsToAccrue) DATEADD(m, ROW_NUMBER() OVER(ORDER BY Id),DATEADD(MONTH, -1, dtmPostDate)) dtmAccrualMonth	
		FROM sysobjects
		OUTER APPLY tblARInvoice
		WHERE intInvoiceId = @intInvoiceId
	) AccrualDate
	WHERE ID.intInvoiceId = @intInvoiceId 
	  AND ID.dblTotal <> 0
	  AND dblDifference <> 0
	ORDER BY dtmAccrualMonth

	UPDATE ACC
	SET dblDifference = ACC.dblInvoiceSubtotal - ACC2.dblTotalAmount
	FROM #ACCRUALS ACC
	INNER JOIN (
		SELECT intInvoiceId		= A.intInvoiceId
			 , dblTotalAmount	= SUM(A.dblAmount)
		FROM tblARInvoiceAccrual A
		GROUP BY A.intInvoiceId
	) ACC2 ON ACC.intInvoiceId = ACC2.intInvoiceId

	--FIX DECIMAL DISCREPANCY
	IF EXISTS (SELECT TOP 1 NULL FROM #ACCRUALS WHERE dblDifference <> 0)
	BEGIN
		UPDATE IA
		SET dblAmount = CASE WHEN ACC.dblDifference > 0 THEN dblAmount + ACC.dblDifference ELSE dblAmount - ACC.dblDifference END
		FROM tblARInvoiceAccrual IA
		INNER JOIN #ACCRUALS ACC ON IA.intInvoiceId = ACC.intInvoiceId
		INNER JOIN (
			SELECT intInvoiceId		= AVG(intInvoiceId)				 
				 , dtmAccrualDate	= MAX(dtmAccrualDate)
			FROM tblARInvoiceAccrual
			GROUP BY intInvoiceId
		) SORTED ON IA.intInvoiceId = SORTED.intInvoiceId AND IA.dtmAccrualDate = SORTED.dtmAccrualDate		
		WHERE ACC.dblDifference <> 0
	END

END
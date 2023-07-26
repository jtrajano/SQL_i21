CREATE FUNCTION [dbo].[fnRKIsDerivativeLocked]
(
	  @intFutOptTransactionId INT = NULL
	, @strScreen NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnLocked BIT = 0

	SELECT @ysnLocked = CAST(ISNULL(
					(	SELECT TOP 1 
							ysnLocked = CASE WHEN  ISNULL(a.intFutOptTransactionId, 0) <> 0
												OR ISNULL(b.intFutOptTransactionId, 0) <> 0
												OR ISNULL(c.intFutOptTransactionId, 0) <> 0
												OR ISNULL(d.intFutOptTransactionId, 0) <> 0
												OR ISNULL(e.intFutOptTransactionId, 0) <> 0
												OR ISNULL(f.intFutOptTransactionId, 0) <> 0
										THEN 1 ELSE 0 END
						FROM tblRKFutOptTransaction der
						OUTER APPLY 
							(
								SELECT TOP 1 intFutOptTransactionId = t.intLFutOptTransactionId 
								FROM tblRKMatchFuturesPSDetail t
								WHERE t.intLFutOptTransactionId = der.intFutOptTransactionId
						) a
						OUTER APPLY 
							(
								SELECT TOP 1 intFutOptTransactionId = t.intSFutOptTransactionId 
								FROM tblRKMatchFuturesPSDetail t
								WHERE t.intSFutOptTransactionId = der.intFutOptTransactionId
						) b
						OUTER APPLY 
							(
								SELECT TOP 1 intFutOptTransactionId = t.intLFutOptTransactionId 
								FROM tblRKOptionsMatchPnS t
								WHERE t.intLFutOptTransactionId = der.intFutOptTransactionId
						) c
						OUTER APPLY 
							(
								SELECT TOP 1 intFutOptTransactionId = t.intSFutOptTransactionId 
								FROM tblRKOptionsMatchPnS t
								WHERE t.intSFutOptTransactionId = der.intFutOptTransactionId
						) d
						OUTER APPLY 
							(
								SELECT TOP 1 t.intFutOptTransactionId 
								FROM tblRKAssignFuturesToContractSummary t
								WHERE ((ISNULL(dblAssignedLots,0) <> 0 OR ISNULL(dblHedgedLots,0) <>  0))	
								AND t.intFutOptTransactionId = der.intFutOptTransactionId
								AND @strScreen <> 'Assign Derivatives'
							 
								UNION
								SELECT TOP 1 t.intFutOptTransactionId 
								FROM tblRKAssignFuturesToContractSummary t
								WHERE ((ISNULL(dblAssignedLotsToSContract,0) <> 0 OR ISNULL(dblAssignedLotsToPContract,0) <>  0))	
								AND t.intFutOptTransactionId = der.intFutOptTransactionId
								AND @strScreen <> 'Assign Derivatives'
						) e
						OUTER APPLY 
							(
								SELECT TOP 1 t.intFutOptTransactionId 
								FROM tblCTPriceFixationDetail t
								WHERE t.intFutOptTransactionId = der.intFutOptTransactionId
						) f
						WHERE der.intFutOptTransactionId = @intFutOptTransactionId
					)
				, 0) AS BIT) 
RETURN @ysnLocked
END
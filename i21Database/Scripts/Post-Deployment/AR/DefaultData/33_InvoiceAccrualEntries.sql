print('/*******************  BEGIN Adding Entries for tblARInvoiceAccrual  *******************/')
GO

SELECT DISTINCT intInvoiceId, DATEADD(MONTH, Nbr - 1, dtmDate),CONVERT(NUMERIC(18,6), dblInvoiceTotal / intPeriodsToAccrue), 1
FROM    
tblARInvoice AR
LEFT JOIN ( SELECT    ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
          FROM      sys.columns c
        ) nbrs
ON 1 =1 
WHERE   Nbr - 1 <= DATEDIFF(MONTH, dtmDate,  DATEADD(MONTH,CASE WHEN intPeriodsToAccrue = 1 THEN 0 ELSE intPeriodsToAccrue - 1 END ,dtmDate)) AND intPeriodsToAccrue > 0 and intInvoiceId NOT IN(SELECT intInvoiceId FROM tblARInvoiceAccrual)
ORDER BY intInvoiceId

GO
print('/*******************  END Adding Entries for tblARInvoiceAccrual  *******************/')
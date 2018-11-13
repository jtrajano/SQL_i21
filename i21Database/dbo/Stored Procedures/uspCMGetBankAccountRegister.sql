CREATE PROCEDURE [dbo].[uspCMGetBankAccountRegister] @intBankAccountId INT, 
                                                    @strUniqueId     NVARCHAR(10) 
AS 
    DECLARE @openingBalance             AS NUMERIC(18, 6), 
            @runningOpeningBalance      AS NUMERIC(18, 6) = 0, 
            @runningEndingBalance       AS NUMERIC(18, 6) = 0, 
            @intTransactionId           AS INT, 
            @strTransactionId           AS NVARCHAR(50), 
            @dblPayment                 AS NUMERIC(18, 6), 
            @dblDeposit                 AS NUMERIC(18, 6), 
            @dblBalance                 AS NUMERIC(18, 6), 
            @dtmDate                    AS DATETIME, 
            @dtmDateReconciled          AS DATETIME, 
            @ysnCheckVoid               AS BIT, 
            @ysnClr                     AS BIT, 
            @intCompanyLocationId       AS INT, 
            @strLocationName            AS NVARCHAR(100), 
            @intBankTransactionTypeId   AS INT, 
            @strBankTransactionTypeName AS NVARCHAR(100), 
            @strReferenceNo             AS NVARCHAR(50), 
            @strMemo                    AS NVARCHAR(250), 
            @strPayee                   AS NVARCHAR(100), 
            @ysnMaskEmployeeName        AS BIT, 
            @RowNum                     BIGINT = 0 

    SELECT TOP 1 @openingBalance = dblStatementOpeningBalance 
    FROM   tblCMBankReconciliation 
    WHERE  intBankAccountId = @intBankAccountId 

    SELECT TOP 1 @ysnMaskEmployeeName = ysnMaskEmployeeName 
    FROM   tblPRCompanyPreference 

    DECLARE @dtmDateEntered DATETIME = Getdate() 

    
	DELETE FROM [tblCMBankAccountRegisterRunningBalance] 
    WHERE  dtmDateEntered < Dateadd(MINUTE, -5, @dtmDateEntered);
	


    WITH CM 
         AS (SELECT intTransactionId, 
                    strTransactionId, 
                    A.intCompanyLocationId, 
                    ISNULL(Company.strLocationName, '') strLocationName,
                    A.intBankTransactionTypeId, 
                    ISNULL(BankType.strBankTransactionTypeName,'') strBankTransactionTypeName,
                    ISNULL(strReferenceNo, '') AS strReferenceNo, 
                    CASE 
                      WHEN strMemo = '' AND ysnCheckVoid = 1 THEN 'Void' 
                      ELSE ISNULL(strMemo, '') 
                    END                        AS strMemo, 
                    CASE 
                      WHEN @ysnMaskEmployeeName = 1 AND A.intBankTransactionTypeId IN ( 21, 23 ) THEN '(restricted information)' 
                      ELSE ISNULL(strPayee, '') 
					END                        AS strPayee, 
                    Cast(dtmDate AS DATE)      AS dtmDate, 
                    dtmDateReconciled, 
                    CASE 
                      WHEN A.intBankTransactionTypeId IN ( 3, 9, 12, 13, 14, 15, 16, 20, 21, 22, 23 ) THEN 
						dblAmount 
                      WHEN A.intBankTransactionTypeId IN ( 2, 5 ) AND ISNULL(dblAmount,0) < 0 THEN dblAmount * -1 
                      ELSE 0 
                    END                        AS dblPayment, 
                    CASE 
                      WHEN A.intBankTransactionTypeId IN ( 1, 10, 11, 18, 19, 103, 116, 121, 122, 123 ) THEN dblAmount 
                      WHEN A.intBankTransactionTypeId = 5 AND ISNULL(dblAmount,0) > 0 THEN dblAmount 
                      ELSE 0 
                    END                        AS dblDeposit, 
                    ysnCheckVoid, 
                    ysnClr 
             FROM   tblCMBankTransaction A 
			 LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = A.intCompanyLocationId
			 LEFT JOIN tblCMBankTransactionType BankType ON BankType.intBankTransactionTypeId = A.intBankTransactionTypeId
             WHERE  intBankAccountId = @intBankAccountId 
                    AND  ((ysnPosted = 1))
					
					
					  ), 
         CTEORDER 
         AS (SELECT ROW_NUMBER() 
                      OVER( 
                        ORDER BY dtmDate, intTransactionId) rowId, 
                    * ,
					(dblDeposit - dblPayment ) + ISNULL( @openingBalance, 0) lineBalance
             FROM   CM), 
         CTERESULT 
         AS (SELECT @intBankAccountId 
                    intBankAccountId, 
                    balance.dblEndingBalance - a.lineBalance dblOpeningBalance, 
                    balance.dblEndingBalance, 
                    a.*, 
                    @strUniqueId 
                    [strUniqueId] 
             FROM   CTEORDER a 
                    OUTER APPLY(SELECT ( Sum(dblDeposit - dblPayment) + ISNULL( @openingBalance, 0) ) dblEndingBalance 
                                FROM   CTEORDER b WHERE  a.rowId >= b.rowId) balance) 
    INSERT INTO -- 
    [tblCMBankAccountRegisterRunningBalance] 
    ([intTransactionId], 
     [strTransactionId], 
     [intCompanyLocationId], 
     [strLocationName], 
     [intBankTransactionTypeId], 
     [strBankTransactionTypeName], 
     [strReferenceNo], 
     [strMemo], 
     [strPayee], 
     [dtmDate], 
     [dtmDateReconciled], 
     [ysnCheckVoid], 
     [strUniqueId], 
     dblPayment, 
     dblDeposit, 
     [dblEndingBalance], 
     [dblOpeningBalance], 
     dtmDateEntered,
	 rowId
	 ) 
    SELECT [intTransactionId], 
           [strTransactionId], 
           [intCompanyLocationId], 
           [strLocationName], 
           [intBankTransactionTypeId], 
           [strBankTransactionTypeName], 
           [strReferenceNo], 
           [strMemo], 
           [strPayee], 
           [dtmDate], 
           [dtmDateReconciled], 
           [ysnCheckVoid], 
           [strUniqueId], 
           dblPayment, 
           dblDeposit, 
           [dblEndingBalance], 
           [dblOpeningBalance], 
           @dtmDateEntered,
		   rowId
    FROM   CTERESULT 

GO 


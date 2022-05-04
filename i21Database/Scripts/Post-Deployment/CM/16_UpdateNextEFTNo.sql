GO
;WITH eftTable as(
SELECT intBankAccountId, (intEFTNoId+1) Id FROM tblCMEFTNumbers
UNION 
SELECT intBankAccountId, CASE WHEN ISNULL(intEFTNextNo,0) = 0 THEN 1 ELSE intEFTNextNo END  Id FROM tblCMBankAccount
),
MaxTable AS (
    select intBankAccountId, Max(Id) Id FROM eftTable GROUP BY intBankAccountId
)
UPDATE A set intEFTNextNo = B.Id
FROM
tblCMBankAccount A JOIN MaxTable B on A.intBankAccountId =  B.intBankAccountId
GO
CREATE PROCEDURE uspAPCompareBalance
(
    @asOfDate DATETIME = NULL,
    --@emailProfileName NVARCHAR(200) = NULL,
    --@recipients NVARCHAR(MAX) = NULL,
    --@emailSubject NVARCHAR(500) = NULL,
    @htmlResult NVARCHAR(MAX) OUTPUT
)
AS
BEGIN

    DECLARE 
	@companyName AS NVARCHAR(MAX) 
 	,@resultAsHTML AS NVARCHAR(MAX) = '';
    --DECLARE @subject NVARCHAR(500) = ISNULL(@emailSubject, 'AP Balance Compare');

     SELECT TOP 1 @companyName = ISNULL(strCompanyName, '') FROM tblSMCompanySetup

    IF OBJECT_ID(N'tempdb..#tmpAPClearingBalanceCompare') IS NOT NULL DROP TABLE #tmpAPClearingBalanceCompare
    CREATE TABLE #tmpAPClearingBalanceCompare(dblReportBalance DECIMAL(18,6), dblGLBalance DECIMAL(18,6), dblDifference DECIMAL(18,6))

    -- INSERT INTO #tmpAPClearingBalanceCompare
    EXEC uspAPClearingReportVSGLSummary

    INSERT INTO #tmpAPClearingBalanceCompare
    SELECT
    A.dblBalance AS dblReportBalance,
    B.dblBalance AS dblGLBalance,
    A.dblBalance + B.dblBalance AS dblDifference
    FROM tmpAPClearingBalance A
    CROSS APPLY tmpAPClearingGLBalance B

    --SELECT * FROM #tmpAPClearingBalanceCompare

    IF OBJECT_ID(N'tempdb..#tmpAPClearingGLBalanceCompare') IS NOT NULL DROP TABLE #tmpAPClearingGLBalanceCompare
    CREATE TABLE #tmpAPClearingGLBalanceCompare(dblReportBalance DECIMAL(18,6), dblGLBalance DECIMAL(18,6), dblDifference DECIMAL(18,6))

    -- INSERT INTO #tmpAPClearingGLBalanceCompare
    EXEC uspAPAccountReportVSGLSummary

    INSERT INTO #tmpAPClearingGLBalanceCompare
    SELECT 
        A.dblBalance AS dblReportBalance,
        B.dblBalance AS dblGLBalance,
        A.dblBalance - B.dblBalance AS dblDifference
    FROM tmpAPAccountBalance A
    CROSS APPLY tmpAPGLAccountBalance B

    --SELECT * FROM #tmpAPClearingGLBalanceCompare

    --IF @emailProfileName IS NOT NULL AND @recipients IS NOT NULL
    --BEGIN

        IF EXISTS(SELECT 1 FROM #tmpAPClearingBalanceCompare WHERE dblDifference > 1 OR dblDifference < -1)
        BEGIN
            SET @resultAsHTML += 
				N'<h1>AP Clearing vs GL Result for ' + @companyName +'</h1>'+
				N'<table border="1">' + 
				N'<tr><th align=''right''>Report Balance</th><th align=''right''>GL Balance</th><th align=''right''>Difference</th></tr>' 

            SET @resultAsHTML += 
                        N'<tr>' + 
                        N'<td align=''right''>'+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblReportBalance) AS NVARCHAR) FROM #tmpAPClearingBalanceCompare) +'</td>' + 
                        N'<td align=''right''>'+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblGLBalance) AS NVARCHAR) FROM #tmpAPClearingBalanceCompare) +'</td>' + 
                        N'<td align=''right''> '+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblDifference) AS NVARCHAR) FROM #tmpAPClearingBalanceCompare) +'</td>' + 
                        N'</tr>'

            SET @resultAsHTML += N'</table>'; 
        END

        IF EXISTS(SELECT 1 FROM #tmpAPClearingGLBalanceCompare WHERE dblDifference > 1 OR dblDifference < -1)
        BEGIN
            SET @resultAsHTML += 
				N'<h1>AP Account vs GL Result for ' + @companyName +'</h1>'+
				N'<table border="1">' + 
				N'<tr><th align=''right''>Report Balance</th><th align=''right''>GL Balance</th><th align=''right''>Difference</th></tr>' 

            SET @resultAsHTML += 
                        N'<tr>' + 
                        N'<td align=''right''>'+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblReportBalance) AS NVARCHAR) FROM #tmpAPClearingGLBalanceCompare) +'</td>' + 
                        N'<td align=''right''>'+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblGLBalance) AS NVARCHAR) FROM #tmpAPClearingGLBalanceCompare) +'</td>' + 
                        N'<td align=''right''> '+ (SELECT CAST(CONVERT(DECIMAL(18,2), dblDifference) AS NVARCHAR) FROM #tmpAPClearingGLBalanceCompare) +'</td>' + 
                        N'</tr>'

            SET @resultAsHTML += N'</table>'; 
        END

        SET @htmlResult = @resultAsHTML;
        -- IF @resultAsHTML != ''
        -- BEGIN
        --     -- Send the email 
        --     EXEC msdb.dbo.sp_send_dbmail
        --         @profile_name = @emailProfileName
        --         ,@recipients = @recipients
        --         ,@subject = @subject
        --         ,@body = @resultAsHTML
        --         ,@body_format = 'HTML'			

        --     PRINT 'Email Sent to Queue.'
        -- END
    --END

END